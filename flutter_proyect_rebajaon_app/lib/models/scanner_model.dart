class ScannerModel {
  final int idLote;
  final String nombre;
  final String principioActivo;
  final String presentacion;
  final String fabricante;
  final String codigoBarras;
  final String numeroLote;
  final int cantidadDisponible;
  final String fechaVencimiento;
  final double precio;

  ScannerModel({
    required this.idLote,
    required this.nombre,
    required this.principioActivo,
    required this.presentacion,
    required this.fabricante,
    required this.codigoBarras,
    required this.numeroLote,
    required this.cantidadDisponible,
    required this.fechaVencimiento,
    required this.precio,
  });

  factory ScannerModel.fromMap(Map<String, dynamic> map) {
    return ScannerModel(
      idLote: int.parse(map['id_lote'].toString()),

      nombre: map['nombre'] ?? '',

      principioActivo: map['principio_activo'] ?? '',

      presentacion: map['presentacion'] ?? '',

      fabricante: map['fabricante'] ?? '',

      codigoBarras: map['codigo_barras'] ?? '',

      numeroLote: map['numero_lote'] ?? '',

      cantidadDisponible: int.parse(map['cantidad_disponible'].toString()),

      fechaVencimiento: map['fecha_vencimiento']?.toString() ?? '',

      precio: double.parse(map['precio'].toString()),
    );
  }
}
