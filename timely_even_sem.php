<?php

session_start();
if (!isset($_SESSION['loggedin'])) {
    header("Location: index.php");
    exit();
}

// Cache control headers
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

include 'db_config.php';

// Clear existing data from test table
$delete_query = "DELETE FROM test";
if (!$conn->query($delete_query)) {
    die("Error deleting data: " . $conn->error);
}
// Clear existing data from timetable table
$delete_query = "DELETE FROM timetable";
if (!$conn->query($delete_query)) {
    die("Error deleting data: " . $conn->error);
}

// Call the stored procedure to insert new data
$call_procedure = "CALL InsertEvenData()";
if (!$conn->query($call_procedure)) {
    die("Error calling procedure: " . $conn->error);
}

// Call the stored procedure to insert new data
$call_procedure = "CALL damodar()";
if (!$conn->query($call_procedure)) {
    die("Error calling procedure: " . $conn->error);
}

// Fetch unique days of the week
$days_query = "SELECT DISTINCT DayOfWeek 
               FROM timetable 
               ORDER BY FIELD(DayOfWeek, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')";

$days_result = $conn->query($days_query);

// Fetch unique periods (timeslots)
$periods_query = "SELECT DISTINCT TimeSlot FROM timetable ORDER BY TimeSlot";
$periods_result = $conn->query($periods_query);

$periods = [];
while ($row = $periods_result->fetch_assoc()) {
    $periods[] = $row['TimeSlot'];
}

// Replace existing timeslots query section with:
$timeslots_query = "SELECT timeslotID, timings, IsBreak FROM timeslot ORDER BY timeslotID";
$timeslots_result = $conn->query($timeslots_query);

$timings = [];
$recess_period = 3; // Setting recess as 3rd column
$recess_timing = "10:15 - 10:45";

while ($row = $timeslots_result->fetch_assoc()) {
    $timings[$row['timeslotID']] = $row['timings'];
}

// Add in <head> section
echo '<link rel="stylesheet" href="css/timetable.css">';
echo '<script src="JS/timetable.js"></script>';

// Add print buttons

echo '<button id="back" onclick="window.location.href=\'dashboard.php\'">Back</button>';
// echo '<div class="semester-header">Even Semester</div>';
echo "<div class='print-buttons'>";
echo "<button onclick='printAllTimetables()'>Print All Timetables</button>";
if ($days_result->num_rows > 0) {
    // Generate individual print buttons for each day
    while ($day_row = $days_result->fetch_assoc()) {
        $dayOfWeek = $day_row['DayOfWeek'];
        echo "<button onclick='printDay(\"$dayOfWeek\")'>Print $dayOfWeek</button>";
    }
    // Reset pointer to allow reuse of $days_result
    $days_result->data_seek(0);
}
echo "</div>";

$teacherColors = array();
$colorIndex = 1;

function getTeacherColorClass($teacherInitial) {
    global $teacherColors, $colorIndex;
    if (!isset($teacherColors[$teacherInitial])) {
        $teacherColors[$teacherInitial] = $colorIndex;
        $colorIndex = ($colorIndex % 25) + 1;
    }
    return "teacher-color-" . $teacherColors[$teacherInitial];
}

if ($days_result->num_rows > 0) {
    while ($day_row = $days_result->fetch_assoc()) {
        $dayOfWeek = $day_row['DayOfWeek'];
        echo "<h2> $dayOfWeek</h2>";

        echo "<table class='timetable'>";
        echo "<tr>";
        echo "<th>Class-Division</th>";
        $col_count = 1;
        foreach ($periods as $period) {
            if ($col_count == $recess_period) {
                echo "<th class='recess'>RECESS</th>";
            }
            echo "<th>" . (isset($timings[$period]) ? $timings[$period] : "Period $period") . "</th>";
            $col_count++;
        }
        echo "</tr>";

        $class_query = "SELECT DISTINCT Class, ClassDivision FROM timetable ORDER BY Class, ClassDivision";
        $class_result = $conn->query($class_query);

        while ($class_row = $class_result->fetch_assoc()) {
            $class = $class_row['Class'];
            $division = $class_row['ClassDivision'];

            echo "<tr>";
            echo "<td><strong> $class $division</strong></td>";

            $col_count = 1;
            foreach ($periods as $period) {
                if ($col_count == $recess_period) {
                    echo "<td class='recess'>-</td>";
                }
                
                $query = "SELECT SubjectCode, TeacherInitial 
                          FROM timetable 
                          WHERE DayOfWeek = '$dayOfWeek' 
                          AND TimeSlot = '$period' 
                          AND Class = '$class' 
                          AND ClassDivision = '$division'";

                $result = $conn->query($query);

                if (!$result) {
                    echo "<td>Error: " . $conn->error . "</td>";
                } elseif ($result->num_rows > 0) {
                    $row = $result->fetch_assoc();
                    $colorClass = getTeacherColorClass($row['TeacherInitial']);
                    echo "<td data-day='$dayOfWeek' data-period='$period'>";
                    echo "{$row['SubjectCode']}<br>";
                    echo "<small class='teacher-initial {$colorClass}'>";
                    echo "({$row['TeacherInitial']})";
                    echo "</small></td>";
                } else {
                    echo "<td data-day='$dayOfWeek' data-period='$period'>-</td>";
                }
                $col_count++;
            }

            echo "</tr>";
        }

        echo "</table>";
        echo "<div class='day-separator'></div>";
    }
} else {
    echo "No timetable data found.";
}

$conn->close();
?>
<button id="goToTop" title="Go to top">↑</button>
<!-- Add reset layout button -->
<button id="reset-layout" class="reset-layout-btn">Reset Layout</button>

<!-- Initialize autosave for even semester -->
<script src="JS/timetableAutosave.js"></script>
<script>
document.addEventListener('DOMContentLoaded', () => {
    new TimetableAutosave('even');
});
</script>
</body>
