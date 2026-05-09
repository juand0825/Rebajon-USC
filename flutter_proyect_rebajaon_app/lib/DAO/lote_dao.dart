import 'package:flutter_proyect_rebajaon_app/models/lote_model.dart';

import '../database/db_connection.dart';

class LoteDao {

  // INSERTAR LOTE

  Future<void> insertarLote(
      LoteModel lote) async {

    final conn =
        await DbConnection.getConnection();

    await conn.execute(

      '''
      INSERT INTO lotes
      (
        id_medicamento,
        numero_lote,
        fecha_fabricacion,
        fecha_vencimiento,
        cantidad_inicial,
        cantidad_disponible,
        codigo_barras
      )

      VALUES
      (
        :id_medicamento,
        :numero_lote,
        :fecha_fabricacion,
        :fecha_vencimiento,
        :cantidad_inicial,
        :cantidad_disponible,
        :codigo_barras
      )
      ''',

      {

        'id_medicamento':
            lote.idMedicamento,

        'numero_lote':
            lote.numeroLote,

        'fecha_fabricacion':
            lote.fechaFabricacion,

        'fecha_vencimiento':
            lote.fechaVencimiento,

        'cantidad_inicial':
            lote.cantidadInicial,

        'cantidad_disponible':
            lote.cantidadDisponible,

        'codigo_barras':
            lote.codigoBarras,
      },
    );
  }

  // LISTAR LOTES

  Future<List<LoteModel>>
      listarLotesPorMedicamento(
          int idMedicamento) async {

    final conn =
        await DbConnection.getConnection();

    final result = await conn.execute(

      '''
      SELECT *
      FROM lotes
      WHERE id_medicamento =
            :id_medicamento
      ''',

      {
        'id_medicamento':
            idMedicamento,
      },
    );

    return result.rows

        .map(
          (row) => LoteModel.fromMap(
            row.assoc(),
          ),
        )

        .toList();
  }

  // BUSCAR POR CÓDIGO DE BARRAS

  Future<LoteModel?>
      buscarPorCodigoBarras(
          String codigoBarras) async {

    final conn =
        await DbConnection.getConnection();

    final result = await conn.execute(

      '''
      SELECT *
      FROM lotes
      WHERE codigo_barras =
            :codigo_barras
      LIMIT 1
      ''',

      {
        'codigo_barras':
            codigoBarras,
      },
    );

    if (result.rows.isEmpty) {

      return null;
    }

    return LoteModel.fromMap(
      result.rows.first.assoc(),
    );
  }

  // DESCONTAR STOCK

  Future<void> descontarStock(
      String codigoBarras) async {

    final conn =
        await DbConnection.getConnection();

    await conn.execute(

      '''
      UPDATE lotes

      SET cantidad_disponible =
          cantidad_disponible - 1

      WHERE codigo_barras =
            :codigo_barras

      AND cantidad_disponible > 0
      ''',

      {
        'codigo_barras':
            codigoBarras,
      },
    );
  }
}