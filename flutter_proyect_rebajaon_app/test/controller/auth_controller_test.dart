import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_proyect_rebajaon_app/Controllers/auth_controller.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/usuario_dao.dart';
import 'package:flutter_proyect_rebajaon_app/models/usuario_model.dart';

// Genera el mock automáticamente
@GenerateMocks([UsuarioDao])
import 'auth_controller_test.mocks.dart';

void main() {
  late AuthController controller;
  late MockUsuarioDao mockDao;

  setUp(() {
    mockDao = MockUsuarioDao();
    controller = AuthController(usuarioDao: mockDao);
  });

  // ─── LOGIN ───────────────────────────────────────────────
  group('login()', () {
    test(
      'retorna true y guarda datos cuando las credenciales son válidas',
      () async {
        final usuarioFalso = UsuarioModel(
          id: 8,
          email: 'trujillohoyos@gmail.com',
          rol: 'farmaceutico',
          numIdentificacion: '1111546372',
        );

        when(
          mockDao.login('1111546372', '78945'),
        ).thenAnswer((_) async => usuarioFalso);

        final resultado = await controller.login('1111546372', '78945');

        expect(resultado, isTrue);
        expect(controller.rolActual, equals('farmaceutico'));
        expect(controller.idUsuarioActual, equals(8));
        expect(controller.emailActual, equals('trujillohoyos@gmail.com'));
        expect(controller.error, isNull);
      },
    );

    test('retorna false y setea error cuando el usuario no existe', () async {
      when(mockDao.login('1111111111', '0000')).thenAnswer((_) async => null);

      final resultado = await controller.login('1111111111', '0000');

      expect(resultado, isFalse);
      expect(controller.error, equals('Documento o contraseña incorrectos'));
    });

    test(
      'retorna false y setea error cuando el documento está vacío',
      () async {
        final resultado = await controller.login('', '78945');

        expect(resultado, isFalse);
        expect(controller.error, equals('Por favor completa todos los campos'));
        verifyZeroInteractions(mockDao);
      },
    );

    test('retorna false y setea error cuando la clave está vacía', () async {
      final resultado = await controller.login('1111546372', '');

      expect(resultado, isFalse);
      expect(controller.error, equals('Por favor completa todos los campos'));
    });

    test(
      'retorna false y setea error de conexión cuando el DAO lanza excepción',
      () async {
        when(mockDao.login(any, any)).thenThrow(Exception('timeout'));

        final resultado = await controller.login('1111546372', '78945');

        expect(resultado, isFalse);
        expect(controller.error, equals('Error de conexión'));
      },
    );
  });

  // ─── REGISTER ────────────────────────────────────────────
  group('register()', () {
    test('registra correctamente con datos válidos', () async {
      when(mockDao.registrar(any, any, any, any)).thenAnswer((_) async {});
      when(mockDao.obtenerTodos()).thenAnswer((_) async => []);

      await controller.register(
        'nuevo@gmail.com',
        '12345',
        '1234567891',
        'farmaceutico',
      );

      expect(controller.registrado, isTrue);
      expect(controller.error, isNull);
    });

    test('no llama al DAO si el email está vacío', () async {
      await controller.register('', '12345', '1234567891', 'farmaceutico');

      expect(controller.error, equals('Todos los campos son obligatorios'));
      verifyZeroInteractions(mockDao);
    });

    test('no llama al DAO si numIdentificacion no tiene 10 dígitos', () async {
      await controller.register(
        'nuevo@gmail.com',
        '12345',
        '123',
        'farmaceutico',
      );

      expect(
        controller.error,
        equals('El número de identificación debe tener 10 dígitos'),
      );
      verifyZeroInteractions(mockDao);
    });

    test('setea error si el DAO lanza excepción al registrar', () async {
      when(
        mockDao.registrar(any, any, any, any),
      ).thenThrow(Exception('DB error'));

      await controller.register(
        'nuevo@gmail.com',
        '12345',
        '1234567891',
        'farmaceutico',
      );

      expect(controller.registrado, isFalse);
      expect(controller.error, contains('Error al registrar'));
    });
  });

  // ─── CERRAR SESIÓN ───────────────────────────────────────
  group('cerrarSesion()', () {
    test('limpia todos los datos del usuario', () async {
      final usuarioFalso = UsuarioModel(
        id: 8,
        email: 'trujillohoyos@gmail.com',
        rol: 'farmaceutico',
        numIdentificacion: '1111546372',
      );

      when(mockDao.login(any, any)).thenAnswer((_) async => usuarioFalso);

      await controller.login('1111546372', '78945');

      controller.cerrarSesion();

      expect(controller.idUsuarioActual, isNull);
      expect(controller.rolActual, isNull);
      expect(controller.emailActual, isNull);
    });
  });
}
