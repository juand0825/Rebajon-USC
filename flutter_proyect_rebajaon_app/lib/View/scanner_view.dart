import 'package:flutter/material.dart';

import '../Controllers/scanner_controller.dart';
import '../models/scanner_model.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final scannerController = ScannerController();

  final codigoCtrl = TextEditingController();

  ScannerModel? medicamento;

  bool cargando = false;

  Future<void> buscarCodigo(String codigo) async {
    if (codigo.trim().isEmpty) {
      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado = await scannerController.buscarMedicamento(codigo);

    setState(() {
      medicamento = resultado;
      cargando = false;
    });

    codigoCtrl.clear();

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicamento no encontrado')),
      );
    }
  }

  @override
  void dispose() {
    codigoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner Farmacéutico')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: codigoCtrl,
              autofocus: true,
              onSubmitted: buscarCodigo,
              decoration: const InputDecoration(
                labelText: 'Escanee el código',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),

            const SizedBox(height: 30),

            if (cargando) const CircularProgressIndicator(),

            if (!cargando && medicamento != null)
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicamento!.nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Código: '
                        '${medicamento!.codigoBarras}',
                      ),

                      Text(
                        'Lote: '
                        '${medicamento!.numeroLote}',
                      ),

                      Text(
                        'Stock: '
                        '${medicamento!.cantidadDisponible}',
                      ),

                      Text(
                        'Vence: '
                        '${medicamento!.fechaVencimiento}',
                      ),

                      Text(
                        'Precio: \$'
                        '${medicamento!.precio.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),

            if (!cargando && medicamento == null)
              const Text('Escanee un medicamento'),
          ],
        ),
      ),
    );
  }
}
