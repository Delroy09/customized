<?php
session_start();

if (isset($_SESSION['loggedin'])) {
    header("Location: dashboard.php");
    exit();
}

header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

include 'db_config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if (empty($username) || empty($password)) {
        $response = ['success' => false, 'error' => 'Username and password are required.'];
    } else {
        $stmt = $conn->prepare("SELECT * FROM admin WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            if ($password === $user['password']) {
                $_SESSION['username'] = $user['username'];
                $_SESSION['loggedin'] = true;
                $_SESSION['login_success'] = true;
                $response = ['success' => true, 'redirect' => 'dashboard.php'];
            } else {
                $response = ['success' => false, 'error' => 'Incorrect password'];
            }
        } else {
            $response = ['success' => false, 'error' => 'User not found'];
        }
    }

    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}
if (isset($_GET['logout']) && $_GET['logout'] == 'success') {
  echo '<div class="logout-popup">
          <span>You have been successfully logged out.</span>
          <img src="image/circle-check.svg" alt="Logo">
        </div>';
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Timely Login</title>
  <link rel="stylesheet" href="login.css">
  <!-- Link Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Lexend:wght@100..900&display=swap" rel="stylesheet"></head>

<body>
  <div class="light-login">
    <!-- Logo section -->
    <div class="basic-header">
      <div class="logo">
        <img class="logomark" src="image/Light.svg" alt="Timely Logo">
      </div>
    </div>
    <div class="container">
      <div class="main-content">
        <div class="onboarding-sign-up">
          <div class="div">
            <!-- Welcome header -->
            <header class="header">
              <div class="welcome-title">Welcome to Timely</div>
              <p class="welcome-subtitle">Please sign in to continue</p>
            </header>
            <!-- Login form -->
            <form id="login-form" action="index.php" method="post">
              <div class="form-section">
                <div class="input-standard">
                  <input class="text-wrapper-3" type="text" name="username" id="username" placeholder="Enter your username">
                </div>
                <div class="input-standard">
                  <input class="text-wrapper-3" type="password" name="password" id="password" placeholder="Enter your password">
                </div>
                <div class="button-filled">
                  <button class="text-wrapper-4" type="submit">Sign In</button>
                </div>
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
            <div class="oauth-container">
                <div class="divider">
                    <span>or</span>
                </div>
                <a href="google-auth.php" class="google-btn">
                    <img src="image/google-icon.svg" alt="Google">
                    Sign in with Google
                </a>
            </div>
           <!-- Remember me section -->
<div class="checkbox-small">
  <input type="checkbox" name="rememberMe" id="rememberMe">
  <div class="remember-me-text">Remember me</div>
  <!-- <a href="forgot-password.php" class="forgot-password-link">Forgot password?</a> Added Forgot Password link -->
</div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <script src="JS/login.js"></script>
</body>

</html>
