import 'package:flutter/cupertino.dart';
import 'package:sqlbase/src/feature/table/sqlrecord.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqlbase/sqlbase.dart';

import '../../utility/phpresponse.dart';
import '../../utility/sqlmap.dart';

part '../table/components/filters_sqltable.dart';
part '../table/components/filters_sqldualtable.dart';




part '../table/functions/read.dart';

part '../table/functions/create.dart';

/// Represents a SQL table and operations on it.
class SqlTable {
  @visibleForTesting
  final String tableName;
  @visibleForTesting
  final String url;
  @visibleForTesting
  final String key;
  @visibleForTesting
  final List<Select>? select;
  @visibleForTesting
  final bool distinct;

  // Stores filters for future use (e.g., where conditions)
  final List<Map<String, dynamic>> _filterList = [];

  SqlTable(this.tableName, this.url, this.key,
      {this.select, this.distinct = false});

  /// Accesses a single record by its ID and optional column name.
  SqlRecord record(dynamic recordId, {String? column}) {
    if (recordId != null && column == null) {
      throw ArgumentError(
          'You must specify the column name when providing a record ID.');
    }
    return SqlRecord(recordId, column, table: this);
  }

  /// Converts this SqlTable instance into a Map (useful for serialization).
  Map<String, dynamic> toMap() {
    return {'tableName': tableName, 'url': url, 'key': key, 'select': select};
  }

  /// Factory constructor to create SqlTable from a Map.
  factory SqlTable.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('tableName') ||
        !map.containsKey('url') ||
        !map.containsKey('key')) {
      throw ArgumentError('Missing required fields in map for SqlTable');
    }

    return SqlTable(
      map['tableName'] as String,
      map['url'] as String,
      map['key'] as String,
    );
  }

  SqlJoinTable leftJoin(String table2, {required List<Select> select}) {
    return SqlJoinTable(
        SqlTable(tableName, url, key, select: this.select), table2, select);
  }
}

class SqlJoinTable {
  final SqlTable tableInfo;
  final String secondTableName;
  final List<Select>? select;

  SqlJoinTable(this.tableInfo, this.secondTableName, this.select);

  basedOn({required String table1, required String table2}) async {
    String table_1 = "${tableInfo.tableName.trim()}.${table1.trim()}";
    String table_2 = "${secondTableName.trim()}.${table2.trim()}";
    try {
      final response = await http.post(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        Uri.parse(tableInfo.url),
        body: {
          'key': tableInfo.key,
          'action': 'SQL-LEFT-JOIN',
          "payload": {
            'table': tableInfo.tableName,
            'table2': secondTableName,
            'table1-select': jsonEncode(tableInfo.select?.toMap()),
            'table2-select': jsonEncode(select?.toMap()),
            "others": table_1 + table_2

          }
        },
      );
      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
}

class SqlDualTable {
  final SqlTable tableInfo;
  final String secondTableName;
  final List<Select>? select;

  final List<Map<String, dynamic>> _filterList;

  SqlDualTable(
      this.tableInfo, this.secondTableName, this.select, this._filterList);

  Future<SqlBaseResponse> get({required Compare basedOn}) async {
    try {
      final response = await http.post(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        Uri.parse(tableInfo.url),
        body: {
          'key': tableInfo.key,
          'action': 'GET-DUAL-TABLE',
          'table': tableInfo.tableName,
          'table2': secondTableName,
          'table1-select': jsonEncode(tableInfo.select?.toMap()),
          'table2-select': jsonEncode(select?.toMap()),
          'based-on': jsonEncode([basedOn.toMap()]),
          'conditions': jsonEncode(_filterList.isEmpty ? null : _filterList),
        },
      );
      _filterList.clear();
      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
}
