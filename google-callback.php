<?php
require_once 'vendor/autoload.php';
require_once 'db_config.php';
session_start();

try {
    $config = require_once 'config/google-config.php';
    $client = new Google_Client();
    $client->setClientId($config['client_id']);
    $client->setClientSecret($config['client_secret']);
    $client->setRedirectUri($config['redirect_uri']);

    if (isset($_GET['code'])) {
        $token = $client->fetchAccessTokenWithAuthCode($_GET['code']);
        
        if (!isset($token['error'])) {
            $client->setAccessToken($token['access_token']);
            $google_oauth = new Google_Service_Oauth2($client);
            $google_account_info = $google_oauth->userinfo->get();
            
            $email = $google_account_info->email;
            
            // Check for institutional email
            if (strpos($email, '@vvm.edu.in') !== false) {
                // Check if email exists in admin table
                $stmt = $conn->prepare("SELECT * FROM admin WHERE email = ?");
                $stmt->bind_param("s", $email);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows > 0) {
                    $admin = $result->fetch_assoc();
                    $_SESSION['username'] = $admin['username'];
                    $_SESSION['loggedin'] = true;
                    
                    // Update Google ID if not set
                    if (empty($admin['google_id'])) {
                        $google_id = $google_account_info->id;
                        $update = $conn->prepare("UPDATE admin SET google_id = ? WHERE email = ?");
                        $update->bind_param("ss", $google_id, $email);
                        $update->execute();
                    }
                    
                    header('Location: dashboard.php');  // Updated here
                    exit();
                } else {
                    $_SESSION['error'] = "Email not authorized";
                    header('Location: index.php');
                    exit();
                }
            } else {
                $_SESSION['error'] = "Please use your institutional email";
                header('Location: index.php');
                exit();
            }
        }
    }
} catch (Exception $e) {
    $_SESSION['error'] = "Authentication failed";
    header('Location: index.php');
    exit();
}

header('Location: index.php');
exit();