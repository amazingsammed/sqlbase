<?php
header('Content-Type: application/json');

$host = 'localhost';
$dbname = 'store_app';
$dbname = 'grok_store';
$username = 'root';
$password = '';
$accessToken = '123456';
$encryptionKey = 'ILOVESQLBASE2025';

$header = getallheaders();


if (!isset($header['authorization']) || str_replace("Bearer ", "", $header['authorization']) !== $accessToken) {
    die(json_encode(['error' => 'Contact The Developer: Error Key']));
}

if (!isset($_POST['payload'])) {
    die(json_encode(['error' => 'Contact The Developer: Error Payload']));
}
if (!isset($header['x-timestamp'])) {
    die(json_encode(['error' => 'Contact The Developer: Error Timestamp']));
}

$payload = base64_decode($_POST['payload']);
$decrypt = openssl_decrypt($payload, "AES-128-CBC", $encryptionKey, OPENSSL_RAW_DATA, $header['x-timestamp']);
$postData = json_decode($decrypt, true);

//die(json_encode(['error' => $postData]));

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Get request parameters
    $action = $postData['action'] ?? '';
    $table = $postData['table'] ?? '';
    $data = isset($postData['data']) ? json_decode($postData['data'], true) : [];
    $conditions = isset($postData['conditions']) ? json_decode($postData['conditions'], true) : [];
    $select = isset($postData['select']) ? json_decode($postData['select'], true) : [];
    $table1 = $postData['table'] ?? '';
    $table2 = $postData['table2'] ?? '';
    $table1select = isset($postData['table1-select']) ? json_decode($postData['table1-select'], true) : [];
    $table2select = isset($postData['table2-select']) ? json_decode($postData['table2-select'], true) : [];
    $basedOn = isset($postData['based-on']) ? json_decode($postData['based-on'], true) : [];
    $where = $postData['where'] ?? '';
    $orderBy = $postData['orderBy'] ?? '';
    $limit = $postData['limit'] ?? '';
    $joins = json_decode($postData['joins'] ?? '[]', true);
    $email = $postData['email'] ?? '';
    $password = $postData['password'] ?? '';
    $newpassword = $postData['newpassword'] ?? '';
    $adminUserid = $postData['adminid'] ?? '';

    function escapeIdentifier($input): string
    {
        return preg_replace('/[^a-zA-Z0-9_\\.]/', '', $input);
    }

    // Validate inputs
    if (empty($action) || empty($table)) {
        http_response_code(400);
        die(json_encode(['error' => 'Missing action or table']));
    }
    if (!preg_match('/^[a-zA-Z0-9_]+$/', $table)) {
        http_response_code(400);
        die(json_encode(['error' => 'Invalid table name']));
    }

    switch ($action) {
        case "RAWQUERY":
            if (!isset($postData['command'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid command']);
                break;
            }
            $sql = $postData['command'];
            if (stripos(strtolower($sql), 'delete') !== false || stripos(strtolower($sql), 'update') !== false) {
                http_response_code(403);
                echo json_encode(['error' => 'Delete and update commands are not supported']);
                break;
            }
            $stmt = $pdo->prepare($sql);
            $stmt->execute();
            echo json_encode(['success' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;

        case "SIGN-UP":
            if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !$password || empty($data)) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid email, password, or data']);
                break;
            }
            $stmt = $pdo->prepare("SELECT * FROM `$table` WHERE email = ?");
            $stmt->execute([$email]);
            if ($stmt->fetch()) {
                http_response_code(409);
                echo json_encode(['error' => 'User already exists']);
                break;
            }
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $uuid = generateUUIDv4();
            $columns = implode(', ', array_map('escapeIdentifier', array_keys($data)));
            $placeholders = ':' . implode(', :', array_keys($data));
            $sql = "INSERT INTO `$table` (userid, email, password, $columns) VALUES (:uuid, :email, :password, $placeholders)";
            $stmt = $pdo->prepare($sql);
            $stmt->bindValue(':uuid', $uuid);
            $stmt->bindValue(':email', $email);
            $stmt->bindValue(':password', $hashedPassword);
            foreach ($data as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->execute();
            $stmt = $pdo->prepare("SELECT * FROM `$table` WHERE email = ?");
            $stmt->execute([$email]);
            $newUser = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['success' => true, 'data' => $newUser]);
            break;

        case 'SIGN-IN':
            if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !$password) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid email or password']);
                break;
            }
            $stmt = $pdo->prepare("SELECT * FROM `$table` WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$user) {
                http_response_code(401);
                echo json_encode(['error' => 'User does not exist']);
                break;
            }
            if (!password_verify($password, $user['password'])) {
                http_response_code(401);
                echo json_encode(['error' => 'Invalid email or password']);
                break;
            }
            echo json_encode(['success' => true, 'data' => $user]);
            break;

        case 'CHANGEPWD':
            if (!filter_var($email, FILTER_VALIDATE_EMAIL) || !$password) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid email or password']);
                break;
            }
            $stmt = $pdo->prepare("SELECT * FROM `$table` WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$user) {
                http_response_code(401);
                echo json_encode(['error' => 'User does not exist']);
                break;
            }
            if (!password_verify($password, $user['password'])) {
                http_response_code(401);
                echo json_encode(['error' => 'Invalid email or password']);
                break;
            }
            $hashedPassword = password_hash($newpassword, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("UPDATE `$table` SET password = '$hashedPassword' WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['success' => true, 'data' => $user]);
            break;

        case 'ADMINCHANGEPWD':
            $stmt = $pdo->prepare("SELECT * FROM `$table` WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$user) {
                http_response_code(401);
                echo json_encode(['error' => 'User does not exist']);
                break;
            }
            $hashedPassword = password_hash($newpassword, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("UPDATE `$table` SET password = '$hashedPassword' , editedby = '$adminUserid' WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['success' => true, 'data' => $user]);
            break;

        case 'TABLE-GET':
            $columns = [];
            if (!empty($select)) {
                foreach ($select as $field) {
                    if (!isset($field['name'])) continue;
                    $colName = escapeIdentifier($field['name']);
                    $alias = isset($field['as']) ? escapeIdentifier($field['as']) : $colName;
                    $columns[] = "`$colName` AS `$alias`";
                }
            }
            $selectClause = empty($columns) ? '*' : implode(", ", $columns);
            $sql = "SELECT $selectClause FROM `$table`";
            $params = [];
            $whereClauses = [];
            $paramIndex = 0;

            if (!empty($conditions) && is_array($conditions)) {
                foreach ($conditions as $element) {
                    $type = strtolower($element['type'] ?? '');
                    $field = escapeIdentifier($element['field'] ?? '');
                    $operator = strtoupper(trim($element['function'] ?? '='));
                    $value = $element['value'] ?? '';

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
                        $orderBy = in_array($dir, ['ASC', 'DESC']) ? " ORDER BY `$value` $dir" : " ORDER BY `$value` ASC";
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
            $sql .= ($groupBy ?? '') . ($orderBy ?? '') . ($limit ?? '');

            try {
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo json_encode(['success' => true, 'data' => $results]);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Query failed: ' . $e->getMessage()]);
            }
            break;

        case 'TABLE-ADD':
            if (empty($data)) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid data']);
                break;
            }
            $columns = implode(', ', array_map('escapeIdentifier', array_keys($data)));
            $placeholders = ':' . implode(', :', array_keys($data));
            $sql = "INSERT INTO `$table` ($columns) VALUES ($placeholders)";
            $stmt = $pdo->prepare($sql);
            foreach ($data as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->execute();
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
            break;

        case 'TABLE-ADDMANY':
            if (!is_array($data) || empty($data)) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid data']);
                break;
            }
            $columns = implode(', ', array_map('escapeIdentifier', array_keys($data[0])));
            $placeholders = ':' . implode(', :', array_keys($data[0]));
            $sql = "INSERT INTO `$table` ($columns) VALUES ($placeholders)";
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
            if (empty($conditions)) {
                http_response_code(400);
                echo json_encode(['error' => 'No conditions provided']);
                break;
            }
            $sql = "DELETE FROM `$table`";
            $whereClauses = [];
            $params = [];
            $paramIndex = 0;
            foreach ($conditions as $element) {
                $field = escapeIdentifier($element['field'] ?? '');
                $value = $element['value'] ?? '';
                $paramName = ":param$paramIndex";
                $whereClauses[] = "`$field` = $paramName";
                $params[$paramName] = $value;
                $paramIndex++;
            }
            if (!empty($whereClauses)) {
                $sql .= ' WHERE ' . implode(' AND ', $whereClauses);
            }
            try {
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                echo json_encode(['success' => true, 'affected_rows' => $stmt->rowCount()]);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Delete failed: ' . $e->getMessage()]);
            }
            break;

        case 'RECORD-UPDATE':
            if (empty($data) || empty($conditions)) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid data or conditions']);
                break;
            }
            $setParts = [];
            foreach ($data as $key => $value) {
                $setParts[] = "`" . escapeIdentifier($key) . "` = :set_$key";
            }
            $setClause = implode(', ', $setParts);
            $whereParts = [];
            $params = [];
            foreach ($conditions as $index => $cond) {
                $field = escapeIdentifier($cond['field']);
                $param = ":cond_$index";
                $whereParts[] = "`$field` = $param";
                $params["cond_$index"] = $cond['value'];
            }
            $whereClause = implode(' AND ', $whereParts);
            $sql = "UPDATE `$table` SET $setClause WHERE $whereClause";
            $stmt = $pdo->prepare($sql);
            foreach ($data as $key => $value) {
                $stmt->bindValue(":set_$key", $value);
            }
            foreach ($params as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->execute();
            echo json_encode(['success' => true, 'rowsAffected' => $stmt->rowCount()]);
            break;

        case 'BATCH-INSERT':
            if (!is_array($data) || empty($data)) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid data']);
                break;
            }
            try {
                $pdo->beginTransaction();
                foreach ($data as $batch) {
                    $table = escapeIdentifier($batch['table']);
                    $type = $batch['type'];
                    $data = $batch['data'];
                    if ($type === 'single') {
                        insertRow($pdo, $table, $data);
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
                echo json_encode(['error' => 'Transaction failed: ' . $e->getMessage()]);
            }
            break;

        case "GET-DUAL-TABLE":
            $table1 = escapeIdentifier($table1);
            $table2 = escapeIdentifier($table2);
            $table1Cols = buildColumns($table1select, $table1);
            $table2Cols = buildColumns($table2select, $table2);
            $selectClause = implode(", ", array_merge(empty($table1Cols) ? ["`$table1`.*"] : $table1Cols, empty($table2Cols) ? ["`$table2`.*"] : $table2Cols));
            $selectClause = empty($selectClause) ? "*" : $selectClause;
            $col1 = escapeIdentifier($basedOn[0]['table1'] ?? '');
            $col2 = escapeIdentifier($basedOn[0]['table2'] ?? '');
            $operator = in_array($basedOn[0]['func'] ?? '=', ['=', '<', '>', '<=', '>=']) ? $basedOn[0]['func'] : '=';
            $whereCondition = "`$table1`.`$col1` $operator `$table2`.`$col2`";
            $sql = "SELECT DISTINCT $selectClause FROM `$table1`, `$table2` WHERE $whereCondition";
            $params = [];
            $whereClauses = [];
            $paramIndex = 0;

            if (!empty($conditions) && is_array($conditions)) {
                foreach ($conditions as $element) {
                    $type = strtolower($element['type'] ?? '');
                    $field = escapeIdentifier($element['field'] ?? '');
                    $operator = strtoupper(trim($element['function'] ?? '='));
                    $value = $element['value'] ?? '';
                    if ($type === 'where') {
                        $allowedOperators = ['=', '!=', '<', '<=', '>', '>=', 'LIKE'];
                        if (!in_array($operator, $allowedOperators)) {
                            $operator = '=';
                        }
                        $paramName = ":param$paramIndex";
                        $whereClauses[] = "`$table1`.`$field` $operator $paramName";
                        $params[$paramName] = $value;
                        $paramIndex++;
                    } elseif ($type === 'groupby') {
                        $sql .= " GROUP BY `$value`";
                    } elseif ($type === 'orderby') {
                        $dir = strtoupper($operator);
                        $sql .= in_array($dir, ['ASC', 'DESC']) ? " ORDER BY `$value` $dir" : " ORDER BY `$value` ASC";
                    } elseif ($type === 'limit') {
                        if (is_numeric($value)) {
                            $sql .= " LIMIT " . intval($value);
                        }
                    } elseif ($type === 'offset') {
                        if (is_numeric($value)) {
                            $sql .= " OFFSET " . intval($value);
                        }
                    }
                }
            }

            if (!empty($whereClauses)) {
                $sql .= " AND " . implode(' AND ', $whereClauses);
            }

            try {
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo json_encode(['success' => true, 'data' => $results]);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Query failed: ' . $e->getMessage()]);
            }
            break;

        case 'select':
            $select = json_decode($postData['select'] ?? '[]', true);
            $from = json_decode($postData['from'] ?? '[]', true);
            if (empty($from)) {
                http_response_code(400);
                echo json_encode(['error' => 'FROM clause is required for SELECT']);
                break;
            }
            $selectEscaped = empty($select) ? '*' : implode(", ", array_map('escapeIdentifier', $select));
            $fromEscaped = implode(", ", array_map('escapeIdentifier', $from));
            $sql = "SELECT $selectEscaped FROM $fromEscaped";
            if (!empty($joins)) {
                foreach ($joins as $join) {
                    if (!empty($join)) {
                        $sql .= " $join";
                    }
                }
            }
            if (!empty($where)) {
                $sql .= " WHERE $where";
            }
            if (!empty($orderBy)) {
                $sql .= " ORDER BY " . escapeIdentifier($orderBy);
            }
            if (!empty($limit)) {
                $sql .= " LIMIT " . intval($limit);
            }
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
            echo json_encode(['success' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;

        case 'insert':
            $values = json_decode($postData['values'] ?? '{}', true);
            if (empty($table) || empty($values)) {
                http_response_code(400);
                echo json_encode(['error' => 'Table and values are required for INSERT']);
                break;
            }
            $columns = array_keys($values);
            $placeholders = array_map(fn($c) => ":$c", $columns);
            $sql = "INSERT INTO `" . escapeIdentifier($table) . "` (" .
                implode(", ", array_map('escapeIdentifier', $columns)) .
                ") VALUES (" . implode(", ", $placeholders) . ")";
            $stmt = $pdo->prepare($sql);
            foreach ($values as $col => $val) {
                $stmt->bindValue(":$col", $val, is_null($val) ? PDO::PARAM_NULL : PDO::PARAM_STR);
            }
            $stmt->execute();
            echo json_encode(['success' => true, 'insert_id' => $pdo->lastInsertId()]);
            break;

        case 'update':
            $set = json_decode($postData['set'] ?? '{}', true);
            if (empty($table) || empty($set)) {
                http_response_code(400);
                echo json_encode(['error' => 'Table and SET values are required for UPDATE']);
                break;
            }
            $setClauses = [];
            foreach ($set as $col => $val) {
                $ph = ":set_$col";
                $setClauses[] = "`" . escapeIdentifier($col) . "` = $ph";
                $params["set_$col"] = $val;
            }
            $sql = "UPDATE `" . escapeIdentifier($table) . "` SET " . implode(", ", $setClauses);
            if (isset($postData['column']) && isset($postData['value'])) {
                $c = escapeIdentifier($postData['column']);
                $v = escapeIdentifier($postData['value']);
                $sql .= " WHERE $c = '$v'";
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'No conditions found']);
                break;
            }
            $stmt = $pdo->prepare($sql);
            foreach ($params as $k => $v) {
                $stmt->bindValue(":$k", $v, is_null($v) ? PDO::PARAM_NULL : PDO::PARAM_STR);
            }
            $stmt->execute();
            echo json_encode(['success' => true, 'affected_rows' => $stmt->rowCount()]);
            break;

        case 'delete':
            if (empty($table)) {
                http_response_code(400);
                echo json_encode(['error' => 'Table is required for DELETE']);
                break;
            }
            $sql = "DELETE FROM `" . escapeIdentifier($table) . "`";
            if (isset($postData['column']) && isset($postData['value'])) {
                $c = escapeIdentifier($postData['column']);
                $v = escapeIdentifier($postData['value']);
                $sql .= " WHERE $c = '$v'";
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'No conditions found']);
                break;
            }
            $stmt = $pdo->prepare($sql);
            $stmt->execute();
            echo json_encode(['success' => true, 'affected_rows' => $stmt->rowCount()]);
            break;

        default:
            http_response_code(400);
            echo json_encode(['error' => 'Invalid action']);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}

function insertRow(PDO $pdo, string $table, array $data): void
{
    $columns = array_map('escapeIdentifier', array_keys($data));
    $placeholders = array_map(fn($col) => ':' . $col, $columns);
    $sql = sprintf(
        "INSERT INTO `%s` (%s) VALUES (%s)",
        escapeIdentifier($table),
        implode(', ', $columns),
        implode(', ', $placeholders)
    );
    $stmt = $pdo->prepare($sql);
    foreach ($data as $key => $value) {
        $stmt->bindValue(":$key", $value);
    }
    $stmt->execute();
}

function generateUUIDv4(): string
{
    return sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}

function sanitizeIdentifier($val): string
{
    return preg_replace('/[^a-zA-Z0-9_]/', '', $val);
}

function buildColumns($fields, $tableAlias): array
{
    $cols = [];
    if (empty($fields)) {
        return $cols;
    }
    foreach ($fields as $field) {
        if (!isset($field['name'])) continue;
        $name = sanitizeIdentifier($field['name']);
        $alias = isset($field['as']) ? sanitizeIdentifier($field['as']) : $name;
        $cols[] = "`$tableAlias`.`$name` AS `$alias`";
    }
    return $cols;
}

?>