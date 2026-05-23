import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/auth_controller.dart';
import '../Models/usuario_model.dart';
import '../Temas/Estilos.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _emailCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _numIdentificacionCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  String _rolSeleccionado = 'farmaceutico';
  bool _verClave = false;
  bool _verCodigo = false;

  static const String _codigoFarma = "110537";
  static const String _codigoAdmin = "944157";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().cargarUsuarios();
    });

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        context.read<AuthController>().cargarUsuarios();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _claveCtrl.dispose();
    _numIdentificacionCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  void _intentarRegistrar(BuildContext context, AuthController auth) {
    if (_emailCtrl.text.isEmpty ||
        _claveCtrl.text.isEmpty ||
        _numIdentificacionCtrl.text.isEmpty ||
        _codigoCtrl.text.isEmpty) {
      _mostrarSnack(
        context,
        "Por favor completa todos los campos",
        esError: true,
      );
      return;
    }

    final codigoValido =
        (_rolSeleccionado == 'farmaceutico' &&
            _codigoCtrl.text == _codigoFarma) ||
        (_rolSeleccionado == 'admin' && _codigoCtrl.text == _codigoAdmin);

    if (!codigoValido) {
      _mostrarSnack(context, "Código de acceso incorrecto", esError: true);
      return;
    }

    auth.register(
      _emailCtrl.text.trim(),
      _claveCtrl.text,
      _numIdentificacionCtrl.text.trim(),
      _rolSeleccionado,
    );
  }

  void _mostrarSnack(BuildContext context, String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? AppColors.error : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.registrado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarSnack(context, "✓ Usuario registrado exitosamente");
        auth.resetRegistrado();
        _emailCtrl.clear();
        _claveCtrl.clear();
        _numIdentificacionCtrl.clear();
        _codigoCtrl.clear();
        setState(() => _rolSeleccionado = 'farmaceutico');
        _tabController.animateTo(1);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
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
              child: const Icon(
                Icons.manage_accounts_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gestión de usuarios",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Panel de administración",
                  style: TextStyle(color: Color(0xFFB8D4F0), fontSize: 12),
                ),
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
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.person_add_outlined, size: 18),
              text: "Nuevo usuario",
            ),
            Tab(
              icon: Icon(Icons.people_outline, size: 18),
              text: "Usuarios registrados",
            ),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _PanelRegistro(
            emailCtrl: _emailCtrl,
            claveCtrl: _claveCtrl,
            numIdCtrl: _numIdentificacionCtrl,
            codigoCtrl: _codigoCtrl,
            rolSeleccionado: _rolSeleccionado,
            verClave: _verClave,
            verCodigo: _verCodigo,
            onRolChanged: (v) => setState(() => _rolSeleccionado = v!),
            onVerClaveToggle: () => setState(() => _verClave = !_verClave),
            onVerCodigoToggle: () => setState(() => _verCodigo = !_verCodigo),
            onRegistrar: () => _intentarRegistrar(context, auth),
            auth: auth,
          ),
          const _PanelUsuarios(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// PANEL REGISTRO
// ════════════════════════════════════════════════════════════
class _PanelRegistro extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController claveCtrl;
  final TextEditingController numIdCtrl;
  final TextEditingController codigoCtrl;
  final String rolSeleccionado;
  final bool verClave;
  final bool verCodigo;
  final ValueChanged<String?> onRolChanged;
  final VoidCallback onVerClaveToggle;
  final VoidCallback onVerCodigoToggle;
  final VoidCallback onRegistrar;
  final AuthController auth;

  const _PanelRegistro({
    required this.emailCtrl,
    required this.claveCtrl,
    required this.numIdCtrl,
    required this.codigoCtrl,
    required this.rolSeleccionado,
    required this.verClave,
    required this.verCodigo,
    required this.onRolChanged,
    required this.onVerClaveToggle,
    required this.onVerCodigoToggle,
    required this.onRegistrar,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Crear nuevo usuario", style: AppTextos.titulo),
                          SizedBox(height: 2),
                          Text(
                            "Completa los datos para registrar el acceso",
                            style: AppTextos.apagado,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _Seccion(
                label: "DATOS DE ACCESO",
                child: Column(
                  children: [
                    _Campo(
                      controller: emailCtrl,
                      label: "Correo electrónico",
                      icono: Icons.email_outlined,
                      tipo: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: claveCtrl,
                      obscureText: !verClave,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            verClave
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: onVerClaveToggle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _Seccion(
                label: "DATOS PERSONALES",
                child: _Campo(
                  controller: numIdCtrl,
                  label: "Número de identificación",
                  icono: Icons.badge_outlined,
                  tipo: TextInputType.number,
                  maxLength: 10,
                ),
              ),

              const SizedBox(height: 16),

              _Seccion(
                label: "ROL Y AUTORIZACIÓN",
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: "Rol del usuario",
                        prefixIcon: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'farmaceutico',
                          child: Text("Farmacéutico"),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text("Administrador"),
                        ),
                      ],
                      onChanged: onRolChanged,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codigoCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: !verCodigo,
                      decoration: InputDecoration(
                        labelText: "Código de acceso",
                        prefixIcon: const Icon(
                          Icons.key_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            verCodigo
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: onVerCodigoToggle,
                        ),
                        helperText:
                            "Ingresa el código correspondiente al rol seleccionado",
                        helperStyle: AppTextos.etiqueta,
                      ),
                    ),
                  ],
                ),
              ),

              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorTint,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          auth.error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: auth.cargando ? null : onRegistrar,
                  icon: auth.cargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    auth.cargando ? "Registrando..." : "Crear usuario",
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// PANEL USUARIOS REGISTRADOS
// ════════════════════════════════════════════════════════════
class _PanelUsuarios extends StatelessWidget {
  const _PanelUsuarios();

  void _mostrarSnack(BuildContext context, String msg, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? AppColors.error : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── DIÁLOGO CONFIRMAR ELIMINACIÓN ────────────────────────
  Future<void> _confirmarEliminar(
    BuildContext context,
    AuthController auth,
    UsuarioModel u,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Eliminar usuario",
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Estás seguro de que deseas eliminar a:",
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      u.email,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Esta acción no se puede deshacer.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text("Eliminar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final ok = await auth.eliminarUsuario(u.id);
      if (context.mounted) {
        _mostrarSnack(
          context,
          ok ? "Usuario eliminado" : (auth.error ?? "Error al eliminar"),
          esError: !ok,
        );
      }
    }
  }

  // ── DIÁLOGO EDITAR ───────────────────────────────────────
  Future<void> _abrirEditar(
    BuildContext context,
    AuthController auth,
    UsuarioModel u,
  ) async {
    final emailCtrl = TextEditingController(text: u.email);
    final numIdCtrl = TextEditingController(text: u.numIdentificacion);
    final claveCtrl = TextEditingController();
    String rolSeleccionado = u.rol;
    bool verClave = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Editar usuario",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),

                  // Email
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Num identificación
                  TextField(
                    controller: numIdCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: "Número de identificación",
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rol
                  DropdownButtonFormField<String>(
                    value: rolSeleccionado,
                    decoration: const InputDecoration(
                      labelText: "Rol",
                      prefixIcon: Icon(
                        Icons.admin_panel_settings_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'farmaceutico',
                        child: Text("Farmacéutico"),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text("Administrador"),
                      ),
                    ],
                    onChanged: (v) =>
                        setStateDialog(() => rolSeleccionado = v!),
                  ),
                  const SizedBox(height: 12),

                  // Nueva clave (opcional)
                  TextField(
                    controller: claveCtrl,
                    obscureText: !verClave,
                    decoration: InputDecoration(
                      labelText: "Nueva contraseña (opcional)",
                      helperText: "Déjala vacía para no cambiarla",
                      helperStyle: AppTextos.etiqueta,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          verClave
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () =>
                            setStateDialog(() => verClave = !verClave),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (emailCtrl.text.isEmpty || numIdCtrl.text.isEmpty) {
                  return;
                }
                Navigator.pop(ctx);
                final ok = await auth.actualizarUsuario(
                  id: u.id,
                  email: emailCtrl.text.trim(),
                  numIdentificacion: numIdCtrl.text.trim(),
                  rol: rolSeleccionado,
                  nuevaClave: claveCtrl.text.isEmpty ? null : claveCtrl.text,
                );
                if (context.mounted) {
                  _mostrarSnack(
                    context,
                    ok
                        ? "✓ Usuario actualizado"
                        : (auth.error ?? "Error al actualizar"),
                    esError: !ok,
                  );
                }
              },
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text("Guardar"),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    emailCtrl.dispose();
    numIdCtrl.dispose();
    claveCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.cargandoUsuarios) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (auth.usuarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.people_outline,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Sin usuarios registrados", style: AppTextos.titulo),
            const SizedBox(height: 6),
            const Text(
              "Los usuarios aparecerán aquí\ntras el registro.",
              style: AppTextos.apagado,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: auth.usuarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final u = auth.usuarios[i];
        final esAdmin = u.rol == 'admin';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: esAdmin
                  ? AppColors.primaryTint
                  : AppColors.secondaryTint,
              child: Icon(
                esAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.medication_outlined,
                color: esAdmin ? AppColors.primary : AppColors.secondary,
                size: 22,
              ),
            ),
            title: Text(
              u.email,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "ID: ${u.numIdentificacion}",
                style: AppTextos.etiqueta,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge rol
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: esAdmin
                        ? AppColors.primaryTint
                        : AppColors.secondaryTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    esAdmin ? "Admin" : "Farmacéutico",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: esAdmin
                          ? AppColors.primary
                          : AppColors.secondaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Botón editar
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  tooltip: "Editar",
                  onPressed: () => _abrirEditar(context, auth, u),
                ),
                // Botón eliminar
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: "Eliminar",
                  onPressed: () => _confirmarEliminar(context, auth, u),
                ),
              ],
            ),
          ),
        );
      },
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
  final int? maxLength;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icono,
    this.tipo = TextInputType.text,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: AppColors.textMuted, size: 20),
      ),
    );
  }
}
