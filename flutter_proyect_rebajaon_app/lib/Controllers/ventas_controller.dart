import '../DAO/lote_dao.dart';
import '../DAO/scanner_dao.dart';
import '../DAO/ventas_dao.dart';
import '../Controllers/alerta_controller.dart';

import '../models/scanner_model.dart';
import '../models/ventas_model.dart';

class VentasController {
  final ScannerDao scannerDao = ScannerDao();
  final LoteDao loteDao = LoteDao();
  final VentaDao ventaDao = VentaDao();
  final AlertaController alertaController = AlertaController();

  final List<VentaItemModel> carrito = [];

  // ==========================================
  // BUSCAR MEDICAMENTO POR CÓDIGO
  // ==========================================
  Future<ScannerModel?> buscarMedicamento(String codigo) async {
    return await scannerDao.buscarPorCodigo(codigo);
  }

  // ==========================================
  // BUSCAR MEDICAMENTOS POR NOMBRE
  // ==========================================
  Future<List<ScannerModel>> buscarMedicamentosPorNombre(
    String nombre,
  ) async {
    return await scannerDao.buscarPorNombre(nombre);
  }

  // ==========================================
  // VALIDAR SI EL LOTE ESTÁ VENCIDO
  // ==========================================
  bool loteVencido(String fechaVencimiento) {
    final hoy = DateTime.now();
    final hoySinHora = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    );

    final vencimiento = DateTime.parse(
      fechaVencimiento,
    );

    return vencimiento.isBefore(hoySinHora);
  }

  // ==========================================
  // AGREGAR MEDICAMENTO AL CARRITO
  // ==========================================
  String? agregarAlCarrito(
    ScannerModel medicamento,
  ) {
    if (!medicamento.activo) {
      return 'Este medicamento está inactivo';
    }

    if (loteVencido(
      medicamento.fechaVencimiento,
    )) {
      return 'El lote está vencido';
    }

    final stockDisponible =
        medicamento.cantidadDisponible;

    if (stockDisponible <= 0) {
      return 'No hay stock disponible';
    }

    final index = carrito.indexWhere(
      (item) =>
          item.codigoBarras ==
          medicamento.codigoBarras,
    );

    // Si el medicamento ya existe en el carrito
    if (index != -1) {
      final cantidadActual =
          carrito[index].cantidad;

      // Validar contra el stock real
      if (cantidadActual >=
          stockDisponible) {
        return 'Ya no puedes agregar más unidades';
      }

      carrito[index].cantidad++;
      return null;
    }

    // Si no existe en el carrito, agregarlo
    carrito.add(
      VentaItemModel(
        idLote: medicamento.idLote,
        idMedicamento:
            medicamento.idMedicamento,
        nombre: medicamento.nombre,
        codigoBarras:
            medicamento.codigoBarras,
        precio: medicamento.precio,
        stockMinimo:
            medicamento.stockMinimo,
        cantidad: 1,
      ),
    );

    return null;
  }

  // ==========================================
  // QUITAR UNA UNIDAD
  // ==========================================
  void quitarUnaUnidad(int index) {
    if (carrito[index].cantidad > 1) {
      carrito[index].cantidad--;
    } else {
      carrito.removeAt(index);
    }
  }

  // ==========================================
  // ELIMINAR PRODUCTO DEL CARRITO
  // ==========================================
  void eliminarDelCarrito(int index) {
    carrito.removeAt(index);
  }

  // ==========================================
  // CALCULAR TOTAL
  // ==========================================
  double calcularTotal() {
    double total = 0;

    for (final item in carrito) {
      total += item.subtotal;
    }

    return total;
  }

  // ==========================================
  // FINALIZAR VENTA
  // ==========================================
  Future<void> finalizarVenta() async {
    if (carrito.isEmpty) {
      throw Exception(
        'El carrito está vacío',
      );
    }

    final copiaCarrito =
        List<VentaItemModel>.from(
      carrito,
    );

    // Validar stock y estado
    for (final item in copiaCarrito) {
      final productoActual =
          await scannerDao.buscarPorCodigo(
        item.codigoBarras,
      );

      if (productoActual == null) {
        throw Exception(
          'No se encontró ${item.nombre}',
        );
      }

      if (!productoActual.activo) {
        throw Exception(
          '${item.nombre} está inactivo',
        );
      }

      if (loteVencido(
        productoActual
            .fechaVencimiento,
      )) {
        throw Exception(
          'El lote de ${item.nombre} está vencido',
        );
      }

      if (productoActual
              .cantidadDisponible <
          item.cantidad) {
        throw Exception(
          'No hay stock suficiente para ${item.nombre}',
        );
      }
    }

    // Descontar stock
    for (final item in copiaCarrito) {
      final descontado =
          await loteDao
              .descontarStockPorCantidad(
        item.codigoBarras,
        item.cantidad,
      );

      if (!descontado) {
        throw Exception(
          'No se pudo descontar el stock de ${item.nombre}',
        );
      }
    }

    // Registrar venta
    await ventaDao.registrarVenta(
      total: calcularTotal(),
      items: copiaCarrito,
    );

    // Generar alertas de stock mínimo
    for (final item in copiaCarrito) {
      final productoActualizado =
          await scannerDao.buscarPorCodigo(
        item.codigoBarras,
      );

      if (productoActualizado != null) {
        await alertaController
            .generarAlertaStockMinimo(
          idMedicamento:
              productoActualizado
                  .idMedicamento,
          nombreMedicamento:
              productoActualizado
                  .nombre,
          stockActual:
              productoActualizado
                  .stockActual,
          stockMinimo:
              productoActualizado
                  .stockMinimo,
        );
      }
    }

    // Limpiar carrito
    carrito.clear();
  }
}