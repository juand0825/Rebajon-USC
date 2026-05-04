// Este archivo le dice a FLUTTER como organizar los datos de un lote de medicamentos
class LoteModel {
  final int id; // Identificador único del lote
  final String createTime; // Fecha y hora en que se creó el lote
  final int idMedicamento; // Relación con el medicamento al que pertenece
  final String numeroLote; // Número que identifica el lote
  final String fechaFabricacion; // Fecha en que fue fabricado
  final String fechaVencimiento; // Fecha en que vence
  final int cantidadInicial; // Cantidad con la que inició el lote
  final int cantidadDisponible; // Cantidad actual disponible
  final String codigoBarras; // Código de barras del lote

  LoteModel({
    required this.id,
    required this.createTime,
    required this.idMedicamento,
    required this.numeroLote,
    required this.fechaFabricacion,
    required this.fechaVencimiento,
    required this.cantidadInicial,
    required this.cantidadDisponible,
    required this.codigoBarras,
  });

  // Convierte un Map (JSON o base de datos) en un objeto LoteModel
  factory LoteModel.fromMap(Map<String, dynamic> map) {
    return LoteModel(
      id: int.parse(map['id'].toString()), // Convierte el id a entero
      createTime: map['createTime'], // Asigna la fecha de creación
      idMedicamento: int.parse(map['idMedicamento'].toString()), // Convierte el id del medicamento
      numeroLote: map['numeroLote'], // Asigna el número de lote
      fechaFabricacion: map['fechaFabricacion'], // Asigna fecha de fabricación
      fechaVencimiento: map['fechaVencimiento'], // Asigna fecha de vencimiento
      cantidadInicial: int.parse(map['cantidadInicial'].toString()), // Convierte cantidad inicial
      cantidadDisponible: int.parse(map['cantidadDisponible'].toString()), // Convierte cantidad disponible
      codigoBarras: map['codigoBarras'], // Asigna el código de barras
    );
  }
}