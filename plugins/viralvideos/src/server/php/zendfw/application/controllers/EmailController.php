<?
require_once 'Zend/Controller/Action.php';
require_once 'Zend/Session/Namespace.php';
require_once 'Zend/Service/TypePadAntiSpam.php';

require_once '../application/filters/EmailFormFilter.php';

class EmailController extends Zend_Controller_Action
{
	protected $config;
	protected $session;
	
    protected function initConfig()
    {
    	$this->config = Zend_Registry::get('config');
    }
    
	protected function initSession()
    {
    	Zend_Session::setOptions($this->config->tokenSession->toArray());
    	Zend_Session::start();
    	
    }
    
    public function init()
    {
    	$this->initConfig();
        $this->initSession();
        
        if ($this->config->mail->backend == "smtp")
        {
        	$tr = new Zend_Mail_Transport_Smtp($this->config->mail->smtp->host, $this->config->mail->smtp->options->toArray());
			Zend_Mail::setDefaultTransport($tr);
        }
    }
    
    public function preDispatch()
    {
     
       $this->_helper->viewRenderer->setNoRender();
       	   
	   $filters = array(
		    '*'     => new EmailFormFilter()
	   );
	   
	   $alnum = new Zend_Validate_Alnum(true);
	   
	   $validators = array(
	   		'name' => array('NotEmpty',$alnum,'allowEmpty' => false),
	   		'email' => array('NotEmpty','EmailAddress','allowEmpty' => false),
	   		'subject' => array('NotEmpty','allowEmpty' => false),
	   		'message' => array('NotEmpty','allowEmpty' => false),
	   		'to' => array('NotEmpty','allowEmpty' => false),
	   		'token' => array('NotEmpty','Alnum','allowEmpty' => false)
	   );
	   
	   $options = array(
		    'missingMessage' => "Field '%field%' is required"
	   );
	   
	   $this->input = new Zend_Filter_Input($filters, $validators, $this->_request->getParams(), $options);
	   
       $this->subject = $this->input->subject;
       $this->message = $this->input->getUnescaped('message');
       $this->name = $this->input->name;
       $this->email = $this->input->email;
       $this->to = $this->input->to;
	   $this->token = $this->input->token;
	
    }
    
    public function indexAction()
    {
    	if ($this->_request->isPost())
		{

			
		   if ($this->input->hasInvalid()) {
                          $missing = "";
                          $notalnum = "";
                          $message = "";
                          foreach ($this->input->getInvalid() as $key=>$value)
                          {
                                  if (isset($value["isEmpty"])) $missing .= $key.",";
                                  if (isset($value["notAlnum"])) $notalnum .= $key.",";

                          }

                          if ($missing) $message.= "Following are required $missing \n";
                          if ($notalnum) $message.= "Following are alpha numeric only $notalnum";

                          throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>$message)));
         
           }
			

			
			if(!$this->_helper->csrf->isValidToken($this->token))
			{
				throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>'Token validation failed')));
			} 
			
			
			if ($this->config->antispam)
			{
				switch ($this->config->antispam)
				{
					case "typepad":
						$spam = new Zend_Service_TypePadAntiSpam($this->config->typepad->key, "http://".$_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"]); 
					break;
					case "akismet":
						$spam = new Zend_Service_Akismet($this->config->akismet->key,"http://".$_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"]);
					break;
				}
				
				if (isset($spam))
				{
					if ($spam->verifyKey()) { 
							$params = array(); 
        					$params["user_ip"] = $_SERVER['REMOTE_ADDR']; 
        					$params["user_agent"] = $_SERVER['HTTP_USER_AGENT'];
        					$params["referrer"] = $_SERVER[ 'HTTP_REFERER'];
       	 					$params["comment_type"] = "email";
        					$params["comment_author"] = $this->name;
        					$params["comment_author_email"] = $this->email;
       						$params["comment_content"] = $this->message;
       			
       						if ($spam->isSpam($params))
       						{
       							throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>'Message failed due to spam')));
       						}
							
					}
				}
			}
			

	    	$mail = new Zend_Mail();
	    	$mail->setHeaderEncoding(Zend_Mime::ENCODING_BASE64);
			$mail->setBodyText($this->subject);
			$mail->setFrom($this->email, $this->name);
			
			$emails = explode(",", $this->to);

			$validator = new Zend_Validate_EmailAddress();
			
			foreach ($emails as $value)
			{
				if ($validator->isValid($value)) $mail->addTo($value);
			}
			
	
			$mail->setSubject($this->subject);
			$mail->setBodyText($this->message);
			$mail->setBodyHtml($this->message);
			
			try {
				$mail->send();
			} catch (Exception $e) {
				throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>'Mail send was not successful')));
			}
						
			$this->getResponse()->setBody(Zend_Json::encode(array("success"=>"Message succesfully sent")));
	
		} 
    }
    
    
    
    
	
}
?>