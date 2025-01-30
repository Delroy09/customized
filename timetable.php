<?php
session_start();

// Check if the user is logged in
if (!isset($_SESSION['user'])) {
    header("Location: index.php");
    exit();
}

// Check if the class name is passed via POST
$className = isset($_POST['className']) ? $_POST['className'] : 'No class selected';
$classDiv = isset($_POST['classDiv']) ? $_POST['classDiv'] : 'Unknown division';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Timetable</title>
    <link rel="stylesheet" href="css/timetable.css">
</head>
<body>

    <!-- Header with logo -->
    <header>
        <div class="header-container">
            <img src="img/logo - dark.svg" alt="Timely Logo" class="logo">
        </div>
    </header>

    <div class="container">
        <!-- Back button -->
        <div class="button-wrapper">
            <button onclick="window.location.href='class.php'">Back</button>
        </div>
        <br><br>

        <!-- Display the selected class name -->
        <h2 class="class-title">Class: <?php echo htmlspecialchars($className); ?> - <?php echo htmlspecialchars($classDiv); ?></h2>
        <br>

        <!-- Timetable buttons -->
        <div class="button-wrapper">
            <button data-btn type="button">Generate Timetable</button>
            <button class="clear-button" data-clear type="button">Clear Timetable</button>
        </div>
        <br>

        <!-- Timetable Grid -->
        <div class="grid">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Time</th>
                        <th scope="col">Monday</th>
                        <th scope="col">Tuesday</th>
                        <th scope="col">Wednesday</th>
                        <th scope="col">Thursday</th>
                        <th scope="col">Friday</th>
                        <th scope="col">Saturday</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th scope="row">8:15am</th>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                    </tr>
                    <tr>
                        <th scope="row">9:15am</th>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                    </tr>
                    <!-- Lunch Break Row -->
                    <tr class="lunch-row">
                        <th scope="row">10:15am</th>
                        <td colspan="7">Lunch Break</td>
                    </tr>
                    <tr>
                        <th scope="row">10:45am</th>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                    </tr>
                    <tr>
                        <th scope="row">11:45am</th>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                    </tr>
                    <tr>
                        <th scope="row">12:45pm</th>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                        <td data-cell></td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <!-- Notes section -->
        <div id="notes-section">
            <h2 class="note">Add a Note</h2>
            <input type="text" id="note-input" placeholder="Enter your note here">
            <button id="add-note-btn">Add Note</button>
            <ul id="notes-list"></ul>
        </div>

        <!-- Settings panel -->
        <div id="settings-panel">
            <h2>Customize Timetable</h2>
            <label for="cell-color">Cell Background Color:</label>
            <input type="color" id="cell-color" name="cell-color">
            <br>
            <label for="font-color">Font Color:</label>
            <input type="color" id="font-color" name="font-color">
            <br>
            <label for="font-size">Font Size:</label>
            <input type="number" id="font-size" name="font-size" min="10" max="30">
            <br>
            <button id="reset-settings-btn" class="small-button">Reset</button>
        </div>

        <br><br>
        <button id="print-btn" onclick="window.print()">Print</button>
    </div>

    <script src="scripts/script.js"></script>
    <script src="scripts/contextMenu.js"></script>
</body>
</html>
