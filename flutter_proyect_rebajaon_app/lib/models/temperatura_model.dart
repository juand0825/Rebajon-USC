class TemperaturaModel {
  final int? id;
  final String? creaTime;
  final int idMedicamento;
  final double temperatura;
  final double rangoMin;
  final double rangoMax;
  final bool fueraDeRango;

  TemperaturaModel({
    this.id,
    this.creaTime,
    required this.idMedicamento,
    required this.temperatura,
    required this.rangoMin,
    required this.rangoMax,
    required this.fueraDeRango,
  });

  factory TemperaturaModel.fromMap(Map<String, dynamic> map) {
    return TemperaturaModel(
      id: int.parse(map['id'].toString()),
      creaTime: map['creaTime']?.toString(),
      idMedicamento: int.parse(map['id_medicamento'].toString()),
      temperatura: double.parse(map['temperatura'].toString()),
      rangoMin: double.parse(map['rango_min'].toString()),
      rangoMax: double.parse(map['rango_max'].toString()),
      fueraDeRango: map['fuera_de_rango'].toString() == '1',
    );
  }
}