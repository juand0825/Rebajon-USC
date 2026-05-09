import 'package:flutter/material.dart';
import '../Controllers/medicamento_controller.dart';

class MedicamentosView extends StatefulWidget {
  const MedicamentosView({super.key});

  @override
  State<MedicamentosView> createState() => _MedicamentosViewState();
}

class _MedicamentosViewState extends State<MedicamentosView> {
  final medicamentoController = MedicamentoController();

  // Controladores de medicamentos
  final nombreCtrl = TextEditingController();
  final principioCtrl = TextEditingController();
  final presentacionCtrl = TextEditingController();
  final fabricanteCtrl = TextEditingController();
  final precioCtrl = TextEditingController(); // NUEVO
  final stockMinimoCtrl = TextEditingController();

  // Controladores de lotes
  final loteCtrl = TextEditingController();
  final fechaFabCtrl = TextEditingController();
  final fechaVenCtrl = TextEditingController();
  final cantidadInicialCtrl = TextEditingController();
  final cantidadDisponibleCtrl = TextEditingController();
  final codigoCtrl = TextEditingController();

  bool requiereRefrigeracion = false;
  bool activo = true;

  Widget campo(String texto, TextEditingController controlador) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        keyboardType:
            texto == "Precio" ||
                texto.contains("Cantidad") ||
                texto.contains("Stock")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: texto,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void limpiar() {
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

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> guardar() async {
    // Validar campos obligatorios
    if (nombreCtrl.text.isEmpty ||
        precioCtrl.text.isEmpty ||
        stockMinimoCtrl.text.isEmpty ||
        loteCtrl.text.isEmpty ||
        cantidadInicialCtrl.text.isEmpty ||
        cantidadDisponibleCtrl.text.isEmpty) {
      mostrarMensaje("Completa los campos obligatorios");
      return;
    }

    // Convertir valores numéricos
    final precio = double.tryParse(precioCtrl.text);
    final stockMinimo = int.tryParse(stockMinimoCtrl.text);
    final cantidadInicial = int.tryParse(cantidadInicialCtrl.text);
    final cantidadDisponible = int.tryParse(cantidadDisponibleCtrl.text);

    // Validar conversiones
    if (precio == null ||
        stockMinimo == null ||
        cantidadInicial == null ||
        cantidadDisponible == null) {
      mostrarMensaje("Precio, stock y cantidades deben ser números válidos");
      return;
    }

    // Validar cantidades
    if (cantidadDisponible > cantidadInicial) {
      mostrarMensaje(
        "La cantidad disponible no puede ser mayor que la inicial",
      );
      return;
    }

    try {
      await medicamentoController.guardarMedicamentoYLote(
        nombre: nombreCtrl.text,
        principioActivo: principioCtrl.text,
        presentacion: presentacionCtrl.text,
        fabricante: fabricanteCtrl.text,
        precio: precio, // SE ENVÍA A LA BASE DE DATOS
        stockMinimo: stockMinimo,
        requiereRefrigeracion: requiereRefrigeracion,
        activo: activo,
        numeroLote: loteCtrl.text,
        fechaFabricacion: fechaFabCtrl.text,
        fechaVencimiento: fechaVenCtrl.text,
        cantidadInicial: cantidadInicial,
        cantidadDisponible: cantidadDisponible,
        codigoBarras: codigoCtrl.text,
      );

      mostrarMensaje("Medicamento y lote guardados correctamente");
      limpiar();
    } catch (e) {
      mostrarMensaje("Error al guardar: $e");
    }
  }

  @override
  void dispose() {
    // Dispose medicamentos
    nombreCtrl.dispose();
    principioCtrl.dispose();
    presentacionCtrl.dispose();
    fabricanteCtrl.dispose();
    precioCtrl.dispose();
    stockMinimoCtrl.dispose();

    // Dispose lotes
    loteCtrl.dispose();
    fechaFabCtrl.dispose();
    fechaVenCtrl.dispose();
    cantidadInicialCtrl.dispose();
    cantidadDisponibleCtrl.dispose();
    codigoCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicamentos")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Datos del medicamento",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            campo("Nombre", nombreCtrl),
            campo("Principio activo", principioCtrl),
            campo("Presentación", presentacionCtrl),
            campo("Fabricante", fabricanteCtrl),
            campo("Precio", precioCtrl), // NUEVO CAMPO
            campo("Stock mínimo", stockMinimoCtrl),

            CheckboxListTile(
              title: const Text("¿Requiere refrigeración?"),
              value: requiereRefrigeracion,
              onChanged: (value) {
                setState(() {
                  requiereRefrigeracion = value ?? false;
                });
              },
            ),

            CheckboxListTile(
              title: const Text("Activo"),
              value: activo,
              onChanged: (value) {
                setState(() {
                  activo = value ?? true;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Datos del lote",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            campo("Número de lote", loteCtrl),
            campo("Fecha de fabricación", fechaFabCtrl),
            campo("Fecha de vencimiento", fechaVenCtrl),
            campo("Cantidad inicial", cantidadInicialCtrl),
            campo("Cantidad disponible", cantidadDisponibleCtrl),
            campo("Código de barras", codigoCtrl),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: guardar,
                    child: const Text("Guardar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: limpiar,
                    child: const Text("Limpiar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
