import 'package:flutter/material.dart';
import '../DAO/usuario_dao.dart';

class AuthController extends ChangeNotifier {
  bool cargando = false;
  String? error;
  bool registrado = false;

  int? idUsuarioActual;
  String? rolActual;
  String? emailActual;

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
    } catch (e) {
      error = "Error al registrar: $e";
    }

    cargando = false;
    notifyListeners();
  }

  Future<bool> login(String email, String clave) async {
    if (email.isEmpty || clave.isEmpty) {
      error = "Por favor completa todos los campos";
      notifyListeners();
      return false;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final usuario = await _dao.login(email, clave);

      if (usuario != null) {
        idUsuarioActual = usuario.id;
        rolActual = usuario.rol;
        emailActual = usuario.email;

        cargando = false;
        notifyListeners();
        return true;
      } else {
        error = "No estás registrado, por favor regístrate";
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
    notifyListeners();
  }
}
