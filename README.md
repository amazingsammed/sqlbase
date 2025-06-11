# SQLbase

Dart to php to Sql database

# More contribution needed
This is the repo
https://github.com/amazingsammed/sqlbase

# Usage
1. [Download PHP script](blob:https://github.com/7085519d-acfb-4f87-a739-50ee317c4c12)
2. Put it in your **http** directory or ***www folder*** of ***wampserver***
3. Change the initial configuration of the php file
```php 
$host = 'YourAddress';
$dbname = 'YourDatatbaseName';
$username = 'YourUsername';
$password = 'YourPassword';
/// this apikey must match with the one you provided
/// in flutter intialization.
$apiKey = '123456';
```
4. Initialize the plugin in your flutter app.
 ```dart
Sqlbase.initialize(url: "TheFile.php", key: '123456')
```

# A Complete Guide
This is the basic complete guide to use sqlbase plugin made by Sammed Technologies

```dart
/// Initialize the plugin
Sqlbase.initialize(url: "http://localhost/sqlbase.php", key: '123456');


final mydb = Sqlbase();

// To  read all data from a table
await myDB.table("tablename").get();


// To  insert  data into a table
await myDB.table("tablename").add(
{
    "name" : 'Flutter',
    "year" : 2015
});

// To  update  data in a table
await myDB.table("tablename").record("1",column:"id").update(
{
    "name" : 'Nextjs',
    "year" : 2019
});


// To  delete  data in a table
await myDB.table("tablename").record("1",column:"id").delete();

```

# Methods for table
- .where("name", isEqualto: "Sammed")
- .isEqualTo("name":"Sammed")
- .limit(10)
- .orderBy("id","ASC")
- .groupBy("gender")




