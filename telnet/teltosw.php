<?php
include ("telnet.php"); 
$ip=$_POST['ipaddress'];

$telnet = new telnet($ip,23);
$telnet->write("dalou\r\nshow process cpu\r\n");
$str=$telnet->read_till("PID");
$telnet->write("exit\r\n");
$telnet->close();
$str_fives1=substr($str,strrpos($str,"five seconds:")+14);
$str_fives=substr($str_fives1,0,strpos($str_fives1,';'));
$str_onem1=substr($str,strrpos($str,"one minute:")+12);
$str_onem=substr($str_onem1,0,strpos($str_onem1,'%')+1);

$str_fivem1=substr($str,strrpos($str,"five minutes:")+14);
$str_fivem=substr($str_fivem1,0,strpos($str_fivem1,'%')+1);
$back = array(
'fives' =>$str_fives,
'onem'=>$str_onem,
'fivem'=>$str_fivem,
);
echo json_encode($back);
?>