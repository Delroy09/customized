<?php
require_once 'db_config.php';

$response = array();

// Fetch semesters
$semesterQuery = "SELECT semesterID, semesterName FROM semester ORDER BY semesterID";
$semesterResult = $conn->query($semesterQuery);

$semesters = array();
while($row = $semesterResult->fetch_assoc()) {
    $semesters[] = $row;
}

// Fetch programmes
$programmeQuery = "SELECT programmeID, programmeName FROM programme ORDER BY programmeID";
$programmeResult = $conn->query($programmeQuery);

$programmes = array();
while($row = $programmeResult->fetch_assoc()) {
    $programmes[] = $row;
}

$response['semesters'] = $semesters;
$response['programmes'] = $programmes;

header('Content-Type: application/json');
echo json_encode($response);

$conn->close();
?>