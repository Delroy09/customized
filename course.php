<?php

include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'];

    // Add course
    if ($action === 'add') {
        $courseID = $_POST['courseID'];
        $courseName = $_POST['courseName'];
        $courseInitial = $_POST['courseInitial'];
        $courseType = $_POST['courseType'];
        $isPracIncluded = $_POST['isPracIncluded'];
        $theoryHrs = $_POST['theoryHrs'];
        $pracHrs = $_POST['pracHrs'];
        $theoryCredits = $_POST['theoryCredits'];
        $pracCredits = $_POST['pracCredits'];
        $semesterID = $_POST['semesterID'];
        $programmeID = $_POST['programmeID'];
        
        $sql = "INSERT INTO course (courseID, courseName, courseInitial, courseType, isPracIncluded, theoryHrs, pracHrs, theoryCredits, pracCredits, semesterID, programmeID) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssiiiiiis", $courseID, $courseName, $courseInitial, $courseType, $isPracIncluded, $theoryHrs, $pracHrs, $theoryCredits, $pracCredits, $semesterID, $programmeID);
        $stmt->execute();
        echo json_encode(["success" => true, "message" => "Course added successfully"]);
    }

    // Delete course
    elseif ($action === 'delete') {
        $courseID = $_POST['courseID'];
        $sql = "DELETE FROM course WHERE courseID = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $courseID);
        $stmt->execute();
        echo json_encode(["success" => true, "message" => "Course deleted successfully"]);
    }

    // Update course
    elseif ($action === 'update') {
        $courseID = $_POST['courseID'];
        $courseName = $_POST['courseName'];
        $courseInitial = $_POST['courseInitial'];
        $courseType = $_POST['courseType'];
        $isPracIncluded = $_POST['isPracIncluded'];
        $theoryHrs = $_POST['theoryHrs'];
        $pracHrs = $_POST['pracHrs'];
        $theoryCredits = $_POST['theoryCredits'];
        $pracCredits = $_POST['pracCredits'];
        $semesterID = $_POST['semesterID'];
        $programmeID = $_POST['programmeID'];
        
        $sql = "UPDATE course SET courseName = ?, courseInitial = ?, courseType = ?, isPracIncluded = ?, theoryHrs = ?, pracHrs = ?, theoryCredits = ?, pracCredits = ?, semesterID = ?, programmeID = ? 
                WHERE courseID = ?";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssssiiiiiis", $courseName, $courseInitial, $courseType, $isPracIncluded, $theoryHrs, $pracHrs, $theoryCredits, $pracCredits, $semesterID, $programmeID, $courseID);
        $stmt->execute();
        echo json_encode(["success" => true, "message" => "Course updated successfully"]);
    }
}

// Fetch course list
elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $result = $conn->query("SELECT * FROM course");
    $courses = [];
    while ($row = $result->fetch_assoc()) {
        $courses[] = $row;
    }
    echo json_encode($courses);
}

$conn->close();
?>
