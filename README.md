# SQLbase

**SQLbase** is a lightweight Flutter plugin that enables seamless communication between a Flutter app and an SQL database through a simple PHP backend. It’s designed to function similarly to Firebase queries, making it easy and intuitive to use.



## 🚀 Features

- Connects Flutter with MySQL using PHP
- Easy query interface inspired by Firebase
- Lightweight and easy to integrate
- Supports CRUD operations (Create, Read, Update, Delete)
- Supports advanced SQL features like filtering, ordering, and grouping



## 📦 Installation

Add `sqlbase` to your `pubspec.yaml` file:

```yaml
dependencies:
  sqlbase: 0.0.4^ # Replace with the latest version
```

Then run:

```bash
flutter pub get
```



## ⚙️ Setup Guide

### 1. Download the PHP Script
**Link**  - https://github.com/amazingsammed/sqlbase/blob/master/asset/sqlbase.php


### 2. Deploy the Script

Place the downloaded PHP file in your server’s root directory:

- For **WAMP**, place it in the `www/` folder
- For other servers, use the respective public folder

### 3. Configure the PHP Script

Open the script and set your database configuration:

```php
$host = 'Your_Address';
$dbname = 'Your_Database_Name';
$username = 'Your_Username';
$password = 'Your_Password';

// API key must match the one used in your Flutter app
$apiKey = '123456';
```

## 📘 Usage Guide

### Initialize

```dart
final Sqlbase.initialize(url: "http://localhost/sqlbase.php", key: '123456');
final myDB = Sqlbase();

///  Read Data
await myDB.table("users").get();

///  Insert Data
await myDB.table("users").add({
  "name": "Flutter",
  "year": 2015,
});

///  Update Data
await myDB.table("users").record("1", column: "id").update({
  "name": "Next.js",
  "year": 2019,
});

///  Delete Data
await myDB.table("users").record("1", column: "id").delete();

```





##  Database Methods

- `.table("column")`
- `.select([])`
- `.insertInto("tablename")`
- `.deleteFrom("tablename")`
- `.auth("tablename")`




##  Table Methods

- `.where("column", isEqualTo: "value")`
- `.isEqualTo({"column": "value"})`
- `.limit(10)`
- `.orderBy("column", "ASC" or "DESC")`
- `.groupBy("column")`
- `.get()`
- `.add(Map<String, dynamic> data)`
- `.addMany(List<Map<String, dynamic>> dataList)`

##  Record Methods

- `.update(Map<String, dynamic> newData)`
- `.delete()`



##  Best Practices

- Ensure the API key in your PHP file and Flutter app **match**
- Use HTTPS in production for secure communication
- Use environment variables or a secure config file for DB credentials



##  Examples

```dart
// Read with condition
await myDB.table("products").where("price", isEqualTo: 100).get();

// Group and order
await myDB.table("users").groupBy("gender").orderBy("id", "DESC").limit(5).get();
```



## 🤝 Contributing

We welcome contributions! Feel free to fork the repo and submit pull requests.

🔗 GitHub: [https://github.com/amazingsammed/sqlbase](https://github.com/amazingsammed/sqlbase)



## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

