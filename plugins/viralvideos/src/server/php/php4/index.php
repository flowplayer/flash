<?


require_once 'ShareEmail.php';

if ($_POST)
{
	$config = array(
					"backend" => "mail"
					);
	/*$config = array(
					"backend" => "sendmail",
					"backendParams" => array(
											"sendmail" => array(
																"sendmail_path" => "/usr/bin/sendmail",
																"sendmail_args" => "-i"
																),
											)
					);*/
	/*$config = array(
					"backend" => "smtp",
					"backendParams" => array(
											"smtp" => array(
															"host" => "localhost",
															"port" => 25,
															"auth" => true,
															"username" => "",
															"password" => "",
															"localhost" => "localhost",
															"timeout" => null,
															"verp" => false,
															"debug" => false,
															"persist" => true	
															)
											)
											
					);*/
		
		/*$config = array(
					"backend" => "smtp",
					"backendParams" => array(
											"smtp" => array(
															"host" => "ssl://mail.example.com",
															"port" => 465,
															"auth" => true,
															"username" => "",
															"password" => "",
															"localhost" => "localhost",
															"timeout" => null,
															"verp" => false,
															"debug" => false,
															"persist" => true	
															)
											)
											
					);*/
					
	$email = new ShareEmail($config);
	$email->setSubject($_POST["subject"]);
	$email->setMessage($_POST["message"]);
	$email->setNameFrom($_POST["name"]);
	$email->setNameFrom($_POST["email"]);
	$email->setEmailTo($_POST["to"]);
	$email->send();
	
}

?>
