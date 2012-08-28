package org.flexunit.flexui.data.filter
{
   import org.flexunit.flexui.controls.FlexUnitLabels;
   import org.flexunit.flexui.data.TestFunctionRowData;

   public class IgnoredTestFunctionStatus implements ITestFunctionStatus
   {
      public function isTestFunctionVisible( test : TestFunctionRowData ) : Boolean
      {
         return test.testIgnored;
      }
      
      public function get label() : String
      {
         return FlexUnitLabels.IGNORED_TESTS;
      }
   }
}