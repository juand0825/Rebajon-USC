import 'package:flutter/material.dart';
import '../DAO/alerta_dao.dart';
import '../models/alerta_model.dart';

class AlertasView extends StatefulWidget {
  const AlertasView({super.key});

  @override
  State<AlertasView> createState() => _AlertasViewState();
}

class _AlertasViewState extends State<AlertasView> {
  final alertaDao = AlertaDao();

  List<AlertaModel> alertas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarAlertas();
  }

  Future<void> cargarAlertas() async {
    try {
      final lista = await alertaDao.listarAlertas();
      setState(() {
        alertas = lista;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al cargar alertas")));
    }
  }

  Color colorGravedad(AlertaModel alerta) {
    if (alerta.resulta) {
      return Colors.green;
    }

    switch (alerta.nivelGravedad) {
      case 'CRITICO':
        return const Color.fromARGB(193, 244, 0, 24);
      case 'ADVERTENCIA':
        return const Color.fromARGB(255, 255, 153, 0);
      default:
        return const Color.fromARGB(255, 0, 117, 212);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alertas")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : alertas.isEmpty
          ? const Center(child: Text("No hay alertas registradas"))
          : ListView.builder(
              itemCount: alertas.length,
              itemBuilder: (context, index) {
                final alerta = alertas[index];

                return Card(
                  color: colorGravedad(alerta),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      alerta.tipo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Gravedad: ${alerta.nivelGravedad}\n"
                      "Mensaje: ${alerta.mensaje}\n"
                      "Resulta: ${alerta.resulta ? "Sí" : "No"}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
