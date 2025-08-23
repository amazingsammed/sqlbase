import 'dart:io';

import 'package:sqlbase/src/feature/authentication/sqlauth.dart';
export  'package:sqlbase/src/models/selectModel.dart';


import '../sqlbase.dart';
export  'feature/create_table/sql_table.dart';
import 'feature/raw/rawquery.dart';
import 'feature/raw/rawsql.dart';
import 'feature/transaction/sqlbatch.dart';

/// The main entry point for interacting with the SQLbase plugin.
///
/// This class provides methods for initializing the SQLbase connection,
/// interacting with tables, performing authentication, and executing
/// SQL operations such as `SELECT`, `INSERT`, `UPDATE`, `DELETE`, and `TRANSACTION`.
class Sqlbase {
  static String? _url;
  static String? _key;
  static String? _encryptionKey;

  /// Initializes the SQLbase connection with the given [url] and [key].
  ///
  /// This method must be called before performing any database operations.
  ///
  /// Example:
  /// ```dart
  /// Sqlbase.initialize(url: 'https://yourdomain.com/sql.php', key: 'your_api_key');
  /// ```
  static void initialize({required String url, required String key,String encryptionKey = "ILOVESQLBASE2025"}) {
    _url = url;
    _key = key;
    _encryptionKey = encryptionKey;
  }


    static void createTable(List<SQLTable> tables, {String outputPath = 'schema.sql'}) {
      final buffer = StringBuffer();
      for (final table in tables) {
        buffer.writeln(table.toCreateTableSql());
        buffer.writeln();
      }
      final file = File(outputPath);
      file.writeAsStringSync(buffer.toString());
  }


  /// Returns an instance of [SqlTable] for interacting with a specific table.
  ///
  /// [tableName] is the name of the database table.
  /// [select] is an optional list of fields to select from the table.
  /// [distinct] indicates whether to return distinct results.
  ///
  /// Example:
  /// ```dart
  /// var table = Sqlbase().table('users', select: [Select('name'), Select('email')]);
  /// ```
  SqlTable table(String tableName, {List<Select>? select, bool distinct = false}) {
    _checkInitialized();
    return SqlTable(tableName, _url!, _key!, select: select, distinct: distinct);
  }

  /// Returns an instance of [SqlAuth] for performing authentication on a table.
  ///
  /// Typically used for login, signup, and verification purposes.
  ///
  /// Example:
  /// ```dart
  /// var auth = Sqlbase().auth('users');
  /// ```
  SqlAuth auth(String tableName) {
    _checkInitialized();
    return SqlAuth(tableName, _url!, _key!);
  }

  /// Executes a database transaction using the [SqlBatch] API.
  ///
  /// [result] is a callback function that receives a [SqlBatch] instance.
  /// You can chain multiple operations like insert, update, and delete.
  ///
  /// Example:
  /// ```dart
  /// await Sqlbase().transaction((batch) {
  ///   return batch
  ///     ..insert('users', {'name': 'John'})
  ///     ..delete('logs', where: 'id = ?', args: [5]);
  /// });
  /// ```
  Future<SqlBaseResponse> transaction(SqlBatch Function(SqlBatch action) result) async {
    _checkInitialized();
    SqlBatch batch = SqlBatch(_url!, _key!);
    SqlBatch data = result(batch);
    return await data.commit();
  }

  /// Begins a `SELECT` query using a fluent query builder interface.
  ///
  /// [fields] is a list of field names to retrieve, or `null` to select all (`*`).
  ///
  /// Example:
  /// ```dart
  /// Sqlbase.select(['id', 'name']).from('users').where('id', isEqualTo: 5).get();
  /// ```
  @Deprecated("use SqlBase().table(tablename).get()")
  static SelectFromStep select(List<String>? fields) {
    _checkInitialized();
    return SelectFromStep(_url!, _key!, fields);
  }

  /// Begins an `INSERT` query for the specified [table].
  ///
  /// Example:
  /// ```dart
  /// Sqlbase.insertInto('users').values({'name': 'Alice'}).execute();
  /// ```
  @Deprecated("use SqlBase().table(tablename).insert")
  static InsertQuery insertInto(String table) {
    _checkInitialized();
    return InsertQuery(_url!, _key!, table);
  }

  /// Begins an `UPDATE` query for the specified [table].
  ///
  /// Example:
  /// ```dart
  /// Sqlbase.update('users').set({'name': 'Bob'}).where('id', isEqualTo: 3).execute();
  /// ```
  @Deprecated("use SqlBase().table(tablename).record(recordid).update")
  static UpdateQuery update(String table) {
    _checkInitialized();
    return UpdateQuery(_url!, _key!, table);
  }

  /// Begins a `DELETE` query for the specified [table].
  ///
  /// Example:
  /// ```dart
  /// Sqlbase.deleteFrom('users').where('id', isEqualTo: 10).execute();
  /// ```
  @Deprecated("use SqlBase().table(tablename).record(recordid).delete")
  static DeleteQuery deleteFrom(String table) {
    _checkInitialized();
    return DeleteQuery(_url!, _key!, table);
  }

  /// Ensures that SQLbase is initialized before allowing operations.
  static void _checkInitialized() {
    if (_url == null || _key == null || _encryptionKey ==null) {
      throw Exception('Sqlbase not initialized. Call Sqlbase.initialize first.');
    }
    if (_encryptionKey!.length!=16 ) {
      throw Exception('Encryption key must be 16');
    }
  }
  @Deprecated("Not Recommended, only select statement works")
  static RawQuery rawQuery(String command) {
    _checkInitialized();
    return RawQuery(_url!, _key!, command);
  }
}



