class ReporteResumenModel {
  final int totalVentas;
  final double totalIngresos;
  final int totalProductosVendidos;
  final int alertasPendientes;
  final int alertasResueltas;
  final int medicamentosSinStock;
  final int medicamentosStockMinimo;
  final int lotesRegistrados;

  ReporteResumenModel({
    required this.totalVentas,
    required this.totalIngresos,
    required this.totalProductosVendidos,
    required this.alertasPendientes,
    required this.alertasResueltas,
    required this.medicamentosSinStock,
    required this.medicamentosStockMinimo,
    required this.lotesRegistrados,
  });
}

class ReporteVentaProductoModel {
  final String medicamento;
  final int cantidadVendida;
  final double totalVendido;

  ReporteVentaProductoModel({
    required this.medicamento,
    required this.cantidadVendida,
    required this.totalVendido,
  });

  factory ReporteVentaProductoModel.fromMap(Map<String, dynamic> map) {
    return ReporteVentaProductoModel(
      medicamento: map['medicamento'] ?? '',
      cantidadVendida: int.parse(map['cantidad_vendida'].toString()),
      totalVendido: double.parse(map['total_vendido'].toString()),
    );
  }
}

class ReporteAlertaModel {
  final String tipo;
  final String gravedad;
  final int cantidad;

  ReporteAlertaModel({
    required this.tipo,
    required this.gravedad,
    required this.cantidad,
  });

  factory ReporteAlertaModel.fromMap(Map<String, dynamic> map) {
    return ReporteAlertaModel(
      tipo: map['tipo'] ?? '',
      gravedad: map['nivel_gravedad'] ?? '',
      cantidad: int.parse(map['cantidad'].toString()),
    );
  }
}

class ReporteLoteModel {
  final String medicamento;
  final String numeroLote;
  final int cantidadInicial;
  final int cantidadDisponible;
  final String fechaVencimiento;
  final String codigoBarras;

  ReporteLoteModel({
    required this.medicamento,
    required this.numeroLote,
    required this.cantidadInicial,
    required this.cantidadDisponible,
    required this.fechaVencimiento,
    required this.codigoBarras,
  });

  factory ReporteLoteModel.fromMap(Map<String, dynamic> map) {
    return ReporteLoteModel(
      medicamento: map['medicamento'] ?? '',
      numeroLote: map['numero_lote'] ?? '',
      cantidadInicial: int.parse(map['cantidad_inicial'].toString()),
      cantidadDisponible: int.parse(map['cantidad_disponible'].toString()),
      fechaVencimiento: map['fecha_vencimiento']?.toString() ?? '',
      codigoBarras: map['codigo_barras'] ?? '',
    );
  }
}

class ReporteInventarioModel {
  final String medicamento;
  final int stockActual;
  final int stockMinimo;
  final double precio;
  final bool activo;

  ReporteInventarioModel({
    required this.medicamento,
    required this.stockActual,
    required this.stockMinimo,
    required this.precio,
    required this.activo,
  });

  factory ReporteInventarioModel.fromMap(Map<String, dynamic> map) {
    return ReporteInventarioModel(
      medicamento: map['nombre'] ?? '',
      stockActual: int.parse(map['stock_actual'].toString()),
      stockMinimo: int.parse(map['stock_minimo'].toString()),
      precio: double.parse(map['precio'].toString()),
      activo: map['activo'].toString() == '1',
    );
  }
}
