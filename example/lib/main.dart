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
              // Sqlbase.createTable([
              //   DBTable(
              //     name:"Users",
              //     column: [
              //       DBColumn("id",type: ColumnType.int,length:11,isPrimary:true,autoIncrement:true),
              //       DBColumn("name",type: ColumnType.varChar,length:225),
              //       DBColumn("email",type: ColumnType.varChar,length:225),
              //       DBColumn("createddate",type: ColumnType.date),
              //     ]
              //   ),
              //   DBTable(
              //       name:"Business",
              //       column: [
              //         DBColumn("id",type: ColumnType.int,isPrimary:true,autoIncrement:true),
              //         DBColumn("id",type: ColumnType.int,foreignKey:'Users.id',autoIncrement:true),
              //         DBColumn("name",type: ColumnType.varChar),
              //         DBColumn("address",type: ColumnType.varChar),
              //         DBColumn("createddate",type: ColumnType.date),
              //       ]
              //   ),
              // ]);

           SqlBaseResponse data=  await Sqlbase.rawQuery("Select * from user delete").execute();
           print(data.toString());
            },
            child: Text('Try')),
      ),
    );
  }
}
