import 'package:flutter/material.dart';
import '../DAO/medicamento_dao.dart';
import '../models/medicamento_model.dart';
import '../Controllers/temperatura_controller.dart';
import '../Controllers/alerta_controller.dart';
import '../DAO/lote_dao.dart';
import '../Controllers/medicamento_controller.dart';
import '../Temas/Estilos.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> with SingleTickerProviderStateMixin {
  final medicamentoDao = MedicamentoDao();
  final temperaturaController = TemperaturaController();
  final alertaController = AlertaController();
  final loteDao = LoteDao();
  final medicamentoController = MedicamentoController();

  late final TabController _tabController;

  List<MedicamentoModel> medicamentos = [];
  bool cargando = true;

  String busquedaInventario = '';
  final buscarInventarioCtrl = TextEditingController();

  MedicamentoModel? medicamentoSeleccionado;
  final temperaturaCtrl = TextEditingController();
  final rangoMinCtrl = TextEditingController();
  final rangoMaxCtrl = TextEditingController();

  MedicamentoModel? medicamentoLoteSeleccionado;
  final loteCtrl = TextEditingController();
  final fechaFabCtrl = TextEditingController();
  final fechaVenCtrl = TextEditingController();
  final cantidadInicialCtrl = TextEditingController();
  final cantidadDisponibleCtrl = TextEditingController();
  final codigoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    cargarMedicamentos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    buscarInventarioCtrl.dispose();
    temperaturaCtrl.dispose();
    rangoMinCtrl.dispose();
    rangoMaxCtrl.dispose();
    loteCtrl.dispose();
    fechaFabCtrl.dispose();
    fechaVenCtrl.dispose();
    cantidadInicialCtrl.dispose();
    cantidadDisponibleCtrl.dispose();
    codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> cargarMedicamentos() async {
    try {
      final lista = await medicamentoDao.listarMedicamentos();
      setState(() {
        medicamentos = lista;
        cargando = false;
      });

      final lotes = await loteDao.listarLotes();

      for (var medicamento in lista) {
        await alertaController.generarAlertaStockMinimo(
          idMedicamento: medicamento.id!,
          nombreMedicamento: medicamento.nombre,
          stockActual: medicamento.stockActual,
          stockMinimo: medicamento.stockMinimo,
        );
      }

      for (var lote in lotes) {
        final encontrados = lista.where((m) => m.id == lote.idMedicamento);
        if (encontrados.isEmpty) continue;

        final medicamento = encontrados.first;
        final fechaVencimiento = DateTime.tryParse(lote.fechaVencimiento);
        if (fechaVencimiento == null) continue;

        await alertaController.generarAlertaVencimientoProximo(
          idMedicamento: lote.idMedicamento,
          idLote: lote.id!,
          nombreMedicamento: medicamento.nombre,
          fechaVencimiento: fechaVencimiento,
        );
        await alertaController.generarAlertaMedicamentoVencido(
          idMedicamento: lote.idMedicamento,
          idLote: lote.id!,
          nombreMedicamento: medicamento.nombre,
          fechaVencimiento: fechaVencimiento,
        );
      }
    } catch (e) {
      setState(() => cargando = false);
      mostrarMensaje('Error al cargar inventario: $e');
    }
  }

  List<MedicamentoModel> get medicamentosFiltrados {
    final texto = busquedaInventario.trim().toLowerCase();
    if (texto.isEmpty) return medicamentos;
    return medicamentos.where((m) {
      return m.nombre.toLowerCase().contains(texto) ||
          m.principioActivo.toLowerCase().contains(texto) ||
          m.presentacion.toLowerCase().contains(texto) ||
          m.fabricante.toLowerCase().contains(texto);
    }).toList();
  }

  List<MedicamentoModel> get medicamentosRefrigerados =>
      medicamentos.where((m) => m.requiereRefrigeracion).toList();

  // ── Semáforo de stock ──────────────────────────────────────────
  Color _colorStock(MedicamentoModel m) {
    if (m.stockActual <= 0) return AppColors.error;
    if (m.stockActual <= m.stockMinimo) return AppColors.warning;
    return AppColors.secondary;
  }

  Color _bgStock(MedicamentoModel m) {
    if (m.stockActual <= 0) return AppColors.errorTint;
    if (m.stockActual <= m.stockMinimo) return AppColors.warningTint;
    return AppColors.secondaryTint;
  }

  IconData _iconStock(MedicamentoModel m) {
    if (m.stockActual <= 0) return Icons.error_outline;
    if (m.stockActual <= m.stockMinimo) return Icons.warning_amber_outlined;
    return Icons.check_circle_outline;
  }

  String _textoStock(MedicamentoModel m) {
    if (m.stockActual <= 0) return 'Sin stock';
    if (m.stockActual <= m.stockMinimo) return 'Stock mínimo';
    return 'Disponible';
  }

  // ── Mensajes ──────────────────────────────────────────────────
  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(mensaje, style: const TextStyle(fontSize: 14)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        backgroundColor: AppColors.primary,
      ));
  }

  // ── Diálogo stock actualizado ─────────────────────────────────
  Future<void> mostrarDialogoStockActualizado(MedicamentoModel medicamento) async {
    final ok = medicamento.stockActual > medicamento.stockMinimo;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ok ? AppColors.secondaryTint : AppColors.warningTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              ok ? Icons.inventory_2_outlined : Icons.warning_amber_outlined,
              color: ok ? AppColors.secondary : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text('Stock actualizado', style: AppTextos.titulo),
        ]),
        content: Text(
          ok
              ? 'El stock de ${medicamento.nombre} fue actualizado correctamente.'
              : 'El stock de ${medicamento.nombre} fue actualizado.',
          style: AppTextos.cuerpo,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // ── Guardar lote ──────────────────────────────────────────────
  Future<void> guardarNuevoLote() async {
    if (medicamentoLoteSeleccionado == null ||
        loteCtrl.text.isEmpty ||
        fechaVenCtrl.text.isEmpty ||
        cantidadInicialCtrl.text.isEmpty ||
        cantidadDisponibleCtrl.text.isEmpty ||
        codigoCtrl.text.isEmpty) {
      mostrarMensaje('Completa los campos obligatorios del lote');
      return;
    }

    final cantidadInicial = int.tryParse(cantidadInicialCtrl.text);
    final cantidadDisponible = int.tryParse(cantidadDisponibleCtrl.text);

    if (cantidadInicial == null || cantidadDisponible == null) {
      mostrarMensaje('Las cantidades del lote deben ser números válidos');
      return;
    }
    if (cantidadDisponible > cantidadInicial) {
      mostrarMensaje('La cantidad disponible no puede ser mayor que la inicial');
      return;
    }

    try {
      final idMedicamento = medicamentoLoteSeleccionado!.id!;
      await medicamentoController.guardarLoteAMedicamentoExistente(
        idMedicamento: idMedicamento,
        numeroLote: loteCtrl.text.trim(),
        fechaFabricacion: fechaFabCtrl.text.trim(),
        fechaVencimiento: fechaVenCtrl.text.trim(),
        cantidadInicial: cantidadInicial,
        cantidadDisponible: cantidadDisponible,
        codigoBarras: codigoCtrl.text.trim(),
      );

      final actualizado = await medicamentoDao.buscarPorId(idMedicamento);
      if (actualizado != null) {
        await alertaController.resolverAlertaStockMinimoSiCorresponde(
          idMedicamento: actualizado.id!,
          stockActual: actualizado.stockActual,
          stockMinimo: actualizado.stockMinimo,
        );
        await mostrarDialogoStockActualizado(actualizado);
      } else {
        mostrarMensaje('Lote agregado correctamente');
      }

      loteCtrl.clear();
      fechaFabCtrl.clear();
      fechaVenCtrl.clear();
      cantidadInicialCtrl.clear();
      cantidadDisponibleCtrl.clear();
      codigoCtrl.clear();
      setState(() {
        medicamentoLoteSeleccionado = null;
        cargando = true;
      });
      await cargarMedicamentos();
    } catch (e) {
      mostrarMensaje('Error al agregar lote: $e');
    }
  }

  // ── Guardar temperatura ───────────────────────────────────────
  Future<void> guardarTemperatura() async {
    if (medicamentoSeleccionado == null ||
        temperaturaCtrl.text.isEmpty ||
        rangoMinCtrl.text.isEmpty ||
        rangoMaxCtrl.text.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    final temperatura = double.tryParse(temperaturaCtrl.text);
    final rangoMin = double.tryParse(rangoMinCtrl.text);
    final rangoMax = double.tryParse(rangoMaxCtrl.text);

    if (temperatura == null || rangoMin == null || rangoMax == null) {
      mostrarMensaje('La temperatura y los rangos deben ser números');
      return;
    }

    try {
      await temperaturaController.guardarTemperatura(
        idMedicamento: medicamentoSeleccionado!.id!,
        temperatura: temperatura,
        rangoMin: rangoMin,
        rangoMax: rangoMax,
      );

      final mensajeCadenaFrio = await alertaController.generarAlertaCadenaFrio(
        idMedicamento: medicamentoSeleccionado!.id!,
        nombreMedicamento: medicamentoSeleccionado!.nombre,
        temperatura: temperatura,
        rangoMin: rangoMin,
        rangoMax: rangoMax,
      );

      if (mensajeCadenaFrio != null) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.errorTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.device_thermostat, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Alerta de cadena frío', style: AppTextos.titulo),
            ]),
            content: Text(mensajeCadenaFrio, style: AppTextos.cuerpo),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }

      final fueraDeRango = temperatura < rangoMin || temperatura > rangoMax;
      mostrarMensaje(fueraDeRango ? 'Temperatura fuera de rango' : 'Temperatura guardada correctamente');

      temperaturaCtrl.clear();
      rangoMinCtrl.clear();
      rangoMaxCtrl.clear();
      setState(() => medicamentoSeleccionado = null);
    } catch (e) {
      mostrarMensaje('Error al guardar temperatura: $e');
    }
  }

  // ══════════════════════════════════════════
  // WIDGETS DE UI
  // ══════════════════════════════════════════

  Widget _campo(String label, TextEditingController ctrl, {TextInputType? tipo, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: tipo,
        style: AppTextos.cuerpo,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: AppTextos.apagado,
        ),
      ),
    );
  }

  Widget _stockBadge(MedicamentoModel m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgStock(m),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconStock(m), size: 14, color: _colorStock(m)),
          const SizedBox(width: 5),
          Text(
            _textoStock(m),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _colorStock(m)),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaMedicamento(MedicamentoModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.nombre, style: AppTextos.cuerpo.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('${m.presentacion} · ${m.fabricante}', style: AppTextos.etiqueta),
                    ],
                  ),
                ),
                _stockBadge(m),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5, color: AppColors.inputBorder),
            const SizedBox(height: 10),

            // Fila de stats
            Row(
              children: [
                _statChip(Icons.inventory_2_outlined, 'Stock actual', '${m.stockActual}'),
                const SizedBox(width: 8),
                _statChip(Icons.arrow_downward, 'Stock mínimo', '${m.stockMinimo}'),
                const SizedBox(width: 8),
                if (m.requiereRefrigeracion)
                  _statChip(Icons.ac_unit, 'Refrigeración', 'Sí', color: AppColors.primaryLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value, {Color? color}) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 5),
          Text('$label: ', style: AppTextos.etiqueta),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c)),
        ],
      ),
    );
  }

  // ── Resumen top ───────────────────────────────────────────────
  Widget _buildResumen() {
    final sinStock = medicamentos.where((m) => m.stockActual <= 0).length;
    final critico = medicamentos.where((m) => m.stockActual > 0 && m.stockActual <= m.stockMinimo).length;
    final ok = medicamentos.where((m) => m.stockActual > m.stockMinimo).length;

    return Row(
      children: [
        _resumenCard(Icons.check_circle_outline, 'Disponibles', '$ok', AppColors.secondary, AppColors.secondaryTint),
        const SizedBox(width: 10),
        _resumenCard(Icons.warning_amber_outlined, 'Stock mínimo', '$critico', AppColors.warning, AppColors.warningTint),
        const SizedBox(width: 10),
        _resumenCard(Icons.error_outline, 'Sin stock', '$sinStock', AppColors.error, AppColors.errorTint),
        const SizedBox(width: 10),
        _resumenCard(Icons.ac_unit, 'Refrigerados', '${medicamentosRefrigerados.length}', AppColors.primaryLight, AppColors.primaryTint),
      ],
    );
  }

  Widget _resumenCard(IconData icon, String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: color)),
                Text(label, style: AppTextos.etiqueta),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab: Inventario ───────────────────────────────────────────
  Widget _tabInventario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildResumen(),
        const SizedBox(height: 16),

        // Buscador
        TextField(
          controller: buscarInventarioCtrl,
          style: AppTextos.cuerpo,
          onChanged: (v) => setState(() => busquedaInventario = v),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, principio activo, presentación…',
            hintStyle: AppTextos.apagado,
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
            suffixIcon: busquedaInventario.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                    onPressed: () {
                      buscarInventarioCtrl.clear();
                      setState(() => busquedaInventario = '');
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 14),

        if (medicamentosFiltrados.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No hay medicamentos registrados', style: AppTextos.apagado),
                ],
              ),
            ),
          )
        else
          ...medicamentosFiltrados.map(_tarjetaMedicamento),
      ],
    );
  }

  // ── Tab: Nuevo lote ───────────────────────────────────────────
  Widget _tabNuevoLote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _seccionHeader(Icons.add_box_outlined, 'Agregar lote a medicamento existente'),
        const SizedBox(height: 16),

        // Dropdown medicamento
        DropdownButtonFormField<MedicamentoModel>(
          value: medicamentoLoteSeleccionado,
          style: AppTextos.cuerpo,
          decoration: InputDecoration(
            labelText: 'Medicamento',
            labelStyle: AppTextos.apagado,
            prefixIcon: const Icon(Icons.medication_outlined, size: 20, color: AppColors.textMuted),
          ),
          items: medicamentos.where((m) => m.activo).map((m) {
            return DropdownMenuItem(value: m, child: Text(m.nombre));
          }).toList(),
          onChanged: (v) => setState(() => medicamentoLoteSeleccionado = v),
        ),
        const SizedBox(height: 12),

        _campo('Número de lote', loteCtrl),
        _campo('Fecha de fabricación', fechaFabCtrl, hint: 'YYYY-MM-DD'),
        _campo('Fecha de vencimiento *', fechaVenCtrl, hint: 'YYYY-MM-DD'),
        _campo('Cantidad inicial *', cantidadInicialCtrl, tipo: TextInputType.number),
        _campo('Cantidad disponible *', cantidadDisponibleCtrl, tipo: TextInputType.number),
        _campo('Código de barras *', codigoCtrl),

        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: guardarNuevoLote,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar lote'),
          ),
        ),
      ],
    );
  }

  // ── Tab: Temperatura ──────────────────────────────────────────
  Widget _tabTemperatura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _seccionHeader(Icons.device_thermostat, 'Registro de temperatura'),
        const SizedBox(height: 16),

        // Info banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Solo se muestran medicamentos que requieren refrigeración.',
                  style: AppTextos.etiqueta.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<MedicamentoModel>(
          value: medicamentoSeleccionado,
          style: AppTextos.cuerpo,
          decoration: InputDecoration(
            labelText: 'Medicamento refrigerado',
            labelStyle: AppTextos.apagado,
            prefixIcon: const Icon(Icons.ac_unit, size: 20, color: AppColors.primaryLight),
          ),
          items: medicamentosRefrigerados.map((m) {
            return DropdownMenuItem(value: m, child: Text(m.nombre));
          }).toList(),
          onChanged: (v) => setState(() => medicamentoSeleccionado = v),
        ),
        const SizedBox(height: 12),

        _campo('Temperatura actual (°C)', temperaturaCtrl, tipo: TextInputType.number),
        _campo('Rango mínimo (°C)', rangoMinCtrl, tipo: TextInputType.number),
        _campo('Rango máximo (°C)', rangoMaxCtrl, tipo: TextInputType.number),

        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: guardarTemperatura,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Guardar temperatura'),
          ),
        ),
      ],
    );
  }

  Widget _seccionHeader(IconData icon, String titulo) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(titulo, style: AppTextos.titulo),
      ],
    );
  }

  // ══════════════════════════════════════════
  // BUILD PRINCIPAL
  // ══════════════════════════════════════════
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
            const Icon(Icons.inventory_2_outlined, size: 20),
            const SizedBox(width: 8),
            const Text('Inventario', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${medicamentos.length} productos',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt_outlined, size: 18), text: 'Inventario'),
            Tab(icon: Icon(Icons.add_box_outlined, size: 18), text: 'Nuevo lote'),
            Tab(icon: Icon(Icons.device_thermostat, size: 18), text: 'Temperatura'),
          ],
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Inventario
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: _tabInventario(),
                ),
                // Tab 2: Nuevo lote
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: _tabNuevoLote(),
                ),
                // Tab 3: Temperatura
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: _tabTemperatura(),
                ),
              ],
            ),
    );
  }
}