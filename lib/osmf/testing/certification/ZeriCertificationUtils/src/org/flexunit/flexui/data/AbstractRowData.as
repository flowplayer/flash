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
package org.flexunit.flexui.data
{
   import org.flexunit.flexui.controls.FlexUnitLabels;
   
   import mx.formatters.NumberFormatter;
   
   /**
    * Abstract class representing a row in the test cases tree.
    * A row can be either a test class (node) or a test case (leaf)
    */   
   public class AbstractRowData
   {
      public var label : String;
      public var qualifiedClassName : String;
      public var testSuccessful : Boolean;
      public var testIsFailure : Boolean;
      public var testIgnored : Boolean;

      /**
       * @return the class name from the qualified class name
       */      
      public function get className() : String
      {
         if ( qualifiedClassName )
         {
            var splitIndex : int = qualifiedClassName.lastIndexOf( "::" );

            if ( splitIndex >= 0 )
            {
               return qualifiedClassName.substring( splitIndex + 2 );
            }
         }

         return qualifiedClassName;
      }

      /**
       * Abstract method. Defined in TestCaseRowData and in TestClassRowData
       * 
       * @return the count of assertions which have been made either in average if
       * the current row is a test class or in total if the current row is a test case
       */
      public function get assertionsMade() : Number
      {
         throw new Error( "TestSummaryRowData::assertionsMade is an abstract method" );
      }

      public function get failIcon() : Class
      {
         throw new Error( "TestSummaryRowData::failIcon is an abstract method" );
      }

      public function get passIcon() : Class
      {
         throw new Error( "TestSummaryRowData::passIcon is an abstract method" );
      }
      
      /**
       * Abstract method which allows the legend to be correctly formatted.
       *  
       * @return true for the TestClassRowData and false for the TestCaseRowData
       */      
      public function get isAverage() : Boolean
      {
         throw new Error( "TestSummaryRowData::isAverage is an abstract method" );
      }
      
      public function get formattedAssertionsMade() : String
      {
         var f : NumberFormatter = new NumberFormatter();
         
         f.precision = 2;
         f.rounding = "nearest";
         
         return f.format( assertionsMade );
      }
      
      /**
       * @return the correcly formatted (no typos) legend for the number of assertions
       * made.
       * 
       * Can return :
       *  - 0 assertions have been made in average
       *  - 0 assertions have been made in total
       *  - 1 assertion has been made in average
       *  - 1 assertion has been made in total
       *  - 2 assertions have been made in average
       *  - 2 assertions have been made in total
       */      
      public function get assertionsMadeLegend() : String
      {
         return FlexUnitLabels.formatAssertions( 
                           formattedAssertionsMade,
                           assertionsMade,
                           isAverage );
      }
   }
}
