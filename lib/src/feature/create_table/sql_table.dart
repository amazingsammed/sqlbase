import 'package:sqlbase/src/feature/create_table/table_column.dart';
export  'package:sqlbase/src/feature/create_table/table_column.dart';

class SQLTable {
  final String name;
  final List<TableColumn> column;
  final List<String> compositePrimaryKeys;

  SQLTable({
    required this.name,
    required this.column,
    this.compositePrimaryKeys = const [],
  });

  String toCreateTableSql() {
    List<String> cols = column.map((col) => col.toSql()).toList();
    List<String> constraints = [];

    if (compositePrimaryKeys.isNotEmpty) {
      constraints.add(
          'PRIMARY KEY (${compositePrimaryKeys.map((k) => '`$k`').join(', ')})');
    }

    for (var col in column) {
      final fk = col.foreignKeyConstraint();
      if (fk != null) constraints.add(fk);
    }

    final allLines = [...cols, ...constraints].join(',\n  ');
    return 'CREATE TABLE `$name` (\n  $allLines\n);';
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'columns': column.map((c) => c.toMap()).toList(),
    'compositePrimaryKeys': compositePrimaryKeys,
  };
}