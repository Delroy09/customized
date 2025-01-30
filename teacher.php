<?php

include 'db_config.php';

$action = $_GET['action'] ?? $_POST['action'] ?? '';

if ($action == 'add') {
    $teacherInitial = $_POST['teacherInitial'];
    $teacherName = $_POST['teacherName'];

    $stmt = $conn->prepare("INSERT INTO teacher (teacherInitial, teacherName) VALUES (?, ?)");
    $stmt->bind_param("ss", $teacherInitial, $teacherName);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add teacher.']);
    }
    $stmt->close();
} elseif ($action == 'read') {
    $result = $conn->query("SELECT teacherInitial, teacherName FROM teacher");
    $teachers = [];

    while ($row = $result->fetch_assoc()) {
        $teachers[] = $row;
    }

    echo json_encode($teachers);
} elseif ($action == 'update') {
    $currentInitial = $_POST['currentInitial'];
    $newInitial = $_POST['newInitial'];
    $teacherName = $_POST['teacherName'];

    $stmt = $conn->prepare("UPDATE teacher SET teacherInitial = ?, teacherName = ? WHERE teacherInitial = ?");
    $stmt->bind_param("sss", $newInitial, $teacherName, $currentInitial);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update teacher.']);
    }
    $stmt->close();
} elseif ($action == 'delete') {
    $teacherInitial = $_POST['teacherInitial'];

    $stmt = $conn->prepare("DELETE FROM teacher WHERE teacherInitial = ?");
    $stmt->bind_param("s", $teacherInitial);

    if ($stmt->execute()) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete teacher.']);
    }
    $stmt->close();
}

$conn->close();
?>
