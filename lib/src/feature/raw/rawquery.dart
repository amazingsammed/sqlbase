

import '../../../sqlbase.dart';
import '../../utility/phpresponse.dart';
import 'package:http/http.dart' as http;

class RawQuery{
  final String _url;
  final String _key;
  final String _command;
  const RawQuery(this._url,this._key,this._command);

  Future<SqlBaseResponse> execute() async {
    try {
      final response = await http.post(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        Uri.parse(_url),
        body: {
          'key': _key,
          'action': 'RAWQUERY',
          'table': 'RAWQUERY',
          'command': _command,
        },
      );


      return phpResponse(response);
    } catch (e) {

      return SqlBaseResponse(
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
}