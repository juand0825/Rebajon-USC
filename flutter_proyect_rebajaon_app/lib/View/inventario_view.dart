import 'package:flutter/material.dart';
import '../DAO/medicamento_dao.dart';
import '../models/medicamento_model.dart';
import '../Controllers/temperatura_controller.dart';
import '../Controllers/alerta_controller.dart';
import '../DAO/lote_dao.dart';
import '../Controllers/medicamento_controller.dart';

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
  final medicamentoController = MedicamentoController();

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
    cargarMedicamentos();
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

        if (encontrados.isEmpty) {
          continue;
        }

        final medicamento = encontrados.first;
        final fechaVencimiento = DateTime.tryParse(lote.fechaVencimiento);

        if (fechaVencimiento == null) {
          continue;
        }

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
      setState(() {
        cargando = false;
      });

      mostrarMensaje("Error al cargar inventario: $e");
    }
  }

  List<MedicamentoModel> get medicamentosFiltrados {
    final texto = busquedaInventario.trim().toLowerCase();

    if (texto.isEmpty) {
      return medicamentos;
    }

    return medicamentos.where((m) {
      return m.nombre.toLowerCase().contains(texto) ||
          m.principioActivo.toLowerCase().contains(texto) ||
          m.presentacion.toLowerCase().contains(texto) ||
          m.fabricante.toLowerCase().contains(texto);
    }).toList();
  }

  List<MedicamentoModel> get medicamentosRefrigerados {
    return medicamentos.where((m) => m.requiereRefrigeracion).toList();
  }

  Color colorEstadoStock(MedicamentoModel medicamento) {
    if (medicamento.stockActual <= 0) {
      return Colors.red;
    }

    if (medicamento.stockActual <= medicamento.stockMinimo) {
      return Colors.orange;
    }

    return Colors.green;
  }

  IconData iconoEstadoStock(MedicamentoModel medicamento) {
    if (medicamento.stockActual <= 0) {
      return Icons.error;
    }

    if (medicamento.stockActual <= medicamento.stockMinimo) {
      return Icons.warning;
    }

    return Icons.check_circle;
  }

  String textoEstadoStock(MedicamentoModel medicamento) {
    if (medicamento.stockActual <= 0) {
      return "Sin stock";
    }

    if (medicamento.stockActual <= medicamento.stockMinimo) {
      return "Stock mínimo";
    }

    return "Disponible";
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> mostrarDialogoStockActualizado(
    MedicamentoModel medicamento,
  ) async {
    final stockSuperaMinimo = medicamento.stockActual > medicamento.stockMinimo;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Stock actualizado"),
          content: Text(
            stockSuperaMinimo
                ? "El stock de ${medicamento.nombre} fue actualizado correctamente."
                : "El stock de ${medicamento.nombre} fue actualizado.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> guardarNuevoLote() async {
    if (medicamentoLoteSeleccionado == null ||
        loteCtrl.text.isEmpty ||
        fechaVenCtrl.text.isEmpty ||
        cantidadInicialCtrl.text.isEmpty ||
        cantidadDisponibleCtrl.text.isEmpty ||
        codigoCtrl.text.isEmpty) {
      mostrarMensaje("Completa los campos obligatorios del lote");
      return;
    }

    final cantidadInicial = int.tryParse(cantidadInicialCtrl.text);
    final cantidadDisponible = int.tryParse(cantidadDisponibleCtrl.text);

    if (cantidadInicial == null || cantidadDisponible == null) {
      mostrarMensaje("Las cantidades del lote deben ser números válidos");
      return;
    }

    if (cantidadDisponible > cantidadInicial) {
      mostrarMensaje(
        "La cantidad disponible no puede ser mayor que la inicial",
      );
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

      final medicamentoActualizado = await medicamentoDao.buscarPorId(
        idMedicamento,
      );

      if (medicamentoActualizado != null) {
        await alertaController.resolverAlertaStockMinimoSiCorresponde(
          idMedicamento: medicamentoActualizado.id!,
          stockActual: medicamentoActualizado.stockActual,
          stockMinimo: medicamentoActualizado.stockMinimo,
        );

        await mostrarDialogoStockActualizado(medicamentoActualizado);
      } else {
        mostrarMensaje("Lote agregado correctamente");
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
      mostrarMensaje("Error al agregar lote: $e");
    }
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
          builder: (context) {
            return AlertDialog(
              title: const Text("Alerta"),
              content: Text(mensajeCadenaFrio),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Aceptar"),
                ),
              ],
            );
          },
        );
      }

      final fueraDeRango = temperatura < rangoMin || temperatura > rangoMax;

      mostrarMensaje(
        fueraDeRango
            ? "Temperatura fuera de rango"
            : "Temperatura guardada correctamente",
      );

      temperaturaCtrl.clear();
      rangoMinCtrl.clear();
      rangoMaxCtrl.clear();

      setState(() {
        medicamentoSeleccionado = null;
      });
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

  Widget etiquetaEstado(MedicamentoModel medicamento) {
    final colorEstado = colorEstadoStock(medicamento);
    final iconoEstado = iconoEstadoStock(medicamento);
    final textoEstado = textoEstadoStock(medicamento);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorEstado.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorEstado),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconoEstado, size: 16, color: colorEstado),
          const SizedBox(width: 6),
          Text(
            textoEstado,
            style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget tarjetaMedicamento(MedicamentoModel medicamento) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(medicamento.nombre)),
            etiquetaEstado(medicamento),
          ],
        ),
        subtitle: Text(
          "Presentación: ${medicamento.presentacion}\n"
          "Fabricante: ${medicamento.fabricante}\n"
          "Stock actual: ${medicamento.stockActual}\n"
          "Stock mínimo: ${medicamento.stockMinimo}\n"
          "Refrigeración: ${medicamento.requiereRefrigeracion ? "Sí" : "No"}",
        ),
      ),
    );
  }

  @override
  void dispose() {
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
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Inventario registrado",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: buscarInventarioCtrl,
                          onChanged: (value) {
                            setState(() {
                              busquedaInventario = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Buscar medicamento",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  medicamentosFiltrados.isEmpty
                      ? const Text("No hay medicamentos registrados")
                      : Column(
                          children: medicamentosFiltrados.map((medicamento) {
                            return tarjetaMedicamento(medicamento);
                          }).toList(),
                        ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  const Text(
                    "Agregar lote a medicamento existente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<MedicamentoModel>(
                    value: medicamentoLoteSeleccionado,
                    decoration: const InputDecoration(
                      labelText: "Medicamento",
                      border: OutlineInputBorder(),
                    ),
                    items: medicamentos.where((m) => m.activo).map((m) {
                      return DropdownMenuItem(value: m, child: Text(m.nombre));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        medicamentoLoteSeleccionado = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),
                  campo("Número de lote", loteCtrl),
                  campo("Fecha de fabricación", fechaFabCtrl),
                  campo("Fecha de vencimiento", fechaVenCtrl),
                  campo("Cantidad inicial", cantidadInicialCtrl),
                  campo("Cantidad disponible", cantidadDisponibleCtrl),
                  campo("Código de barras", codigoCtrl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardarNuevoLote,
                      child: const Text("Agregar lote"),
                    ),
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
