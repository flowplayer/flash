<?

set_include_path(get_include_path() . PATH_SEPARATOR . "../application/lib");

require_once 'Zend/Loader/Autoloader.php';
require_once 'Zend/Controller/Front.php';
require_once 'Zend/Config/Xml.php';
require_once 'Zend/Controller/Router/Route.php';

require_once '../application/plugins/CsrfProtect.php';



$autoloader = Zend_Loader_Autoloader::getInstance();

$config = new Zend_Config_Xml('../application/config/config.xml', 'production');



$registry = Zend_Registry::getInstance();
$registry->set('config', $config);

Zend_Controller_Action_HelperBroker::addPath('../application/helpers', 'CU_Controller_Action_Helper');

$front = Zend_Controller_Front::getInstance();
$front->setControllerDirectory('../application/controllers');

$protect = new CU_Controller_Plugin_CsrfProtect(array(
    'expiryTime' => $config->mail->tokenExpiry, 
    'keyName' => 'csrf', 
    'autoProtect' => false
));

$front->registerPlugin($protect);
$front->dispatch();


?>