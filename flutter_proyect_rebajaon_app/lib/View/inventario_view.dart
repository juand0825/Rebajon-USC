import 'package:flutter/material.dart';
import '../DAO/medicamento_dao.dart';
import '../models/medicamento_model.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final medicamentoDao = MedicamentoDao();

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
      setState(() {
        medicamentos = lista;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      mostrarMensaje("Error al cargar inventario");
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

  void guardarTemperatura() {
    final incompleto =
        medicamentoSeleccionado == null ||
        temperaturaCtrl.text.isEmpty ||
        rangoMinCtrl.text.isEmpty ||
        rangoMaxCtrl.text.isEmpty;

    if (incompleto) {
      mostrarMensaje("Completa todos los campos de temperatura");
      return;
    }

    final temperatura = double.tryParse(temperaturaCtrl.text);
    final rangoMin = double.tryParse(rangoMinCtrl.text);
    final rangoMax = double.tryParse(rangoMaxCtrl.text);

    final numerosInvalidos =
        temperatura == null || rangoMin == null || rangoMax == null;

    if (numerosInvalidos) {
      mostrarMensaje("La temperatura y los rangos deben ser números");
      return;
    }

    final fueraDeRango = temperatura < rangoMin || temperatura > rangoMax;

    mostrarMensaje(
      fueraDeRango
          ? "Temperatura fuera de rango"
          : "Temperatura registrada correctamente",
    );

    temperaturaCtrl.clear();
    rangoMinCtrl.clear();
    rangoMaxCtrl.clear();

    setState(() {
      medicamentoSeleccionado = null;
    });
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
