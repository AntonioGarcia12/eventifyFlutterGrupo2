<?php
// Datos de conexión a la base de datos
$servername = "127.0.0.1"; // Puede ser localhost o el IP del servidor
$username = "root"; // Nombre de usuario de la base de datos
$password = ""; // Contraseña de la base de datos
$dbname = "eventifybd"; // Nombre de la base de datos

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

// Consulta para obtener los usuarios
$sql = "SELECT * FROM users"; // Ajusta esta consulta a tus necesidades
$result = $conn->query($sql);

$users = array();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row; // Agregar cada fila al array de usuarios
    }
    echo json_encode($users); // Devolver los datos en formato JSON
} else {
    echo json_encode([]);
}

$conn->close();
