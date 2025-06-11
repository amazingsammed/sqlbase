


part of 'package:sqlbase/src/feature/table/sqltable.dart';
extension SqlTogetherWith on SqlTable{

  SqlDualTable togetherWith(String table,{ List<Select>? select}){

    return SqlDualTable(SqlTable(tableName, url, key,select: this.select),table,select);
  }
}

class Compare{
  String firstTableColumn;
  SqlCompare compare;
  String secondTableColumn;

 Compare(this.firstTableColumn,this.compare,this.secondTableColumn);

  Map<String, dynamic> toMap() {
    return {
      'table1': firstTableColumn,
      'func': "=",
      'table2': secondTableColumn,
    };
  }

  factory Compare.fromMap(Map<String, dynamic> map) {
    return Compare(
      map['firstTable'] as String,
       map['compare'] as SqlCompare,
       map['secondTable'] as String,
    );
  }
}

enum SqlCompare{
  equalTo,
  noEqualTo
}