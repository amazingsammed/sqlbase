<?php
header('Content-Type: application/json');

// Configuration
$host = 'localhost';
$dbname = 'store_app';
$username = 'root';
$password = '';
$apiKey = '123456';

if (!isset($_POST['key']) || $_POST['key'] !== $apiKey) {
    die(json_encode(['error' => 'Invalid API key']));
}



try {
    // Connect to database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Get request parameters
    $action = $_POST['action'] ?? '';
    $table = $_POST['table'] ?? '';
    $data = isset($_POST['data']) ? json_decode($_POST['data'], true) : [];
    $conditions = isset($_POST['conditions']) ? json_decode($_POST['conditions'], true) : [];
    $uuid = generateUUIDv4();

    // Validate inputs
    if (empty($action) || empty($table)) {
        die(json_encode(['error' => 'Missing action or table']));
    }
    if (!preg_match('/^[a-zA-Z0-9_]+$/', $table)) {
        die(json_encode(['error' => true, 'message' => 'Invalid table name']));
    }

    switch ($action) {
        case "SIGN-UP":
            $email = $_POST['email'] ?? '';
            $password = $_POST['password'] ?? '';
            $data = json_decode($_POST['data'], true) ?? [];
            if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !$password) {
                http_response_code(400);
                echo json_encode(['error' => $email]);
                echo json_encode(['error' => $password]);
                echo json_encode(['error' => $data]);
                echo json_encode(['error' => 'Invalid input.']);
                break;
            }
            $stmt = $pdo->prepare("SELECT * FROM $table WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch();
            if ($user) {
                http_response_code(409); // Conflict
                echo json_encode(['error' => 'User already exists.']);
                break;
            }
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $dataJson = json_encode($data);


            $columns = implode(', ', array_keys($data));
            $placeholders = ':' . implode(', :', array_keys($data));

            $sql = "INSERT INTO $table (userid,email, password, $columns) VALUES ('$uuid' ,:email, :password, $placeholders)";
            $stmt = $pdo->prepare($sql);
            $stmt->bindValue(':email', $email);
            $stmt->bindValue(':password', $hashedPassword);
            foreach ($data as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->execute();
            $stmt = $pdo->prepare("SELECT * FROM $table WHERE email = ?");
            $stmt->execute([$email]);
            $newUser = $stmt->fetch();
            echo json_encode(['success' => true, 'data' => $newUser]);
            break;
        case 'SIGN-IN':
            $email = $_POST['email'] ?? '';
            $password = $_POST['password'] ?? '';
//            if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !$password) {
//                http_response_code(400);
//                echo json_encode(['error' => 'Invalid input.']);
//                break;
//            }
            $stmt = $pdo->prepare("SELECT * FROM $table WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch();
            if (!$user) {
                http_response_code(401); // Unauthorized
                echo json_encode(['error' => 'User does not exist']);
                break;

            }
            if (!password_verify($password, $user['password'])) {
                http_response_code(401); // Unauthorized
                echo json_encode(['error' => 'Invalid email or password.']);
                break;

            }
            echo json_encode(['success' => true, 'data' => $user]);
            break;

        case 'TABLE-GET':
            // Validate table name to avoid SQL injection
            if (!preg_match('/^[a-zA-Z0-9_]+$/', $table)) {
                echo json_encode(['error' => true, 'message' => 'Invalid table name']);
                break;
            }

            $sql = "SELECT * FROM `$table`";
            $params = [];
            $whereClauses = [];
            $orderBy = '';
            $groupBy = '';
            $limit = '';
            $paramIndex = 0;

            if (!empty($conditions) && is_array($conditions)) {
                foreach ($conditions as $element) {
                    $type = strtolower($element['type'] ?? '');
                    $field = $element['field'] ?? '';
                    $operator = strtoupper(trim($element['function'] ?? '='));
                    $value = $element['value'] ?? '';

                    // Validate field name
                    if (!preg_match('/^[a-zA-Z0-9_]+$/', $field)) {
                        continue;
                    }

                    if ($type === 'where') {
                        $allowedOperators = ['=', '!=', '<', '<=', '>', '>=', 'LIKE'];
                        if (!in_array($operator, $allowedOperators)) {
                            $operator = '=';
                        }
                        $paramName = ":param$paramIndex";
                        $whereClauses[] = "`$field` $operator $paramName";
                        $params[$paramName] = $value;
                        $paramIndex++;
                    } elseif ($type === 'groupby') {
                        $groupBy = " GROUP BY `$value`";
                    } elseif ($type === 'orderby') {
                        $dir = strtoupper($operator);
                        if (!in_array($dir, ['ASC', 'DESC'])) $dir = 'ASC';
                        $orderBy = " ORDER BY `$value` $dir";
                    } elseif ($type === 'limit') {
                        if (is_numeric($value)) {
                            $limit = " LIMIT " . intval($value);
                        }
                    } elseif ($type === 'offset') {
                        if (is_numeric($value)) {
                            $limit .= " OFFSET " . intval($value);
                        }
                    }
                }
            }

            if (!empty($whereClauses)) {
                $sql .= ' WHERE ' . implode(' AND ', $whereClauses);
            }

            $sql .= $groupBy . $orderBy . $limit;
            //echo json_encode(['error' => true, 'data' => $sql]);
            // break;

            try {
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo json_encode(['success' => true, 'data' => $results]);
            } catch (PDOException $e) {
                echo json_encode(['error' => true, 'message' => $e->getMessage()]);
            }
            break;

        case 'TABLE-ADD':
            $columns = implode(', ', array_keys($data));
            $placeholders = ':' . implode(', :', array_keys($data));
            $sql = "INSERT INTO $table ($columns) VALUES ($placeholders)";
            $stmt = $pdo->prepare($sql);
            foreach ($data as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->execute();
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
            break;
        case 'TABLE-ADDMANY':
            if (!is_array($data) || empty($data)) {
                echo json_encode(['message' => "Invalid Data", 'error' => 'Invalid data']);
                break;
            }

            // Get columns from the first row
            $columns = implode(', ', array_keys($data[0]));
            $placeholders = ':' . implode(', :', array_keys($data[0]));
            $sql = "INSERT INTO $table ($columns) VALUES ($placeholders)";
            $stmt = $pdo->prepare($sql);

            $insertedIds = [];

            foreach ($data as $row) {
                foreach ($row as $key => $value) {
                    $stmt->bindValue(":$key", $value);
                }
                $stmt->execute();
                $insertedIds[] = $pdo->lastInsertId();
            }

            echo json_encode(['success' => true, 'ids' => $insertedIds]);
            break;
        case 'RECORD-DELETE':
            $sql = "DELETE  FROM `$table`";
            $params = [];
            $whereClauses = [];
            $orderBy = '';
            $groupBy = '';
            $limit = '';
            $paramIndex = 0;

            if (!empty($conditions) && is_array($conditions)) {
                foreach ($conditions as $element) {
                    $type = strtolower('where');
                    $field = $element['field'] ?? '';
                    $operator = strtoupper('=');
                    $value = $element['value'] ?? '';

                    // Validate field name
                    if (!preg_match('/^[a-zA-Z0-9_]+$/', $field)) {
                        continue;
                    }

                    if ($type === 'where') {
                        // Sanitize allowed operators
                        $allowedOperators = ['=', '!=', '<', '<=', '>', '>=', 'LIKE'];
                        if (!in_array($operator, $allowedOperators)) {
                            $operator = '=';
                        }
                        $paramName = ":param$paramIndex";
                        $whereClauses[] = "`$field` $operator $paramName";
                        $params[$paramName] = $value;
                        $paramIndex++;
                    }
                }
                if (!empty($whereClauses)) {
                    $sql .= ' WHERE ' . implode(' AND ', $whereClauses);
                }

                try {
                    $stmt = $pdo->prepare($sql);
                    $stmt->execute($params);
                    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    echo json_encode(['success' => true, 'data' => $results]);
                } catch (PDOException $e) {
                    echo json_encode(['error' => true, 'message' => $e->getMessage()]);
                }
                break;
            }


            echo json_encode(['error' => true, 'message' => "No Logic"]);

            break;
        case 'RECORD-UPDATE':
            $data = json_decode($_POST['data'], true);
            $conditions = json_decode($_POST['conditions'], true);

            if (!$data || empty($conditions)) {
                echo json_encode(['success' => false, 'error' => 'Invalid data or conditions']);
                break;
            }

            // Build SET clause
            $setParts = [];
            foreach ($data as $key => $value) {
                $setParts[] = "$key = :set_$key";
            }
            $setClause = implode(', ', $setParts);

            // Build WHERE clause
            $whereParts = [];
            foreach ($conditions as $index => $cond) {
                $field = $cond['field'];
                $param = ":cond_$index";
                $whereParts[] = "$field = $param";
            }
            $whereClause = implode(' AND ', $whereParts);

            $sql = "UPDATE $table SET $setClause WHERE $whereClause";
            $stmt = $pdo->prepare($sql);

            // Bind SET values
            foreach ($data as $key => $value) {
                $stmt->bindValue(":set_$key", $value);
            }

            // Bind WHERE values
            foreach ($conditions as $index => $cond) {
                $stmt->bindValue(":cond_$index", $cond['value']);
            }

            $success = $stmt->execute();
            echo json_encode(['success' => $success, 'rowsAffected' => $stmt->rowCount()]);
            break;
        case 'BATCH-INSERT':
        $data = json_decode($_POST['data'],true);
          if (!is_array($data) || empty($data)) {
                echo json_encode(['message' => "$data", 'error' => 'Invalid data']);
                break;
            }
            try {
                $pdo->beginTransaction();

                foreach ($data as $batch) {
                    $table = $batch['table'];
                    $type = $batch['type'];
                    $data = $batch['data'];
                    if ($type === 'single') {
                      insertRow($pdo, $table, $data);
                      break;
                    } elseif ($type === 'many') {
                        foreach ($data as $row) {
                            insertRow($pdo, $table, $row);
                        }
                    } else {
                        throw new Exception("Invalid type '$type' for table '$table'");
                    }
                }

                $pdo->commit();
                echo json_encode(['success' => true]);

            } catch (Exception $e) {
                $pdo->rollBack();
                http_response_code(500);
                echo json_encode(['error' => 'Transaction failed', 'message' => $e->getMessage()]);
            }
            break;

        default:
            echo json_encode(['error' => 'Invalid action']);
    }
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}

function insertRow(PDO $pdo, string $table, array $data): void
{
    $columns = array_keys($data);
    $placeholders = array_map(fn($col) => ':' . $col, $columns);

    $sql = sprintf(
        "INSERT INTO %s (%s) VALUES (%s)",
        $table,
        implode(', ', $columns),
        implode(', ', $placeholders)
    );

    $stmt = $pdo->prepare($sql);
    foreach ($data as $key => $value) {
        $stmt->bindValue(":$key", $value);
    }
    $stmt->execute();
}

function generateUUIDv4()
{
    return sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),                 // 32 bits
        mt_rand(0, 0xffff),                                     // 16 bits
        mt_rand(0, 0x0fff) | 0x4000,                             // 16 bits, version 4
        mt_rand(0, 0x3fff) | 0x8000,                             // 16 bits, variant
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)  // 48 bits
    );
}


function testinsertRow(PDO $pdo, string $table, array $data): void
{
    $columns = array_keys($data);
    $placeholders = array_map(fn($col) => ':' . $col, $columns);

    $sql = sprintf(
        "INSERT INTO %s (%s) VALUES (%s)",
        $table,
        implode(', ', $columns),
        implode(', ', $placeholders)
    );
   echo json_encode(['error' => 'Transaction failed', 'message' => $sql]);

}

?>