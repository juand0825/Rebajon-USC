import '../database/db_connection.dart';
import '../models/temperatura_model.dart';

class TemperaturaDao {
  Future<void> insertarTemperatura(TemperaturaModel temperatura) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      INSERT INTO registro_temperatura
      (id_medicamento, temperatura, rango_min, rango_max)
      VALUES (:id_medicamento, :temperatura, :rango_min, :rango_max)
      ''',
      {
        'id_medicamento': temperatura.idMedicamento,
        'temperatura': temperatura.temperatura,
        'rango_min': temperatura.rangoMin,
        'rango_max': temperatura.rangoMax,
      },
    );
  }

  Future<List<TemperaturaModel>> listarTemperaturas() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('SELECT * FROM registro_temperatura');

    return result.rows
        .map((row) => TemperaturaModel.fromMap(row.assoc()))
        .toList();
  }
}
