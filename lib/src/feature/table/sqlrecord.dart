import 'dart:convert';

import 'package:sqlbase/sqlbase.dart';
import 'package:sqlbase/src/utility/sqlbaseresponse.dart';
import 'package:http/http.dart' as http;
import '../../utility/phpresponse.dart';

class SqlRecord {
  final SqlTable table;
  final dynamic recordID;
  final String? columName;



  SqlBaseResponse get() {
    try {
      return SqlBaseResponse(statusCode: 0);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }

  Future<SqlBaseResponse> update(Map<String,dynamic> data) async {
    if(columName!.isEmpty){
      throw Exception('You need to specify the row-Id and Column in row');
    }
    try {
      final response = await http.post(
        Uri.parse(table.url),
        body: {
          'key': table.key,
          'action': 'RECORD-UPDATE',
          'table': table.tableName,
          'data': jsonEncode(data),
          'conditions': jsonEncode([{
            "field":columName.toString(),
            "value":recordID
          }]),
        },
      );
      print(response.body);
      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }

  Future<SqlBaseResponse> create(Map<String,dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(table.url),
        body: {
          'key': table.key,
          'action': 'create_record',
          'table': table.tableName,
          'data': jsonEncode(data),
          'conditions': jsonEncode([]),
        },
      );
      return phpResponse(response);
      return SqlBaseResponse(statusCode: 0);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }

  Future<SqlBaseResponse> delete() async {
    if(columName!.isEmpty){
      throw Exception('You need to specify the row-Id and Column in row');
    }
    try {
      final response = await http.post(
        Uri.parse(table.url),
        body: {
          'key': table.key,
          'action': 'RECORD-DELETE',
          'table': table.tableName,
          'conditions': jsonEncode([{"field":columName.toString(),"value":recordID}]),
        },
      );

      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }

  const SqlRecord(this.recordID,this.columName,{
    required this.table,
  });

  Future<SqlBaseResponse> add(Map<String,dynamic> data) async {
    final Map<String,dynamic> myData = {};
    myData.addAll(data);
    if(recordID.toString().isNotEmpty) {
      myData.addAll({columName.toString():recordID});
    }
    try {
      final response = await http.post(
        Uri.parse(table.url),
        body: {
          'key': table.key,
          'action': 'TABLE-ADD',
          'table': table.tableName,
          'data': jsonEncode(myData),
        },
      );
      return phpResponse(response);
      return SqlBaseResponse(statusCode: 0);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }
}
