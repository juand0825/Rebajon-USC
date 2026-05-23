import '../DAO/lote_dao.dart';
import '../DAO/scanner_dao.dart';
import '../DAO/ventas_dao.dart';
import '../DAO/carrito_dao.dart';
import '../Controllers/alerta_controller.dart';

import '../models/scanner_model.dart';
import '../models/ventas_model.dart';

class VentasController {
 final ScannerDao scannerDao;
final LoteDao loteDao;
final VentaDao ventaDao;
final CarritoDao carritoDao;
final AlertaController alertaController;

VentasController({
  ScannerDao? scannerDao,
  LoteDao? loteDao,
  VentaDao? ventaDao,
  CarritoDao? carritoDao,
  AlertaController? alertaController,
}) : scannerDao = scannerDao ?? ScannerDao(),
     loteDao = loteDao ?? LoteDao(),
     ventaDao = ventaDao ?? VentaDao(),
     carritoDao = carritoDao ?? CarritoDao(),
     alertaController = alertaController ?? AlertaController();
  final List<VentaItemModel> carrito = [];

  Future<ScannerModel?> buscarMedicamento(String codigo) async {
    return await scannerDao.buscarPorCodigo(codigo);
  }

  Future<List<ScannerModel>> buscarMedicamentosPorNombre(String nombre) async {
    return await scannerDao.buscarPorNombre(nombre);
  }

  bool loteVencido(String fechaVencimiento) {
    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final vencimiento = DateTime.parse(fechaVencimiento);

    return vencimiento.isBefore(hoySinHora);
  }

  String? agregarAlCarrito(ScannerModel medicamento) {
    if (!medicamento.activo) {
      return 'Este medicamento está inactivo';
    }

    if (loteVencido(medicamento.fechaVencimiento)) {
      return 'El lote está vencido';
    }

    final stockDisponible = medicamento.cantidadDisponible;

    if (stockDisponible <= 0) {
      return 'No hay stock disponible';
    }

    final index = carrito.indexWhere(
      (item) => item.codigoBarras == medicamento.codigoBarras,
    );

    if (index != -1) {
      final cantidadActual = carrito[index].cantidad;

      if (cantidadActual >= stockDisponible) {
        return 'Ya no puedes agregar más unidades';
      }

      carrito[index].cantidad++;
      return null;
    }

    carrito.add(
      VentaItemModel(
        idLote: medicamento.idLote,
        idMedicamento: medicamento.idMedicamento,
        nombre: medicamento.nombre,
        codigoBarras: medicamento.codigoBarras,
        precio: medicamento.precio,
        stockMinimo: medicamento.stockMinimo,
        cantidad: 1,
      ),
    );

    return null;
  }

  void quitarUnaUnidad(int index) {
    if (carrito[index].cantidad > 1) {
      carrito[index].cantidad--;
    } else {
      carrito.removeAt(index);
    }
  }

  void eliminarDelCarrito(int index) {
    carrito.removeAt(index);
  }

  double calcularTotal() {
    double total = 0;

    for (final item in carrito) {
      total += item.subtotal;
    }

    return total;
  }

  Future<List<String>> finalizarVenta({required int idUsuario}) async {
    if (carrito.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    final copiaCarrito = List<VentaItemModel>.from(carrito);
    final List<String> avisosStock = [];

    for (final item in copiaCarrito) {
      final productoActual = await scannerDao.buscarPorCodigo(
        item.codigoBarras,
      );

      if (productoActual == null) {
        throw Exception('No se encontró ${item.nombre}');
      }

      if (!productoActual.activo) {
        throw Exception('${item.nombre} está inactivo');
      }

      if (loteVencido(productoActual.fechaVencimiento)) {
        throw Exception('El lote de ${item.nombre} está vencido');
      }

      if (productoActual.cantidadDisponible < item.cantidad) {
        throw Exception('No hay stock suficiente para ${item.nombre}');
      }
    }

    final idCarrito = await carritoDao.crearCarrito(idUsuario);

    await carritoDao.guardarDetalleCarrito(
      idCarrito: idCarrito,
      items: copiaCarrito,
    );

    for (final item in copiaCarrito) {
      final descontado = await loteDao.descontarStockPorCantidad(
        item.codigoBarras,
        item.cantidad,
      );

      if (!descontado) {
        throw Exception('No se pudo descontar el stock de ${item.nombre}');
      }
    }

    await ventaDao.registrarVenta(
      idUsuario: idUsuario,
      idCarrito: idCarrito,
      total: calcularTotal(),
      items: copiaCarrito,
    );

    await carritoDao.confirmarCarrito(idCarrito);

    for (final item in copiaCarrito) {
      final productoActualizado = await scannerDao.buscarPorCodigo(
        item.codigoBarras,
      );

      if (productoActualizado != null) {
        await alertaController.generarAlertaStockMinimo(
          idMedicamento: productoActualizado.idMedicamento,
          nombreMedicamento: productoActualizado.nombre,
          stockActual: productoActualizado.stockActual,
          stockMinimo: productoActualizado.stockMinimo,
        );

        if (productoActualizado.stockActual <= 0) {
          avisosStock.add(
            '${productoActualizado.nombre} quedó sin stock. Revisa las alertas.',
          );
        } else if (productoActualizado.stockActual <=
            productoActualizado.stockMinimo) {
          avisosStock.add(
            '${productoActualizado.nombre} alcanzó el stock mínimo. Revisa las alertas.',
          );
        }
      }
    }

    carrito.clear();
    return avisosStock;
  }
}
