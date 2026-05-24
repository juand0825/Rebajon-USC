import '../DAO/medicamento_dao.dart';
import '../DAO/lote_dao.dart';

import '../models/medicamento_model.dart';
import '../models/lote_model.dart';

class MedicamentoController {
  final MedicamentoDao medicamentoDao;
final LoteDao loteDao;
MedicamentoController({MedicamentoDao? medicamentoDao, LoteDao? loteDao})
    : medicamentoDao = medicamentoDao ?? MedicamentoDao(),
      loteDao = loteDao ?? LoteDao();

  Future<void> guardarMedicamentoYLote({
    required String nombre,

    required String principioActivo,

    required String presentacion,

    required String fabricante,

    required double precio,

    required int stockMinimo,

    required bool requiereRefrigeracion,

    required bool activo,

    required String numeroLote,

    required String fechaFabricacion,

    required String fechaVencimiento,

    required int cantidadInicial,

    required int cantidadDisponible,

    required String codigoBarras,
  }) async {
    final medicamento = MedicamentoModel(
      nombre: nombre,

      principioActivo: principioActivo,

      presentacion: presentacion,

      fabricante: fabricante,

      precio: precio,

      stockActual: cantidadDisponible,

      stockMinimo: stockMinimo,

      requiereRefrigeracion: requiereRefrigeracion,

      activo: activo,
    );

    await medicamentoDao.insertarMedicamento(medicamento);

    final medicamentoGuardado = await medicamentoDao.buscarPorNombre(nombre);

    if (medicamentoGuardado == null) {
      throw Exception('No se pudo obtener el medicamento guardado');
    }

    final lote = LoteModel(
      idMedicamento: medicamentoGuardado.id!,

      numeroLote: numeroLote,

      fechaFabricacion: fechaFabricacion,

      fechaVencimiento: fechaVencimiento,

      cantidadInicial: cantidadInicial,

      cantidadDisponible: cantidadDisponible,

      codigoBarras: codigoBarras,
    );

    await loteDao.insertarLote(lote);
  }

  Future<void> guardarLoteAMedicamentoExistente({
    required int idMedicamento,
    required String numeroLote,
    required String fechaFabricacion,
    required String fechaVencimiento,
    required int cantidadInicial,
    required int cantidadDisponible,
    required String codigoBarras,
  }) async {
    final lote = LoteModel(
      idMedicamento: idMedicamento,
      numeroLote: numeroLote,
      fechaFabricacion: fechaFabricacion,
      fechaVencimiento: fechaVencimiento,
      cantidadInicial: cantidadInicial,
      cantidadDisponible: cantidadDisponible,
      codigoBarras: codigoBarras,
    );

    await loteDao.insertarLote(lote);
  }
}
