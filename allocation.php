<?php

include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'];

    // Add allocation
    if ($action === 'add') {
        $teacherInitial = $_POST['teacherInitial'];
        $courseID = $_POST['courseID'];
        $classNo = $_POST['classNo'];
        $lab = $_POST['lab'];
        $semesterID = $_POST['semesterID'];
        $programmeID = $_POST['programmeID'];

        $sql = "INSERT INTO coursealloc (teacherInitial, courseID, classNo, lab, semesterID, programmeID) 
                VALUES (?, ?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssss", $teacherInitial, $courseID, $classNo, $lab, $semesterID, $programmeID);
        $stmt->execute();
        echo json_encode(["success" => true, "message" => "Allocation added successfully"]);
    }

    // Delete allocation
    elseif ($action === 'delete') {
        $allocationID = $_POST['allocationID'];
        $sql = "DELETE FROM coursealloc WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $allocationID);
        $stmt->execute();
        echo json_encode(["success" => true, "message" => "Allocation deleted successfully"]);
    }

    // Update allocation
    elseif ($action === 'update') {
        $allocationID = $_POST['allocationID'];
        $teacherInitial = $_POST['teacherInitial'];
        $courseID = $_POST['courseID'];
        $classNo = $_POST['classNo'];
        $lab = $_POST['lab'];
        $semesterID = $_POST['semesterID'];
        $programmeID = $_POST['programmeID'];
        
        $sql = "UPDATE coursealloc 
                SET teacherInitial = ?, courseID = ?, classNo = ?, lab = ?, semesterID = ?, programmeID = ?
                WHERE id = ?";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssssi", $teacherInitial, $courseID, $classNo, $lab, $semesterID, $programmeID, $allocationID);
        $stmt->execute();
        echo json_encode(["success" => true, "message" => "Allocation updated successfully"]);
    }
}

// Fetch allocation list
elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $result = $conn->query("SELECT * FROM coursealloc");
    $allocations = [];
    while ($row = $result->fetch_assoc()) {
        $allocations[] = $row;
    }
    echo json_encode($allocations);
}

$conn->close();
?>
