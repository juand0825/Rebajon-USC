import '../database/db_connection.dart';
import '../models/ventas_model.dart';

class CarritoDao {
  Future<int> crearCarrito(int idUsuario) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      INSERT INTO carrito (id_usuario, estado)
      VALUES (:id_usuario, 'abierto')
      ''',
      {'id_usuario': idUsuario},
    );

    final result = await conn.execute('SELECT LAST_INSERT_ID() AS id');
    return int.parse(result.rows.first.assoc()['id'].toString());
  }

  Future<void> guardarDetalleCarrito({
    required int idCarrito,
    required List<VentaItemModel> items,
  }) async {
    final conn = await DbConnection.getConnection();

    for (final item in items) {
      await conn.execute(
        '''
        INSERT INTO detalle_carrito
        (id_carrito, id_lote, cantidad)
        VALUES
        (:id_carrito, :id_lote, :cantidad)
        ''',
        {
          'id_carrito': idCarrito,
          'id_lote': item.idLote,
          'cantidad': item.cantidad,
        },
      );
    }
  }

  Future<void> confirmarCarrito(int idCarrito) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      UPDATE carrito
      SET estado = 'confirmado'
      WHERE id = :id_carrito
      ''',
      {'id_carrito': idCarrito},
    );
  }
}
