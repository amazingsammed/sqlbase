import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../sqlbase.dart';
import '../../utility/phpresponse.dart';

/// An abstract class that defines the `execute()` method required for all SQL queries.
abstract class ExecutableQuery {
  /// Executes the query and returns the result.
  Future<dynamic> execute();
}

/// Builder class for starting a `SELECT` query.
///
/// Use [SelectFromStep] to define the fields to select,
/// then call [from()] to define the source tables.
class SelectFromStep {
  final String _url;
  final String _key;
  final List<String>? _fields;

  /// Creates a new instance for starting a select query.
  ///
  /// [_url] is the API endpoint.
  /// [_key] is the API key.
  /// [_fields] is the list of fields to select (or null for all).
  SelectFromStep(this._url, this._key, this._fields);

  /// Specifies the table(s) to select from.
  ///
  /// Returns a [SelectQuery] to allow further filtering or chaining.
  SelectQuery from(List<String> tables) {
    return SelectQuery(_url, _key, _fields, tables);
  }
}

/// Represents a `SELECT` query and supports chaining WHERE, JOIN, ORDER BY, and LIMIT clauses.
class SelectQuery implements ExecutableQuery {
  final String _url;
  final String _key;
  final List<String>? _fields;
  final List<String> _tables;
  String? _where;
  final List<String> _joins = [];
  String? _orderBy;
  int? _limit;

  /// Creates a query with selected fields and tables.
  SelectQuery(this._url, this._key, this._fields, this._tables);

  /// Adds a custom SQL JOIN clause.
  ///
  /// Example: `.join("INNER JOIN profiles ON users.id = profiles.user_id")`
  SelectQuery join(String joinClause) {
    _joins.add(joinClause);
    return this;
  }

  /// Adds WHERE conditions to the query.
  ///
  /// You can combine multiple conditions using named parameters.
  SelectQuery where(String field,
      {dynamic isEqualTo,
        dynamic isGreaterThan,
        dynamic isLessThan,
        dynamic isNotEqualTo}) {
    List<String> conditions = [];
    if (isEqualTo != null) conditions.add("$field = '$isEqualTo'");
    if (isGreaterThan != null) conditions.add("$field > '$isGreaterThan'");
    if (isLessThan != null) conditions.add("$field < '$isLessThan'");
    if (isNotEqualTo != null) conditions.add("$field != '$isNotEqualTo'");

    if (_where != null && conditions.isNotEmpty) {
      _where = "($_where) AND (${conditions.join(' AND ')})";
    } else {
      _where = conditions.join(' AND ');
    }
    return this;
  }

  /// Specifies how to order the result set.
  ///
  /// Defaults to ascending order.
  SelectQuery orderBy(String field, {bool descending = false}) {
    _orderBy = "$field ${descending ? 'DESC' : 'ASC'}";
    return this;
  }

  /// Limits the number of returned records.
  SelectQuery limit(int count) {
    _limit = count;
    return this;
  }

  /// Executes the query and returns a [SqlBaseResponse].
  @override
  Future<SqlBaseResponse> execute() async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: {
          'action': 'select',
          'key': _key,
          'table': 't',
          'select': jsonEncode(_fields),
          'from': jsonEncode(_tables),
          'joins': jsonEncode(_joins),
          'where': _where ?? "",
          'orderBy': _orderBy ?? "",
          'limit': _limit?.toString() ?? "",
        },
      );

      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }
}

/// A builder for performing `INSERT` operations on a SQL table.
class InsertQuery implements ExecutableQuery {
  final String _url;
  final String _table;
  final String _key;
  Map<String, dynamic> _values = {};

  /// Creates a new InsertQuery.
  InsertQuery(this._url, this._key, this._table);

  /// Sets the values to insert.
  ///
  /// Example: `.values({'name': 'John', 'email': 'john@example.com'})`
  InsertQuery values(Map<String, dynamic> values) {
    _values = values;
    return this;
  }

  /// Executes the insert operation and returns a [SqlBaseResponse].
  @override
  Future<SqlBaseResponse> execute() async {
    if (_values.isEmpty) {
      return SqlBaseResponse(
          statusCode: 0, error: "you need to use the values method first");
    }
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: {
          'action': 'insert',
          'table': _table,
          'key': _key,
          'values': jsonEncode(_values),
        },
      );

      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }
}

/// A builder for performing `UPDATE` operations on a SQL table.
class UpdateQuery implements ExecutableQuery {
  final String _url;
  final String _table;
  final String _key;
  Map<String, dynamic> _setValues = {};
  String? _column;
  String? _value;

  /// Creates a new UpdateQuery.
  UpdateQuery(this._url, this._key, this._table);

  /// Sets the column values to update.
  UpdateQuery set(Map<String, dynamic> values) {
    _setValues = values;
    return this;
  }

  /// Defines the row to update with a basic WHERE clause.
  UpdateQuery where(String column, String value) {
    _column = column;
    _value = value;
    return this;
  }

  /// Executes the update operation and returns a [SqlBaseResponse].
  @override
  Future<SqlBaseResponse> execute() async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: {
          'action': 'update',
          'table': _table,
          'key': _key,
          'set': jsonEncode(_setValues),
          'column': _column,
          'value': _value
        },
      );

      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }
}

/// A builder for performing `DELETE` operations on a SQL table.
class DeleteQuery implements ExecutableQuery {
  final String _url;
  final String _table;
  final String _key;
  String? _column;
  String? _value;

  /// Creates a new DeleteQuery.
  DeleteQuery(this._url, this._key, this._table);

  /// Sets the condition for the deletion.
  ///
  /// Example: `.where('id', '5')`
  DeleteQuery where(String column, String value) {
    _column = column;
    _value = value;
    return this;
  }

  /// Executes the delete operation and returns a [SqlBaseResponse].
  @override
  Future<dynamic> execute() async {
    if (_column!.isEmpty || _value!.isEmpty) {
      return SqlBaseResponse(
          statusCode: 0, error: "you need to use the values method first");
    }
    try {

      final response = await http.post(
        Uri.parse(_url),
        body: {
          'action': 'delete',
          'table': _table,
          'key': _key,
          'column': _column,
          'value': _value
        },
      );

      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }
}