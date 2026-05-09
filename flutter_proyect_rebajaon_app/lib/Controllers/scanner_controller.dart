import '../DAO/scanner_dao.dart';
import '../models/scanner_model.dart';

class ScannerController {

  final ScannerDao scannerDao = ScannerDao();

  Future<ScannerModel?> buscarMedicamento(
      String codigo) async {

    return await scannerDao.buscarPorCodigo(codigo);
  }
}