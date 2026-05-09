import 'package:mysql_client/mysql_client.dart';

class DbConnection {
  static MySQLConnection? _connection;

  static Future<MySQLConnection> getConnection() async {
    if (_connection != null)  {
      return _connection!;
    }

    _connection = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3308,
      userName: 'root',
      password: 'Arc11@22',
      databaseName: 'farmacia',
    );

    await _connection!.connect();
    return _connection!;
  }
}