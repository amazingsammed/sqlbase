import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:encrypt/encrypt.dart';

List sqlEncryptData(
    {required Map<String, dynamic> data,
    String key = 'ILOVESQLBASE2025',
    String? iv}) {
  final iv = generateReference();

  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));

  final cipherText = encrypter.encrypt(jsonEncode(data), iv: IV.fromUtf8(iv));

  return [iv, cipherText.base64];
}

Future postData({required String url,required String key,required Map<String,dynamic> data}) {
 final data2= sqlEncryptData(data: data);
 return http.post(
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $key',
      'X-Timestamp': data2[0]
    },
    Uri.parse(url),
    body: {"payload": data2[1]},
  );
}

String generateReference() {
  int micros = DateTime.now().microsecondsSinceEpoch;
  return _toBase36(micros).padLeft(16, '0').toUpperCase();
}

String _toBase36(int value) {
  const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String result = '';
  while (value > 0) {
    result = chars[value % 36] + result;
    value ~/= 36;
  }
  return result;
}
