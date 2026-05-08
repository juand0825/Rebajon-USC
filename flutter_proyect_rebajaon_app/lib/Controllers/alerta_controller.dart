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

  Future<void> generarAlertaVencimientoProximo({
    required int idMedicamento,
    required int idLote,
    required String nombreMedicamento,
    required DateTime fechaVencimiento,
  }) async {
    final hoy = DateTime.now();
    final diferencia = fechaVencimiento.difference(hoy).inDays;

    if (diferencia < 0 || diferencia > 30) return;

    final yaExiste = await alertaDao.existeAlertaActiva(
      idMedicamento: idMedicamento,
      tipo: 'VENCIMIENTO_PROXIMO',
    );

    if (yaExiste) return;

    final alerta = AlertaModel(
      idMedicamento: idMedicamento,
      idLote: idLote,
      tipo: 'VENCIMIENTO_PROXIMO',
      nivelGravedad: 'ADVERTENCIA',
      mensaje:
          'El lote del medicamento $nombreMedicamento está próximo a vencer.',
      resulta: false,
    );

    await alertaDao.insertarAlerta(alerta);
  }

  Future<void> generarAlertaMedicamentoVencido({
    required int idMedicamento,
    required int idLote,
    required String nombreMedicamento,
    required DateTime fechaVencimiento,
  }) async {
    final hoy = DateTime.now();

    if (!fechaVencimiento.isBefore(hoy)) return;

    final yaExiste = await alertaDao.existeAlertaActiva(
      idMedicamento: idMedicamento,
      tipo: 'MEDICAMENTO_VENCIDO',
    );

    if (yaExiste) return;

    final alerta = AlertaModel(
      idMedicamento: idMedicamento,
      idLote: idLote,
      tipo: 'MEDICAMENTO_VENCIDO',
      nivelGravedad: 'CRITICO',
      mensaje:
          'El lote del medicamento $nombreMedicamento se encuentra vencido.',
      resulta: false,
    );

    await alertaDao.insertarAlerta(alerta);
  }
}
