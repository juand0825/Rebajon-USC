import '../database/db_connection.dart';
import '../models/scanner_model.dart';

class ScannerDao {
  Future<ScannerModel?> buscarPorCodigo(String codigoBarras) async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute(
      '''
      SELECT
        l.id AS id_lote,
        m.id AS id_medicamento,
        m.nombre,
        m.principio_activo,
        m.presentacion,
        m.fabricante,
        m.precio,
        m.stock_actual,
        m.stock_minimo,
        m.requiere_refrigeracion,
        m.activo,
        l.codigo_barras,
        l.numero_lote,
        l.cantidad_disponible,
        l.fecha_vencimiento
      FROM lotes l
      INNER JOIN medicamentos m
        ON m.id = l.id_medicamento
      WHERE l.codigo_barras = :codigo
      LIMIT 1
      ''',
      {'codigo': codigoBarras},
    );

    if (result.rows.isEmpty) {
      return null;
    }

    return ScannerModel.fromMap(result.rows.first.assoc());
  }

  Future<List<ScannerModel>> buscarPorNombre(String nombre) async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute(
      '''
      SELECT
        l.id AS id_lote,
        m.id AS id_medicamento,
        m.nombre,
        m.principio_activo,
        m.presentacion,
        m.fabricante,
        m.precio,
        m.stock_actual,
        m.stock_minimo,
        m.requiere_refrigeracion,
        m.activo,
        l.codigo_barras,
        l.numero_lote,
        l.cantidad_disponible,
        l.fecha_vencimiento
      FROM lotes l
      INNER JOIN medicamentos m
        ON m.id = l.id_medicamento
      WHERE m.nombre LIKE :nombre
        AND l.cantidad_disponible > 0
        AND m.activo = 1
      ORDER BY m.nombre ASC
      ''',
      {'nombre': '%$nombre%'},
    );

    return result.rows.map((row) => ScannerModel.fromMap(row.assoc())).toList();
  }

  Future<List<ScannerModel>> listarMedicamentosDisponibles() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('''
      SELECT
        l.id AS id_lote,
        m.id AS id_medicamento,
        m.nombre,
        m.principio_activo,
        m.presentacion,
        m.fabricante,
        m.precio,
        m.stock_actual,
        m.stock_minimo,
        m.requiere_refrigeracion,
        m.activo,
        l.codigo_barras,
        l.numero_lote,
        l.cantidad_disponible,
        l.fecha_vencimiento
      FROM lotes l
      INNER JOIN medicamentos m
        ON m.id = l.id_medicamento
      WHERE l.cantidad_disponible > 0
        AND m.activo = 1
      ORDER BY m.nombre ASC
      ''');

    return result.rows.map((row) => ScannerModel.fromMap(row.assoc())).toList();
  }
}
