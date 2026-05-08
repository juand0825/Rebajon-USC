import 'package:flutter/material.dart';
import '../DAO/medicamento_dao.dart';
import '../models/medicamento_model.dart';
import '../Controllers/temperatura_controller.dart';
import '../Controllers/alerta_controller.dart';
import '../DAO/lote_dao.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final medicamentoDao = MedicamentoDao();
  final temperaturaController = TemperaturaController();
  final alertaController = AlertaController();
  final loteDao = LoteDao();

  List<MedicamentoModel> medicamentos = [];
  bool cargando = true;

  MedicamentoModel? medicamentoSeleccionado;
  final temperaturaCtrl = TextEditingController();
  final rangoMinCtrl = TextEditingController();
  final rangoMaxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarMedicamentos();
  }

  Future<void> cargarMedicamentos() async {
    try {
      final lista = await medicamentoDao.listarMedicamentos();
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
        final medicamento = lista.firstWhere((m) => m.id == lote.idMedicamento);

        await alertaController.generarAlertaVencimientoProximo(
          idMedicamento: lote.idMedicamento,
          idLote: lote.id!,
          nombreMedicamento: medicamento.nombre,
          fechaVencimiento: DateTime.parse(lote.fechaVencimiento),
        );

        await alertaController.generarAlertaMedicamentoVencido(
          idMedicamento: lote.idMedicamento,
          idLote: lote.id!,
          nombreMedicamento: medicamento.nombre,
          fechaVencimiento: DateTime.parse(lote.fechaVencimiento),
        );
      }

      setState(() {
        medicamentos = lista;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      mostrarMensaje("Error al cargar inventario: $e");
    }
  }

  List<MedicamentoModel> get medicamentosRefrigerados {
    return medicamentos.where((m) => m.requiereRefrigeracion).toList();
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> guardarTemperatura() async {
    final incompleto =
        medicamentoSeleccionado == null ||
        temperaturaCtrl.text.isEmpty ||
        rangoMinCtrl.text.isEmpty ||
        rangoMaxCtrl.text.isEmpty;

    if (incompleto) {
      mostrarMensaje("Completa todos los campos");
      return;
    }

    final temperatura = double.tryParse(temperaturaCtrl.text);
    final rangoMin = double.tryParse(rangoMinCtrl.text);
    final rangoMax = double.tryParse(rangoMaxCtrl.text);

    if (temperatura == null || rangoMin == null || rangoMax == null) {
      mostrarMensaje("La temperatura y los rangos deben ser números");
      return;
    }

    try {
      await temperaturaController.guardarTemperatura(
        idMedicamento: medicamentoSeleccionado!.id!,
        temperatura: temperatura,
        rangoMin: rangoMin,
        rangoMax: rangoMax,
      );

      await alertaController.generarAlertaCadenaFrio(
        idMedicamento: medicamentoSeleccionado!.id!,
        nombreMedicamento: medicamentoSeleccionado!.nombre,
        temperatura: temperatura,
        rangoMin: rangoMin,
        rangoMax: rangoMax,
      );

      final fueraDeRango = temperatura < rangoMin || temperatura > rangoMax;

      mostrarMensaje(
        fueraDeRango
            ? "Temperatura fuera de rango"
            : "Temperatura guardada correctamente",
      );

      temperaturaCtrl.clear();
      rangoMinCtrl.clear();
      rangoMaxCtrl.clear();
      setState(() => medicamentoSeleccionado = null);
    } catch (e) {
      mostrarMensaje("Error al guardar temperatura: $e");
    }
  }

  Widget campo(String texto, TextEditingController controlador) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        decoration: InputDecoration(
          labelText: texto,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    temperaturaCtrl.dispose();
    rangoMinCtrl.dispose();
    rangoMaxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventario")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inventario registrado",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  medicamentos.isEmpty
                      ? const Text("No hay medicamentos registrados")
                      : Column(
                          children: medicamentos.map((m) {
                            return Card(
                              child: ListTile(
                                title: Text(m.nombre),
                                subtitle: Text(
                                  "Presentación: ${m.presentacion}\n"
                                  "Fabricante: ${m.fabricante}\n"
                                  "Stock actual: ${m.stockActual}\n"
                                  "Stock mínimo: ${m.stockMinimo}\n"
                                  "Refrigeración: ${m.requiereRefrigeracion ? "Sí" : "No"}",
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  const Text(
                    "Registro de temperatura",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<MedicamentoModel>(
                    value: medicamentoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: "Medicamento refrigerado",
                      border: OutlineInputBorder(),
                    ),
                    items: medicamentosRefrigerados.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m.nombre));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        medicamentoSeleccionado = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),
                  campo("Temperatura actual", temperaturaCtrl),
                  campo("Rango mínimo", rangoMinCtrl),
                  campo("Rango máximo", rangoMaxCtrl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardarTemperatura,
                      child: const Text("Guardar temperatura"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
