import 'package:flutter/material.dart';

import '../Controllers/ventas_controller.dart';
import '../models/scanner_model.dart';

class VentasView extends StatefulWidget {
  const VentasView({super.key});

  @override
  State<VentasView> createState() => _VentasViewState();
}

class _VentasViewState extends State<VentasView> {
  final VentasController controller = VentasController();
  final TextEditingController codigoCtrl = TextEditingController();

  bool cargando = false;
  List<ScannerModel> resultadosBusqueda = [];

  @override
  void dispose() {
    codigoCtrl.dispose();
    super.dispose();
  }

  // ==========================================
  // BUSCAR MEDICAMENTO POR CÓDIGO
  // ==========================================
  Future<void> buscarMedicamento() async {
    final codigo = codigoCtrl.text.trim();

    if (codigo.isEmpty) return;

    setState(() {
      cargando = true;
    });

    final resultado = await controller.buscarMedicamento(codigo);

    setState(() {
      cargando = false;
    });

    if (resultado == null) {
      _mostrarMensaje('No se encontró el medicamento');
      return;
    }

    if (resultado.cantidadDisponible <= 0) {
      _mostrarMensaje('No hay stock disponible');
      return;
    }

    await _mostrarDialogoMedicamento(resultado);

    codigoCtrl.clear();

    setState(() {
      resultadosBusqueda = [];
    });
  }

  // ==========================================
  // BUSCAR POR NOMBRE
  // ==========================================
  Future<void> buscarPorNombre(String nombre) async {
    if (nombre.trim().isEmpty) {
      setState(() {
        resultadosBusqueda = [];
      });
      return;
    }

    final resultados = await controller.buscarMedicamentosPorNombre(nombre);

    setState(() {
      resultadosBusqueda = resultados;
    });
  }

  // ==========================================
  // DIÁLOGO DE DETALLES
  // ==========================================
  Future<void> _mostrarDialogoMedicamento(ScannerModel medicamento) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Medicamento Encontrado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre comercial: ${medicamento.nombre}'),
              const SizedBox(height: 8),
              Text('Precio: \$${medicamento.precio.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Principio activo: ${medicamento.principioActivo}'),
              const SizedBox(height: 8),
              Text('Presentación: ${medicamento.presentacion}'),
              const SizedBox(height: 8),
              Text('Laboratorio/Fabricante: ${medicamento.fabricante}'),
              const SizedBox(height: 8),
              Text('Lote: ${medicamento.numeroLote}'),
              const SizedBox(height: 8),
              Text('Fecha de vencimiento: ${medicamento.fechaVencimiento}'),
              const SizedBox(height: 8),
              Text('Stock disponible: ${medicamento.cantidadDisponible}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.agregarAlCarrito(medicamento);
              Navigator.pop(context);

              _mostrarMensaje('${medicamento.nombre} agregado al carrito');

              setState(() {});
            },
            child: const Text('Agregar al carrito'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FINALIZAR VENTA
  // ==========================================
  Future<void> finalizarVenta() async {
    if (controller.carrito.isEmpty) {
      _mostrarMensaje('El carrito está vacío');
      return;
    }

    try {
      await controller.finalizarVenta();

      setState(() {
        resultadosBusqueda = [];
      });

      _mostrarMensaje('Venta realizada correctamente');
    } catch (e) {
      _mostrarMensaje('Error al finalizar la venta');
    }
  }

  // ==========================================
  // ELIMINAR PRODUCTO COMPLETO
  // ==========================================
  void eliminarItem(int index) {
    setState(() {
      controller.eliminarDelCarrito(index);
    });
  }

  // ==========================================
  // QUITAR UNA UNIDAD
  // ==========================================
  void quitarUnaUnidad(int index) {
    setState(() {
      controller.quitarUnaUnidad(index);
    });
  }

  // ==========================================
  // MENSAJES
  // ==========================================
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ==========================================
  // LISTA DE MEDICAMENTOS
  // ==========================================
  Widget _buildListaMedicamentos() {
    if (resultadosBusqueda.isNotEmpty) {
      return _buildLista(resultadosBusqueda);
    }

    return FutureBuilder<List<ScannerModel>>(
      future: controller.scannerDao.listarMedicamentosDisponibles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final medicamentos = snapshot.data!;

        if (medicamentos.isEmpty) {
          return const Center(child: Text('No hay medicamentos disponibles'));
        }

        return _buildLista(medicamentos);
      },
    );
  }

  Widget _buildLista(List<ScannerModel> medicamentos) {
    return ListView.builder(
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        final med = medicamentos[index];

        return Card(
          child: ListTile(
            title: Text(med.nombre),
            subtitle: Text('Stock: ${med.cantidadDisponible}'),
            trailing: Text(
              '\$${med.precio.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await _mostrarDialogoMedicamento(med);
            },
          ),
        );
      },
    );
  }

  // ==========================================
  // PANEL IZQUIERDO
  // ==========================================
  Widget _buildBuscador() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buscar medicamento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: codigoCtrl,
              autofocus: true,
              onSubmitted: (_) => buscarMedicamento(),
              onChanged: buscarPorNombre,
              decoration: InputDecoration(
                labelText: 'Código de barras o nombre',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: buscarMedicamento,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: buscarMedicamento,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Buscar medicamento'),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Medicamentos disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(child: _buildListaMedicamentos()),

            if (cargando)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PANEL DERECHO - CARRITO
  // ==========================================
  Widget _buildCarrito() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Carrito de compras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            if (controller.carrito.isEmpty)
              const Expanded(
                child: Center(child: Text('El carrito está vacío')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: controller.carrito.length,
                  itemBuilder: (context, index) {
                    final item = controller.carrito[index];

                    return Card(
                      child: ListTile(
                        title: Text(item.nombre),
                        subtitle: Text(
                          '${item.cantidad} x \$${item.precio.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.orange,
                              ),
                              onPressed: () => quitarUnaUnidad(index),
                            ),
                            Text('\$${item.subtotal.toStringAsFixed(2)}'),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarItem(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const Divider(),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${controller.calcularTotal().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: finalizarVenta,
                icon: const Icon(Icons.check),
                label: const Text('Finalizar venta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // INTERFAZ PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildBuscador()),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildCarrito()),
          ],
        ),
      ),
    );
  }
}
