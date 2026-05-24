import '../database/db_connection.dart';
import '../models/usuario_model.dart';

class UsuarioDao {
  Future<void> registrar(
    String email,
    String clave,
    String numIdentificacion,
    String rol,
  ) async {
    final connection = await DbConnection.getConnection();
    await connection.execute(
      '''
      INSERT INTO usuarios (email, clave, numIdentificacion, rol)
      VALUES (:email, :clave, :numIdentificacion, :rol)
      ''',
      {
        'email': email,
        'clave': clave,
        'numIdentificacion': numIdentificacion,
        'rol': rol,
      },
    );
  }

  Future<UsuarioModel?> login(
    String numIdentificacion,
    String clave,
  ) async {
    final conn = await DbConnection.getConnection();
    final result = await conn.execute(
      '''
      SELECT * FROM usuarios
      WHERE numIdentificacion = :numIdentificacion
      AND clave = :clave
      LIMIT 1
      ''',
      {'numIdentificacion': numIdentificacion, 'clave': clave},
    );
    if (result.rows.isEmpty) return null;
    return UsuarioModel.fromMap(result.rows.first.assoc());
  }

  Future<List<UsuarioModel>> obtenerTodos() async {
    final conn = await DbConnection.getConnection();
    final result = await conn.execute(
      'SELECT id, email, numIdentificacion, rol FROM usuarios ORDER BY id DESC',
    );
    return result.rows
        .map((row) => UsuarioModel.fromMap(row.assoc()))
        .toList();
  }

  Future<void> eliminar(int id) async {
    final conn = await DbConnection.getConnection();
    await conn.execute(
      'DELETE FROM usuarios WHERE id = :id',
      {'id': id},
    );
  }

  Future<void> actualizar({
    required int id,
    required String email,
    required String numIdentificacion,
    required String rol,
    String? nuevaClave,
  }) async {
    final conn = await DbConnection.getConnection();

    if (nuevaClave != null && nuevaClave.isNotEmpty) {
      await conn.execute(
        '''
        UPDATE usuarios
        SET email = :email,
            numIdentificacion = :numIdentificacion,
            rol = :rol,
            clave = :clave
        WHERE id = :id
        ''',
        {
          'email': email,
          'numIdentificacion': numIdentificacion,
          'rol': rol,
          'clave': nuevaClave,
          'id': id,
        },
      );
    } else {
      await conn.execute(
        '''
        UPDATE usuarios
        SET email = :email,
            numIdentificacion = :numIdentificacion,
            rol = :rol
        WHERE id = :id
        ''',
        {
          'email': email,
          'numIdentificacion': numIdentificacion,
          'rol': rol,
          'id': id,
        },
      );
    }
  }
}