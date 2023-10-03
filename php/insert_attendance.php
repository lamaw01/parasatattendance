<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);


if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('employee_id', $input)){
    $employee_id = $input['employee_id'];
    // $event_id = 'Christmas Party 2023';

    $sql0 = "SELECT event_id FROM tbl_event WHERE event_id=(SELECT MAX(event_id) FROM tbl_event)";

    $sql1 = "SELECT * FROM tbl_event_log WHERE employee_id = :employee_id AND event_id = :event_id";

    $sql2 = "INSERT INTO tbl_event_log(employee_id, event_id) VALUES (:employee_id,:event_id)";

    try {
        $sql_last_event_id = $conn->prepare($sql0);
        $sql_last_event_id->execute();
        $result_sql_last_event_id = $sql_last_event_id->fetch(PDO::FETCH_ASSOC);
        $event_id = $result_sql_last_event_id['event_id'];

        $sql_check = $conn->prepare($sql1);
        $sql_check->bindParam(':employee_id', $employee_id, PDO::PARAM_STR);
        $sql_check->bindParam(':event_id', $event_id, PDO::PARAM_STR);
        $sql_check->execute();
        $result_sql_check = $sql_check->fetch(PDO::FETCH_ASSOC);
        if($result_sql_check){
            echo json_encode(array('success'=>true,'message'=>'already logged'));
            return;
        }
        $sql_insert = $conn->prepare($sql2);
        $sql_insert->bindParam(':employee_id', $employee_id, PDO::PARAM_STR);
        $sql_insert->bindParam(':event_id', $event_id, PDO::PARAM_STR);
        $sql_insert->execute();
        echo json_encode(array('success'=>true,'message'=>'ok'));
    } catch (PDOException $e) {
        echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
    } finally{
        // Closing the connection.
        $conn = null;
    }
}else{
    echo json_encode(array('success'=>false,'message'=>'error input'));
    die();
}
?>