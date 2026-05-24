class AlertaModel {
  final int? id;
  final String? createTime;
  final int? idMedicamento;
  final int? idLote;
  final String tipo;
  final String nivelGravedad;
  final String mensaje;
  final bool resulta;
  final String? fechaResolucion;

  AlertaModel({
    this.id,
    this.createTime,
    this.idMedicamento,
    this.idLote,
    required this.tipo,
    required this.nivelGravedad,
    required this.mensaje,
    required this.resulta,
    this.fechaResolucion,
  });

  factory AlertaModel.fromMap(Map<String, dynamic> map) {
    return AlertaModel(
      id: int.parse(map['id'].toString()),
      createTime: map['create_time']?.toString(),
      idMedicamento: map['id_medicamento'] != null
          ? int.parse(map['id_medicamento'].toString())
          : null,
      idLote: map['id_lote'] != null
          ? int.parse(map['id_lote'].toString())
          : null,
      tipo: map['tipo'] ?? '',
      nivelGravedad: map['nivel_gravedad'] ?? '',
      mensaje: map['mensaje'] ?? '',
      resulta: map['resulta'].toString() == '1',
      fechaResolucion: map['fecha_resolucion']?.toString(),
    );
  }
}
