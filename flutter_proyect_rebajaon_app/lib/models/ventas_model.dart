class VentaItemModel {
  final int idLote;
  final String nombre;
  final String codigoBarras;
  final double precio;
  int cantidad;

  VentaItemModel({
    required this.idLote,
    required this.nombre,
    required this.codigoBarras,
    required this.precio,
    required this.cantidad,
  });

  double get subtotal => precio * cantidad;
}
