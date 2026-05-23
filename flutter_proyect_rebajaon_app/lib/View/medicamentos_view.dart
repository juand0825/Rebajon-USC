import 'package:flutter/material.dart';
import '../Controllers/medicamento_controller.dart';
import '../Temas/Estilos.dart';

class MedicamentosView extends StatefulWidget {
  const MedicamentosView({super.key});

  @override
  State<MedicamentosView> createState() => _MedicamentosViewState();
}

class _MedicamentosViewState extends State<MedicamentosView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final medicamentoController = MedicamentoController();

  // ── Medicamento ──────────────────────────────────────────
  final nombreCtrl = TextEditingController();
  final principioCtrl = TextEditingController();
  final presentacionCtrl = TextEditingController();
  final fabricanteCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final stockMinimoCtrl = TextEditingController();
  bool requiereRefrigeracion = false;
  bool activo = true;

  // ── Lote ─────────────────────────────────────────────────
  final loteCtrl = TextEditingController();
  final fechaFabCtrl = TextEditingController();
  final fechaVenCtrl = TextEditingController();
  final cantidadInicialCtrl = TextEditingController();
  final cantidadDisponibleCtrl = TextEditingController();
  final codigoCtrl = TextEditingController();

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    nombreCtrl.dispose();
    principioCtrl.dispose();
    presentacionCtrl.dispose();
    fabricanteCtrl.dispose();
    precioCtrl.dispose();
    stockMinimoCtrl.dispose();
    loteCtrl.dispose();
    fechaFabCtrl.dispose();
    fechaVenCtrl.dispose();
    cantidadInicialCtrl.dispose();
    cantidadDisponibleCtrl.dispose();
    codigoCtrl.dispose();
    super.dispose();
  }

  void _limpiar() {
    nombreCtrl.clear();
    principioCtrl.clear();
    presentacionCtrl.clear();
    fabricanteCtrl.clear();
    precioCtrl.clear();
    stockMinimoCtrl.clear();
    loteCtrl.clear();
    fechaFabCtrl.clear();
    fechaVenCtrl.clear();
    cantidadInicialCtrl.clear();
    cantidadDisponibleCtrl.clear();
    codigoCtrl.clear();
    setState(() {
      requiereRefrigeracion = false;
      activo = true;
    });
  }

  void _snack(String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? AppColors.error : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _guardar() async {
    // Validación campos obligatorios
    if (nombreCtrl.text.isEmpty ||
        precioCtrl.text.isEmpty ||
        stockMinimoCtrl.text.isEmpty ||
        loteCtrl.text.isEmpty ||
        cantidadInicialCtrl.text.isEmpty ||
        cantidadDisponibleCtrl.text.isEmpty) {
      _snack("Completa todos los campos obligatorios", esError: true);
      return;
    }

    final precio = double.tryParse(precioCtrl.text);
    final stockMinimo = int.tryParse(stockMinimoCtrl.text);
    final cantidadInicial = int.tryParse(cantidadInicialCtrl.text);
    final cantidadDisponible = int.tryParse(cantidadDisponibleCtrl.text);

    if (precio == null || stockMinimo == null ||
        cantidadInicial == null || cantidadDisponible == null) {
      _snack("Precio, stock y cantidades deben ser números válidos",
          esError: true);
      return;
    }

    if (cantidadDisponible > cantidadInicial) {
      _snack("La cantidad disponible no puede superar la inicial",
          esError: true);
      return;
    }

    setState(() => _guardando = true);

    try {
      await medicamentoController.guardarMedicamentoYLote(
        nombre: nombreCtrl.text.trim(),
        principioActivo: principioCtrl.text.trim(),
        presentacion: presentacionCtrl.text.trim(),
        fabricante: fabricanteCtrl.text.trim(),
        precio: precio,
        stockMinimo: stockMinimo,
        requiereRefrigeracion: requiereRefrigeracion,
        activo: activo,
        numeroLote: loteCtrl.text.trim(),
        fechaFabricacion: fechaFabCtrl.text.trim(),
        fechaVencimiento: fechaVenCtrl.text.trim(),
        cantidadInicial: cantidadInicial,
        cantidadDisponible: cantidadDisponible,
        codigoBarras: codigoCtrl.text.trim(),
      );

      _snack("✓ Medicamento y lote guardados correctamente");
      _limpiar();
    } catch (e) {
      _snack("Error al guardar: $e", esError: true);
    }

    setState(() => _guardando = false);
  }

  Future<void> _seleccionarFecha(TextEditingController ctrl) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (fecha != null) {
      ctrl.text =
          "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medication_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Medicamentos",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                Text("Registro y gestión",
                    style:
                        TextStyle(color: Color(0xFFB8D4F0), fontSize: 12)),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFB8D4F0),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(
                icon: Icon(Icons.medication_outlined, size: 18),
                text: "Medicamento"),
            Tab(
                icon: Icon(Icons.inventory_2_outlined, size: 18),
                text: "Lote"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _pestanaMedicamento(),
          _pestanaLote(),
        ],
      ),

      // ── BOTONES FLOTANTES ─────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
              top: BorderSide(color: AppColors.inputBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _limpiar,
                icon: const Icon(Icons.refresh_outlined, size: 18),
                label: const Text("Limpiar"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: AppColors.inputBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label:
                    Text(_guardando ? "Guardando..." : "Guardar todo"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // PESTAÑA MEDICAMENTO
  // ════════════════════════════════════════════════════════
  Widget _pestanaMedicamento() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),

              // Banner info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.15), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medication_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nuevo medicamento",
                              style: AppTextos.titulo),
                          SizedBox(height: 2),
                          Text(
                            "Completa la información del producto farmacéutico",
                            style: AppTextos.apagado,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Identificación ───────────────────────────
              _Seccion(
                label: "IDENTIFICACIÓN",
                child: Column(
                  children: [
                    _Campo(
                        controller: nombreCtrl,
                        label: "Nombre del medicamento *",
                        icono: Icons.medication_outlined),
                    const SizedBox(height: 12),
                    _Campo(
                        controller: principioCtrl,
                        label: "Principio activo",
                        icono: Icons.science_outlined),
                    const SizedBox(height: 12),
                    _Campo(
                        controller: presentacionCtrl,
                        label: "Presentación",
                        icono: Icons.category_outlined),
                    const SizedBox(height: 12),
                    _Campo(
                        controller: fabricanteCtrl,
                        label: "Fabricante",
                        icono: Icons.factory_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Precios y stock ──────────────────────────
              _Seccion(
                label: "PRECIO Y STOCK",
                child: Row(
                  children: [
                    Expanded(
                      child: _Campo(
                        controller: precioCtrl,
                        label: "Precio *",
                        icono: Icons.attach_money_outlined,
                        tipo: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefijo: "\$",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Campo(
                        controller: stockMinimoCtrl,
                        label: "Stock mínimo *",
                        icono: Icons.warning_amber_outlined,
                        tipo: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Configuración ────────────────────────────
              _Seccion(
                label: "CONFIGURACIÓN",
                child: Column(
                  children: [
                    _Switch(
                      valor: requiereRefrigeracion,
                      label: "Requiere refrigeración",
                      descripcion: "El medicamento debe mantenerse en frío",
                      icono: Icons.ac_unit_outlined,
                      color: AppColors.primaryLight,
                      onChanged: (v) =>
                          setState(() => requiereRefrigeracion = v),
                    ),
                    const Divider(height: 1, color: AppColors.inputBorder),
                    _Switch(
                      valor: activo,
                      label: "Medicamento activo",
                      descripcion: "Disponible para dispensación",
                      icono: Icons.check_circle_outline,
                      color: AppColors.secondary,
                      onChanged: (v) => setState(() => activo = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // PESTAÑA LOTE
  // ════════════════════════════════════════════════════════
  Widget _pestanaLote() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),

              // Banner info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.secondary.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inventory_2_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Datos del lote",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryDark)),
                          SizedBox(height: 2),
                          Text(
                            "Ingresa la información de trazabilidad del lote",
                            style: AppTextos.apagado,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Identificación lote ──────────────────────
              _Seccion(
                label: "IDENTIFICACIÓN DEL LOTE",
                child: Column(
                  children: [
                    _Campo(
                        controller: loteCtrl,
                        label: "Número de lote *",
                        icono: Icons.tag_outlined),
                    const SizedBox(height: 12),
                    _Campo(
                        controller: codigoCtrl,
                        label: "Código de barras",
                        icono: Icons.qr_code_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Fechas ───────────────────────────────────
              _Seccion(
                label: "FECHAS",
                child: Column(
                  children: [
                    _CampoFecha(
                      controller: fechaFabCtrl,
                      label: "Fecha de fabricación",
                      icono: Icons.calendar_today_outlined,
                      onTap: () => _seleccionarFecha(fechaFabCtrl),
                    ),
                    const SizedBox(height: 12),
                    _CampoFecha(
                      controller: fechaVenCtrl,
                      label: "Fecha de vencimiento",
                      icono: Icons.event_outlined,
                      onTap: () => _seleccionarFecha(fechaVenCtrl),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Cantidades ───────────────────────────────
              _Seccion(
                label: "CANTIDADES",
                child: Row(
                  children: [
                    Expanded(
                      child: _Campo(
                        controller: cantidadInicialCtrl,
                        label: "Cantidad inicial *",
                        icono: Icons.inventory_outlined,
                        tipo: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Campo(
                        controller: cantidadDisponibleCtrl,
                        label: "Cantidad disponible *",
                        icono: Icons.add_box_outlined,
                        tipo: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ════════════════════════════════════════════════════════════
class _Seccion extends StatelessWidget {
  final String label;
  final Widget child;
  const _Seccion({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(label, style: AppTextos.etiqueta),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final TextInputType tipo;
  final String? prefijo;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icono,
    this.tipo = TextInputType.text,
    this.prefijo,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: AppColors.textMuted, size: 20),
        prefixText: prefijo,
        prefixStyle: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _CampoFecha extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final VoidCallback onTap;

  const _CampoFecha({
    required this.controller,
    required this.label,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: AppColors.textMuted, size: 20),
        suffixIcon: const Icon(Icons.chevron_right,
            color: AppColors.textMuted, size: 20),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool valor;
  final String label;
  final String descripcion;
  final IconData icono;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _Switch({
    required this.valor,
    required this.label,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: valor ? color.withOpacity(0.12) : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono,
                color: valor ? color : AppColors.textMuted, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: valor
                            ? AppColors.textPrimary
                            : AppColors.textMuted)),
                Text(descripcion,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: color,
            trackOutlineColor:
                WidgetStateProperty.all(AppColors.inputBorder),
          ),
        ],
      ),
    );
  }
}