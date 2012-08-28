<?
require_once 'Zend/Controller/Action.php';
require_once 'Zend/Session/Namespace.php';

class IndexController extends Zend_Controller_Action
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
    	
    	$this->_session = new Zend_Session_Namespace('TokenCheck');
    	
    }
    
	
    
    public function init()
    {
    	$this->initConfig();
        $this->initSession();
        
       
    }
    
    public function preDispatch()
    {
             

    }
    
    public function indexAction()
    {		
		if (isset($_SERVER["REDIRECT_STATUS"]) ) {
			$this->_session->clientIP = $_SERVER["HTTP_X_FORWARDED_FOR"];
			$this->_session->clientAgent = $_SERVER["HTTP_USER_AGENT"];
			$this->_session->httpHost = $_SERVER["HTTP_HOST"];
		} else {
			$this->_session->referringURL =  "http://".$_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"];
		}
		$this->view->emailToken = $this->_helper->csrf->getToken();	
    }
    
    
    public function tokenAction()
    {
    	//error_reporting(0);
    	$this->_helper->viewRenderer->setNoRender();
    	
    	$response = $this->getResponse()
             ->setHeader('Expires', 'Mon, 26 Jul 1997 05:00:00 GMT')
             ->setHeader('Last-Modified', gmdate("D, d M Y H:i:s") . " GMT")
             ->setHeader('Cache-Control', 'no-store, no-cache, must-revalidate')
             ->setHeader('Cache-Control', 'post-check=0, pre-check=0',true)
             ->setHeader('Pragma', 'no-cache');
    	
    	if ($this->_session->referringURL == $_SERVER["HTTP_REFERER"] && isset($_SERVER["HTTP_REFERER"]))
    	{
        	$response->appendBody(Zend_Json::encode(array("token"=>$this->_helper->csrf->getToken())));
    	} elseif (isset($_SERVER["REDIRECT_STATUS"]) && $this->_session->clientIP == $_SERVER["HTTP_X_FORWARDED_FOR"] && $this->_session->clientAgent == $_SERVER["HTTP_USER_AGENT"] && $this->_session->httpHost == $_SERVER["HTTP_HOST"]) { 
    		$response->appendBody(Zend_Json::encode(array("token"=>$this->_helper->csrf->getToken())));
    	} elseif (!isset($_SERVER["HTTP_REFERER"])) {
    		throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>'No referer')));
    	} else {
    		throw new Zend_Service_Exception(Zend_Json::encode(array("error"=>sprintf("Referer %s is not allowed",$_SERVER["HTTP_REFERER"]))));
    	}
    }
    
    
    
	
}
?>