// Este archivo le dice a FLUTTER como organizar los datos de un medicamento
class MedicamentoModel {
  final int id; // Identificador único del medicamento
  final String createTime; // Fecha y hora en que se creó el registro
  final String nombre; // Nombre del medicamento
  final String principioActivo; // Sustancia principal que produce el efecto
  final String presentacion; // Forma en que se presenta (tableta, jarabe, etc.)
  final String fabricante; // Empresa que lo produce
  final int stockActual; // Cantidad disponible actualmente
  final int stockMinimo; // Cantidad mínima permitida antes de alertar
  final bool requiereRefrigeracion; // Indica si necesita refrigeración
  final bool activo; // Indica si el medicamento está activo en el sistema

  MedicamentoModel({
    required this.id,
    required this.createTime,
    required this.nombre,
    required this.principioActivo,
    required this.presentacion,
    required this.fabricante,
    required this.stockActual,
    required this.stockMinimo,
    required this.requiereRefrigeracion,
    required this.activo,
  });

  // Convierte un Map (JSON o base de datos) en un objeto MedicamentoModel
  factory MedicamentoModel.fromMap(Map<String, dynamic> map) {
    return MedicamentoModel(
      id: int.parse(map['id'].toString()), // Convierte el id a entero
      createTime: map['createTime'], // Asigna la fecha de creación
      nombre: map['nombre'], // Asigna el nombre
      principioActivo: map['principioActivo'], // Asigna el principio activo
      presentacion: map['presentacion'], // Asigna la presentación
      fabricante: map['fabricante'], // Asigna el fabricante
      stockActual: int.parse(map['stockActual'].toString()), // Convierte stock actual a entero
      stockMinimo: int.parse(map['stockMinimo'].toString()), // Convierte stock mínimo a entero
      requiereRefrigeracion: map['requiereRefrigeracion'] == 1 || map['requiereRefrigeracion'] == true, // Convierte a booleano
      activo: map['activo'] == 1 || map['activo'] == true, // Convierte a booleano
    );
  }
}