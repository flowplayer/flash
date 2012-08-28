<?

class EmailFormFilter implements Zend_Filter_Interface
{
    protected $_matchRegex = array(
    							"/to\:/i",
    							"/from\:/i",
    							"/bcc\:/i",
    							"/cc\:/i",
    							"/Content\-Transfer\-Encoding\:/i",
    							"/Content\-Type\:/i",
    							"/Mime\-Version\:/i" 
  						); 
 
    public function filter($value)
    {
    	return preg_replace($this->_matchRegex, "", (string) $value);
    }
}

?>