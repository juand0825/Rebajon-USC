import 'package:flutter/material.dart';
import '../DAO/reporte_dao.dart';
import '../models/reporte_model.dart';
import '../Temas/Estilos.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView>
    with SingleTickerProviderStateMixin {
  final reporteDao = ReporteDao();

  ReporteResumenModel? resumen;
  List<ReporteVentaProductoModel> productosVendidos = [];
  List<ReporteAlertaModel> alertas = [];
  List<ReporteLoteModel> lotes = [];
  List<ReporteInventarioModel> inventario = [];

  bool cargando = true;
  bool cargandoVentas = false;

  late final TabController _tabController;

  // Filtro de fechas para ventas
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    cargarReportes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> cargarReportes() async {
    try {
      final resumenData = await reporteDao.obtenerResumen();
      final productosData = await reporteDao.productosMasVendidos(
        fechaDesde: _fechaDesde,
        fechaHasta: _fechaHasta,
      );
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
      setState(() => cargando = false);
      _mostrarMensaje('Error al cargar reportes: $e');
    }
  }

  // Re-carga solo la sección de ventas cuando cambia el filtro de fecha
  Future<void> _recargarVentas() async {
    setState(() => cargandoVentas = true);
    try {
      final data = await reporteDao.productosMasVendidos(
        fechaDesde: _fechaDesde,
        fechaHasta: _fechaHasta,
      );
      setState(() {
        productosVendidos = data;
        cargandoVentas = false;
      });
    } catch (e) {
      setState(() => cargandoVentas = false);
      _mostrarMensaje('Error al filtrar ventas: $e');
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          backgroundColor: AppColors.primary,
        ),
      );
  }

  // ── Helpers ───────────────────────────────────────────────────
  String _dinero(double v) => '\$${v.toStringAsFixed(2)}';

  String _formatearTipo(String tipo) {
    switch (tipo) {
      case 'STOCK_MINIMO':
        return 'Stock mínimo';
      case 'VENCIMIENTO_PROXIMO':
        return 'Vencimiento próximo';
      case 'MEDICAMENTO_VENCIDO':
        return 'Medicamento vencido';
      case 'CADENA_FRIO':
        return 'Cadena de frío';
      default:
        return tipo.replaceAll('_', ' ');
    }
  }

  String _formatearFecha(DateTime? d) {
    if (d == null) return 'Sin límite';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Color _colorGravedad(String g) {
    switch (g) {
      case 'CRITICO':
        return AppColors.error;
      case 'ADVERTENCIA':
        return AppColors.warning;
      default:
        return AppColors.primaryLight;
    }
  }

  Color _bgGravedad(String g) {
    switch (g) {
      case 'CRITICO':
        return AppColors.errorTint;
      case 'ADVERTENCIA':
        return AppColors.warningTint;
      default:
        return AppColors.primaryTint;
    }
  }

  // ── Selector de fecha ─────────────────────────────────────────
  Future<void> _pickFecha({required bool esDesde}) async {
    final inicial = esDesde
        ? (_fechaDesde ?? DateTime.now())
        : (_fechaHasta ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
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

    if (picked == null) return;

    setState(() {
      if (esDesde) {
        _fechaDesde = picked;
        // Si la fecha hasta es anterior a la nueva desde, la resetea
        if (_fechaHasta != null && _fechaHasta!.isBefore(picked)) {
          _fechaHasta = null;
        }
      } else {
        _fechaHasta = picked;
        if (_fechaDesde != null && _fechaDesde!.isAfter(picked)) {
          _fechaDesde = null;
        }
      }
    });

    await _recargarVentas();
  }

  Future<void> _limpiarFiltro() async {
    setState(() {
      _fechaDesde = null;
      _fechaHasta = null;
    });
    await _recargarVentas();
  }

  // ══════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════

  // ── Tab 1: Resumen ────────────────────────────────────────────
  Widget _tabResumen() {
    final r = resumen!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen general', style: AppTextos.titulo),
          const SizedBox(height: 14),

          // Ventas e ingresos
          Row(
            children: [
              _kpiCard(
                Icons.point_of_sale_outlined,
                'Ventas realizadas',
                r.totalVentas.toString(),
                AppColors.primary,
                AppColors.primaryTint,
              ),
              const SizedBox(width: 10),
              _kpiCard(
                Icons.attach_money,
                'Ingresos totales',
                _dinero(r.totalIngresos),
                AppColors.secondaryDark,
                AppColors.secondaryTint,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kpiCard(
                Icons.shopping_cart_outlined,
                'Productos vendidos',
                r.totalProductosVendidos.toString(),
                AppColors.primaryLight,
                AppColors.primaryTint,
              ),
              const SizedBox(width: 10),
              _kpiCard(
                Icons.qr_code_outlined,
                'Lotes registrados',
                r.lotesRegistrados.toString(),
                AppColors.textMuted,
                AppColors.background,
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text('Estado de alertas', style: AppTextos.titulo),
          const SizedBox(height: 14),

          Row(
            children: [
              _kpiCard(
                Icons.notifications_active_outlined,
                'Alertas pendientes',
                r.alertasPendientes.toString(),
                AppColors.error,
                AppColors.errorTint,
              ),
              const SizedBox(width: 10),
              _kpiCard(
                Icons.check_circle_outline,
                'Alertas resueltas',
                r.alertasResueltas.toString(),
                AppColors.secondary,
                AppColors.secondaryTint,
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text('Estado del inventario', style: AppTextos.titulo),
          const SizedBox(height: 14),

          Row(
            children: [
              _kpiCard(
                Icons.error_outline,
                'Sin stock',
                r.medicamentosSinStock.toString(),
                AppColors.error,
                AppColors.errorTint,
              ),
              const SizedBox(width: 10),
              _kpiCard(
                Icons.warning_amber_outlined,
                'Stock mínimo',
                r.medicamentosStockMinimo.toString(),
                AppColors.warning,
                AppColors.warningTint,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(
    IconData icon,
    String label,
    String valor,
    Color color,
    Color bg,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  Text(label, style: AppTextos.etiqueta, maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Ventas por producto ────────────────────────────────
  Widget _tabVentas() {
    // Agrupar por fecha para mostrar secciones
    final Map<String, List<ReporteVentaProductoModel>> porFecha = {};
    for (final p in productosVendidos) {
      porFecha.putIfAbsent(p.fecha, () => []).add(p);
    }

    return Column(
      children: [
        // Barra de filtro de fecha
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filtrar por fecha',
                    style: AppTextos.etiqueta.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (_fechaDesde != null || _fechaHasta != null)
                    GestureDetector(
                      onTap: _limpiarFiltro,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorTint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _fechaBtn(
                      label: 'Desde',
                      fecha: _fechaDesde,
                      onTap: () => _pickFecha(esDesde: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _fechaBtn(
                      label: 'Hasta',
                      fecha: _fechaHasta,
                      onTap: () => _pickFecha(esDesde: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista
        Expanded(
          child: cargandoVentas
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : productosVendidos.isEmpty
              ? _buildVacio('No hay ventas en el período seleccionado')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: porFecha.length,
                  itemBuilder: (_, i) {
                    final fecha = porFecha.keys.elementAt(i);
                    final items = porFecha[fecha]!;
                    final totalDia = items.fold<double>(
                      0,
                      (s, p) => s + p.totalVendido,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabecera de fecha
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      fecha.isEmpty ? 'Sin fecha' : fecha,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _dinero(totalDia),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Items del día
                        ...items.map((p) => _tarjetaVenta(p)),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _fechaBtn({
    required String label,
    required DateTime? fecha,
    required VoidCallback onTap,
  }) {
    final activo = fecha != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: activo ? AppColors.primaryTint : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.inputBorder,
            width: activo ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: activo ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                activo ? _formatearFecha(fecha) : label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: activo ? FontWeight.w500 : FontWeight.w400,
                  color: activo ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaVenta(ReporteVentaProductoModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medication_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.medicamento,
                  style: AppTextos.cuerpo.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.cantidadVendida} unidades vendidas',
                  style: AppTextos.etiqueta,
                ),
              ],
            ),
          ),
          Text(
            _dinero(p.totalVendido),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Alertas ────────────────────────────────────────────
  Widget _tabAlertas() {
    if (alertas.isEmpty) {
      return _buildVacio('No hay alertas registradas');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: alertas.length,
      itemBuilder: (_, i) {
        final a = alertas[i];
        final color = _colorGravedad(a.gravedad);
        final bg = _bgGravedad(a.gravedad);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.warning_amber_outlined,
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatearTipo(a.tipo),
                                style: AppTextos.cuerpo.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${a.cantidad} alertas',
                                style: AppTextos.etiqueta,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            a.gravedad,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab 4: Lotes ──────────────────────────────────────────────
  Widget _tabLotes() {
    if (lotes.isEmpty) return _buildVacio('No hay lotes registrados');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: lotes.length,
      itemBuilder: (_, i) {
        final l = lotes[i];
        final pct = l.cantidadInicial > 0
            ? (l.cantidadDisponible / l.cantidadInicial).clamp(0.0, 1.0)
            : 0.0;
        final Color barColor = pct > 0.5
            ? AppColors.secondary
            : pct > 0.2
            ? AppColors.warning
            : AppColors.error;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.qr_code_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.medicamento,
                          style: AppTextos.cuerpo.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Lote: ${l.numeroLote}  ·  Vence: ${l.fechaVencimiento}',
                          style: AppTextos.etiqueta,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de stock
              Row(
                children: [
                  Text('Disponible: ', style: AppTextos.etiqueta),
                  Text(
                    '${l.cantidadDisponible}/${l.cantidadInicial}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: barColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: AppColors.inputBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
              const SizedBox(height: 8),
              Text('Código: ${l.codigoBarras}', style: AppTextos.etiqueta),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 5: Inventario ─────────────────────────────────────────
  Widget _tabInventario() {
    if (inventario.isEmpty) return _buildVacio('No hay inventario registrado');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: inventario.length,
      itemBuilder: (_, i) {
        final inv = inventario[i];
        final sinStock = inv.stockActual <= 0;
        final stockBajo = !sinStock && inv.stockActual <= inv.stockMinimo;
        final Color color = sinStock
            ? AppColors.error
            : stockBajo
            ? AppColors.warning
            : AppColors.secondary;
        final Color bg = sinStock
            ? AppColors.errorTint
            : stockBajo
            ? AppColors.warningTint
            : AppColors.secondaryTint;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.medicamento,
                      style: AppTextos.cuerpo.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stock: ${inv.stockActual}  ·  Mín: ${inv.stockMinimo}',
                      style: AppTextos.etiqueta,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _dinero(inv.precio),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sinStock
                          ? 'Sin stock'
                          : stockBajo
                          ? 'Stock mínimo'
                          : 'Disponible',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVacio(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 52,
              color: AppColors.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 14),
            Text(msg, style: AppTextos.apagado),
          ],
        ),
      ),
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
            const Icon(Icons.bar_chart_outlined, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Reportes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() => cargando = true);
              cargarReportes();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_outlined, size: 16),
              text: 'Resumen',
            ),
            Tab(
              icon: Icon(Icons.point_of_sale_outlined, size: 16),
              text: 'Ventas',
            ),
            Tab(
              icon: Icon(Icons.notifications_outlined, size: 16),
              text: 'Alertas',
            ),
            Tab(
              icon: Icon(Icons.inventory_2_outlined, size: 16),
              text: 'Lotes',
            ),
            Tab(
              icon: Icon(Icons.list_alt_outlined, size: 16),
              text: 'Inventario',
            ),
          ],
        ),
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : resumen == null
          ? Center(
              child: Text(
                'No se pudo cargar el reporte',
                style: AppTextos.apagado,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _tabResumen(),
                _tabVentas(),
                _tabAlertas(),
                _tabLotes(),
                _tabInventario(),
              ],
            ),
    );
  }
}
