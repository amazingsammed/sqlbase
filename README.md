# SQLbase

Dart to php to Sql database

# More contribution needed
This is the repo
https://github.com/amazingsammed/sqlbase

# Usage

* There a php file in the asset folder of this project, put it in your **http** directory or ***www folder*** of ***wampserver***
* Make sure the php ***apikey***  match the one you are initializing
```dart
Sqlbase.initialize(url: "url_to_file.php", key: '123456')
```

# In Dart
To use the plugin, run
```dart
//use this to initialize the plugin
Sqlbase.initialize(url: "http://localhost/sqlbase.php", key: '123456');
```
# Queries
This looks similar to firebase queries
```dart
// To  get all data from a table
await myDB.table("tablename").get();
```
# Sample Code
```
final mydb = Sqlbase();

final SqlTable businessDB = mydb.table('business');
final SqlTable storeDB = mydb.table('stores');
final SqlTable userstoreDB = mydb.table('user_store');
final SqlTable userbusinessDB = mydb.table('user_business');
final SqlTable users = mydb.table('users');
final SqlTable stockItemDB = mydb.table('stock_item');
final SqlTable categoryDB = mydb.table('stock_item_category');
final SqlTable groupDB = mydb.table('stock_item_group');
final SqlTable unitDB = mydb.table('stock_item_unit');
final SqlTable voucherDB = mydb.table('voucher');



 Future<List<Item>> getAllItems({required Store store}) async {
    List<Item> items = [];
    var data =
        await stockItemDB.where('storeid', isEqualTo:store.storeid).where('busid', isEqualTo:store.busid).get();
    for (var element in data.data['data']) {
      items.add(Item.fromMap(element));
    }
    return items;
  }
  
   Future<List<Groups>> getAllGroups({required Store store}) async {
    List<Groups> items = [];
    var data =
        await groupDB.where('storeid',isEqualTo: store.storeid).where('busid', isEqualTo:store.busid).get();
    for (var element in data.data['data']) {
      items.add(Groups.fromMap(element));
    }
    return items;
  }
```




