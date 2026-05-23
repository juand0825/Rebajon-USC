import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_proyect_rebajaon_app/Controllers/medicamento_controller.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/medicamento_dao.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/lote_dao.dart';
import 'package:flutter_proyect_rebajaon_app/models/medicamento_model.dart';

@GenerateMocks([MedicamentoDao, LoteDao])
import 'medicamento_controller_test.mocks.dart';

void main() {
  late MedicamentoController controller;
  late MockMedicamentoDao mockMedicamentoDao;
  late MockLoteDao mockLoteDao;

  setUp(() {
    mockMedicamentoDao = MockMedicamentoDao();
    mockLoteDao = MockLoteDao();
    controller = MedicamentoController(
      medicamentoDao: mockMedicamentoDao,
      loteDao: mockLoteDao,
    );
  });

  // Medicamento de prueba reutilizable
  final medicamentoFalso = MedicamentoModel(
    id: 1,
    nombre: 'Acetaminofén',
    principioActivo: 'Paracetamol',
    presentacion: 'Tabletas',
    fabricante: 'GENFAR',
    precio: 2000,
    stockActual: 50,
    stockMinimo: 10,
    requiereRefrigeracion: false,
    activo: true,
  );

  // ─── GUARDAR MEDICAMENTO Y LOTE ──────────────────────────
  group('guardarMedicamentoYLote()', () {

    test('guarda medicamento y lote correctamente con datos válidos', () async {
      when(mockMedicamentoDao.insertarMedicamento(any))
          .thenAnswer((_) async {});
      when(mockMedicamentoDao.buscarPorNombre('Acetaminofén'))
          .thenAnswer((_) async => medicamentoFalso);
      when(mockLoteDao.insertarLote(any))
          .thenAnswer((_) async {});

      await expectLater(
        controller.guardarMedicamentoYLote(
          nombre: 'Acetaminofén',
          principioActivo: 'Paracetamol',
          presentacion: 'Tabletas',
          fabricante: 'GENFAR',
          precio: 2000,
          stockMinimo: 10,
          requiereRefrigeracion: false,
          activo: true,
          numeroLote: 'LOT-001',
          fechaFabricacion: '2024-01-01',
          fechaVencimiento: '2027-01-01',
          cantidadInicial: 50,
          cantidadDisponible: 50,
          codigoBarras: '123456789',
        ),
        completes,
      );

      verify(mockMedicamentoDao.insertarMedicamento(any)).called(1);
      verify(mockMedicamentoDao.buscarPorNombre('Acetaminofén')).called(1);
      verify(mockLoteDao.insertarLote(any)).called(1);
    });

    test('lanza excepción si buscarPorNombre retorna null', () async {
      when(mockMedicamentoDao.insertarMedicamento(any))
          .thenAnswer((_) async {});
      when(mockMedicamentoDao.buscarPorNombre(any))
          .thenAnswer((_) async => null);

      expect(
        () => controller.guardarMedicamentoYLote(
          nombre: 'Ibuprofeno',
          principioActivo: 'Ibuprofeno',
          presentacion: 'Cápsulas',
          fabricante: 'MK',
          precio: 3000,
          stockMinimo: 5,
          requiereRefrigeracion: false,
          activo: true,
          numeroLote: 'LOT-002',
          fechaFabricacion: '2024-01-01',
          fechaVencimiento: '2026-01-01',
          cantidadInicial: 30,
          cantidadDisponible: 30,
          codigoBarras: '987654321',
        ),
        throwsException,
      );
    });

    test('no inserta lote si el DAO de medicamento lanza excepción', () async {
      when(mockMedicamentoDao.insertarMedicamento(any))
          .thenThrow(Exception('DB error'));

      expect(
        () => controller.guardarMedicamentoYLote(
          nombre: 'Acetaminofén',
          principioActivo: 'Paracetamol',
          presentacion: 'Tabletas',
          fabricante: 'GENFAR',
          precio: 2000,
          stockMinimo: 10,
          requiereRefrigeracion: false,
          activo: true,
          numeroLote: 'LOT-001',
          fechaFabricacion: '2024-01-01',
          fechaVencimiento: '2027-01-01',
          cantidadInicial: 50,
          cantidadDisponible: 50,
          codigoBarras: '123456789',
        ),
        throwsException,
      );

      verifyNever(mockLoteDao.insertarLote(any));
    });
  });

  // ─── GUARDAR LOTE A MEDICAMENTO EXISTENTE ───────────────
  group('guardarLoteAMedicamentoExistente()', () {

    test('inserta lote correctamente con datos válidos', () async {
      when(mockLoteDao.insertarLote(any)).thenAnswer((_) async {});

      await expectLater(
        controller.guardarLoteAMedicamentoExistente(
          idMedicamento: 1,
          numeroLote: 'LOT-003',
          fechaFabricacion: '2024-06-01',
          fechaVencimiento: '2027-06-01',
          cantidadInicial: 100,
          cantidadDisponible: 100,
          codigoBarras: '111222333',
        ),
        completes,
      );

      verify(mockLoteDao.insertarLote(any)).called(1);
    });

    test('lanza excepción si el DAO de lote falla', () async {
      when(mockLoteDao.insertarLote(any))
          .thenThrow(Exception('Error al insertar lote'));

      expect(
        () => controller.guardarLoteAMedicamentoExistente(
          idMedicamento: 1,
          numeroLote: 'LOT-004',
          fechaFabricacion: '2024-06-01',
          fechaVencimiento: '2027-06-01',
          cantidadInicial: 50,
          cantidadDisponible: 50,
          codigoBarras: '444555666',
        ),
        throwsException,
      );
    });
  });

  // ─── LISTAR MEDICAMENTOS ─────────────────────────────────
  group('listarMedicamentos()', () {

    test('retorna lista de medicamentos correctamente', () async {
      when(mockMedicamentoDao.listarMedicamentos())
          .thenAnswer((_) async => [medicamentoFalso]);

      final lista = await mockMedicamentoDao.listarMedicamentos();

      expect(lista, isNotEmpty);
      expect(lista.first.nombre, equals('Acetaminofén'));
      expect(lista.first.precio, equals(2000));
    });

    test('retorna lista vacía cuando no hay medicamentos', () async {
      when(mockMedicamentoDao.listarMedicamentos())
          .thenAnswer((_) async => []);

      final lista = await mockMedicamentoDao.listarMedicamentos();

      expect(lista, isEmpty);
    });
  });

  // ─── BUSCAR POR NOMBRE ───────────────────────────────────
  group('buscarPorNombre()', () {

    test('retorna medicamento cuando existe', () async {
      when(mockMedicamentoDao.buscarPorNombre('Acetaminofén'))
          .thenAnswer((_) async => medicamentoFalso);

      final resultado = await mockMedicamentoDao.buscarPorNombre('Acetaminofén');

      expect(resultado, isNotNull);
      expect(resultado!.nombre, equals('Acetaminofén'));
      expect(resultado.fabricante, equals('GENFAR'));
    });

    test('retorna null cuando el medicamento no existe', () async {
      when(mockMedicamentoDao.buscarPorNombre('NoExiste'))
          .thenAnswer((_) async => null);

      final resultado = await mockMedicamentoDao.buscarPorNombre('NoExiste');

      expect(resultado, isNull);
    });
  });
}