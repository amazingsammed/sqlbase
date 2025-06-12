import 'package:flutter/material.dart';

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
              var data = await Sqlbase.update('user')
                  .where('name', 'Sammed')
                  .set({"name": "Sammed  Twumasi"}).execute();
              print(data.toString());
            },
            child: Text('Try')),
      ),
    );
  }
}
