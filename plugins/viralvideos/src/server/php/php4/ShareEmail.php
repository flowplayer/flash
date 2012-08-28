<?

require_once 'Mail.php';


class ShareEmail 
{
	var $_emailTo = array();
	var $_recipients = "";
	var $_emailFrom = "";
	var $_nameFrom = "";
	var $_subject = "";
	var $_message = "";
	var $_headers = array();
	var $_mail = null;
	var $_config = array(
						"backend" => "mail",
						"backendParams" => array(
												"mail" => null,
												"sendmail" => array(
																	"sendmail_path" => "/usr/bin/sendmail",
																	"sendmail_args" => "-i"
																	),
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
						);
	
	
	function ShareEmail($config)
	{
		array_merge($_config, $config);
		$_mail =& Mail::factory($_config["backend"], $_config["backendParams"][$_config["backend"]]);
	}
	
	function setEmailTo($email)
	{
		$emails = split(",", $email);
		
		foreach ($emails as $value)
		{
			array_push($_emailTo, $value);
		}
		
		$_recipients = implode(",",$_emailTo);
	}
	
	function setSubject($subject)
	{
		$_subject = $subject;
	}
	
	function setMessage($message)
	{
		$_message = $message;
	}
	
	function setEmailFrom($email)
	{
		$_emailFrom = $email;
	}
	
	function setNameFrom($name)
	{
		$_nameFrom = $name;
	}
	
	function send()
	{
		$_headers["From"] = "$_nameFrom <$_emailFrom>";
		$_headers["Reply-To"] = "$nameFrom <$emailFrom>";
		$_headers["X-Mailer"] = "PHP/" . phpversion();
		
		if (count($_emailTo) > 1) $_headers["Bcc"] = $_recipients;
		$_headers["Subject"] = $_subject;
		
		
		$_mail->send($_recipients, $_headers, $_message);
		
		if (PEAR::isError($mail)) {
		  echo("<p>" . $mail->getMessage() . "</p>");
		} else {
		  echo("<p>Message successfully sent!</p>");
		}
	}
	
	
	
}

?>
