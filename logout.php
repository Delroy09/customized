<?php
session_start();

// Check if user is logged in
if (isset($_SESSION['loggedin'])) {
    // Clear all session variables
    $_SESSION = array();

    // Destroy the session cookie
    if (isset($_COOKIE[session_name()])) {
        setcookie(session_name(), '', time()-3600, '/');
    }

    // Destroy the session
    session_destroy();

    // Cache control headers
    header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
    header("Cache-Control: post-check=0, pre-check=0", false);
    header("Pragma: no-cache");

    // Redirect with a message
    header("Location: index.php?logout=success");
} else {
    // If not logged in, redirect anyway
    header("Location: index.php");
}
exit();
?>