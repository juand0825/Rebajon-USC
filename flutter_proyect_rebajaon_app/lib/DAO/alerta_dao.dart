import '../database/db_connection.dart';
import '../models/alerta_model.dart';

class AlertaDao {
  Future<void> insertarAlerta(AlertaModel alerta) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      INSERT INTO alerta
      (id_medicamento, id_lote, tipo, nivel_gravedad, mensaje, resulta)
      VALUES (:id_medicamento, :id_lote, :tipo, :nivel_gravedad, :mensaje, :resulta)
      ''',
      {
        'id_medicamento': alerta.idMedicamento,
        'id_lote': alerta.idLote,
        'tipo': alerta.tipo,
        'nivel_gravedad': alerta.nivelGravedad,
        'mensaje': alerta.mensaje,
        'resulta': alerta.resulta ? 1 : 0,
      },
    );
  }

  Future<List<AlertaModel>> listarAlertas() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('SELECT * FROM alerta ORDER BY id DESC');

    return result.rows.map((row) => AlertaModel.fromMap(row.assoc())).toList();
  }

  Future<bool> existeAlertaActiva({
    required int idMedicamento,
    required String tipo,
  }) async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute(
      '''
    SELECT * FROM alerta
    WHERE id_medicamento = :id_medicamento
    AND tipo = :tipo
    AND resulta = 0
    LIMIT 1
    ''',
      {'id_medicamento': idMedicamento, 'tipo': tipo},
    );

    return result.rows.isNotEmpty;
  }

  Future<void> resolverAlertasActivas({
    required int idMedicamento,
    required String tipo,
  }) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
    UPDATE alerta
    SET resulta = 1,
        fecha_resolucion = NOW()
    WHERE id_medicamento = :id_medicamento
      AND tipo = :tipo
      AND resulta = 0
    ''',
      {'id_medicamento': idMedicamento, 'tipo': tipo},
    );
  }

  Future<void> actualizarAlertaActiva({
    required int idMedicamento,
    required String tipo,
    required String nivelGravedad,
    required String mensaje,
  }) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
    UPDATE alerta
    SET nivel_gravedad = :nivel_gravedad,
        mensaje = :mensaje
    WHERE id_medicamento = :id_medicamento
      AND tipo = :tipo
      AND resulta = 0
    ''',
      {
        'id_medicamento': idMedicamento,
        'tipo': tipo,
        'nivel_gravedad': nivelGravedad,
        'mensaje': mensaje,
      },
    );
  }
}
