part of 'package:sqlbase/src/feature/table/sqltable.dart';

extension WhereFilter on SqlTable {
  SqlTable where(String field,
      {dynamic isEqualTo,
      dynamic isGreaterThan,
      dynamic isLessThan,
      dynamic isNotEqualTo}) {
    if (isEqualTo != null) {
      _filterList
          .add(SqlMap(field: field, function: '=', value: isEqualTo).toMap());
    } else if (isGreaterThan != null) {
      _filterList.add(
          SqlMap(field: field, function: '>', value: isGreaterThan).toMap());
    } else if (isLessThan != null) {
      _filterList
          .add(SqlMap(field: field, function: '<', value: isLessThan).toMap());
    } else if (isNotEqualTo != null) {
      _filterList.add(
          SqlMap(field: field, function: '!=', value: isNotEqualTo).toMap());
    } else {
      throw Exception('Where method need at least one criteria');
    }
    return this;
  }

  SqlTable isEqualTo(String rowname, dynamic value) {
    _filterList
        .add(SqlMap(field: rowname, function: '=', value: value).toMap());
    return this;
  }
}
