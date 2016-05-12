<?php
error_reporting(-1);

class Telnet {
 var $sock = NULL;
 
 function telnet($host,$port) {
  $this->sock = fsockopen($host,$port, $errno, $errstr, 3);
  stream_set_timeout($this->sock,2,0);
 }

 function close() {
  if ($this->sock)  fclose($this->sock);
  $this->sock = NULL;
 }
 
 function write($buffer) {
  $buffer = str_replace(chr(255),chr(255).chr(255),$buffer);
  fwrite($this->sock,$buffer);
 }
 
 function getc() {
  return fgetc($this->sock); 
 }

 function read_till($what) {
  $buf = '';
  while (1) {
   $IAC = chr(255);
   
   $DONT = chr(254);
   $DO = chr(253);
   
   $WONT = chr(252);
   $WILL = chr(251);
   
   $theNULL = chr(0);
 
   $c = $this->getc();
   
   if ($c === false) return $buf;
   if ($c == $theNULL) {
    continue;
   }
 
   if ($c == "limit") {
    continue;
   }//单字符过滤，比如输入a，所有的a不会显示出来

   if ($c != $IAC) {
    $buf .= $c;
  
    if ($what == (substr($buf,strlen($buf)-strlen($what)))) {
     return $buf;
    }
    else {
     continue;
    }
   }

   $c = $this->getc();
   
   if ($c == $IAC) {
   $buf .= $c;
   }
   else if (($c == $DO) || ($c == $DONT)) {
    $opt = $this->getc();
    // echo "we wont ".ord($opt)."\n";
    fwrite($this->sock,$IAC.$WONT.$opt);
   }
   elseif (($c == $WILL) || ($c == $WONT)) {
    $opt = $this->getc();
    // echo "we dont ".ord($opt)."\n";
    fwrite($this->sock,$IAC.$DONT.$opt);
   }
   else {
    // echo "where are we? c=".ord($c)."\n";
   }
  }
 }
}

/*
使用方法 示例
$telnet = new telnet("192.168.0.1",23);
echo $telnet->read_till("login: ");
$telnet->write("kongxx\r\n");
echo $telnet->read_till("password: ");
$telnet->write("KONGXX\r\n");
echo $telnet->read_till(":> ");
$telnet->write("ls\r\n");
echo $telnet->read_till(":> ");
echo $telnet->close();

*/
?>