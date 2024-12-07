<!-- to be modified -->

<?php
session_start();
if (!isset($_SESSION['user'])) {
    header("Location: login.php"); 
    exit();
}
include 'db_config.php';

$sql = "SELECT className, classDiv FROM class";
$result = $conn->query($sql);

$classDetails = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $classDetails[] = $row;
    }
} else {
    echo "No classes found.";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Class</title>
    <link rel="stylesheet" href="css/classes.css">
</head>
<body>
    <div class="container">
        <h1>Select a Class</h1>
        <form action="timetable.php" method="post">
            <div class="radio-buttons">
                <?php
                foreach ($classDetails as $class) {
                    echo '<label>';
                    echo '<input type="radio" name="className" value="' . $class['className'] . '" data-class-div="' . $class['classDiv'] . '" required> ';
                    echo $class['className'] . '  ' . $class['classDiv'];
                    echo '</label><br>';
                }
                ?>
            </div>
            <input type="hidden" id="classDivInput" name="classDiv" value="">
            <button type="submit" class="save-btn">Save and Next</button>
        </form>
    </div>
    <script>
        document.querySelectorAll('input[name="className"]').forEach(radio => {
            radio.addEventListener('change', function () {
                const classDiv = this.getAttribute('data-class-div');
                document.getElementById('classDivInput').value = classDiv;
            });
        });
    </script>
</body>
</html>
