package org.osmf.net
{
	import org.osmf.net.rules.RuleBase;

	public class ABRTestUtils
	{
		// helper function to test whether two Vector.<Number> are equal
		public static function equalNumberVectors(v:Vector.<Number>, w:Vector.<Number>):Boolean
		{
			if (v == w)
			{
				return true;
			}
			
			if (v == null || w == null)
			{
				return false;
			}
			
			if (v.length != w.length)
			{
				return false;
			}
			
			for (var i:uint = 0; i < v.length; i++)
			{
				if (v[i] != w[i] && !(isNaN(v[i]) && isNaN(w[i]))) 
				{
					return false;
				}
			}
			
			return true;
		}
		
		// helper function to test whether two Vector.<Number> are equal
		public static function equalRuleBaseVectors(v:Vector.<RuleBase>, w:Vector.<RuleBase>):Boolean
		{
			if (v == w)
			{
				return true;
			}
			
			if (v == null || w == null)
			{
				return false;
			}
			
			if (v.length != w.length)
			{
				return false;
			}
			
			for (var i:uint = 0; i < v.length; i++)
			{
				if (v[i] != w[i]) 
				{
					return false;
				}
			}
			
			return true;
		}
	}
}