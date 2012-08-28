<?php
/**
 * Action helper for protecting against CSRF
 *
 * @author Jani Hartikainen <firstname at codeutopia net>
 */
class CU_Controller_Action_Helper_Csrf extends Zend_Controller_Action_Helper_Abstract
{
	/**
	 * @var CU_Controller_Plugin_CsrfProtect
	 */
	protected $_plugin = null;
	
	public function getPlugin()
	{
		if($this->_plugin == null)
		{
			$this->_plugin = Zend_Controller_Front::getInstance()->getPlugin('CU_Controller_Plugin_CsrfProtect');
		}
		
		return $this->_plugin;
	}
	
	public function setPlugin(CU_Controller_Plugin_CsrfProtect $plugin)
	{
		$this->_plugin = $plugin;
	}
	
	public function getToken()
	{
		return $this->getPlugin()->getToken();
	}
	
	/**
	 * Checks if value is the valid token for the previous request
	 * @param string $value
	 * @return bool
	 */
	public function isValidToken($value)
	{
		return $this->getPlugin()->isValidToken($value);
	}
}
?>