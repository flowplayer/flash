/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.test.mast
{
	/**
	 * Centralized test class for MAST constants, such as URLs to MAST documents.
	 **/
	public class MASTTestConstants
	{
		public static const MISSING_MAST_DOCUMENT_URL:String = "http://bad.url.com//missing_mast.xml";
		
		public static const INVALID_XML_MAST_DOCUMENT_URL:String = "http://bad.url.com/mast/invalid_xml_mast_response.xml";
		public static const INVALID_XML_MAST_DOCUMENT_CONTENTS:String =
			"<NotValidXML>";

		public static const INVALID_MAST_DOCUMENT_URL:String = "http://bad.url.com/mast/invalid_mast_inline_ad_response.xml";
		public static const INVALID_MAST_DOCUMENT_CONTENTS:String =
			"<NotAVastDocument/>";

		public static const MAST_DOCUMENT_URL:String = "http://mediapm.edgesuite.net/osmf/content/mast/mast_sample_onitemstart.xml";
		public static const MAST_DOCUMENT_CONTENTS:XML =
			<MAST xsi:schemaLocation="http://openvideoplayer.sf.net/mast http://openvideoplayer.sf.net/mast/mast.xsd" xmlns="http://openvideoplayer.sf.net/mast" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
				<triggers>
					<trigger id="preroll" description="preroll before every item" >
						<startConditions>
							<condition type="event" name="OnItemStart" >
								<!-- This child condition must also be true, so the preroll only triggers with content 1min or longer -->
								<condition type="property" name ="duration" operator="GEQ" value="1:00" />
							</condition>
						</startConditions>
						<endConditions>
							<condition type="event" name="OnItemEnd" /> <!-- This 'resets' the trigger for the next clip-->
						</endConditions>
						<sources>
			                    <source uri="http://ad.doubleclick.net/pfadx/N270.135279.6816128834321/B3442378.2;dcadv=1379578;sz=0x0;ord=123;dcmt=text/html" format="vast">
			                    <sources /> <!--Child sources, in case we had any that were dependant on this one -->
								<targets>
									<target region ="linear" type ="linear" >
										<!--This is assumed already for linear, but has been explicitly defined here-->
										<target region ="banner1" type ="banner" /><!-- This child target (companion banner) will only be placed if the parent target succeeds -->
									</target>
								</targets>
							</source>
						</sources>
					</trigger>
				</triggers>
			</MAST>
		
		public static const MAST_DOCUMENT_TEST_PARSER:XML = 
			<MAST xsi:schemaLocation="http://openvideoplayer.sf.net/mast http://openvideoplayer.sf.net/mast/mast.xsd" xmlns="http://openvideoplayer.sf.net/mast" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
				<triggers>
					<trigger id="preroll" description="preroll before every item" >
						<startConditions>
							<condition type="event" name="OnItemStart" >
								<!-- This child condition must also be true, so the preroll only triggers with content 1min or longer -->
								<condition type="property" name ="duration" operator="GEQ" value="60" />
							</condition>
						</startConditions>
						<endConditions>
							<condition type="event" name="OnItemEnd" /> <!-- This 'resets' the trigger for the next clip-->
						</endConditions>
						<sources>
			                    <source uri="http://ad.doubleclick.net/pfadx/N270.135279.6816128834321/B3442378.2;dcadv=1379578;sz=0x0;ord=123;dcmt=text/html" format="vast">
			                    <sources /> <!--Child sources, in case we had any that were dependant on this one -->
								<targets>
									<target region ="linear" type ="linear" >
										<!--This is assumed already for linear, but has been explicitly defined here-->
										<target region ="banner1" type ="banner" /><!-- This child target (companion banner) will only be placed if the parent target succeeds -->
									</target>
								</targets>
							</source>
						</sources>
					</trigger>
					<trigger id="midroll" description="midroll" >
						<startConditions>
							<condition type="property" name="position" operator="GTR" value="90" >
								<!-- This child condition must also be true, so the preroll only triggers with content 1min or longer -->
								<condition type="property" name="duration" operator="LEQ" value="360" />
								<condition type="property" name="fullScreen" operator="NEQ" value="true" />
							</condition>
						</startConditions>
						<endConditions>
							<condition type="event" name="OnItemEnd" /> <!-- This 'resets' the trigger for the next clip-->
						</endConditions>
							<sources>
			                    <source uri="http://ad.doubleclick.net/pfadx/N270.135279.6816128834321/B3442378.2;dcadv=1379578;sz=0x0;ord=123;dcmt=text/html" format="vast">
				                    <sources>
				                    	<source uri="http://foo.bar.com/something.flv" format="foobar" />
				                    	<source uri="http://for.bar.com/else.flv" format="foobar" />
				                    </sources>
									<targets>
										<target region ="linear" type ="linear" >
											<!--This is assumed already for linear, but has been explicitly defined here-->
											<target region ="banner1" type ="banner" /><!-- This child target (companion banner) will only be placed if the parent target succeeds -->
										</target>
										<target region ="linear2" type ="linear2" >
											<target region ="banner2" type ="banner" />
										</target>
									</targets>
								</source>
							</sources>
					</trigger>
					<trigger id="postroll" description="postroll" >
						<startConditions>
							<condition type="event" name="OnItemEnd" >
								<!-- This child condition must also be true, so the preroll only triggers with content 1min or longer -->
								<condition type="property" name="duration" operator="LT" value="360" />
								<condition type="property" name="position" operator="MOD" value="4" />
							</condition>
						</startConditions>
						<endConditions>
							<condition type="event" name="OnItemEnd" /> <!-- This 'resets' the trigger for the next clip-->
						</endConditions>
						<sources>
			                    <source uri="http://ad.doubleclick.net/pfadx/N270.135279.6816128834321/B3442378.2;dcadv=1379578;sz=0x0;ord=123;dcmt=text/html" format="vast">
			                    <sources /> <!--Child sources, in case we had any that were dependant on this one -->
								<targets>
									<target region ="linear" type ="linear" >
										<!--This is assumed already for linear, but has been explicitly defined here-->
										<target region ="banner1" type ="banner" /><!-- This child target (companion banner) will only be placed if the parent target succeeds -->
									</target>
								</targets>
							</source>
						</sources>
					</trigger>
				</triggers>
			</MAST>

		public static const MAST_DOCUMENT_TEST_PARSER_BAD_DATA:XML =
			<MAST xsi:schemaLocation="http://openvideoplayer.sf.net/mast http://openvideoplayer.sf.net/mast/mast.xsd" xmlns="http://openvideoplayer.sf.net/mast" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
				<triggers>
					<trigger id="preroll" description="preroll before every item" >
						<startConditions>
							<condition type="event" >
								<!-- This child condition must also be true, so the preroll only triggers with content 1min or longer -->
								<condition type="property" name ="duration" operator="GEQ" />
							</condition>
						</startConditions>
						<endConditions>
							<condition type="event" name="OnItemEnd" /> <!-- This 'resets' the trigger for the next clip-->
						</endConditions>
						<sources>
			                    <source uri="http://ad.doubleclick.net/pfadx/N270.135279.6816128834321/B3442378.2;dcadv=1379578;sz=0x0;ord=123;dcmt=text/html" format="vast">
			                    <sources /> <!--Child sources, in case we had any that were dependant on this one -->
								<targets>
									<target region ="linear" type ="linear" >
										<!--This is assumed already for linear, but has been explicitly defined here-->
										<target region ="banner1" type ="banner" /><!-- This child target (companion banner) will only be placed if the parent target succeeds -->
									</target>
								</targets>
							</source>
						</sources>
					</trigger>
				</triggers>
			</MAST>
		
	}
}