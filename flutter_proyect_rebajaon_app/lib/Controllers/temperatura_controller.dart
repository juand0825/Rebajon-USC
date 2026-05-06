import '../DAO/temperatura_dao.dart';
import '../models/temperatura_model.dart';

class TemperaturaController {
  final TemperaturaDao temperaturaDao = TemperaturaDao();

  Future<void> guardarTemperatura({
    required int idMedicamento,
    required double temperatura,
    required double rangoMin,
    required double rangoMax,
  }) async {
    final fueraDeRango = temperatura < rangoMin || temperatura > rangoMax;

    final nuevoRegistro = TemperaturaModel(
      idMedicamento: idMedicamento,
      temperatura: temperatura,
      rangoMin: rangoMin,
      rangoMax: rangoMax,
      fueraDeRango: fueraDeRango,
    );

    await temperaturaDao.insertarTemperatura(nuevoRegistro);
  }
}