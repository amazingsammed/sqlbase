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




