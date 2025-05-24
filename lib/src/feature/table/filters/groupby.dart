part of 'package:sqlbase/src/feature/table/sqltable.dart';

extension GroupbyFilter on SqlTable {
  SqlTable groupBy(String group) {

    if(group.isEmpty) return this;
      _filterList.add(SqlMap(type:'groupby',field: tableName, function: 'group', value: group).toMap());


    return this;
  }

}