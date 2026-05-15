import '../database/db_connection.dart';
import '../models/ventas_model.dart';

class VentaDao {
  Future<int> registrarVenta({
    required double total,
    required List<VentaItemModel> items,
  }) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      INSERT INTO ventas (total, estado)
      VALUES (:total, 'completada')
      ''',
      {'total': total},
    );

    final result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
    final idVenta = int.parse(result.rows.first.assoc()['id'].toString());

    for (final item in items) {
      await conn.execute(
        '''
        INSERT INTO detalle_ventas
        (
          id_venta,
          id_lote,
          cantidad,
          precio_unitario,
          subtotal
        )
        VALUES
        (
          :id_venta,
          :id_lote,
          :cantidad,
          :precio_unitario,
          :subtotal
        )
        ''',
        {
          'id_venta': idVenta,
          'id_lote': item.idLote,
          'cantidad': item.cantidad,
          'precio_unitario': item.precio,
          'subtotal': item.subtotal,
        },
      );
    }

    return idVenta;
  }
}
