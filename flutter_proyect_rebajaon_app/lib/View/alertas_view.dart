import 'package:flutter/material.dart';
import '../DAO/alerta_dao.dart';
import '../models/alerta_model.dart';
import '../Temas/Estilos.dart';

class AlertasView extends StatefulWidget {
  const AlertasView({super.key});

  @override
  State<AlertasView> createState() => _AlertasViewState();
}

class _AlertasViewState extends State<AlertasView> with SingleTickerProviderStateMixin {
  final alertaDao = AlertaDao();

  List<AlertaModel> alertas = [];
  bool cargando = true;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    cargarAlertas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> cargarAlertas() async {
    try {
      final lista = await alertaDao.listarAlertas();
      setState(() {
        alertas = lista;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: const Text('Error al cargar alertas'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          backgroundColor: AppColors.primary,
        ));
    }
  }

  // ── Helpers de texto / color / ícono ─────────────────────────

  String _formatearTipo(String tipo) {
    switch (tipo) {
      case 'STOCK_MINIMO':         return 'Stock mínimo';
      case 'VENCIMIENTO_PROXIMO':  return 'Vencimiento próximo';
      case 'MEDICAMENTO_VENCIDO':  return 'Medicamento vencido';
      case 'CADENA_FRIO':          return 'Cadena de frío';
      default:                     return tipo.replaceAll('_', ' ');
    }
  }

  String _textoGravedad(AlertaModel a) {
    if (a.resulta) return 'Correcto';
    switch (a.nivelGravedad) {
      case 'CRITICO':     return 'Crítico';
      case 'ADVERTENCIA': return 'Advertencia';
      case 'INFO':        return 'Información';
      default:            return a.nivelGravedad;
    }
  }

  Color _colorFg(AlertaModel a) {
    if (a.resulta) return AppColors.secondaryDark;
    switch (a.nivelGravedad) {
      case 'CRITICO':     return AppColors.error;
      case 'ADVERTENCIA': return AppColors.warning;
      default:            return AppColors.primaryLight;
    }
  }

  Color _colorBg(AlertaModel a) {
    if (a.resulta) return AppColors.secondaryTint;
    switch (a.nivelGravedad) {
      case 'CRITICO':     return AppColors.errorTint;
      case 'ADVERTENCIA': return AppColors.warningTint;
      default:            return AppColors.primaryTint;
    }
  }

  IconData _icono(AlertaModel a) {
    if (a.resulta) return Icons.check_circle_outline;
    switch (a.nivelGravedad) {
      case 'CRITICO':     return Icons.error_outline;
      case 'ADVERTENCIA': return Icons.warning_amber_outlined;
      default:            return Icons.info_outline;
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'STOCK_MINIMO':         return Icons.inventory_2_outlined;
      case 'VENCIMIENTO_PROXIMO':  return Icons.event_outlined;
      case 'MEDICAMENTO_VENCIDO':  return Icons.remove_shopping_cart_outlined;
      case 'CADENA_FRIO':          return Icons.ac_unit;
      default:                     return Icons.notifications_outlined;
    }
  }

  // ── Listas filtradas por tab ──────────────────────────────────

  List<AlertaModel> get _todas => alertas;
  List<AlertaModel> get _criticas  => alertas.where((a) => !a.resulta && a.nivelGravedad == 'CRITICO').toList();
  List<AlertaModel> get _advertencias => alertas.where((a) => !a.resulta && a.nivelGravedad == 'ADVERTENCIA').toList();
  List<AlertaModel> get _resueltas => alertas.where((a) => a.resulta).toList();

  List<AlertaModel> get _alertasFiltradas {
    switch (_tabController.index) {
      case 1: return _criticas;
      case 2: return _advertencias;
      case 3: return _resueltas;
      default: return _todas;
    }
  }

  // ── Resumen chips ─────────────────────────────────────────────
  Widget _buildResumen() {
    final pendientes = alertas.where((a) => !a.resulta).length;
    final criticas   = _criticas.length;
    final advert     = _advertencias.length;
    final resueltas  = _resueltas.length;

    return Row(children: [
      _resumenChip(Icons.notifications_active_outlined, 'Pendientes', pendientes, AppColors.primary, AppColors.primaryTint),
      const SizedBox(width: 8),
      _resumenChip(Icons.error_outline, 'Críticas', criticas, AppColors.error, AppColors.errorTint),
      const SizedBox(width: 8),
      _resumenChip(Icons.warning_amber_outlined, 'Advertencias', advert, AppColors.warning, AppColors.warningTint),
      const SizedBox(width: 8),
      _resumenChip(Icons.check_circle_outline, 'Resueltas', resueltas, AppColors.secondary, AppColors.secondaryTint),
    ]);
  }

  Widget _resumenChip(IconData icon, String label, int count, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color)),
            Text(label, style: AppTextos.etiqueta),
          ]),
        ]),
      ),
    );
  }

  // ── Tarjeta de alerta ─────────────────────────────────────────
  Widget _buildTarjeta(AlertaModel a) {
    final fg = _colorFg(a);
    final bg = _colorBg(a);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          // Barra lateral de color
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: fg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Fila superior: tipo + badges
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Ícono tipo
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                    child: Icon(_iconoTipo(a.tipo), size: 18, color: fg),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_formatearTipo(a.tipo),
                          style: AppTextos.cuerpo.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(a.mensaje, style: AppTextos.apagado, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  // Badge gravedad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_icono(a), size: 13, color: fg),
                      const SizedBox(width: 4),
                      Text(
                        _textoGravedad(a),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg),
                      ),
                    ]),
                  ),
                ]),

                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.5, color: AppColors.inputBorder),
                const SizedBox(height: 8),

                // Fila inferior: estado + fecha si existe
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: a.resulta ? AppColors.secondaryTint : AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a.resulta ? '✓ Resuelta' : '● Pendiente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: a.resulta ? AppColors.secondaryDark : AppColors.primary,
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Lista vacía ───────────────────────────────────────────────
  Widget _buildVacio(String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(children: [
          Icon(Icons.notifications_none_outlined, size: 52, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 14),
          Text(mensaje, style: AppTextos.apagado),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════
  // BUILD PRINCIPAL
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final pendientes = alertas.where((a) => !a.resulta).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        title: Row(children: [
          const Icon(Icons.notifications_outlined, size: 20),
          const SizedBox(width: 8),
          const Text('Alertas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          if (pendientes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pendientes pendientes',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () {
              setState(() => cargando = true);
              cargarAlertas();
            },
            tooltip: 'Recargar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: 'Todas (${_todas.length})'),
            Tab(text: 'Críticas (${_criticas.length})'),
            Tab(text: 'Advertencias (${_advertencias.length})'),
            Tab(text: 'Resueltas (${_resueltas.length})'),
          ],
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              // Resumen fijo arriba
              if (alertas.isNotEmpty)
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: _buildResumen(),
                ),

              // Lista por tab
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLista(_todas,       'No hay alertas registradas'),
                    _buildLista(_criticas,    'No hay alertas críticas'),
                    _buildLista(_advertencias,'No hay advertencias'),
                    _buildLista(_resueltas,   'No hay alertas resueltas'),
                  ],
                ),
              ),
            ]),
    );
  }

  Widget _buildLista(List<AlertaModel> lista, String mensajeVacio) {
    if (lista.isEmpty) return _buildVacio(mensajeVacio);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: lista.length,
      itemBuilder: (_, i) => _buildTarjeta(lista[i]),
    );
  }
}