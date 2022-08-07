<?php

/*
	This is simple example how to import script to the RouterBoard using PHP.

	required library routeros_api.class.php
		class could be download from:
			* origin: https://github.com/BenMenking/routeros-api
			* fork: https://github.com/IgorAlov/routeros-api

*/

require_once('routeros_api.class.php');
//=============================================================================
//define your variables of  the router board
define("ROS_IP","192.168.88.2");
define("ROS_USER","admin");
define("ROS_PASS","admin");
//=============================================================================
function	microtik_import_apiscript($API,$script_name)
	{
	if(!isset($API)||$script_name=="") return false;

   echo "Fetching...\n";
	$arrID=$API->comm("/tool/fetch", 
		array(
			"mode"					=> "https",
        	"check-certificate"  => "no",
        	"url"						=> "https://raw.githubusercontent.com/IgorAlov/".$script_name."/main/".$script_name,
			"dst-path"				=> $script_name,
			"keep-result"			=> "yes",
			"ascii"					=> "yes"
      ));
	
   //take a time to download a script file from the url
   sleep(2);
	
   //Getting id of the downloaded script
   echo "Getting ID...\n";
   $arrID=$API->comm("/file/getall", 
		array(
			".proplist"=> ".id",
			"?name"		=> $script_name
			));
	$script_id=(isset($arrID["0"][".id"]))?$arrID["0"][".id"]:"";
	
   //check if we have downloaded script
   echo "Importing....\n";
   if($script_id!="")
		$arrID=$API->comm("/import", 
	  		array(
				"file-name"		=> $script_name
				));
	else
		echo "unable to get script id.\n";

   return true;
	}
//=============================================================================
$API = new RouterosAPI();

echo "connecting...\n";
if($API->connect(ROS_IP, ROS_USER, ROS_PASS))    
   {
   echo "Connected to [".ROS_IP."]\n";
   echo "Import ".(microtik_import_apiscript($API,"rb-setfw.rsc")?"Success":"Fail")."\n";
   $API->disconnect();   
   }
else echo "can't to connect to IP [".ROS_IP."]";
echo "done.\n";
?>
