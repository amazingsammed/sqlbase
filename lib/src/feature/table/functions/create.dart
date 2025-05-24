
part of 'package:sqlbase/src/feature/table/sqltable.dart';

extension SqlTableCreate on SqlTable{
  Future<SqlBaseResponse> add(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'key': key,
          'action': 'TABLE-ADD',
          'table': tableName,
          'data': jsonEncode(data),
        },
      );
      return phpResponse(response);
    } catch (e) {
      Exception(e);
      return SqlBaseResponse(statusCode: 0, error: "Something went wrong");
    }
  }

  Future<SqlBaseResponse> addMany(
      List<Map<String, dynamic>> data) async {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'key': key,
        'action': 'TABLE-ADDMANY',
        'table': tableName,
        'data': jsonEncode(data),
      },
    );
    return phpResponse(response);
  }
}