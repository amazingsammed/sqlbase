import 'package:flutter/cupertino.dart';
import 'package:sqlbase/src/feature/table/sqlrecord.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqlbase/sqlbase.dart';

import '../../utility/phpresponse.dart';
import '../../utility/sqlbaseresponse.dart';
import '../../utility/sqlmap.dart';

part '../table/filters/where.dart';
part '../table/filters/join.dart';
part '../table/filters/limit.dart';
part '../table/filters/orderby.dart';
part '../table/filters/togetherwith.dart';
part '../table/filters/groupby.dart';
part '../table/functions/read.dart';
part '../table/functions/create.dart';

// class SqlTable {
//   final String tableName;
//   final String url;
//   final String key;
//   final List<Map> _filterList = [];
//
//
//
//   SqlTable(this.tableName, this.url, this.key) ;
//
//   SqlRecord record(dynamic recordId,{String? column}){
//     if (recordId != null && column == null) {
//       throw Exception('You need to specify the Column');
//     }
//     return SqlRecord(recordId,column,table: this);
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'tableName': tableName,
//       'url': url,
//       'key': key,
//     };
//   }
//
//   factory SqlTable.fromMap(Map<String, dynamic> map) {
//     return SqlTable(
//        map['tableName'] as String,
//        map['url'] as String,
//       map['key'] as String,
//     );
//   }
// }

/// Represents a SQL table and operations on it.
class SqlTable {
  final String tableName;
  final String url;
  final String key;

  // Stores filters for future use (e.g., where conditions)
  final List<Map<String, dynamic>> _filterList = [];

  SqlTable(this.tableName, this.url, this.key);

  /// Accesses a single record by its ID and optional column name.
  SqlRecord record(dynamic recordId, {String? column}) {
    if (recordId != null && column == null) {
      throw ArgumentError('You must specify the column name when providing a record ID.');
    }
    return SqlRecord(recordId, column, table: this);
  }

  /// Converts this SqlTable instance into a Map (useful for serialization).
  Map<String, dynamic> toMap() {
    return {
      'tableName': tableName,
      'url': url,
      'key': key,
    };
  }

  /// Factory constructor to create SqlTable from a Map.
  factory SqlTable.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('tableName') || !map.containsKey('url') || !map.containsKey('key')) {
      throw ArgumentError('Missing required fields in map for SqlTable');
    }

    return SqlTable(
      map['tableName'] as String,
      map['url'] as String,
      map['key'] as String,
    );
  }
}

class SqlDualTable{
  SqlTable tableInfo;
  String secondTableName;
  Compare data;

  SqlDualTable(this.tableInfo, this.secondTableName, this.data);

  Future<SqlBaseResponse> get()async{
    return SqlBaseResponse(statusCode: 200);
  }
}
