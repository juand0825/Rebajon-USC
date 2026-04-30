// Este archivo le dice a FLUTTER como organizar los datos del usuario
class UsuarioModel {
  final int id;
  final String email;
  final String rol;
  final String numIdentificacion;

  UsuarioModel({
    required this.id,
    required this.email,
    required this.rol,
    required this.numIdentificacion,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel (
      id: int.parse(map['id'].toString()),
      email: map['email'],
      rol: map['rol'],
      numIdentificacion: map['numIdentificacion']
    );
  }
}
