part of 'package:sqlbase/src/feature/table/sqltable.dart';

extension LimitFilter on SqlTable {
  SqlTable limit(int limit) {
_filterList.add(SqlMap(type:'limit',field: tableName, function: '', value: limit).toMap());
    return this;
  }

}