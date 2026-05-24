class LoteModel {
  final int? id;
  final String? createTime;
  final int idMedicamento;
  final String numeroLote;
  final String fechaFabricacion;
  final String fechaVencimiento;
  final int cantidadInicial;
  final int cantidadDisponible;
  final String codigoBarras;

  LoteModel({
    this.id,
    this.createTime,
    required this.idMedicamento,
    required this.numeroLote,
    required this.fechaFabricacion,
    required this.fechaVencimiento,
    required this.cantidadInicial,
    required this.cantidadDisponible,
    required this.codigoBarras,
  });

  factory LoteModel.fromMap(Map<String, dynamic> map) {
    return LoteModel(
      id: int.parse(map['id'].toString()),
      createTime: map['create_time']?.toString(),
      idMedicamento: int.parse(map['id_medicamento'].toString()),
      numeroLote: map['numero_lote'] ?? '',
      fechaFabricacion: map['fecha_fabricacion']?.toString() ?? '',
      fechaVencimiento: map['fecha_vencimiento']?.toString() ?? '',
      cantidadInicial: int.parse(map['cantidad_inicial'].toString()),
      cantidadDisponible: int.parse(map['cantidad_disponible'].toString()),
      codigoBarras: map['codigo_barras'] ?? '',
    );
  }
}
