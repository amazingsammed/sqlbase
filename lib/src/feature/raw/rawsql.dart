import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../sqlbase.dart';
import '../../utility/phpresponse.dart';

abstract class ExecutableQuery {
  Future<dynamic> execute();
}

class SelectFromStep {
  final String _url;
  final String _key;
  final List<String>? _fields;

  SelectFromStep(this._url, this._key, this._fields);

  SelectQuery from(List<String> tables) {
    return SelectQuery(_url, _key, _fields, tables);
  }
}

class SelectQuery implements ExecutableQuery {
  final String _url;
  final String _key;
  final List<String>? _fields;
  final List<String> _tables;
  String? _where;
  List<String> _joins = [];
  String? _orderBy;
  int? _limit;

  SelectQuery(this._url, this._key, this._fields, this._tables);

  SelectQuery join(String joinClause) {
    _joins.add(joinClause);
    return this;
  }

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

  SelectQuery orderBy(String field, {bool descending = false}) {
    _orderBy = "$field ${descending ? 'DESC' : 'ASC'}";
    return this;
  }

  SelectQuery limit(int count) {
    _limit = count;
    return this;
  }

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

class InsertQuery implements ExecutableQuery {
  final String _url;
  final String _table;
  final String _key;
  Map<String, dynamic> _values = {};

  InsertQuery(this._url, this._key, this._table);

  InsertQuery values(Map<String, dynamic> values) {
    _values = values;
    return this;
  }

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

class UpdateQuery implements ExecutableQuery {
  final String _url;
  final String _table;
  final String _key;
  Map<String, dynamic> _setValues = {};
  String? _column;
  String? _value;

  UpdateQuery(this._url, this._key, this._table);

  UpdateQuery set(Map<String, dynamic> values) {
    _setValues = values;
    return this;
  }

  UpdateQuery where(String column, String value) {
    _column = column;
    _value = value;
    return this;
  }

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

class DeleteQuery implements ExecutableQuery {
  final String _url;
  final String _table;
  final String _key;
  String? _column;
  String? _value;

  DeleteQuery(this._url, this._key, this._table);

  DeleteQuery where(String column, String value) {
    _column = column;
    _value = value;
    return this;
  }

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
