<?php

include 'db_config.php';

$response = [];

if (isset($_GET['programmeID']) && isset($_GET['semesterID'])) {
    // Fetch filtered course IDs based on programmeID and semesterID
    $programmeID = intval($_GET['programmeID']);
    $semesterID = intval($_GET['semesterID']);
    $stmt = $conn->prepare("SELECT DISTINCT courseID FROM course WHERE programmeID = ? AND semesterID = ?");
    $stmt->bind_param("ii", $programmeID, $semesterID);
    $stmt->execute();
    $result = $stmt->get_result();
    $response['courseIDs'] = [];
    while ($row = $result->fetch_assoc()) {
        $response['courseIDs'][] = $row['courseID'];
    }
    $stmt->close();
} else {
    // Default data fetch for initial dropdown population
    // Fetch distinct teacher initials
    $sql = "SELECT DISTINCT teacherInitial, teacherName FROM teacher";
    $result = $conn->query($sql);
    $response['teacherInitials'] = [];
    while ($row = $result->fetch_assoc()) {
    $response['teacherInitials'][] = $row['teacherInitial'] . " - " . $row['teacherName'];
    }


    // Fetch distinct course IDs
    $sql = "SELECT DISTINCT courseID FROM course";
    $result = $conn->query($sql);
    $response['courseIDs'] = [];
    while ($row = $result->fetch_assoc()) {
        $response['courseIDs'][] = $row['courseID'];
    }

    // Fetch distinct class numbers
    $sql = "SELECT DISTINCT classNo FROM class";
    $result = $conn->query($sql);
    $response['classNo'] = [];
    while ($row = $result->fetch_assoc()) {
        $response['classNo'][] = $row['classNo'];
    }

    // Fetch distinct semester IDs
    $sql = "SELECT DISTINCT semesterID FROM semester";
    $result = $conn->query($sql);
    $response['semesterIDs'] = [];
    while ($row = $result->fetch_assoc()) {
        $response['semesterIDs'][] = $row['semesterID'];
    }

    // Fetch distinct programme IDs
    $sql = "SELECT DISTINCT programmeID FROM programme";
    $result = $conn->query($sql);
    $response['programmeIDs'] = [];
    while ($row = $result->fetch_assoc()) {
        $response['programmeIDs'][] = $row['programmeID'];
    }
}

// Output the response as JSON
header('Content-Type: application/json');
echo json_encode($response);

$conn->close();
?>
