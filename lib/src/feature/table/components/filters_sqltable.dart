part of 'package:sqlbase/src/feature/table/sqltable.dart';

extension Filters on SqlTable {
  SqlTable groupBy(String group) {
    if (group.isEmpty) return this;
    _filterList.add(SqlMap(
            type: 'groupby', field: tableName, function: 'group', value: group)
        .toMap());

    return this;
  }

  SqlTable join(List<dynamic> join) {

    return this;
  }
  SqlTable limit(int limit) {
    _filterList.add(SqlMap(type:'limit',field: tableName, function: '', value: limit).toMap());
    return this;
  }

  SqlTable orderBy(String order,{String type ='ASC'}) {
    if(order.isEmpty) return this;

    _filterList.add(SqlMap(type:"orderby",field: tableName, function: type, value: order).toMap());
    return this;
  }

  SqlDualTable togetherWith(String table,{ List<Select>? select}){

    return SqlDualTable(SqlTable(tableName, url, key,select: this.select),table,select,_filterList);
  }

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