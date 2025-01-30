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

$showPopup = false;
if (isset($_SESSION['login_success'])) {
    $showPopup = true;
    unset($_SESSION['login_success']); 
}

?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dashboard</title>
    <link rel="stylesheet" href="dashboard.css" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
    <script src="JS/dashboard.js" defer></script>
    <script>
      // Prevent going back to login page
      window.history.pushState(null, null, window.location.href);
      window.onpopstate = function () {
          window.history.pushState(null, null, window.location.href);
      };
    </script>
  </head>
  <body>
  <?php if ($showPopup): ?>
    <div class="login-popup">
        <span>Login Successful! Welcome To Timely</span>
        <img src="image/circle-check.svg" alt="Logo">
    </div>
<?php endif; ?>
    <div id="mobile-overlay">
        <div class="mobile-content">
            <img src="image/desktop.svg" alt="Desktop Only">
            <h2>Desktop Only</h2>
            <p>Timely is optimized for desktop and laptop devices. Please access it from a computer for the best experience.</p>
        </div>
    </div>
    <div class="sidebar" >
      <div class="logo">
          <img id="s-logo" src="image/Light.svg" alt="Timely Logo">
      </div>
      <div class="nav-container">
        <ul>
            <li><a href="#" class="nav-link" id="course-ic" onclick="activateLink(this)"><img src="image/course.svg" alt="Course Icon" class="sidebar-icon">Course</a></li>
            <li><a href="#" class="nav-link" id="teacher-ic" onclick="activateLink(this)"><img src="image/Teachers.svg" alt="Teacher Icon" class="sidebar-icon">Teacher</a></li>
            <li><a href="#" class="nav-link" id="alloc-ic" onclick="activateLink(this)"><img src="image/alloc_test.svg" alt="Allocate Icon" class="sidebar-icon">Allocate Course</a></li>
<li>
    <a href="timely_odd_sem.php" class="nav-link" id="odd-ic" onclick="showLoader(event)">
        <img src="image/ONe.svg" alt="Odd Icon" class="sidebar-icon">ODD SEM
    </a>
</li>
<li>
    <a href="timely_even_sem.php" class="nav-link" id="even-ic" onclick="showLoader(event)">
        <img src="image/between-vertical-start.svg" alt="Even Icon" class="sidebar-icon">EVEN SEM
    </a>
</li>
<div id="loader-overlay">
  <div class="blob"></div>
</div>
            <!-- <li><a href="class.php" class="nav-link" id="timetable-ic" onclick="activateLink(this)"><img src="image/calendar.svg" alt="Individual Icon" class="sidebar-icon">Generate</a></li> -->
        </ul>
        <div id="logout-section">
          <form action="logout.php" method="POST" id="logout-form">
          <button type="submit" id="logout-btn">
          <span>Logout</span>
        <img src="image/log-out.svg" alt="Logout">
          </button>
          </form>
        </div>
    </div>
  </div>

    <div class="main-content">
      <div id="teacher-section" style="display: none">
        <h2>Manage Teachers</h2>
        <form id="teacher-form" onsubmit="return false;">
        <div class="input-group">
  <label for="teacherInitial"><span class="glyphicon glyphicon-info-sign"></span> Teacher Initial</label><br />
  <input
    type="text"
    id="teacherInitial"
    name="teacherInitial"
    required
  />
</div>

<div class="input-group">
  <label for="teacherName"><span class="glyphicon glyphicon-user"></span> Teacher Name</label><br />
  <input type="text" id="teacherName" name="teacherName" required />
</div>

          <div class="input-group"></div>

          <div class="button-group">
            <button type="button" id="add" name="add">Add</button>
            <button type="reset">Clear</button>
          </div>
        </form>
      </div>

      <div id="teacher-search" style="display: none;">
        <div class="search-container">
            <img src="image/search.png" alt="Search" class="search-icon">
            <input type="text" id="searchTeacher" placeholder="Search By Name" oninput="searchTable('teacher')">
        </div>
    </div>

      <div id="teacher-data" style="display: none">
        <table id="teacher-table">
          <thead>
            <tr>
              <th>Teacher Initial</th>
              <th>Teacher Name</th>
              <th>Update</th> 
              <th>Delete</th> 
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>

      <div id="course-section" style="display: none">
        <h2>Manage Courses</h2>
        <form id="course-form" onsubmit="return false;">
        <div class="input-group">
  <label for="courseID">
    <span class="glyphicon glyphicon-book"></span> Course ID
  </label><br />
  <input type="text" id="courseID" name="courseID" required />
</div>

<div class="input-group">
  <label for="courseName">
    <span class="glyphicon glyphicon-education"></span> Course Name
  </label><br />
  <input type="text" id="courseName" name="courseName" required />
</div>

<div class="input-group">
  <label for="courseInitial">
    <span class="glyphicon glyphicon-info-sign"></span> Course Initial
  </label><br />
  <input type="text" id="courseInitial" name="courseInitial" required />
</div>

<div class="input-group">
  <label for="courseType">
    <span class="glyphicon glyphicon-file"></span> Course Type
  </label><br />
  <select id="courseType" name="courseType" required>
    <option disabled selected></option>
    <option value="Core">Core</option>
    <option value="Major">Major</option>
    <option value="Minor">Minor</option>
    <option value="General Education">General Education</option>
    <option value="Value Added Course">Value Added Course</option>
    <option value="Multidisciplinary Course">Multidisciplinary Course</option>
    <option value="Skill Enchantment Course">Skill Enchantment Course</option>
    <option value="Ability Enhancement Course">Ability Enhancement Course</option>
    <option value="Discipline Specific Elective">Discipline Specific Elective</option>
    <option value="Skill Development Qualification Pack">Skill Development Qualification Pack</option>
  </select>
</div>

<div class="input-group">
  <label for="isPracIncluded">
    <span class="glyphicon glyphicon-menu-down"></span> Practical Included
  </label><br />
  <select id="isPracIncluded" name="isPracIncluded" required>
    <option disabled selected></option>
    <option value="0">No</option>
    <option value="1">Yes</option>
  </select>
</div>

<div class="input-group">
  <label for="theoryHrs">
    <span class="glyphicon glyphicon-hourglass"></span> Theory Hours
  </label><br />
  <input type="number" id="theoryHrs" name="theoryHrs" required />
</div>

<div class="input-group">
  <label for="pracHrs">
    <span class="glyphicon glyphicon-hourglass"></span> Practical Hours
  </label><br />
  <input type="number" id="pracHrs" name="pracHrs" required />
</div>

<div class="input-group">
  <label for="theoryCredits">
    <span class="glyphicon glyphicon-piggy-bank"></span> Theory Credits
  </label><br />
  <input type="number" id="theoryCredits" name="theoryCredits" required />
</div>

<div class="input-group">
  <label for="pracCredits">
    <span class="glyphicon glyphicon-piggy-bank"></span> Practical Credits
  </label><br />
  <input type="number" id="pracCredits" name="pracCredits" required />
</div>

<div class="input-group">
  <label for="semesterID">
    <span class="glyphicon glyphicon-star"></span> Semester ID
  </label><br />
  <select id="semesterID" name="semesterID" required>
    <option disabled selected></option>
    <option value="1">1</option>
    <option value="2">2</option>
    <option value="3">3</option>
    <option value="4">4</option>
    <option value="5">5</option>
    <option value="6">6</option>
  </select>
</div>

<div class="input-group">
  <label for="programmeID">
    <span class="glyphicon glyphicon-list-alt"></span> Programme ID
  </label><br />
  <select id="programmeID" name="programmeID" required>
    <option disabled selected></option>
    <option value="1">BCA</option>
    <option value="2">Bvoc</option>
  </select>
</div>
          <div class="input-group"></div>
          <div class="button-group">
            <button type="submit" id="add-course" name="add-course">Add</button>
            <button type="button" id="update-course" style="display: none">
              Update
            </button>
            <button type="reset">Clear</button>
          </div>
        </form>
      </div>

      <div id="course-search" style="display: none;">
        <div class="search-container">
            <img src="image/search.png" alt="Search" class="search-icon">
            <input type="text" id="searchCourse" placeholder="Search courses..." oninput="searchTable('course')">
        </div>
    </div>


    <div id="odd-sem-section" style="display: none">
    <h2>Generate Odd Semester Timetable</h2>
    <form id="odd-sem-form" onsubmit="return false;">
        <div class="input-group">
            <label for="oddSemester">Select Semester</label><br>
            <select id="oddSemester" name="semester" required>
                <option disabled selected></option>
            </select>
        </div>

        <div class="input-group">
            <label for="oddProgramme">Select Programme</label><br>
            <select id="oddProgramme" name="programme" required>
                <option disabled selected></option>
            </select>
        </div>

        <div class="button-group">
            <button type="submit" id="generate-timetable">Generate Timetable</button>
            <button type="reset">Clear</button>
        </div>
    </form>
  </div>

      <div id="course-data" style="display: none">
        <table id="course-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Initial</th>
              <th>Type</th>
              <th>Practical Included</th>
              <th>Theory Hrs</th>
              <th>Practical Hrs</th>
              <th>Theory Credits</th>
              <th>Practical Credits</th>
              <th>Semester ID</th>
              <th>Programme ID</th>
              <th>Update</th>
              <th>Delete</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>

      <div id="allocation-section" style="display: none">
        <h2>Manage Allocation</h2>
        <form id="allocation-form" onsubmit="return false;">
        <div class="input-group">
    <label for="programmeIDs">
        <span class="glyphicon glyphicon-list-alt"></span> Programme ID
    </label><br>
    <select id="programmeIDs" name="programmeID" required>
        <option disabled selected>Enter Prog ID</option>
    </select><br><br>
</div>

<div class="input-group">
    <label for="semesterIDs">
        <span class="glyphicon glyphicon-star"></span> Semester ID
    </label><br>
    <select id="semesterIDs" name="semesterID" required>
        <option disabled selected>Enter Sem ID</option>
    </select><br><br>
</div>

<div class="input-group">
    <label for="courseIDs">
        <span class="glyphicon glyphicon-book"></span> Course ID
    </label><br>
    <select id="courseIDs" name="courseID" required>
        <!-- <option disabled selected>Enter course ID</option> -->
    </select><br><br>
</div>

<div class="input-group">
    <label for="teacherInitials">
        <span class="glyphicon glyphicon-info-sign"></span> Teacher Initial
    </label><br>
    <select id="teacherInitials" name="teacherInitial" required>
        <option disabled selected>Enter initials</option>
    </select><br><br>
</div>

<div class="input-group">
    <label for="classNo">
        <span class="glyphicon glyphicon-apple"></span> Class No
    </label><br>
    <select id="classNo" name="classNo" required>
        <option disabled selected>Enter class</option>
    </select><br><br>
</div>

<div class="input-group">
    <label for="lab">
        <span class="glyphicon glyphicon-hdd"></span> Lab
    </label><br>
    <input type="text" id="lab" name="lab"><br><br>
</div>
             <div class="button-group">
                <button type="submit" id="add-allocation" name="add-allocation">Add</button>
                <button type="button" id="update-allocation" style="display: none;">Update</button>
                <button type="reset" id="clearButton">Clear</button>
            </div>
        </form>
      </div>

      <div id="allocation-search" style="display: none;">
        <div class="search-container">
            <img src="image/search.png" alt="Search" class="search-icon">
            <input type="text" id="searchAllocation" placeholder="Search allocations..." oninput="searchTable('allocation')">
        </div>

      <div id="allocation-data" style="display: none;">        
        <table id="allocation-table">
            <thead>
                <tr>
                    <th>Teacher Initial</th>
                    <th>Course ID</th>
                    <th>Class No</th>
                    <th>Lab</th>
                    <th>Semester ID</th>
                    <th>Programme ID</th>
                    <th>Update</th>
                    <th>Delete</th>
                </tr>
            </thead>
            <tbody>
                
            </tbody>
        </table>
  </body>
</html>
