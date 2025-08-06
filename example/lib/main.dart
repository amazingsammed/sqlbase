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
            onPressed: createTable,
            child: Text('Try')),
      ),
    );
  }
}









createTable(){
  Sqlbase.createTable([
    SQLTable(
      name:"Users",
      column: [
        TableColumn("id",type: DataType.int,length:11,isPrimary:true,autoIncrement:true),
        TableColumn("name",type: DataType.varChar,length:225),
        TableColumn("email",type: DataType.varChar,length:225),
        TableColumn("createddate",type: DataType.date),
      ]
    ),
    SQLTable(
        name:"Business",
        column: [
          TableColumn("id",type: DataType.int,isPrimary:true,autoIncrement:true),
          TableColumn("userid",type: DataType.int,foreignKey:'Users.id',autoIncrement:true),
          TableColumn("name",type: DataType.varChar),
          TableColumn("address",type: DataType.varChar),
          TableColumn("createddate",type: DataType.date),
        ]
    ),
  ]);
}
insertRecord() async {
  var data = await Sqlbase.insertInto('users').values({'name': "Sammed", 'from': 'Ghana'}).execute();

  if (data.statusCode != 200) {

  }
}
selectRecord() async {
  var data = await Sqlbase.select([]).from(['users']).execute();

  if (data.statusCode != 200) {

  }

}

updateRecord() async {
  var data = await Sqlbase.update('user').where('id', "25").execute();

  if (data.statusCode != 200) {
  }
}

deleteRecord() async {
  var data = await Sqlbase.deleteFrom('user').where('id', "25").execute();

  if (data.statusCode != 200) {
  }
}

rawQuery() async {
  var data = await Sqlbase.rawQuery("Select * from users").execute();

  if (data.statusCode != 200) {
  }
}



createRecordEasy() async {
  Sqlbase myDB = Sqlbase();
  var data = await myDB.table('user').add({'name': "Sammed", 'from': 'Ghana'});
  if (data.statusCode != 200) {
  }
}

createRecordManyEasy() async {
  Sqlbase myDB = Sqlbase();
  var data = await myDB.table('user').addMany([
    {'name': "Sammed", 'from': 'Ghana'},
    {'name': "Ronaldo", 'from': 'Portugal'},
    {'name': "MBS", 'from': 'Saudi Arabia'}
  ]);
  if (data.statusCode != 200) {
  }
}

updateRecordEasy() async {
  Sqlbase myDB = Sqlbase();
  var data = await myDB.table('user').record(1, column: 'id').update(
    {'name': "Sammed", 'from': 'Ghana'},
  );
  if (data.statusCode != 200) {
  }
}

deleteRecordEasy() async {
  Sqlbase myDB = Sqlbase();
  var data = await myDB.table('user').record(1, column: 'id').delete();
  if (data.statusCode != 200) {
  }
}
