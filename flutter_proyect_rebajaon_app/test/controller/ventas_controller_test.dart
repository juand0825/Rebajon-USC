import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_proyect_rebajaon_app/Controllers/ventas_controller.dart';
import 'package:flutter_proyect_rebajaon_app/Controllers/alerta_controller.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/scanner_dao.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/lote_dao.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/ventas_dao.dart';
import 'package:flutter_proyect_rebajaon_app/DAO/carrito_dao.dart';
import 'package:flutter_proyect_rebajaon_app/models/scanner_model.dart';
import 'package:flutter_proyect_rebajaon_app/models/ventas_model.dart';

@GenerateMocks([ScannerDao, LoteDao, VentaDao, CarritoDao, AlertaController])
import 'ventas_controller_test.mocks.dart';

void main() {
  late VentasController controller;
  late MockScannerDao mockScannerDao;
  late MockLoteDao mockLoteDao;
  late MockVentaDao mockVentaDao;
  late MockCarritoDao mockCarritoDao;
  late MockAlertaController mockAlertaController;

  final medicamentoActivo = ScannerModel(
    idLote: 1,
    idMedicamento: 1,
    nombre: 'Acetaminofén',
    principioActivo: 'Paracetamol',
    presentacion: 'Tabletas',
    fabricante: 'GENFAR',
    codigoBarras: '123456789',
    numeroLote: 'LOT-001',
    cantidadDisponible: 45,
    stockActual: 45,
    stockMinimo: 10,
    fechaVencimiento: '2027-01-01',
    precio: 2000,
    requiereRefrigeracion: false,
    activo: true,
  );

  setUp(() {
    mockScannerDao = MockScannerDao();
    mockLoteDao = MockLoteDao();
    mockVentaDao = MockVentaDao();
    mockCarritoDao = MockCarritoDao();
    mockAlertaController = MockAlertaController();

    controller = VentasController(
      scannerDao: mockScannerDao,
      loteDao: mockLoteDao,
      ventaDao: mockVentaDao,
      carritoDao: mockCarritoDao,
      alertaController: mockAlertaController,
    );
  });

  group('agregarAlCarrito()', () {

    test('agrega medicamento activo con stock al carrito', () {
      final resultado = controller.agregarAlCarrito(medicamentoActivo);
      expect(resultado, isNull);
      expect(controller.carrito.length, equals(1));
      expect(controller.carrito.first.nombre, equals('Acetaminofén'));
      expect(controller.carrito.first.cantidad, equals(1));
    });

    test('incrementa cantidad si el medicamento ya está en el carrito', () {
      controller.agregarAlCarrito(medicamentoActivo);
      controller.agregarAlCarrito(medicamentoActivo);
      expect(controller.carrito.length, equals(1));
      expect(controller.carrito.first.cantidad, equals(2));
    });

    test('retorna error si el medicamento está inactivo', () {
      final medicamentoInactivo = ScannerModel(
        idLote: 2, idMedicamento: 2, nombre: 'Ibuprofeno',
        principioActivo: 'Ibuprofeno', presentacion: 'Cápsulas',
        fabricante: 'MK', codigoBarras: '987654321', numeroLote: 'LOT-002',
        cantidadDisponible: 20, stockActual: 20, stockMinimo: 5,
        fechaVencimiento: '2027-01-01', precio: 3000,
        requiereRefrigeracion: false, activo: false,
      );
      final resultado = controller.agregarAlCarrito(medicamentoInactivo);
      expect(resultado, equals('Este medicamento está inactivo'));
      expect(controller.carrito, isEmpty);
    });

    test('retorna error si el lote está vencido', () {
      final medicamentoVencido = ScannerModel(
        idLote: 3, idMedicamento: 3, nombre: 'Aspirina',
        principioActivo: 'ASS', presentacion: 'Tabletas',
        fabricante: 'Bayer', codigoBarras: '111222333', numeroLote: 'LOT-003',
        cantidadDisponible: 10, stockActual: 10, stockMinimo: 5,
        fechaVencimiento: '2020-01-01', precio: 1500,
        requiereRefrigeracion: false, activo: true,
      );
      final resultado = controller.agregarAlCarrito(medicamentoVencido);
      expect(resultado, equals('El lote está vencido'));
      expect(controller.carrito, isEmpty);
    });

    test('retorna error si no hay stock disponible', () {
      final sinStock = ScannerModel(
        idLote: 4, idMedicamento: 4, nombre: 'Loratadina',
        principioActivo: 'Loratadina', presentacion: 'Tabletas',
        fabricante: 'GENFAR', codigoBarras: '444555666', numeroLote: 'LOT-004',
        cantidadDisponible: 0, stockActual: 0, stockMinimo: 5,
        fechaVencimiento: '2027-01-01', precio: 1800,
        requiereRefrigeracion: false, activo: true,
      );
      final resultado = controller.agregarAlCarrito(sinStock);
      expect(resultado, equals('No hay stock disponible'));
      expect(controller.carrito, isEmpty);
    });

    test('retorna error si se supera el stock disponible', () {
      final stockLimitado = ScannerModel(
        idLote: 1, idMedicamento: 1, nombre: 'Acetaminofén',
        principioActivo: 'Paracetamol', presentacion: 'Tabletas',
        fabricante: 'GENFAR', codigoBarras: '123456789', numeroLote: 'LOT-001',
        cantidadDisponible: 1, stockActual: 1, stockMinimo: 10,
        fechaVencimiento: '2027-01-01', precio: 2000,
        requiereRefrigeracion: false, activo: true,
      );
      controller.agregarAlCarrito(stockLimitado);
      final resultado = controller.agregarAlCarrito(stockLimitado);
      expect(resultado, equals('Ya no puedes agregar más unidades'));
      expect(controller.carrito.first.cantidad, equals(1));
    });
  });

  group('quitarUnaUnidad()', () {

    test('reduce cantidad en 1 si hay más de una unidad', () {
      controller.agregarAlCarrito(medicamentoActivo);
      controller.agregarAlCarrito(medicamentoActivo);
      controller.quitarUnaUnidad(0);
      expect(controller.carrito.first.cantidad, equals(1));
    });

    test('elimina el item si la cantidad llega a 0', () {
      controller.agregarAlCarrito(medicamentoActivo);
      controller.quitarUnaUnidad(0);
      expect(controller.carrito, isEmpty);
    });
  });

  group('eliminarDelCarrito()', () {

    test('elimina el item del carrito correctamente', () {
      controller.agregarAlCarrito(medicamentoActivo);
      controller.eliminarDelCarrito(0);
      expect(controller.carrito, isEmpty);
    });
  });

  group('calcularTotal()', () {

    test('retorna 0 cuando el carrito está vacío', () {
      expect(controller.calcularTotal(), equals(0));
    });

    test('calcula el total correctamente con un item', () {
      controller.agregarAlCarrito(medicamentoActivo);
      expect(controller.calcularTotal(), equals(2000));
    });

    test('calcula el total correctamente con múltiples unidades', () {
      controller.agregarAlCarrito(medicamentoActivo);
      controller.agregarAlCarrito(medicamentoActivo);
      expect(controller.calcularTotal(), equals(4000));
    });
  });

  group('loteVencido()', () {

    test('retorna true para fecha pasada', () {
      expect(controller.loteVencido('2020-01-01'), isTrue);
    });

    test('retorna false para fecha futura', () {
      expect(controller.loteVencido('2030-01-01'), isFalse);
    });
  });

  group('finalizarVenta()', () {

    test('lanza excepción si el carrito está vacío', () async {
      expect(
        () => controller.finalizarVenta(idUsuario: 1),
        throwsException,
      );
    });

    test('completa la venta correctamente con carrito válido', () async {
      controller.agregarAlCarrito(medicamentoActivo);

      when(mockScannerDao.buscarPorCodigo('123456789'))
          .thenAnswer((_) async => medicamentoActivo);
      when(mockCarritoDao.crearCarrito(1))
          .thenAnswer((_) async => 10);
      when(mockCarritoDao.guardarDetalleCarrito(
              idCarrito: anyNamed('idCarrito'),
              items: anyNamed('items')))
          .thenAnswer((_) async {});
      when(mockLoteDao.descontarStockPorCantidad('123456789', 1))
          .thenAnswer((_) async => true);
      when(mockVentaDao.registrarVenta(
              idUsuario: anyNamed('idUsuario'),
              idCarrito: anyNamed('idCarrito'),
              total: anyNamed('total'),
              items: anyNamed('items')))
          .thenAnswer((_) async => 1);
      when(mockCarritoDao.confirmarCarrito(10))
          .thenAnswer((_) async {});
      when(mockAlertaController.generarAlertaStockMinimo(
              idMedicamento: anyNamed('idMedicamento'),
              nombreMedicamento: anyNamed('nombreMedicamento'),
              stockActual: anyNamed('stockActual'),
              stockMinimo: anyNamed('stockMinimo')))
          .thenAnswer((_) async => null);

      final avisos = await controller.finalizarVenta(idUsuario: 1);

      expect(avisos, isA<List<String>>());
      expect(controller.carrito, isEmpty);
      verify(mockVentaDao.registrarVenta(
        idUsuario: anyNamed('idUsuario'),
        idCarrito: anyNamed('idCarrito'),
        total: anyNamed('total'),
        items: anyNamed('items'),
      )).called(1);
    });

    test('lanza excepción si el medicamento no se encuentra al finalizar', () async {
      controller.agregarAlCarrito(medicamentoActivo);
      when(mockScannerDao.buscarPorCodigo('123456789'))
          .thenAnswer((_) async => null);
      expect(
        () => controller.finalizarVenta(idUsuario: 1),
        throwsException,
      );
    });
  });
}