import '../DAO/lote_dao.dart';
import '../DAO/scanner_dao.dart';

import '../models/scanner_model.dart';
import '../models/ventas_model.dart';

class VentasController {
  final ScannerDao scannerDao = ScannerDao();
  final LoteDao loteDao = LoteDao();

  final List<VentaItemModel> carrito = [];

  // Buscar por código de barras
  Future<ScannerModel?> buscarMedicamento(String codigo) async {
    return await scannerDao.buscarPorCodigo(codigo);
  }

  // Buscar por nombre
  Future<List<ScannerModel>> buscarMedicamentosPorNombre(String nombre) async {
    return await scannerDao.buscarPorNombre(nombre);
  }

  // Agregar al carrito
  void agregarAlCarrito(ScannerModel medicamento) {
    final index = carrito.indexWhere(
      (item) => item.codigoBarras == medicamento.codigoBarras,
    );

    if (index != -1) {
      carrito[index].cantidad++;
    } else {
      carrito.add(
        VentaItemModel(
          idLote: medicamento.idLote,
          nombre: medicamento.nombre,
          codigoBarras: medicamento.codigoBarras,
          precio: medicamento.precio,
          cantidad: 1,
        ),
      );
    }
  }

  // Quitar una unidad
  void quitarUnaUnidad(int index) {
    if (carrito[index].cantidad > 1) {
      carrito[index].cantidad--;
    } else {
      carrito.removeAt(index);
    }
  }

  // Eliminar producto completo
  void eliminarDelCarrito(int index) {
    carrito.removeAt(index);
  }

  // Calcular total
  double calcularTotal() {
    double total = 0;

    for (var item in carrito) {
      total += item.subtotal;
    }

    return total;
  }

  // Finalizar venta
  Future<void> finalizarVenta() async {
    for (var item in carrito) {
      await loteDao.descontarStockPorCantidad(item.codigoBarras, item.cantidad);
    }

    carrito.clear();
  }
}
