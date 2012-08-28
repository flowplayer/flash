/**
 * Copyright (c) 2009 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author     Joseph Adkins
 * @version    
 **/ 
package org.flexunit.flexui.patterns
{
   import mx.utils.StringUtil;
   
   public class AssertThatPattern extends AbstractPattern
   {  //handles hamcrest assertion.
   	  public static const EXPECTED_START : String = "Expected:";
   	  public static const EXPECTED_END : String = "";
   	  public static const ACTUAL_START : String = "was";
   
      public function AssertThatPattern()
      {
      	 	/* breaks the error based on generic hamcrest regular expression.
      	 	All current hamcrest errors follow this format. */
         //super( /.*Expected.*\s*but: was.*/g );
         super( HAMCREST );
      }
      
      override protected function getActualResult( results : Array ) : String
      {
      	 var actualResult : String = "";
      	 
      	 	/* Split the message array and find where the actual result begins.
      	 	In hamcrest errors, this is denoted by ACTUAL_START */
      	 var resultError : Array = results[ 0 ].split( " " ) as Array;
      	 var start : Number = resultError.indexOf( ACTUAL_START );
      	 
      	 	/* Rebuild the error, removing all "<" and ">" from the message.
      	 	Stop at end of line. */
      	 for ( var i:Number = start + 1; i < resultError.length; i++ ) {
      	 	resultError[ i ] = resultError[ i ].toString().replace( /</g, "" );
      	 	resultError[ i ] = resultError[ i ].toString().replace( />/g, "" );
			resultError[ i ] = resultError[ i ].toString().replace( /\(/g, "" );
			resultError[ i ] = resultError[ i ].toString().replace( /\)/g, "" );
      	  	actualResult += StringUtil.trim( resultError[ i ].toString() ) + " ";
       	 }
         return StringUtil.trim( actualResult );
      }

      override protected function getExpectedResult( results : Array ) : String
      {
      	var expectedResult : String = "";
      	
      		/* Split the message array and find where the expected result begins.
      	 	In hamcrest errors, this is denoted by EXPECTED_START */
      	var resultError : Array = results[ 0 ].split( " " ) as Array;
      	var start : Number = resultError.indexOf( EXPECTED_START );
      	
      		/* Rebuild the error, removing all "<" and ">" from the message.
      	 	Stop when EXPECTED_END is encountered in array (start of actual result) */
      	for ( var i:Number = start + 1; i < resultError.length; i++ ) {
      		resultError[ i ] = resultError[ i ].toString().replace( /</g, "" );
      	 	resultError[ i ] = resultError[ i ].toString().replace( />/g, "" );
			resultError[ i ] = resultError[ i ].toString().replace( /\(/g, "" );
			resultError[ i ] = resultError[ i ].toString().replace( /\)/g, "" );
      		expectedResult += StringUtil.trim( resultError[ i ].toString() ) + " ";
      		
      		if ( resultError[i+1] == EXPECTED_END ) {
      			break;
      		}
      	}
         return StringUtil.trim( expectedResult );     
      }  
   }
}