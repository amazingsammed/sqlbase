

import 'package:sqlbase/src/feature/authentication/sqlauth.dart';
import 'package:sqlbase/src/feature/rawquery/rawquery.dart';

import 'feature/table/sqlrecord.dart';
import 'feature/table/sqltable.dart';

class Sqlbase {
  static String? _url;
  static String? _key;

  static void initialize({required String url, required String key}) {
    _url = url;
    _key = key;
  }

   SqlTable table(String tableName) {
    if (_url == null || _key == null) {
      throw Exception('Sqlbase not initialized. Call Sqlbase.initialize first.');
    }
    return SqlTable(tableName, _url!, _key!);
  }



  SqlAuth auth(String tableName) {
    if (_url == null || _key == null) {
      throw Exception('Sqlbase not initialized. Call Sqlbase.initialize first.');
    }
    return SqlAuth(tableName, _url!, _key!);
  }


}



