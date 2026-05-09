import '../database/db_connection.dart';
import '../models/scanner_model.dart';

class ScannerDao {

  Future<ScannerModel?> buscarPorCodigo(
      String codigoBarras) async {

    final conn = await DbConnection.getConnection();

    final result = await conn.execute(

      '''
      SELECT
        m.nombre,
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

      {
        'codigo': codigoBarras,
      },
    );

    if (result.rows.isEmpty) {
      return null;
    }

    return ScannerModel.fromMap(
      result.rows.first.assoc(),
    );
  }
}