<?php
/**
 * Please note that this is NOT an official Zend Framework package.
 * This is essentially a copy-paste-modification of the original Zend Framework's Service/Akismet.php class to
 * work with the TypePad Anti Spam service. If you find this class useful or find an error etc, please leave a
 * comment at http://calisza.wordpress.com - all feedback is welcome.
 *
 * All original/offical headers have been left intact. Thanks to all the devs who have made the Zend Framework
 * the wonderful product that it is.
 */

/**
 * Zend Framework
 *
 * LICENSE
 *
 * This source file is subject to the new BSD license that is bundled
 * with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://framework.zend.com/license/new-bsd
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@zend.com so we can send you a copy immediately.
 *
 * @category   Zend
 * @package    Zend_Service
 * @subpackage TypePadAntiSpam
 * @copyright  Copyright (c) 2005-2008 Zend Technologies USA Inc. (http://www.zend.com)
 * @license    http://framework.zend.com/license/new-bsd     New BSD License
 */

/**
 * @see Zend_Version
 */
require_once 'Zend/Version.php';

/**
 * @see Zend_Service_Abstract
 */
require_once 'Zend/Service/Abstract.php';

/**
 * Typepad Anti Spam REST service implementation
 *
 * @uses       Zend_Service_Abstract
 * @category   Zend
 * @package    Zend_Service
 * @subpackage TypePadAntiSpam
 * @copyright  Copyright (c) 2005-2008 Zend Technologies USA Inc. (http://www.zend.com)
 * @license    http://framework.zend.com/license/new-bsd     New BSD License
 */
class Zend_Service_TypePadAntiSpam extends Zend_Service_Abstract
{
    /**
     * TypePadAntiSpam API key
     * @var string
     */
    protected $_apiKey;

    /**
     * Blog URL
     * @var string
     */
    protected $_blogUrl;

    /**
     * Charset used for encoding
     * @var string
     */
    protected $_charset = 'UTF-8';

    /**
     * TCP/IP port to use in requests
     * @var int
     */
    protected $_port = 80;

    /**
     * User Agent string to send in requests
     * @var string
     */
    protected $_userAgent;

    /**
     * Constructor
     *
     * @param string $apiKey TypePadAntiSpam API key
     * @param string $blog Blog URL
     * @return void
     */
    public function __construct($apiKey, $blog)
    {
        $this->setBlogUrl($blog)
             ->setApiKey($apiKey)
             ->setUserAgent('Zend Framework/' . Zend_Version::VERSION . ' | TypePadAntiSpam/1.1');
    }

    /**
     * Retrieve blog URL
     *
     * @return string
     */
    public function getBlogUrl()
    {
        return $this->_blogUrl;
    }

    /**
     * Set blog URL
     *
     * @param string $blogUrl
     * @return Zend_Service_TypePadAntiSpam
     * @throws Zend_Service_Exception if invalid URL provided
     */
    public function setBlogUrl($blogUrl)
    {
        require_once 'Zend/Uri.php';
        if (!Zend_Uri::check($blogUrl)) {
            require_once 'Zend/Service/Exception.php';
            throw new Zend_Service_Exception('Invalid url provided for blog');
        }

        $this->_blogUrl = $blogUrl;
        return $this;
    }

    /**
     * Retrieve API key
     *
     * @return string
     */
    public function getApiKey()
    {
        return $this->_apiKey;
    }

    /**
     * Set API key
     *
     * @param string $apiKey
     * @return Zend_Service_TypePadAntiSpam
     */
    public function setApiKey($apiKey)
    {
        $this->_apiKey = $apiKey;
        return $this;
    }

    /**
     * Retrieve charset
     *
     * @return string
     */
    public function getCharset()
    {
        return $this->_charset;
    }

    /**
     * Set charset
     *
     * @param string $charset
     * @return Zend_Service_TypePadAntiSpam
     */
    public function setCharset($charset)
    {
        $this->_charset = $charset;
        return $this;
    }

    /**
     * Retrieve TCP/IP port
     *
     * @return int
     */
    public function getPort()
    {
        return $this->_port;
    }

    /**
     * Set TCP/IP port
     *
     * @param int $port
     * @return Zend_Service_TypePadAntiSpam
     * @throws Zend_Service_Exception if non-integer value provided
     */
    public function setPort($port)
    {
        if (!is_int($port)) {
            require_once 'Zend/Service/Exception.php';
            throw new Zend_Service_Exception('Invalid port');
        }

        $this->_port = $port;
        return $this;
    }

    /**
     * Retrieve User Agent string
     *
     * @return string
     */
    public function getUserAgent()
    {
        return $this->_userAgent;
    }

    /**
     * Set User Agent
     *
     * Should be of form "Some user agent/version | TypePadAntiSpam/version"
     *
     * @param string $userAgent
     * @return Zend_Service_TypePadAntiSpam
     * @throws Zend_Service_Exception with invalid user agent string
     */
    public function setUserAgent($userAgent)
    {
        if (!is_string($userAgent)
            || !preg_match(":^[^\n/]*/[^ ]* \| TypePadAntiSpam/[0-9\.]*$:i", $userAgent))
        {
            require_once 'Zend/Service/Exception.php';
            throw new Zend_Service_Exception('Invalid User Agent string; must be of format "Application name/version | TypePadAntiSpam/version"');
        }

        $this->_userAgent = $userAgent;
        return $this;
    }

    /**
     * Post a request
     *
     * @param string $host
     * @param string $path
     * @param array  $params
     * @return mixed
     */
    protected function _post($host, $path, array $params)
    {
        $uri    = 'http://' . $host . ':' . $this->getPort() . $path;
        $client = self::getHttpClient();
        $client->setUri($uri);
        $client->setConfig(array(
            'useragent'    => $this->getUserAgent(),
        ));

        $client->setHeaders(array(
            'Host'         => $host,
            'Content-Type' => 'application/x-www-form-urlencoded; charset=' . $this->getCharset()
        ));
        $client->setParameterPost($params);

        $client->setMethod(Zend_Http_Client::POST);
        return $client->request();
    }

    /**
     * Verify an API key

     *
     * @param string $key Optional; API key to verify
     * @param string $blog Optional; blog URL against which to verify key
     * @return boolean
     */
    public function verifyKey($key = null, $blog = null)
    {
        if (null === $key) {
            $key = $this->getApiKey();
        }

        if (null === $blog) {
            $blog = $this->getBlogUrl();
        }

        $response = $this->_post('api.antispam.typepad.com', '/1.1/verify-key', array(
            'key'  => $key,
            'blog' => $blog
        ));

        return ('valid' == $response->getBody());
    }

    /**
     * Perform an API call
     *
     * @param string $path
     * @param array $params
     * @return Zend_Http_Response
     * @throws Zend_Service_Exception if missing user_ip or user_agent fields
     */
    protected function _makeApiCall($path, $params)
    {
        if (empty($params['user_ip']) || empty($params['user_agent'])) {
            require_once 'Zend/Service/Exception.php';
            throw new Zend_Service_Exception('Missing required TypePadAntiSpam fields (user_ip and user_agent are required)');
        }

        if (!isset($params['blog'])) {
            $params['blog'] = $this->getBlogUrl();
        }

        return $this->_post($this->getApiKey() . '.api.antispam.typepad.com', $path, $params);
    }

    /**
     * Check a comment for spam
     *
     * Checks a comment to see if it is spam. $params should be an associative
     * array with one or more of the following keys (unless noted, all keys are
     * optional):
     * - blog: URL of the blog. If not provided, uses value returned by {@link getBlogUrl()}
     * - user_ip (required): IP address of comment submitter
     * - user_agent (required): User Agent used by comment submitter
     * - referrer: contents of HTTP_REFERER header
     * - permalink: location of the entry to which the comment was submitted
     * - comment_type: typically, one of 'blank', 'comment', 'trackback', or 'pingback', but may be any value
     * - comment_author: name submitted with the content
     * - comment_author_email: email submitted with the content
     * - comment_author_url: URL submitted with the content
     * - comment_content: actual content
     *
     * Additionally, TypePadAntiSpam suggests returning the key/value pairs in the
     * $_SERVER array, and these may be included in the $params.
     *
     * This method implements the TypePadAntiSpam comment-check REST method.
     *
     * @param array $params
     * @return boolean
     * @throws Zend_Service_Exception with invalid API key
     */
    public function isSpam($params)
    {
        $response = $this->_makeApiCall('/1.1/comment-check', $params);

        $return = trim($response->getBody());
        

        if ('invalid' == $return) {
            require_once 'Zend/Service/Exception.php';
            throw new Zend_Service_Exception('Invalid API key');
        }

        if ('true' == $return) {
            return true;
        }

        return false;
    }

    /**
     * Submit spam
     *
     * Takes the same arguments as {@link isSpam()}.
     *
     * Submits known spam content to TypePadAntiSpam to help train it.
     *
     * This method implements TypePadAntiSpam's submit-spam REST method.
     *
     * @param array $params
     * @return void
     * @throws Zend_Service_Exception with invalid API key
     */
    public function submitSpam($params)
    {
        $response = $this->_makeApiCall('/1.1/submit-spam', $params);
        $value    = trim($response->getBody());
        if ('invalid' == $value) {
            require_once 'Zend/Service/Exception.php';
            throw new Zend_Service_Exception('Invalid API key');
        }
    }

    /**
     * Submit ham
     *
     * Takes the same arguments as {@link isSpam()}.
     *
     * Submits a comment that has been falsely categorized as spam by TypePadAntiSpam
     * as a false positive, telling TypePadAntiSpam's filters not to filter such
     * comments as spam in the future.
     *
     * Unlike {@link submitSpam()} and {@link isSpam()}, a valid API key is
     * never necessary; as a result, this method never throws an exception
     * (unless an exception happens with the HTTP client layer).
     *
     * this method implements TypePadAntiSpam's submit-ham REST method.
     *
     * @param array $params
     * @return void
     */
    public function submitHam($params)
    {
        $response = $this->_makeApiCall('/1.1/submit-ham', $params);
    }
}
?>