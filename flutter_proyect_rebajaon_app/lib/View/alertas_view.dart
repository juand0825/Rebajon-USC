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

  String formatearTipo(String tipo) {
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

  String textoGravedad(AlertaModel alerta) {
    if (alerta.resulta) {
      return 'Correcto';
    }

    switch (alerta.nivelGravedad) {
      case 'CRITICO':
        return 'Crítico';
      case 'ADVERTENCIA':
        return 'Advertencia';
      case 'INFO':
        return 'Información';
      default:
        return alerta.nivelGravedad;
    }
  }

  String textoEstado(AlertaModel alerta) {
    return alerta.resulta ? 'Resuelta' : 'Pendiente';
  }

  Color colorAlerta(AlertaModel alerta) {
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

  IconData iconoAlerta(AlertaModel alerta) {
    if (alerta.resulta) {
      return Icons.check_circle;
    }

    switch (alerta.nivelGravedad) {
      case 'CRITICO':
        return Icons.error;
      case 'ADVERTENCIA':
        return Icons.warning;
      default:
        return Icons.info;
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
                final color = colorAlerta(alerta);

                return Card(
                  color: color.withOpacity(0.90),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(iconoAlerta(alerta), color: Colors.white),
                    title: Text(
                      formatearTipo(alerta.tipo),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "Gravedad: ${textoGravedad(alerta)}\n"
                      "Mensaje: ${alerta.mensaje}\n"
                      "Estado: ${textoEstado(alerta)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
