import 'package:flutter_proyect_rebajaon_app/models/lote_model.dart';

import '../database/db_connection.dart';


class LoteDao {
  Future<void> insertarLote(LoteModel lote) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      INSERT INTO lotes
      (id_medicamento, numero_lote, fecha_fabricacion, fecha_vencimiento, cantidad_inicial, cantidad_disponible, codigo_barras)
      VALUES (:id_medicamento, :numero_lote, :fecha_fabricacion, :fecha_vencimiento, :cantidad_inicial, :cantidad_disponible, :codigo_barras)
      ''',
      {
        'id_medicamento': lote.idMedicamento,
        'numero_lote': lote.numeroLote,
        'fecha_fabricacion': lote.fechaFabricacion,
        'fecha_vencimiento': lote.fechaVencimiento,
        'cantidad_inicial': lote.cantidadInicial,
        'cantidad_disponible': lote.cantidadDisponible,
        'codigo_barras': lote.codigoBarras,
      },
    );
  }

  Future<List<LoteModel>> listarLotesPorMedicamento(int idMedicamento) async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute(
      'SELECT * FROM lotes WHERE id_medicamento = :id_medicamento',
      {'id_medicamento': idMedicamento},
    );

    return result.rows
        .map((row) => LoteModel.fromMap(row.assoc()))
        .toList();
  }
}
