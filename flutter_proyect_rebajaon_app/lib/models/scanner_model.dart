class ScannerModel {

  final String nombre;
  final String codigoBarras;
  final String numeroLote;
  final int cantidadDisponible;
  final String fechaVencimiento;

  ScannerModel({
    required this.nombre,
    required this.codigoBarras,
    required this.numeroLote,
    required this.cantidadDisponible,
    required this.fechaVencimiento,
  });

  factory ScannerModel.fromMap(Map<String, dynamic> map) {

    return ScannerModel(

      nombre: map['nombre'] ?? '',

      codigoBarras: map['codigo_barras'] ?? '',

      numeroLote: map['numero_lote'] ?? '',

      cantidadDisponible:
          int.parse(map['cantidad_disponible'].toString()),

      fechaVencimiento:
          map['fecha_vencimiento'] ?? '',
    );
  }
}