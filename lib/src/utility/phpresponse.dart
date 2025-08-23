import 'dart:convert';

import 'package:http/http.dart';
import 'package:sqlbase/src/utility/sqlbaseresponse.dart';

SqlBaseResponse phpResponse(Response results) {
  if (results.statusCode != 200) {
    return SqlBaseResponse(statusCode: 0, error: results.body);
  }
  var data = jsonDecode(results.body);
 if(data is Map && data.containsKey('error')) return SqlBaseResponse(statusCode: 0,error: results.body);
 if(data.containsKey('success')){
 return SqlBaseResponse(statusCode: 200, data: data);
 }
  return SqlBaseResponse(statusCode: 0, error: results.body);
}
