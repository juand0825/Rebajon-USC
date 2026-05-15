class ScannerModel {
  final int idLote;
  final int idMedicamento;
  final String nombre;
  final String principioActivo;
  final String presentacion;
  final String fabricante;
  final String codigoBarras;
  final String numeroLote;
  final int cantidadDisponible;
  final int stockActual;
  final int stockMinimo;
  final String fechaVencimiento;
  final double precio;
  final bool requiereRefrigeracion;
  final bool activo;

  ScannerModel({
    required this.idLote,
    required this.idMedicamento,
    required this.nombre,
    required this.principioActivo,
    required this.presentacion,
    required this.fabricante,
    required this.codigoBarras,
    required this.numeroLote,
    required this.cantidadDisponible,
    required this.stockActual,
    required this.stockMinimo,
    required this.fechaVencimiento,
    required this.precio,
    required this.requiereRefrigeracion,
    required this.activo,
  });

  factory ScannerModel.fromMap(Map<String, dynamic> map) {
    return ScannerModel(
      idLote: int.parse(map['id_lote'].toString()),

      idMedicamento: int.parse(map['id_medicamento'].toString()),

      nombre: map['nombre'] ?? '',

      principioActivo: map['principio_activo'] ?? '',

      presentacion: map['presentacion'] ?? '',

      fabricante: map['fabricante'] ?? '',

      codigoBarras: map['codigo_barras'] ?? '',

      numeroLote: map['numero_lote'] ?? '',

      cantidadDisponible: int.parse(map['cantidad_disponible'].toString()),

      stockActual: int.parse(map['stock_actual'].toString()),

      stockMinimo: int.parse(map['stock_minimo'].toString()),

      fechaVencimiento: map['fecha_vencimiento']?.toString() ?? '',
      
      precio: double.parse(map['precio'].toString()),

      requiereRefrigeracion: map['requiere_refrigeracion'].toString() == '1',
      
      activo: map['activo'].toString() == '1',
    );
  }
}
