
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utility/encrypt_request.dart';
import '../../utility/phpresponse.dart';
import '../../utility/sqlbaseresponse.dart';

class SqlAuth{
  final String tablename;
  final String url;
  final String key;
  SqlAuth(this.tablename, this.url, this.key);
  Map<String,dynamic>? currentUser;

  Future<SqlBaseResponse>signIn({required String email,required String password})async{
    try {
    password = password.trim();
    email = email.trim();
    Map<String, dynamic> userMap = {};
    userMap.addAll({'action': 'SIGN-IN','table':tablename, 'email': email, 'password': password,'key':key});
      final response = await postData(url: url, key: key, data: userMap);
      return phpResponse(response);
    } catch (e) {
      Exception(e);
      return SqlBaseResponse(statusCode: 0, error: "Something went wrong");
    }
  }

  Future<SqlBaseResponse>signUp({required String email,required String password, Map<String,dynamic>? data})async{
    try {
      password = password.trim();
      email = email.trim();
      Map<String, dynamic> userMap = {};
      userMap.addAll({'action': 'SIGN-UP','table':tablename, 'email': email, 'password': password,'data':jsonEncode(data) });
      final response = await postData(url: url, key: key, data: userMap);

      return phpResponse(response);
    } catch (e) {
      Exception(e);
      return SqlBaseResponse(statusCode: 0, error: e.toString());
    }
  }

  Future authStatus()async{
    if(currentUser!.isNotEmpty){
      return currentUser;
    }
    return null;
  }
}