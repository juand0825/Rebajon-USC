class VentaItemModel {
  final int idLote;
  final int idMedicamento;
  final String nombre;
  final String codigoBarras;
  final double precio;
  final int stockMinimo;
  int cantidad;

  VentaItemModel({
    required this.idLote,
    required this.idMedicamento,
    required this.nombre,
    required this.codigoBarras,
    required this.precio,
    required this.stockMinimo,
    required this.cantidad,
  });

  double get subtotal => precio * cantidad;
}
