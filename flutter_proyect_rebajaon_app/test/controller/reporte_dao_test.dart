import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/reporte_dao.dart';
import 'package:flutter_proyect_rebajaon_app/models/reporte_model.dart';

@GenerateMocks([ReporteDao])
import 'reporte_dao_test.mocks.dart';

void main() {
  late MockReporteDao mockReporteDao;

  setUp(() {
    mockReporteDao = MockReporteDao();
  });

  // ─── OBTENER RESUMEN ─────────────────────────────────────
  group('obtenerResumen()', () {

    test('retorna resumen con datos correctos', () async {
      final resumenFalso = ReporteResumenModel(
        totalVentas: 3,
        totalIngresos: 10000,
        totalProductosVendidos: 5,
        alertasPendientes: 3,
        alertasResueltas: 0,
        medicamentosSinStock: 0,
        medicamentosStockMinimo: 3,
        lotesRegistrados: 1,
      );

      when(mockReporteDao.obtenerResumen())
          .thenAnswer((_) async => resumenFalso);

      final resultado = await mockReporteDao.obtenerResumen();

      expect(resultado.totalVentas, equals(3));
      expect(resultado.totalIngresos, equals(10000));
      expect(resultado.totalProductosVendidos, equals(5));
      expect(resultado.alertasPendientes, equals(3));
      expect(resultado.alertasResueltas, equals(0));
      expect(resultado.medicamentosSinStock, equals(0));
      expect(resultado.medicamentosStockMinimo, equals(3));
      expect(resultado.lotesRegistrados, equals(1));
    });

    test('retorna resumen con valores en cero cuando no hay datos', () async {
      final resumenVacio = ReporteResumenModel(
        totalVentas: 0,
        totalIngresos: 0,
        totalProductosVendidos: 0,
        alertasPendientes: 0,
        alertasResueltas: 0,
        medicamentosSinStock: 0,
        medicamentosStockMinimo: 0,
        lotesRegistrados: 0,
      );

      when(mockReporteDao.obtenerResumen())
          .thenAnswer((_) async => resumenVacio);

      final resultado = await mockReporteDao.obtenerResumen();

      expect(resultado.totalVentas, equals(0));
      expect(resultado.totalIngresos, equals(0));
    });
  });

  // ─── PRODUCTOS MÁS VENDIDOS ──────────────────────────────
  group('productosMasVendidos()', () {

    test('retorna lista de productos vendidos correctamente', () async {
      final productosFalsos = [
        ReporteVentaProductoModel(
          medicamento: 'Acetaminofén',
          cantidadVendida: 5,
          totalVendido: 10000,
        ),
        ReporteVentaProductoModel(
          medicamento: 'Ibuprofeno',
          cantidadVendida: 3,
          totalVendido: 9000,
        ),
      ];

      when(mockReporteDao.productosMasVendidos())
          .thenAnswer((_) async => productosFalsos);

      final resultado = await mockReporteDao.productosMasVendidos();

      expect(resultado, isNotEmpty);
      expect(resultado.length, equals(2));
      expect(resultado.first.medicamento, equals('Acetaminofén'));
      expect(resultado.first.cantidadVendida, equals(5));
      expect(resultado.first.totalVendido, equals(10000));
    });

    test('retorna lista vacía cuando no hay ventas', () async {
      when(mockReporteDao.productosMasVendidos())
          .thenAnswer((_) async => []);

      final resultado = await mockReporteDao.productosMasVendidos();

      expect(resultado, isEmpty);
    });
  });

  // ─── RESUMEN ALERTAS ─────────────────────────────────────
  group('resumenAlertas()', () {

    test('retorna lista de alertas agrupadas correctamente', () async {
      final alertasFalsas = [
        ReporteAlertaModel(
          tipo: 'STOCK_MINIMO',
          gravedad: 'ADVERTENCIA',
          cantidad: 3,
        ),
      ];

      when(mockReporteDao.resumenAlertas())
          .thenAnswer((_) async => alertasFalsas);

      final resultado = await mockReporteDao.resumenAlertas();

      expect(resultado, isNotEmpty);
      expect(resultado.first.tipo, equals('STOCK_MINIMO'));
      expect(resultado.first.gravedad, equals('ADVERTENCIA'));
      expect(resultado.first.cantidad, equals(3));
    });

    test('retorna lista vacía cuando no hay alertas', () async {
      when(mockReporteDao.resumenAlertas())
          .thenAnswer((_) async => []);

      final resultado = await mockReporteDao.resumenAlertas();

      expect(resultado, isEmpty);
    });
  });

  // ─── LOTES REGISTRADOS ───────────────────────────────────
  group('lotesRegistrados()', () {

    test('retorna lista de lotes correctamente', () async {
      final lotesFalsos = [
        ReporteLoteModel(
          medicamento: 'Acetaminofén',
          numeroLote: '123456789',
          cantidadInicial: 50,
          cantidadDisponible: 45,
          fechaVencimiento: '2027-05-19',
          codigoBarras: '123456789',
        ),
      ];

      when(mockReporteDao.lotesRegistrados())
          .thenAnswer((_) async => lotesFalsos);

      final resultado = await mockReporteDao.lotesRegistrados();

      expect(resultado, isNotEmpty);
      expect(resultado.first.medicamento, equals('Acetaminofén'));
      expect(resultado.first.cantidadInicial, equals(50));
      expect(resultado.first.cantidadDisponible, equals(45));
      expect(resultado.first.fechaVencimiento, equals('2027-05-19'));
    });

    test('retorna lista vacía cuando no hay lotes', () async {
      when(mockReporteDao.lotesRegistrados())
          .thenAnswer((_) async => []);

      final resultado = await mockReporteDao.lotesRegistrados();

      expect(resultado, isEmpty);
    });
  });

  // ─── INVENTARIO ACTUAL ───────────────────────────────────
  group('inventarioActual()', () {

    test('retorna inventario correctamente', () async {
      final inventarioFalso = [
        ReporteInventarioModel(
          medicamento: 'Acetaminofén',
          stockActual: 45,
          stockMinimo: 10,
          precio: 2000,
          activo: true,
        ),
      ];

      when(mockReporteDao.inventarioActual())
          .thenAnswer((_) async => inventarioFalso);

      final resultado = await mockReporteDao.inventarioActual();

      expect(resultado, isNotEmpty);
      expect(resultado.first.medicamento, equals('Acetaminofén'));
      expect(resultado.first.stockActual, equals(45));
      expect(resultado.first.precio, equals(2000));
      expect(resultado.first.activo, isTrue);
    });

    test('retorna lista vacía cuando no hay medicamentos', () async {
      when(mockReporteDao.inventarioActual())
          .thenAnswer((_) async => []);

      final resultado = await mockReporteDao.inventarioActual();

      expect(resultado, isEmpty);
    });
  });
}
