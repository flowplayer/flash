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
   import mx.collections.ArrayCollection;
   import mx.collections.IList;
   import mx.collections.ListCollectionView;
   
   import org.flexunit.flexui.data.filter.ITestFunctionStatus;
   import org.flexunit.flexui.data.filter.TestfFunctionStatuses;

   public class TestCaseData extends AbstractRowData
   {
      public var testFunctions : IList = new ArrayCollection();
      public var filterText : String;
      public var selectedTestFunctionStatus : ITestFunctionStatus = TestfFunctionStatuses.ALL;
      
      [Embed(source="/assets/pass_small.png")]
      private static var passImg : Class;

      [Embed(source="/assets/fail_small.png")]
      private static var failImg : Class;

      private var _testsNumber : int;
      private var _testsPassedNumber : int;
	  private var _ignoredNumber:int;

      public function TestCaseData( testFunction : TestFunctionRowData )
      {
         label = testFunction.className;
         qualifiedClassName = testFunction.qualifiedClassName;
         testFunctions = new ArrayCollection();
         testSuccessful = true;
         _testsNumber = 0;
         _testsPassedNumber = 0;
		 _ignoredNumber = 0;
      }

      public function get children() : IList
      {
         return testFunctions;
      }

      override public function get failIcon() : Class
      {
         return failImg;
      }

      override public function get passIcon() : Class
      {
         return passImg;
      }
      
      override public function get isAverage() : Boolean
      {
         return true;
      }

	  public function get ignoredNumber() : int
	  {
		  return _ignoredNumber;
	  }

      public function get testsNumber() : int
      {
         return _testsNumber;
      }

      public function get passedTestsNumber() : int
      {
         return _testsPassedNumber;
      }
      
      override public function get assertionsMade() : Number
      {
         var currentAssertionsMade : Number = 0;
         
         for each ( var test : TestFunctionRowData in testFunctions )
         {
            currentAssertionsMade += test.assertionsMade;
         }
         
         if ( testFunctions.length > 0 )
         {
            return currentAssertionsMade / testFunctions.length;
         }
         return 0;
      }
      
      public function addTest( testFunctionToAdd : TestFunctionRowData ) : void
      {
         testFunctionToAdd.parentTestCaseSummary = this;
		 
		 if ( !testFunctionToAdd.testIgnored ) {
			 if ( !testFunctionToAdd.testSuccessful )
			 {
				 testSuccessful = false;
			 }
			 else
			 {
				 _testsPassedNumber++;
			 }
		 } else {
			 _ignoredNumber++;
		 }
		 
         _testsNumber++;
         testFunctions.addItem( testFunctionToAdd );
      }

      public function refresh() : void
      {
         var filteredChildren : ListCollectionView = testFunctions as ListCollectionView;
         if ( filteredChildren )
         {
            filteredChildren.filterFunction = searchFilterFunc;
            filteredChildren.refresh();
         }
      }

      private function searchFilterFunc( item : Object ) : Boolean
      {
         var testFunction : TestFunctionRowData = item as TestFunctionRowData;
         if ( ( className && className.toLowerCase().indexOf( filterText.toLowerCase() ) != - 1 ) ||
              filterText == null ||
              filterText == "" ||
              testFunction.isVisibleOnFilterText( filterText.toLowerCase() ) )
         {
            if ( selectedTestFunctionStatus.isTestFunctionVisible( testFunction ) )
               return true;
         }

         return false;
      }
   }
}
