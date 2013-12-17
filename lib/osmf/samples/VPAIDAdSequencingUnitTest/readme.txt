VPAIDTestplayer.as is already set up to run multiple ad sequences.
In order to test various sequences, the user will need to modify the String being sent to updateSerialElement()

Steps to Test:
1) Open VPAIDTestplayer.as
2) Locate updateSerialElement("preroll/overlay"); at the end of the constructor.
3) Modify the String being sent as a parameter to this function to test differenct ad sequences.

		"preroll/overlay"
		Preroll - Overlay(Content Video) - Postroll

		"overlay"
		Preroll - Overlay(Content Video)

		"preroll/postroll"
		Preroll - Preroll - Content Video - Postroll - Postroll

		"preroll"
		Preroll - Preroll - Preroll - Content Video

		"postroll"
		Content Video - Postroll
		
4) Publish VPAIDTestPlayer.fla
5) Launch VPAIDTestPlayer.html

Additional Instructions:
To test other creatives, change chosenLinear to any of the other constants in the list preceding it. E.g.:
		public static const chosenLinear:String = LINEAR_VPAID;
		public static const chosenNonLinear:String = NONLINEAR_VPAID;