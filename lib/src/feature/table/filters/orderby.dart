part of 'package:sqlbase/src/feature/table/sqltable.dart';

extension OrderbyFilter on SqlTable {
  SqlTable orderBy(String order,{String type ='ASC'}) {
    if(order.isEmpty) return this;

    _filterList.add(SqlMap(type:"orderby",field: tableName, function: type, value: order).toMap());
    return this;
  }

}
