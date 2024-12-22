<?php
// Start a new or resume existing session
session_start();

include 'db_config.php';

// Handle POST request for login form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get username and password from POST data
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Prepare the SQL statement
    $stmt = $conn->prepare("SELECT role FROM admin WHERE username = ? AND password = ?");
    $stmt->bind_param("ss", $username, $password);

    // Execute the statement
    $stmt->execute();

    // Bind the result to a variable
    $stmt->bind_result($role);

    // Fetch the result
    if ($stmt->fetch()) {
        // Check the role and set the session accordingly
        if ($role === 'bca') {
            $_SESSION['user'] = 'bca';
            header("Location: class.php");
            exit();
        } elseif ($role === 'bvoc') {
            $_SESSION['user'] = 'bvoc';
            header("Location: class.php");
            exit();
        }
    } else {
        // Invalid credentials
        $_SESSION['error'] = "Invalid username or password.";
    }

    // Close the statement
    $stmt->close();
}

// Close the database connection
$conn->close();
?>

<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8" />
  <link rel="stylesheet" href="css/login.css" />
</head>

<body>
  <div class="light-login">
    <div class="basic-header">
      <!-- Logo section -->
      <div class="logo">
        <img class="logomark" src="img/logo - dark.svg" alt="Timely Logo" />
      </div>
    </div>
    <div class="container">
      <div class="main-content">
        <div class="onboarding-sign-up">
          <div class="div">
            <header class="header">
              <!-- Welcome message -->
              <div class="text-wrapper-2">Welcome to Timely</div>
              <p class="p">Please sign in to continue</p>
            </header>
            <!-- Login form -->
            <form id="login-form" action="index.php" method="post">
              <div class="form-section">
                <!-- Username input -->
                <div class="input-standard">
                  <input class="text-wrapper-3" type="text" name="username" id="username" placeholder="Username">
                </div>
                <!-- Password input -->
                <div class="input-standard">
                  <input class="text-wrapper-3" type="password" name="password" id="password" placeholder="Password">
                </div>
                <!-- Sign In button -->
                <div class="button-filled">
                  <button class="text-wrapper-4" type="submit">Sign In</button>
                </div>
                <!-- Error message display -->
                <div id="error-message">
                  <?php
                  if (isset($_SESSION['error'])) {
                      echo $_SESSION['error'];
                      unset($_SESSION['error']);
                  }
                  ?>
                </div>
              </div>
            </form>
            <!-- Forgot Password link -->
            <div class="divider-2">
              <a href="pass_reset.php" class="text-wrapper-5">Forgot Password?</a>
            </div>
            <!-- Divider for alternative sign-in options -->
            <div class="divider-2">
              <div class="text-wrapper-5">----- or continue with ------</div>
            </div>
            <!-- Google sign-in button -->
            <div class="button-outlined">
              <img class="google" src="img/search.png" alt="Google Logo" />
              <div class="text-wrapper-6">Google</div>
            </div>
            <!-- Remember me checkbox -->
            <div class="checkbox-small">
              <input class="checkbox-small" type="checkbox" name="rememberMe" id="rememberMe">
              <div class="text-wrapper-5">Remember me</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Footer section -->
    <div class="basic-footer"></div>
  </div>
  <script src="scripts/login.js"></script>
</body>

</html>