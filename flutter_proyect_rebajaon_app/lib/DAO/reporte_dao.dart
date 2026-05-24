import '../database/db_connection.dart';
import '../models/reporte_model.dart';

class ReporteDao {
  Future<ReporteResumenModel> obtenerResumen() async {
    final conn = await DbConnection.getConnection();

    final ventas = await conn.execute('''
      SELECT
        COUNT(*) AS total_ventas,
        IFNULL(SUM(total), 0) AS total_ingresos
      FROM ventas
      WHERE estado = 'completada'
    ''');

    final productosVendidos = await conn.execute('''
      SELECT IFNULL(SUM(cantidad), 0) AS total_productos
      FROM detalle_ventas
    ''');

    final alertasPendientes = await conn.execute('''
      SELECT COUNT(*) AS total
      FROM alerta
      WHERE resulta = 0
    ''');

    final alertasResueltas = await conn.execute('''
      SELECT COUNT(*) AS total
      FROM alerta
      WHERE resulta = 1
    ''');

    final sinStock = await conn.execute('''
      SELECT COUNT(*) AS total
      FROM medicamentos
      WHERE stock_actual <= 0
    ''');

    final stockMinimo = await conn.execute('''
      SELECT COUNT(*) AS total
      FROM medicamentos
      WHERE stock_actual > 0
        AND stock_actual <= stock_minimo
    ''');

    final lotes = await conn.execute('''
      SELECT COUNT(*) AS total
      FROM lotes
    ''');

    return ReporteResumenModel(
      totalVentas: int.parse(ventas.rows.first.assoc()['total_ventas'].toString()),
      totalIngresos: double.parse(ventas.rows.first.assoc()['total_ingresos'].toString()),
      totalProductosVendidos: int.parse(productosVendidos.rows.first.assoc()['total_productos'].toString()),
      alertasPendientes: int.parse(alertasPendientes.rows.first.assoc()['total'].toString()),
      alertasResueltas: int.parse(alertasResueltas.rows.first.assoc()['total'].toString()),
      medicamentosSinStock: int.parse(sinStock.rows.first.assoc()['total'].toString()),
      medicamentosStockMinimo: int.parse(stockMinimo.rows.first.assoc()['total'].toString()),
      lotesRegistrados: int.parse(lotes.rows.first.assoc()['total'].toString()),
    );
  }

  // Trae todos los productos vendidos con fecha.
  // Si se pasan fechaDesde y fechaHasta filtra por ese rango (inclusive).
  Future<List<ReporteVentaProductoModel>> productosMasVendidos({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final conn = await DbConnection.getConnection();

    String whereClause = "WHERE v.estado = 'completada'";

    if (fechaDesde != null) {
      final desde = fechaDesde.toIso8601String().substring(0, 10);
      whereClause += " AND DATE(v.create_time) >= '$desde'";
    }

    if (fechaHasta != null) {
      final hasta = fechaHasta.toIso8601String().substring(0, 10);
      whereClause += " AND DATE(v.create_time) <= '$hasta'";
    }

    final result = await conn.execute('''
      SELECT
        m.nombre AS medicamento,
        SUM(dv.cantidad) AS cantidad_vendida,
        SUM(dv.subtotal) AS total_vendido,
        DATE(v.create_time) AS fecha
      FROM detalle_ventas dv
      INNER JOIN lotes l ON l.id = dv.id_lote
      INNER JOIN medicamentos m ON m.id = l.id_medicamento
      INNER JOIN ventas v ON v.id = dv.id_venta
      $whereClause
      GROUP BY m.id, m.nombre, DATE(v.create_time)
      ORDER BY fecha DESC, cantidad_vendida DESC
    ''');

    return result.rows
        .map((row) => ReporteVentaProductoModel.fromMap(row.assoc()))
        .toList();
  }

  Future<List<ReporteAlertaModel>> resumenAlertas() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('''
      SELECT
        tipo,
        nivel_gravedad,
        COUNT(*) AS cantidad
      FROM alerta
      GROUP BY tipo, nivel_gravedad
      ORDER BY cantidad DESC
    ''');

    return result.rows
        .map((row) => ReporteAlertaModel.fromMap(row.assoc()))
        .toList();
  }

  Future<List<ReporteLoteModel>> lotesRegistrados() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('''
      SELECT
        m.nombre AS medicamento,
        l.numero_lote,
        l.cantidad_inicial,
        l.cantidad_disponible,
        l.fecha_vencimiento,
        l.codigo_barras
      FROM lotes l
      INNER JOIN medicamentos m ON m.id = l.id_medicamento
      ORDER BY l.id DESC
    ''');

    return result.rows
        .map((row) => ReporteLoteModel.fromMap(row.assoc()))
        .toList();
  }

  Future<List<ReporteInventarioModel>> inventarioActual() async {
    final conn = await DbConnection.getConnection();

    final result = await conn.execute('''
      SELECT
        nombre,
        stock_actual,
        stock_minimo,
        precio,
        activo
      FROM medicamentos
      ORDER BY nombre ASC
    ''');

    return result.rows
        .map((row) => ReporteInventarioModel.fromMap(row.assoc()))
        .toList();
  }
}