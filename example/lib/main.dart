import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sqlbase/sqlbase.dart';

void main() {
  Sqlbase.initialize(url: "http://localhost/sqlbase.php", key: '123456');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  Home({super.key});

  final Sqlbase myDB = Sqlbase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              var items = await myDB.table('subjects').record(23,column: 'id').update(
                  {
                    'subject':"Ghana 1",
                    "id":24
                  });
              print(items.message);
              print(items.error);
              print(items.statusCode);
              print(items.message);
              },
            child: Text('Try')),
      ),
    );
  }
}
