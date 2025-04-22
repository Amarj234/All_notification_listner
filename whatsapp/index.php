<?php
	// error_reporting(E_ALL);
	// ini_set('display_errors', 1);
include_once "connect.php";




// Get POST data

//  print_r($_POST) ;
// Check required fields
if (
     isset($_POST["username"]) && isset($_POST["mobile"]) &&
    isset($_POST["number"]) && isset($_POST["icon"]) && isset($_POST["message"])
) {

  
    // Escape input to prevent SQL injection

    $username = $_POST["username"];
    $mobile =  $_POST["mobile"];
    $number =  $_POST["number"];
    $icon =  $_POST["icon"];
    $message = $_POST["message"];

    // Insert query
    $sql = "INSERT INTO mesasge ( username, mobile, `number`, icon, `message`) 
            VALUES ( '$username', '$mobile', '$number', '$icon', '$message')";

    // Execute query
    if (mysqli_query($conn, $sql)) {
        echo json_encode(["success" => true, "message" => "Message inserted successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Insert failed: " . mysqli_error($conn)]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
}

// Close connection
mysqli_close($conn);
?>