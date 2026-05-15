import 'package:flutter_proyect_rebajaon_app/models/lote_model.dart';
import '../database/db_connection.dart';

class LoteDao {
  Future<void> insertarLote(LoteModel lote) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      INSERT INTO lotes
      (
        id_medicamento,
        numero_lote,
        fecha_fabricacion,
        fecha_vencimiento,
        cantidad_inicial,
        cantidad_disponible,
        codigo_barras
      )
      VALUES
      (
        :id_medicamento,
        :numero_lote,
        :fecha_fabricacion,
        :fecha_vencimiento,
        :cantidad_inicial,
        :cantidad_disponible,
        :codigo_barras
      )
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

    await actualizarStockMedicamento(lote.idMedicamento);
  }

  Future<void> actualizarStockMedicamento(int idMedicamento) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      UPDATE medicamentos
      SET stock_actual = (
        SELECT IFNULL(SUM(cantidad_disponible), 0)
        FROM lotes
        WHERE id_medicamento = :id_medicamento
      )
      WHERE id = :id_medicamento
      ''',
      {'id_medicamento': idMedicamento},
    );
  }

  Future<bool> descontarStockPorCantidad(
    String codigoBarras,
    int cantidad,
  ) async {
    final lote = await buscarPorCodigoBarras(codigoBarras);

    if (lote == null) return false;
    if (lote.cantidadDisponible < cantidad) return false;

    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      UPDATE lotes
      SET cantidad_disponible = cantidad_disponible - :cantidad
      WHERE codigo_barras = :codigo
        AND cantidad_disponible >= :cantidad
      ''',
      {'codigo': codigoBarras, 'cantidad': cantidad},
    );

    await actualizarStockMedicamento(lote.idMedicamento);

    return true;
  }

  Future<List<LoteModel>> listarLotesPorMedicamento(int idMedicamento) async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute(
      '''
      SELECT *
      FROM lotes
      WHERE id_medicamento = :id_medicamento
      ORDER BY fecha_vencimiento ASC
      ''',
      {'id_medicamento': idMedicamento},
    );

    return result.rows.map((row) => LoteModel.fromMap(row.assoc())).toList();
  }

  Future<List<LoteModel>> listarLotes() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('''
      SELECT *
      FROM lotes
      ORDER BY id DESC
      ''');

    return result.rows.map((row) => LoteModel.fromMap(row.assoc())).toList();
  }

  Future<LoteModel?> buscarPorCodigoBarras(String codigoBarras) async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('''
      SELECT *
      FROM lotes
      WHERE codigo_barras = :codigo_barras
      LIMIT 1
      ''',
      {'codigo_barras': codigoBarras},
    );

    if (result.rows.isEmpty) return null;

    return LoteModel.fromMap(result.rows.first.assoc());
  }

  Future<void> descontarStock(String codigoBarras) async {
    await descontarStockPorCantidad(codigoBarras, 1);
  }
}
