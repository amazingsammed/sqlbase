


part of 'package:sqlbase/src/feature/table/sqltable.dart';
extension SqlTogetherWith on SqlTable{

  SqlDualTable togetherWith(String table,{required  Compare basedOn}){

    return SqlDualTable(SqlTable(tableName, url, key),table,basedOn);
  }
}

class Compare{
  String firstTableColumn;
  SqlCompare compare;
  String secondTableColumn;

 Compare(this.firstTableColumn,this.compare,this.secondTableColumn);

  Map<String, dynamic> toMap() {
    return {
      'firstTable': firstTableColumn,
      'compare': compare,
      'secondTable': secondTableColumn,
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