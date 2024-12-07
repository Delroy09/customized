<?php
include 'db_config.php';

$sql = "SELECT courseInitial FROM course WHERE semesterID = 3 AND programmeID = 1";
$result = $conn->query($sql);

$data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row['courseInitial'];
    }
}

header('Content-Type: application/json');
echo json_encode($data);

$conn->close();
?>
