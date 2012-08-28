<?php
/**
 * A controller plugin for protecting forms from CSRF
 * 
 * Works by looking at the response and adding a hidden element to every
 * form, which contains an automatically generated key that is checked
 * on the next request against a key stored in the session
 * 
 * @author Jani Hartikainen <firstname at codeutopia net>
 */
class CU_Controller_Plugin_CsrfProtect extends Zend_Controller_Plugin_Abstract 
{
	/**
	 * Session storage
	 * @var Zend_Session_Namespace
	 */
	protected $_session = null;
	
	/**
	 * The name of the form element which contains the key
	 * @var string
	 */
	protected $_keyName = 'csrf';
	
	/**
	 * How long until the csrf key expires (in seconds)
	 * @var int
	 */
	protected $_expiryTime = 300;
	
	/**
	 * The previous request's token, set by _initializeToken
	 * @var string
	 */
	protected $_previousToken = '';
	
	protected $_autoProtect = true;
	
	public function __construct(array $params = array())
	{
		if(isset($params['expiryTime']))
			$this->setExpiryTime($params['expiryTime']);
		
		if(isset($params['keyName']))
			$this->setKeyName($params['keyName']);	
		
		if(isset($params['autoProtect']))
			$this->_autoProtect = $params['autoProtect'];
			
		$this->_session = new Zend_Session_Namespace('CsrfProtect');
	}
	
	/**
	 * Set the expiry time of the csrf key
	 * @param int $seconds expiry time in seconds. Set 0 for no expiration
	 * @return CU_Controller_Plugin_CsrfProtect implements fluent interface
	 */
	public function setExpiryTime($seconds)
	{
		$this->_expiryTime = $seconds;
		return $this;
	}

	/**
	 * Set the name of the csrf form element
	 * @param string $name
	 * @return CU_Controller_Plugin_CsrfProtect implements fluent interface
	 */
	public function setKeyName($name)
	{
		$this->_keyName = $name;
		return $this;
	}
	
	/**
	 * Performs CSRF protection checks before dispatching occurs
	 * @param Zend_Controller_Request_Abstract $request
	 */
	public function preDispatch(Zend_Controller_Request_Abstract $request)
	{	
		$this->_initializeTokens();

		if($request->isPost() === true && $this->_autoProtect)
		{			
			if(empty($this->_previousToken))
				throw new RuntimeException('A possible CSRF attack detected - no token received');

			$value = $request->getPost($this->_keyName);
			if(!$this->isValidToken($value))
				throw new RuntimeException('A possible CSRF attack detected - tokens do not match');
		}			
	}

	/**
	 * Check if a token is valid for the previous request
	 * @param string $value
	 * @return bool
	 */
	public function isValidToken($value)
	{
		if($value != $this->_previousToken)
			return false;
			
		return true;
	}
	
	/**
	 * Return the CSRF token for this request
	 * @return string
	 */
	public function getToken()
	{
		return $this->_token;
	}
	
	/**
	 * Adds protection to forms
	 */
	public function dispatchLoopShutdown()
	{
		$token = $this->getToken();
		
		$response = $this->getResponse();
		
		$headers = $response->getHeaders();
		foreach($headers as $header)
		{
			//Do not proceed if content-type is not html/xhtml or such
			if($header['name'] == 'Content-Type' && strpos($header['value'], 'html') === false)
				return;			
		}
		
		$element = sprintf('<input type="hidden" name="%s" value="%s" />',
			$this->_keyName,
			$token
		);
		
		$body = $response->getBody();
		
		//Find all forms and add the csrf protection element to them
		$body = preg_replace('/<form[^>]*>/i', '$0' . $element, $body);
		
		$response->setBody($body);
	}
	
	/**
	 * Initializes a new token
	 */
	protected function _initializeTokens()
	{
		$this->_previousToken = $this->_session->key;
		
		$newKey = sha1(microtime() . mt_rand());
		
		$this->_session->key = $newKey;
		if($this->_expiryTime > 0)
			$this->_session->setExpirationSeconds($this->_expiryTime);
		
		$this->_token = $newKey;
	}	
}
?>