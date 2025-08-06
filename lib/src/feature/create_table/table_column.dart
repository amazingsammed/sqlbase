enum DataType {
  int,
  varChar,
  date,
  text,
  bool,
}

String columnTypeToString(DataType type, [int? length]) {
  switch (type) {
    case DataType.int:
      return 'INT';
    case DataType.varChar:
      return 'VARCHAR(${length ?? 255})';
    case DataType.date:
      return 'DATE';
    case DataType.text:
      return 'TEXT';
    case DataType.bool:
      return 'BOOLEAN';
  }
}


class TableColumn {
  final String name;
  final DataType type;
  final int? length;
  final bool isPrimary;
  final bool isNullable;
  final bool autoIncrement;
  final bool isUnique;
  final String? defaultValue;
  final String? check;
  final String? foreignKey;
  final String? onDelete;
  final String? onUpdate;

  TableColumn(
      this.name, {
        required this.type,
        this.length,
        this.isPrimary = false,
        this.isNullable = true,
        this.autoIncrement = false,
        this.isUnique = false,
        this.defaultValue,
        this.check,
        this.foreignKey,
        this.onDelete,
        this.onUpdate,
      });

  String toSql() {
    String sql = '`$name` ${columnTypeToString(type, length)}';

    if (!isNullable) sql += ' NOT NULL';
    if (isUnique) sql += ' UNIQUE';
    if (defaultValue != null) sql += " DEFAULT '$defaultValue'";
    if (check != null) sql += " CHECK ($check)";
    if (autoIncrement) sql += ' AUTO_INCREMENT';
    if (isPrimary) sql += ' PRIMARY KEY'; // Note: use composite primary key for multiple

    return sql;
  }

  bool get hasForeignKey => foreignKey != null && foreignKey!.contains(".");
  String get referencedTable => foreignKey!.split(".")[0];
  String get referencedColumn => foreignKey!.split(".")[1];

  String? foreignKeyConstraint() {
    if (!hasForeignKey) return null;
    String clause =
        'FOREIGN KEY (`$name`) REFERENCES `$referencedTable`(`$referencedColumn`)';
    if (onDelete != null) clause += ' ON DELETE $onDelete';
    if (onUpdate != null) clause += ' ON UPDATE $onUpdate';
    return clause;
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'type': type.name,
    'length': length,
    'isPrimary': isPrimary,
    'isNullable': isNullable,
    'autoIncrement': autoIncrement,
    'isUnique': isUnique,
    'defaultValue': defaultValue,
    'check': check,
    'foreignKey': foreignKey,
    'onDelete': onDelete,
    'onUpdate': onUpdate,
  };
}