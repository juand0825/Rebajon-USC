class MedicamentoModel {
  final int? id;

  final String? createTime;

  final String nombre;

  final String principioActivo;

  final String presentacion;

  final String fabricante;

  final double precio;

  final int stockActual;

  final int stockMinimo;

  final bool requiereRefrigeracion;

  final bool activo;

  MedicamentoModel({
    this.id,

    this.createTime,

    required this.nombre,

    required this.principioActivo,

    required this.presentacion,

    required this.fabricante,

    required this.precio,

    required this.stockActual,

    required this.stockMinimo,

    required this.requiereRefrigeracion,

    required this.activo,
  });

  factory MedicamentoModel.fromMap(Map<String, dynamic> map) {
    return MedicamentoModel(
      id: int.parse(map['id'].toString()),

      createTime: map['create_time']?.toString(),

      nombre: map['nombre'] ?? '',

      principioActivo: map['principio_activo'] ?? '',

      presentacion: map['presentacion'] ?? '',

      fabricante: map['fabricante'] ?? '',

      precio: double.parse(map['precio'].toString()),

      stockActual: int.parse(map['stock_actual'].toString()),

      stockMinimo: int.parse(map['stock_minimo'].toString()),

      requiereRefrigeracion: map['requiere_refrigeracion'].toString() == '1',

      activo: map['activo'].toString() == '1',
    );
  }
}
