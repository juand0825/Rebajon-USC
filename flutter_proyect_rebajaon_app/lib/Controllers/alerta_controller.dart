import '../DAO/alerta_dao.dart';
import '../models/alerta_model.dart';

class AlertaController {
  final AlertaDao alertaDao = AlertaDao();

  Future<void> generarAlertaCadenaFrio({
    required int idMedicamento,
    required String nombreMedicamento,
    required double temperatura,
    required double rangoMin,
    required double rangoMax,
  }) async {
    final fueraDeRango = temperatura < rangoMin || temperatura > rangoMax;

    if (!fueraDeRango) return;

    final yaExiste = await alertaDao.existeAlertaActiva(
      idMedicamento: idMedicamento,
      tipo: 'CADENA_FRIO',
    );

    if (yaExiste) return;

    final alerta = AlertaModel(
      idMedicamento: idMedicamento,
      idLote: null,
      tipo: 'CADENA_FRIO',
      nivelGravedad: 'CRITICO',
      mensaje:
          'La temperatura del medicamento $nombreMedicamento está fuera del rango seguro.',
      resulta: false,
    );

    await alertaDao.insertarAlerta(alerta);
  }

  Future<void> generarAlertaStockMinimo({
    required int idMedicamento,
    required String nombreMedicamento,
    required int stockActual,
    required int stockMinimo,
  }) async {
    if (stockActual > stockMinimo) return;

    final yaExiste = await alertaDao.existeAlertaActiva(
      idMedicamento: idMedicamento,
      tipo: 'STOCK_MINIMO',
    );

    if (yaExiste) return;

    final alerta = AlertaModel(
      idMedicamento: idMedicamento,
      idLote: null,
      tipo: 'STOCK_MINIMO',
      nivelGravedad: 'ADVERTENCIA',
      mensaje: 'El medicamento $nombreMedicamento alcanzó el stock mínimo.',
      resulta: false,
    );

    await alertaDao.insertarAlerta(alerta);
  }
}
