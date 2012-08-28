/*
   Copyright (c) 2008. Adobe Systems Incorporated.
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

     * Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.
     * Neither the name of Adobe Systems Incorporated nor the names of its
       contributors may be used to endorse or promote products derived from this
       software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
*/
package org.flexunit.flexui.patterns
{
   import org.flexunit.flexui.data.TestFunctionRowData;

   public class AbstractPattern
   {
      public static const STRING_IN : String = "String in {0}";
      public static const STRING_MATCHING : String = "String matching {0}";
      public static const STRING_NOT_MATCHING : String = "String not matching {0}";
      public static const SUBSTRING_OF : String = "Substring of {0}";
      public static const NULL : String = "null";
      public static const NOT_NULL : String = "not null";
      public static const UNDEFINED : String = "undefined";
      public static const NOT_UNDEFINED : String = "not undefined";
      public static const CALL_BEFORE : String = "Call before {0}";
      public static const HAMCREST : RegExp = /.*Expected.*\s*but: was.*/;
	  public static const INEQUALITY : RegExp = /.*Expected:.*\s*but: .*/;

      private var _pattern : RegExp;
      private var results : Array;

	  /*  If the assertion error is a standard flexunit error, format it using the
	      constant strings.  If it is a hamcrest error, the pattern is passed and
	      may be used directly. */
      public function AbstractPattern( pattern : Object )
      { 
      	 if ( pattern is String ) {
         	_pattern = new RegExp( pattern.replace( /\{\d\}/g, "(.*)" ) );
         }
         else { // added to adjust for hamcrest patterns
         	_pattern = pattern as RegExp;
      	 }
      }

      public function match( errorMessage : String ) : Boolean
      {
         results = _pattern.exec( errorMessage ) as Array;

         return results && results.length > 0;
      }

      public function apply( newRow : TestFunctionRowData ) : void
      {
         if ( getActualResult( results ) != null )
         {
            newRow.actualResult = getActualResult( results );
         }
         if ( getExpectedResult( results ) != null )
         {
            newRow.expectedResult = getExpectedResult( results );
         }
      }

      protected function getActualResult( results : Array ) : String
      {
         return results[ 1 ];
      }

      protected function getExpectedResult( results : Array ) : String
      {
         return results[ 2 ];
      }
   }
}
