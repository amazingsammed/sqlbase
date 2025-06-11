import 'package:sqlbase/src/feature/authentication/sqlauth.dart';
export  'package:sqlbase/src/models/selectModel.dart';


import '../sqlbase.dart';
import 'feature/transaction/sqlbatch.dart';

class Sqlbase {
  static String? _url;
  static String? _key;

  static void initialize({required String url, required String key}) {
    _url = url;
    _key = key;
  }

  SqlTable table(String tableName, {List<Select>? select, bool distinct = false}) {
    if (_url == null || _key == null) {
      throw Exception(
          'Sqlbase not initialized. Call Sqlbase.initialize first.');
    }
    return SqlTable(
        tableName, _url!, _key!, select: select, distinct: distinct);
  }


  SqlAuth auth(String tableName) {
    if (_url == null || _key == null) {
      throw Exception(
          'Sqlbase not initialized. Call Sqlbase.initialize first.');
    }
    return SqlAuth(tableName, _url!, _key!);
  }


  Future<SqlBaseResponse> transaction(
      SqlBatch Function(SqlBatch action) result) async {
    SqlBatch batch = SqlBatch(_url!, _key!);
    SqlBatch data = result(batch);
    SqlBaseResponse responds = await data.commit();
    return responds;
  }


}



