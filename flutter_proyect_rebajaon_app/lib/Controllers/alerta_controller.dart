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
    final fueraRango = temperatura < rangoMin || temperatura > rangoMax;

    if (!fueraRango) return;

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
}