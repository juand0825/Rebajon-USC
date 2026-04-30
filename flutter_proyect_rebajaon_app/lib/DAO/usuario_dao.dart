import '../database/db_connection.dart';
import '../Models/usuario_model.dart';

class UsuarioDao {
  Future<void> registrar(String email, String clave, String numIdentificacion, String rol) async {
    final connection = await DbConnection.getConnection();
    await connection.execute(
      'INSERT INTO usuarios (email, clave, numIdentificacion, rol) VALUES (:email, :clave, :numIdentificacion, :rol)',
      {
        'email': email,
        'clave': clave,
        'numIdentificacion': numIdentificacion,
        'rol': rol
      }
    );
  }

  Future<UsuarioModel?> login(String email, String clave) async {
    final conn = await DbConnection.getConnection();
    final result = await conn.execute(
      "SELECT * FROM usuarios WHERE email = :email AND clave = :clave LIMIT 1",
      {"email": email, "clave": clave},
    );

    if (result.rows.isEmpty) return null;
    return UsuarioModel.fromMap(result.rows.first.assoc());
  }
}
