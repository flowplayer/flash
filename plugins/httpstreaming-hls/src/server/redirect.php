<?

include "Zend/Http/Client.php";

$client = new Zend_Http_Client($_POST["url"]); 
$response = $client->request(); 
$finalUrl = $client->getUri()->__toString();

echo $finalUrl;

?>