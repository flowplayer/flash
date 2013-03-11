This is a simple player to allow testers to test different VPAID creatives without the presence of VAST.

Steps to test:
Publish VPAIDSample.fla
Launch VPAIDSample.html to test the video player

Expected results:
Content video will play.

Additional Instructions:
To test other creatives, change chosenLinear to any of the other constants in the list preceding it. E.g.:
		public static const chosenLinear:String = LINEAR_VPAID;
		public static const chosenNonLinear:String = NONLINEAR_VPAID;