<?php
session_start();

include 'db_config.php';

// Handle POST request for password reset form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'];

    // Check if the email exists in the database
    $stmt = $conn->prepare("SELECT id FROM admin WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        // Email exists, proceed with password reset process
        // For simplicity, we'll just display a message here
        // In a real application, you would send a reset link to the email
        $_SESSION['message'] = "A password reset link has been sent to your email.";
    } else {
        // Email does not exist
        $_SESSION['error'] = "No account found with that email.";
    }

    $stmt->close();
    $conn->close();
}
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
              <!-- Reset Password message -->
              <div class="text-wrapper-2">Reset Your Password</div>
              <p class="p">Enter your email to reset your password</p>
            </header>
            <!-- Password reset form -->
            <form id="reset-form" action="pass_reset.php" method="post">
              <div class="form-section">
                <!-- Email input -->
                <div class="input-standard">
                  <input class="text-wrapper-3" type="email" name="email" id="email" placeholder="Email" required>
                </div>
                <!-- Reset Password button -->
                <div class="button-filled">
                  <button class="text-wrapper-4" type="submit">Reset Password</button>
                </div>
                <!-- Message display -->
                <div id="message">
                  <?php
                  if (isset($_SESSION['message'])) {
                      echo $_SESSION['message'];
                      unset($_SESSION['message']);
                  }
                  if (isset($_SESSION['error'])) {
                      echo $_SESSION['error'];
                      unset($_SESSION['error']);
                  }
                  ?>
                </div>
              </div>
            </form>
            <!-- Back to login link -->
            <div class="divider-2">
              <a href="index.php" class="text-wrapper-5">Back to login</a>
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