
part of 'package:sqlbase/src/feature/table/sqltable.dart';

extension SqlTableCreate on SqlTable{
  Future<SqlBaseResponse> add(Map<String, dynamic> data2) async {


    try {
      final response = await postData(url: url, key: key, data: {
        'action': 'TABLE-ADD',
        'table': tableName,
        'data': jsonEncode(data2),
      });
      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }

  Future<SqlBaseResponse> addMany(
      List<Map<String, dynamic>> data) async {
    try{
      final response = await postData(url: url, key: key, data: {
        'key': key,
        'action': 'TABLE-ADDMANY',
        'table': tableName,
        'data': jsonEncode(data),
      });
    return phpResponse(response);
  } catch (e) {
  return SqlBaseResponse(statusCode: 0, error: e.toString());
  }
  }
}