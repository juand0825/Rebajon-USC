import 'package:flutter/material.dart';
import '../DAO/reporte_dao.dart';
import '../models/reporte_model.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  final reporteDao = ReporteDao();

  ReporteResumenModel? resumen;
  List<ReporteVentaProductoModel> productosVendidos = [];
  List<ReporteAlertaModel> alertas = [];
  List<ReporteLoteModel> lotes = [];
  List<ReporteInventarioModel> inventario = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarReportes();
  }

  Future<void> cargarReportes() async {
    try {
      final resumenData = await reporteDao.obtenerResumen();
      final productosData = await reporteDao.productosMasVendidos();
      final alertasData = await reporteDao.resumenAlertas();
      final lotesData = await reporteDao.lotesRegistrados();
      final inventarioData = await reporteDao.inventarioActual();

      setState(() {
        resumen = resumenData;
        productosVendidos = productosData;
        alertas = alertasData;
        lotes = lotesData;
        inventario = inventarioData;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar reportes: $e")));
    }
  }

  String formatoDinero(double valor) {
    return "\$${valor.toStringAsFixed(2)}";
  }

  String formatearTipo(String tipo) {
    return tipo.replaceAll('_', ' ');
  }

  Widget tarjetaResumen(String titulo, String valor, IconData icono) {
    return Card(
      child: ListTile(
        leading: Icon(icono, color: Colors.blue),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget seccion(String titulo, Widget contenido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          titulo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        contenido,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = resumen;

    return Scaffold(
      appBar: AppBar(title: const Text("Reportes")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : r == null
          ? const Center(child: Text("No se pudo cargar el reporte"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Ventas realizadas",
                          r.totalVentas.toString(),
                          Icons.point_of_sale,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Ingresos totales",
                          formatoDinero(r.totalIngresos),
                          Icons.attach_money,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Productos vendidos",
                          r.totalProductosVendidos.toString(),
                          Icons.shopping_cart,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Alertas pendientes",
                          r.alertasPendientes.toString(),
                          Icons.warning,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Alertas resueltas",
                          r.alertasResueltas.toString(),
                          Icons.check_circle,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Medicamentos sin stock",
                          r.medicamentosSinStock.toString(),
                          Icons.error,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Stock mínimo",
                          r.medicamentosStockMinimo.toString(),
                          Icons.inventory,
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: tarjetaResumen(
                          "Lotes registrados",
                          r.lotesRegistrados.toString(),
                          Icons.qr_code,
                        ),
                      ),
                    ],
                  ),

                  seccion(
                    "Medicamentos más vendidos",
                    productosVendidos.isEmpty
                        ? const Text("No hay ventas registradas")
                        : Column(
                            children: productosVendidos.map((p) {
                              return Card(
                                child: ListTile(
                                  title: Text(p.medicamento),
                                  subtitle: Text(
                                    "Cantidad vendida: ${p.cantidadVendida}",
                                  ),
                                  trailing: Text(
                                    formatoDinero(p.totalVendido),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  seccion(
                    "Alertas generadas",
                    alertas.isEmpty
                        ? const Text("No hay alertas registradas")
                        : Column(
                            children: alertas.map((a) {
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.warning),
                                  title: Text(formatearTipo(a.tipo)),
                                  subtitle: Text(
                                    "Gravedad: ${a.gravedad}\n"
                                    "Cantidad: ${a.cantidad}",
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  seccion(
                    "Lotes registrados",
                    lotes.isEmpty
                        ? const Text("No hay lotes registrados")
                        : Column(
                            children: lotes.map((l) {
                              return Card(
                                child: ListTile(
                                  title: Text(l.medicamento),
                                  subtitle: Text(
                                    "Lote: ${l.numeroLote}\n"
                                    "Cantidad inicial: ${l.cantidadInicial}\n"
                                    "Cantidad disponible: ${l.cantidadDisponible}\n"
                                    "Vence: ${l.fechaVencimiento}\n"
                                    "Código: ${l.codigoBarras}",
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  seccion(
                    "Inventario actual",
                    inventario.isEmpty
                        ? const Text("No hay inventario registrado")
                        : Column(
                            children: inventario.map((i) {
                              return Card(
                                child: ListTile(
                                  title: Text(i.medicamento),
                                  subtitle: Text(
                                    "Stock actual: ${i.stockActual}\n"
                                    "Stock mínimo: ${i.stockMinimo}\n"
                                    "Estado: ${i.activo ? "Activo" : "Inactivo"}",
                                  ),
                                  trailing: Text(
                                    formatoDinero(i.precio),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
