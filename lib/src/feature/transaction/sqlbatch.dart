import 'dart:convert';

import '../../../sqlbase.dart';

import '../../utility/encrypt_request.dart';
import '../../utility/phpresponse.dart';
class SqlBatch {
  final List<Map> _list = [];

  final String url;
  final String key;
  SqlBatch( this.url, this.key);
  SqlBatch start(){
    _list.clear();
    return this;
  }
  SqlBatch add(String table, Map<String, dynamic> map){
    _list.add({
      "table":table,
      'type': 'single',
      "data": map
    });
    return this;
  }
  SqlBatch addMany(String table,List<Map<String, dynamic>> map){
    _list.add({
      "table":table,
      'type': 'many',
      "data": map
    });
    return this;
  }
  commit() async {

    try {
      final response = await postData(url: url, key: key, data: {
        'action': 'BATCH-INSERT',
        'table': 'batch',
        'data': jsonEncode(_list.isEmpty ? null : _list),
      });

      _list.clear();
      return phpResponse(response);
    } catch (e) {
      return SqlBaseResponse(
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
}