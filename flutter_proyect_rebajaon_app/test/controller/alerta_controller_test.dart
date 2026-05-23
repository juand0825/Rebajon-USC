import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_proyect_rebajaon_app/Controllers/alerta_controller.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/alerta_dao.dart';

@GenerateMocks([AlertaDao])
import 'alerta_controller_test.mocks.dart';

void main() {
  late AlertaController controller;
  late MockAlertaDao mockAlertaDao;

  setUp(() {
    mockAlertaDao = MockAlertaDao();
    controller = AlertaController(alertaDao: mockAlertaDao);
  });

  // ─── STOCK MÍNIMO ────────────────────────────────────────
  group('generarAlertaStockMinimo()', () {

    test('no genera alerta si el stock está por encima del mínimo', () async {
      final resultado = await controller.generarAlertaStockMinimo(
        idMedicamento: 1,
        nombreMedicamento: 'Acetaminofén',
        stockActual: 20,
        stockMinimo: 10,
      );

      expect(resultado, isNull);
      verifyZeroInteractions(mockAlertaDao);
    });

    test('genera alerta ADVERTENCIA si stock llega al mínimo y no existe alerta activa', () async {
      when(mockAlertaDao.existeAlertaActiva(
              idMedicamento: 1, tipo: 'STOCK_MINIMO'))
          .thenAnswer((_) async => false);
      when(mockAlertaDao.insertarAlerta(any))
          .thenAnswer((_) async {});

      final resultado = await controller.generarAlertaStockMinimo(
        idMedicamento: 1,
        nombreMedicamento: 'Acetaminofén',
        stockActual: 10,
        stockMinimo: 10,
      );

      expect(resultado, contains('alcanzó el stock mínimo'));
      verify(mockAlertaDao.insertarAlerta(any)).called(1);
    });

    test('genera alerta CRITICO si stock es 0', () async {
      when(mockAlertaDao.existeAlertaActiva(
              idMedicamento: 1, tipo: 'STOCK_MINIMO'))
          .thenAnswer((_) async => false);
      when(mockAlertaDao.insertarAlerta(any))
          .thenAnswer((_) async {});

      final resultado = await controller.generarAlertaStockMinimo(
        idMedicamento: 1,
        nombreMedicamento: 'Acetaminofén',
        stockActual: 0,
        stockMinimo: 10,
      );

      expect(resultado, contains('se quedó sin stock'));
      verify(mockAlertaDao.insertarAlerta(any)).called(1);
    });

    test('actualiza alerta si ya existe una activa', () async {
      when(mockAlertaDao.existeAlertaActiva(
              idMedicamento: 1, tipo: 'STOCK_MINIMO'))
          .thenAnswer((_) async => true);
      when(mockAlertaDao.actualizarAlertaActiva(
              idMedicamento: anyNamed('idMedicamento'),
              tipo: anyNamed('tipo'),
              nivelGravedad: anyNamed('nivelGravedad'),
              mensaje: anyNamed('mensaje')))
          .thenAnswer((_) async {});

      final resultado = await controller.generarAlertaStockMinimo(
        idMedicamento: 1,
        nombreMedicamento: 'Acetaminofén',
        stockActual: 5,
        stockMinimo: 10,
      );

      expect(resultado, isNull);
      verify(mockAlertaDao.actualizarAlertaActiva(
        idMedicamento: anyNamed('idMedicamento'),
        tipo: anyNamed('tipo'),
        nivelGravedad: anyNamed('nivelGravedad'),
        mensaje: anyNamed('mensaje'),
      )).called(1);
      verifyNever(mockAlertaDao.insertarAlerta(any));
    });
  });

  // ─── CADENA FRÍO ─────────────────────────────────────────
  group('generarAlertaCadenaFrio()', () {

    test('no genera alerta si la temperatura está dentro del rango', () async {
      final resultado = await controller.generarAlertaCadenaFrio(
        idMedicamento: 1,
        nombreMedicamento: 'Insulina',
        temperatura: 5,
        rangoMin: 2,
        rangoMax: 8,
      );

      expect(resultado, isNull);
      verifyZeroInteractions(mockAlertaDao);
    });

    test('genera alerta CRITICO si temperatura está fuera del rango', () async {
      when(mockAlertaDao.existeAlertaActiva(
              idMedicamento: 1, tipo: 'CADENA_FRIO'))
          .thenAnswer((_) async => false);
      when(mockAlertaDao.insertarAlerta(any))
          .thenAnswer((_) async {});

      final resultado = await controller.generarAlertaCadenaFrio(
        idMedicamento: 1,
        nombreMedicamento: 'Insulina',
        temperatura: 15,
        rangoMin: 2,
        rangoMax: 8,
      );

      expect(resultado, contains('fuera del rango seguro'));
      verify(mockAlertaDao.insertarAlerta(any)).called(1);
    });

    test('no genera alerta si ya existe una activa de cadena frío', () async {
      when(mockAlertaDao.existeAlertaActiva(
              idMedicamento: 1, tipo: 'CADENA_FRIO'))
          .thenAnswer((_) async => true);

      final resultado = await controller.generarAlertaCadenaFrio(
        idMedicamento: 1,
        nombreMedicamento: 'Insulina',
        temperatura: 15,
        rangoMin: 2,
        rangoMax: 8,
      );

      expect(resultado, isNull);
      verifyNever(mockAlertaDao.insertarAlerta(any));
    });
  });

  // ─── VENCIMIENTO PRÓXIMO ─────────────────────────────────
  group('generarAlertaVencimientoProximo()', () {

    test('no genera alerta si vence en más de 30 días', () async {
      await controller.generarAlertaVencimientoProximo(
        idMedicamento: 1,
        idLote: 1,
        nombreMedicamento: 'Acetaminofén',
        fechaVencimiento: DateTime.now().add(const Duration(days: 60)),
      );

      verifyZeroInteractions(mockAlertaDao);
    });

    test('genera alerta si vence en menos de 30 días', () async {
      when(mockAlertaDao.existeAlertaActiva(
              idMedicamento: 1, tipo: 'VENCIMIENTO_PROXIMO'))
          .thenAnswer((_) async => false);
      when(mockAlertaDao.insertarAlerta(any))
          .thenAnswer((_) async {});

      await controller.generarAlertaVencimientoProximo(
        idMedicamento: 1,
        idLote: 1,
        nombreMedicamento: 'Acetaminofén',
        fechaVencimiento: DateTime.now().add(const Duration(days: 15)),
      );

      verify(mockAlertaDao.insertarAlerta(any)).called(1);
    });
  });

  // ─── RESOLVER ALERTA ─────────────────────────────────────
  group('resolverAlertaStockMinimoSiCorresponde()', () {

    test('resuelve la alerta si el stock supera el mínimo', () async {
      when(mockAlertaDao.resolverAlertasActivas(
              idMedicamento: anyNamed('idMedicamento'),
              tipo: anyNamed('tipo')))
          .thenAnswer((_) async {});

      await controller.resolverAlertaStockMinimoSiCorresponde(
        idMedicamento: 1,
        stockActual: 20,
        stockMinimo: 10,
      );

      verify(mockAlertaDao.resolverAlertasActivas(
        idMedicamento: anyNamed('idMedicamento'),
        tipo: anyNamed('tipo'),
      )).called(1);
    });

    test('no resuelve la alerta si el stock sigue en mínimo', () async {
      await controller.resolverAlertaStockMinimoSiCorresponde(
        idMedicamento: 1,
        stockActual: 5,
        stockMinimo: 10,
      );

      verifyZeroInteractions(mockAlertaDao);
    });
  });
}