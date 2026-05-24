import 'package:flutter/material.dart';
import '../DAO/usuario_dao.dart';
import '../models/usuario_model.dart';

class AuthController extends ChangeNotifier {
  bool cargando = false;
  String? error;
  bool registrado = false;

  int? idUsuarioActual;
  String? rolActual;
  String? emailActual;

  List<UsuarioModel> usuarios = [];
  bool cargandoUsuarios = false;

  final UsuarioDao _dao;

  AuthController({UsuarioDao? usuarioDao}) : _dao = usuarioDao ?? UsuarioDao();

  Future<void> register(
    String email,
    String clave,
    String numIdentificacion,
    String rol,
  ) async {
    if (email.isEmpty || clave.isEmpty || numIdentificacion.isEmpty) {
      error = "Todos los campos son obligatorios";
      notifyListeners();
      return;
    }

    if (numIdentificacion.length != 10) {
      error = "El número de identificación debe tener 10 dígitos";
      notifyListeners();
      return;
    }

    cargando = true;
    error = null;
    registrado = false;
    notifyListeners();

    try {
      await _dao.registrar(email, clave, numIdentificacion, rol);
      registrado = true;
      await cargarUsuarios();
    } catch (e) {
      error = "Error al registrar: $e";
    }

    cargando = false;
    notifyListeners();
  }

  Future<void> cargarUsuarios() async {
    cargandoUsuarios = true;
    notifyListeners();

    try {
      usuarios = await _dao.obtenerTodos();
    } catch (e) {
      error = "Error al cargar usuarios: $e";
    }

    cargandoUsuarios = false;
    notifyListeners();
  }

  Future<bool> eliminarUsuario(int id) async {
    try {
      await _dao.eliminar(id);
      await cargarUsuarios();
      return true;
    } catch (e) {
      error = "Error al eliminar: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarUsuario({
    required int id,
    required String email,
    required String numIdentificacion,
    required String rol,
    String? nuevaClave,
  }) async {
    if (email.isEmpty || numIdentificacion.isEmpty || rol.isEmpty) {
      error = "Todos los campos son obligatorios";
      notifyListeners();
      return false;
    }

    if (numIdentificacion.length != 10) {
      error = "El número de identificación debe tener 10 dígitos";
      notifyListeners();
      return false;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      await _dao.actualizar(
        id: id,
        email: email,
        numIdentificacion: numIdentificacion,
        rol: rol,
        nuevaClave: nuevaClave,
      );

      await cargarUsuarios();

      cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = "Error al actualizar: $e";
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String numIdentificacion, String clave) async {
    if (numIdentificacion.isEmpty || clave.isEmpty) {
      error = "Por favor completa todos los campos";
      notifyListeners();
      return false;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final usuario = await _dao.login(numIdentificacion, clave);

      if (usuario != null) {
        idUsuarioActual = usuario.id;
        rolActual = usuario.rol;
        emailActual = usuario.email;

        cargando = false;
        notifyListeners();
        return true;
      } else {
        error = "Documento o contraseña incorrectos";
        cargando = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      error = "Error de conexión";
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  void resetRegistrado() {
    registrado = false;
    notifyListeners();
  }

  void cerrarSesion() {
    idUsuarioActual = null;
    rolActual = null;
    emailActual = null;
    usuarios = [];
    error = null;
    registrado = false;
    notifyListeners();
  }
}
