import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Controllers/ventas_controller.dart';
import '../Controllers/auth_controller.dart';
import '../models/scanner_model.dart';
import '../Temas/Estilos.dart';

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
  // BUSCAR MEDICAMENTO POR CÓDIGO DE BARRAS
  // ==========================================
  Future<void> buscarMedicamento() async {
    final codigo = codigoCtrl.text.trim();
    if (codigo.isEmpty) return;

    setState(() => cargando = true);

    final resultado = await controller.buscarMedicamento(codigo);

    setState(() => cargando = false);

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
    setState(() => resultadosBusqueda = []);
  }

  // ==========================================
  // BUSCAR POR NOMBRE
  // ==========================================
  Future<void> buscarPorNombre(String nombre) async {
    if (nombre.trim().isEmpty) {
      setState(() => resultadosBusqueda = []);
      return;
    }

    final resultados = await controller.buscarMedicamentosPorNombre(nombre);
    setState(() => resultadosBusqueda = resultados);
  }

  // ==========================================
  // DIÁLOGO DE MEDICAMENTO ENCONTRADO
  // ==========================================
  Future<void> _mostrarDialogoMedicamento(ScannerModel medicamento) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Medicamento encontrado', style: AppTextos.titulo),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              _infoRow(Icons.label_outline, 'Nombre comercial', medicamento.nombre),
              _infoRow(Icons.attach_money, 'Precio', '\$${medicamento.precio.toStringAsFixed(2)}', valueColor: AppColors.secondary),
              _infoRow(Icons.science_outlined, 'Principio activo', medicamento.principioActivo),
              _infoRow(Icons.inventory_2_outlined, 'Presentación', medicamento.presentacion),
              _infoRow(Icons.factory_outlined, 'Fabricante', medicamento.fabricante),
              _infoRow(Icons.qr_code, 'Lote', medicamento.numeroLote),
              _infoRow(Icons.event_outlined, 'Vencimiento', medicamento.fechaVencimiento),
              _stockRow(medicamento.cantidadDisponible),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final mensaje = controller.agregarAlCarrito(medicamento);
              Navigator.pop(context);
              _mostrarMensaje(mensaje ?? '${medicamento.nombre} agregado al carrito');
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Agregar al carrito'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label: ', style: AppTextos.apagado),
          Expanded(
            child: Text(
              value,
              style: AppTextos.cuerpo.copyWith(color: valueColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockRow(int stock) {
    final bool isLow = stock <= 10;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            isLow ? Icons.warning_amber_outlined : Icons.inventory_outlined,
            size: 16,
            color: isLow ? AppColors.warning : AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Text('Stock disponible: ', style: AppTextos.apagado),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isLow ? AppColors.warningTint : AppColors.secondaryTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$stock unidades',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isLow ? AppColors.warning : AppColors.secondaryDark,
              ),
            ),
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

    final auth = context.read<AuthController>();
    final idUsuario = auth.idUsuarioActual;

    if (idUsuario == null) {
      _mostrarMensaje('No se encontró el usuario en sesión');
      return;
    }

    try {
      final avisosStock = await controller.finalizarVenta(idUsuario: idUsuario);
      setState(() => resultadosBusqueda = []);

      if (avisosStock.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.warningTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Alerta de inventario'),
              ],
            ),
            content: Text(avisosStock.join('\n\n'), style: AppTextos.cuerpo),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        _mostrarMensaje('Venta realizada correctamente');
      }
    } catch (e) {
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ==========================================
  // MANEJO DEL CARRITO
  // ==========================================
  void eliminarItem(int index) => setState(() => controller.eliminarDelCarrito(index));

  void quitarUnaUnidad(int index) => setState(() => controller.quitarUnaUnidad(index));

  Future<void> agregarUnaUnidad(int index) async {
    final item = controller.carrito[index];
    final medicamento = await controller.buscarMedicamento(item.codigoBarras);

    if (medicamento == null) {
      _mostrarMensaje('No se encontró el medicamento');
      return;
    }

    final mensaje = controller.agregarAlCarrito(medicamento);
    if (mensaje != null) _mostrarMensaje(mensaje);
    setState(() {});
  }

  // ==========================================
  // MENSAJES
  // ==========================================
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje, style: const TextStyle(fontSize: 14)),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          backgroundColor: AppColors.primary,
        ),
      );
  }

  // ==========================================
  // STOCK ACTUALIZADO VISUALMENTE
  // ==========================================
  List<ScannerModel> _obtenerMedicamentosConStockActualizado(List<ScannerModel> medicamentos) {
    return medicamentos.map((med) {
      int cantidadEnCarrito = 0;
      for (final item in controller.carrito) {
        if (item.codigoBarras == med.codigoBarras) {
          cantidadEnCarrito = item.cantidad;
          break;
        }
      }
      return ScannerModel(
        idLote: med.idLote,
        idMedicamento: med.idMedicamento,
        nombre: med.nombre,
        codigoBarras: med.codigoBarras,
        precio: med.precio,
        stockMinimo: med.stockMinimo,
        cantidadDisponible: med.cantidadDisponible - cantidadEnCarrito,
        activo: med.activo,
        fechaVencimiento: med.fechaVencimiento,
        principioActivo: med.principioActivo,
        presentacion: med.presentacion,
        fabricante: med.fabricante,
        numeroLote: med.numeroLote,
        stockActual: med.stockActual,
        requiereRefrigeracion: med.requiereRefrigeracion,
      );
    }).toList();
  }

  // ==========================================
  // LISTA DE MEDICAMENTOS
  // ==========================================
  Widget _buildListaMedicamentos() {
    if (resultadosBusqueda.isNotEmpty) {
      return _buildLista(_obtenerMedicamentosConStockActualizado(resultadosBusqueda));
    }

    return FutureBuilder<List<ScannerModel>>(
      future: controller.scannerDao.listarMedicamentosDisponibles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final medicamentos = _obtenerMedicamentosConStockActualizado(snapshot.data!);

        if (medicamentos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text('No hay medicamentos disponibles', style: AppTextos.apagado),
              ],
            ),
          );
        }

        return _buildLista(medicamentos);
      },
    );
  }

  Widget _buildLista(List<ScannerModel> medicamentos) {
    return ListView.separated(
      itemCount: medicamentos.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5, color: AppColors.inputBorder),
      itemBuilder: (context, index) {
        final med = medicamentos[index];
        final bool isLowStock = med.cantidadDisponible > 0 && med.cantidadDisponible <= 10;
        final bool noStock = med.cantidadDisponible <= 0;

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: noStock
              ? null
              : () async {
                  final medicamentoReal = await controller.buscarMedicamento(med.codigoBarras);
                  if (medicamentoReal == null) {
                    _mostrarMensaje('No se encontró el medicamento');
                    return;
                  }
                  final mensaje = controller.agregarAlCarrito(medicamentoReal);
                  _mostrarMensaje(mensaje ?? '${med.nombre} agregado al carrito');
                  setState(() {});
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Ícono
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: noStock
                        ? AppColors.inputBorder.withOpacity(0.4)
                        : isLowStock
                            ? AppColors.warningTint
                            : AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    size: 20,
                    color: noStock
                        ? AppColors.textMuted
                        : isLowStock
                            ? AppColors.warning
                            : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.nombre,
                        style: AppTextos.cuerpo.copyWith(
                          fontWeight: FontWeight.w500,
                          color: noStock ? AppColors.textMuted : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(med.presentacion, style: AppTextos.etiqueta),
                    ],
                  ),
                ),

                // Stock badge
                if (isLowStock)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${med.cantidadDisponible} uds',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.warning),
                    ),
                  )
                else if (noStock)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Sin stock',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.error),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${med.cantidadDisponible} uds',
                      style: AppTextos.etiqueta,
                    ),
                  ),

                // Precio
                Text(
                  '\$${med.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // PANEL IZQUIERDO — BUSCADOR
  // ==========================================
  Widget _buildBuscador() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Buscar medicamento', style: AppTextos.titulo),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Campo de texto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: codigoCtrl,
              autofocus: true,
              onSubmitted: (_) => buscarMedicamento(),
              onChanged: buscarPorNombre,
              style: AppTextos.cuerpo,
              decoration: InputDecoration(
                hintText: 'Código de barras o nombre',
                hintStyle: AppTextos.apagado,
                prefixIcon: const Icon(Icons.qr_code_outlined, size: 20, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: buscarMedicamento,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Botón escanear
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: buscarMedicamento,
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Escanear código de barras'),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5, color: AppColors.inputBorder),

          // Cabecera lista
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Medicamentos disponibles', style: AppTextos.titulo.copyWith(fontSize: 15)),
                if (cargando)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
              ],
            ),
          ),

          // Lista expandida
          Expanded(child: _buildListaMedicamentos()),
        ],
      ),
    );
  }

  // ==========================================
  // PANEL DERECHO — CARRITO
  // ==========================================
  Widget _buildCarrito() {
    final total = controller.calcularTotal();
    final cantidadItems = controller.carrito.fold<int>(0, (sum, item) => sum + item.cantidad);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header carrito
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Carrito de compras', style: AppTextos.titulo),
                const SizedBox(width: 8),
                if (controller.carrito.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$cantidadItems',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, color: AppColors.inputBorder),

          // Lista del carrito
          if (controller.carrito.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 56, color: AppColors.textMuted.withOpacity(0.3)),
                    const SizedBox(height: 14),
                    Text('El carrito está vacío', style: AppTextos.apagado),
                    const SizedBox(height: 6),
                    Text('Agrega medicamentos desde el panel izquierdo', style: AppTextos.etiqueta),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.carrito.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: AppColors.inputBorder),
                itemBuilder: (context, index) {
                  final item = controller.carrito[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ícono
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.medication_outlined, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),

                        // Nombre + precio unitario
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nombre,
                                style: AppTextos.cuerpo.copyWith(fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${item.precio.toStringAsFixed(2)} / ud',
                                style: AppTextos.etiqueta,
                              ),
                            ],
                          ),
                        ),

                        // Controles cantidad
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _qtyBtn(
                              icon: Icons.remove,
                              color: AppColors.error,
                              bg: AppColors.errorTint,
                              onTap: () => quitarUnaUnidad(index),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '${item.cantidad}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            _qtyBtn(
                              icon: Icons.add,
                              color: AppColors.secondaryDark,
                              bg: AppColors.secondaryTint,
                              onTap: () => agregarUnaUnidad(index),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Subtotal
                        SizedBox(
                          width: 72,
                          child: Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryDark,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Eliminar
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.textMuted,
                          splashRadius: 18,
                          onPressed: () => eliminarItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Footer total + botón
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.inputBorder, width: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($cantidadItems ${cantidadItems == 1 ? "unidad" : "unidades"})',
                      style: AppTextos.cuerpo.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: controller.carrito.isEmpty ? null : finalizarVenta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.inputBorder,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Finalizar venta'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ==========================================
  // INTERFAZ PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 20),
            const SizedBox(width: 8),
            const Text('Ventas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('POS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildBuscador()),
            const SizedBox(width: 14),
            Expanded(flex: 3, child: _buildCarrito()),
          ],
        ),
      ),
    );
  }
}