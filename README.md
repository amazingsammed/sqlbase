# SQLbase

**SQLbase** is a lightweight Flutter plugin that enables seamless communication between a Flutter app and an SQL database through a simple PHP backend. It’s designed to function similarly to Firebase queries, making it easy and intuitive to use.

---

## 🚀 Features

- Connects Flutter with MySQL using PHP
- Easy query interface inspired by Firebase
- Lightweight and easy to integrate
- Supports CRUD operations (Create, Read, Update, Delete)
- Supports advanced SQL features like filtering, ordering, and grouping

---

## 📦 Installation

Add `sqlbase` to your `pubspec.yaml` file:

```yaml
dependencies:
  sqlbase: 0.0.3^ # Replace with the latest version
```

Then run:

```bash
flutter pub get
```

---

## ⚙️ Setup Guide

### 1. Download the PHP Script
**Link**  - https://github.com/amazingsammed/sqlbase/blob/master/asset/sqlbase.php

👉 [Download the PHP Script](blob\:https://github.com/7085519d-acfb-4f87-a739-50ee317c4c12)

### 2. Deploy the Script

Place the downloaded PHP file in your server’s root directory:

- For **WAMP**, place it in the `www/` folder
- For other servers, use the respective public folder

### 3. Configure the PHP Script

Open the script and set your database configuration:

```php
$host = 'YourAddress';
$dbname = 'YourDatabaseName';
$username = 'YourUsername';
$password = 'YourPassword';

// API key must match the one used in your Flutter app
$apiKey = '123456';
```

### 4. Initialize the Plugin in Flutter

```dart
Sqlbase.initialize(url: "http://localhost/sqlbase.php", key: '123456');
```

---

## 📘 Usage Guide

### Initialize

```dart
Sqlbase.initialize(url: "http://localhost/sqlbase.php", key: '123456');
final myDB = Sqlbase();
```

### 🔍 Read Data

```dart
await myDB.table("users").get();
```

### ➕ Insert Data

```dart
await myDB.table("users").add({
  "name": "Flutter",
  "year": 2015,
});
```

### ✏️ Update Data

```dart
await myDB.table("users").record("1", column: "id").update({
  "name": "Next.js",
  "year": 2019,
});
```

### ❌ Delete Data

```dart
await myDB.table("users").record("1", column: "id").delete();
```

---

## 🧰 Table Methods

- `.where("column", isEqualTo: "value")`
- `.isEqualTo({"column": "value"})`
- `.limit(10)`
- `.orderBy("column", "ASC" or "DESC")`
- `.groupBy("column")`
- `.get()`
- `.add(Map<String, dynamic> data)`
- `.addMany(List<Map<String, dynamic>> dataList)`

## 🧾 Record Methods

- `.update(Map<String, dynamic> newData)`
- `.delete()`

---

## 📌 Best Practices

- Ensure the API key in your PHP file and Flutter app **match**
- Use HTTPS in production for secure communication
- Validate all user inputs to prevent SQL injection
- Use environment variables or a secure config file for DB credentials

---

## 💡 Examples

```dart
// Read with condition
await myDB.table("products").where("price", isEqualTo: 100).get();

// Group and order
await myDB.table("users").groupBy("gender").orderBy("id", "DESC").limit(5).get();
```

---

## 🧪 Testing

To test locally:

1. Use a tool like **Postman** to verify the PHP script response
2. Check database connection and permissions
3. Enable PHP error display for debugging:
   ```php
   ini_set('display_errors', 1);
   error_reporting(E_ALL);
   ```

---

## 🤝 Contributing

We welcome contributions! Feel free to fork the repo and submit pull requests.

🔗 GitHub: [https://github.com/amazingsammed/sqlbase](https://github.com/amazingsammed/sqlbase)

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

