/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package org.osmf.smpte.tt.rendering
{
	public class Unicode
	{
		
		public static const Whitespace:Vector.<String> = new Vector.<String>([' ']);
		
		public static const VisibleBreakChar:Vector.<String> =
			new Vector.<String>(
				'-',
				'\u007C',
				'\u00AD',
				'\u058A',
				'\u0964',
				'\u0965',
				'\u0E5A',
				'\u0E5B',
				'\u0F0B',
				'\u0F34',
				'\u0F7F',
				'\u0F85',
				'\u0FBE',
				'\u0FBF',
				'\u104A',
				'\u104B',
				'\u1361',
				'\u16EB',
				'\u16EC',
				'\u16ED',
				'\u17D4',
				'\u17D5',
				'\u17D8',
				'\u17DA',
				'\u1802',
				'\u1803',
				'\u1804',
				'\u1805',
				'\u1808',
				'\u1809',
				'\u1A1E',
				'\u2000',
				'\u2001',
				'\u2002',
				'\u2010',
				'\u2012',
				'\u2013',
				'\u2027',
				'\u2056',
				'\u2058',
				'\u2059',
				'\u205A',
				'\u205B',
				'\u205D',
				'\u205E',
				'\u205F',
				'\u2CF9',
				'\u2CFA',
				'\u2CFB',
				'\u2CFC',
				'\u2CFE',
				'\u2CFF',
				'\u2E0E',
				'\u2E0F',
				'\u2E10',
				'\u2E11',
				'\u2E12',
				'\u2E13',
				'\u2E14',
				'\u2E15',
				'\u2E17'
			);
		
		//{ region Break Opportunities
		/// <summary>
		/// These characters all provide a break opportunity in Unicode.
		/// </summary>
		public static const BreakOpportunities:Vector.<String> =
			new Vector.<String>(
				' ',
				'-',
				'\u0009',
				'\u007C',
				'\u00AD',
				'\u058A',
				'\u0964',
				'\u0965',
				'\u0E5A',
				'\u0E5B',
				'\u0F0B',
				'\u0F34',
				'\u0F7F',
				'\u0F85',
				'\u0FBE',
				'\u0FBF',
				'\u104A',
				'\u104B',
				'\u1361',
				'\u1680',
				'\u16EB',
				'\u16EC',
				'\u16ED',
				'\u17D4',
				'\u17D5',
				'\u17D8',
				'\u17DA',
				'\u1802',
				'\u1803',
				'\u1804',
				'\u1805',
				'\u1808',
				'\u1809',
				'\u1A1E',
				'\u2000',
				'\u2001',
				'\u2002',
				'\u2003',
				'\u2004',
				'\u2005',
				'\u2006',
				'\u2008',
				'\u2009',
				'\u200A',
				'\u2010',
				'\u2012',
				'\u2013',
				'\u2027',
				'\u2056',
				'\u2058',
				'\u2059',
				'\u205A',
				'\u205B',
				'\u205D',
				'\u205E',
				'\u205F',
				'\u2CF9',
				'\u2CFA',
				'\u2CFB',
				'\u2CFC',
				'\u2CFE',
				'\u2CFF',
				'\u2E0E',
				'\u2E0F',
				'\u2E10',
				'\u2E11',
				'\u2E12',
				'\u2E13',
				'\u2E14',
				'\u2E15',
				'\u2E17'
			);
		//} endregion
	}
}