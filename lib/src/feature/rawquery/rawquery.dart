

import 'dart:convert';
import 'package:http/http.dart' as http;
class RawQuery{
  final String _sqlCommand;
  final String _url;
  final String _key;

  RawQuery(this._sqlCommand,this._key,this._url);

  execute() async {
    final response = await http.post(
      Uri.parse(_url),
      body: {
        'key': _key,
        'action': 'rawQuery',
        'data': jsonEncode(_sqlCommand),
      },
    );
    return jsonDecode(response.body);
  }
}