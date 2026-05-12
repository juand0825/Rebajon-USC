import 'package:flutter_proyect_rebajaon_app/models/medicamento_model.dart';

import '../database/db_connection.dart';

class MedicamentoDao {
  // INSERTAR MEDICAMENTO

  Future<void> insertarMedicamento(MedicamentoModel medicamento) async {
    final conn = await DbConnection.getConnection();

    await conn.execute(
      '''
      INSERT INTO medicamentos
      (

        nombre,

        principio_activo,

        presentacion,

        fabricante,

        precio,

        stock_actual,

        stock_minimo,

        requiere_refrigeracion,

        activo
      )

      VALUES
      (

        :nombre,

        :principio_activo,

        :presentacion,

        :fabricante,

        :precio,

        :stock_actual,

        :stock_minimo,

        :requiere_refrigeracion,

        :activo
      )
      ''',

      {
        'nombre': medicamento.nombre,

        'principio_activo': medicamento.principioActivo,

        'presentacion': medicamento.presentacion,

        'fabricante': medicamento.fabricante,

        'precio': medicamento.precio,

        'stock_actual': medicamento.stockActual,

        'stock_minimo': medicamento.stockMinimo,

        'requiere_refrigeracion': medicamento.requiereRefrigeracion ? 1 : 0,

        'activo': medicamento.activo ? 1 : 0,
      },
    );
  }

  // LISTAR MEDICAMENTOS

  Future<List<MedicamentoModel>> listarMedicamentos() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('SELECT * FROM medicamentos');

    return result.rows
        .map((row) => MedicamentoModel.fromMap(row.assoc()))
        .toList();
  }

  // BUSCAR POR NOMBRE

  Future<MedicamentoModel?> buscarPorNombre(String nombre) async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute(
      '''
      SELECT *
      FROM medicamentos

      WHERE nombre = :nombre

      ORDER BY id DESC

      LIMIT 1
      ''',

      {'nombre': nombre},
    );

    if (result.rows.isEmpty) {
      return null;
    }

    return MedicamentoModel.fromMap(result.rows.first.assoc());
  }
}
