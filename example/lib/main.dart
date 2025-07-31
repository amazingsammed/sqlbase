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
              SqlBaseResponse data  = await Sqlbase()
                  .table('voucher')
                  .where('status', isEqualTo: '1')
                  .togetherWith("user",select: [Select('name',as: "sammed")])
                  .get(basedOn: Compare('createdby', SqlCompare.equalTo, 'userid'));

              print(data);

            },
            child: Text('Try')),
      ),
    );
  }
}









createTable(){
  Sqlbase.createTable([
    DBTable(
      name:"Users",
      column: [
        DBColumn("id",type: ColumnType.int,length:11,isPrimary:true,autoIncrement:true),
        DBColumn("name",type: ColumnType.varChar,length:225),
        DBColumn("email",type: ColumnType.varChar,length:225),
        DBColumn("createddate",type: ColumnType.date),
      ]
    ),
    DBTable(
        name:"Business",
        column: [
          DBColumn("id",type: ColumnType.int,isPrimary:true,autoIncrement:true),
          DBColumn("id",type: ColumnType.int,foreignKey:'Users.id',autoIncrement:true),
          DBColumn("name",type: ColumnType.varChar),
          DBColumn("address",type: ColumnType.varChar),
          DBColumn("createddate",type: ColumnType.date),
        ]
    ),
  ]);
}
insertRecord() async {
  var data = await Sqlbase.insertInto('users').values({'name': "Sammed", 'from': 'Ghana'}).execute();

  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
  }
}
selectRecord() async {
  var data = await Sqlbase.select([]).from(['users']).execute();

  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
  }
  print(data.toString());
}

updateRecord() async {
  var data = await Sqlbase.update('user').where('id', "25").execute();

  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
  }
}

deleteRecord() async {
  var data = await Sqlbase.deleteFrom('user').where('id', "25").execute();

  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
  }
}

rawQuery() async {
  var data = await Sqlbase.rawQuery("Select * from users").execute();

  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
  }
}



createRecordEasy() async {
  Sqlbase myDB = Sqlbase();
  var data = await myDB.table('user').add({'name': "Sammed", 'from': 'Ghana'});
  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
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
    print(data.error);
    print(data.message);
  }
}

updateRecordEasy() async {
  Sqlbase myDB = Sqlbase();
  var data = await myDB.table('user').record(1, column: 'id').update(
    {'name': "Sammed", 'from': 'Ghana'},
  );
  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
  }
}

deleteRecordEasy() async {
  Sqlbase myDB = Sqlbase();
  var data = await myDB.table('user').record(1, column: 'id').delete();
  if (data.statusCode != 200) {
    print(data.error);
    print(data.message);
  }
}
