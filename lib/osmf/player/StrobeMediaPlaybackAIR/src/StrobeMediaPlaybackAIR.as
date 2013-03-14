package
{
	//import AppMeasurement class frm AppMeasurement.swc
	import com.omniture.AppMeasurement;
	
	import fl.controls.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.*;
	import flash.net.*;
	import flash.system.Capabilities;
	import flash.text.*;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.setTimeout;
	
	import org.osmf.layout.ScaleMode;
	import org.osmf.player.chrome.events.WidgetEvent;
	
	
	// we set the background of the SWF
	[SWF(backgroundColor="0x000000", frameRate="25")]
	
	public class StrobeMediaPlaybackAIR extends Sprite
	{
		// available playlists
		private const xmlURLDesktop:String = "http://catherine.corp.adobe.com/nail/playlists/playlist-desktop.xml";
		private const xmlURLAndroid:String = "http://catherine.corp.adobe.com/nail/playlists/playlist-android.xml";
		private const xmlURLiOS:String = "http://catherine.corp.adobe.com/nail/playlists/playlist-ios.xml";
		
		// the skin to be loaded
		private var skinURL:String = "http://catherine.corp.adobe.com/nail/skin/tablet-skin.xml";
		private var monitor:NetMonitor;
		private var s:AppMeasurement;
		
		// UI elements
		private var backgroundHomeView:Sprite;
		private var backMatrix:Matrix;
		private var whiteSheetHomeView:Sprite;
		private var backgroundVideoView:Sprite;
		private var whiteLeftSheetVideoView:Sprite;
		private var whiteRightSheetVideoView:Sprite;
		private var subTitleTxt:TextField;
		private var subTitleBg:Sprite;
		private var subTitleSep:Sprite;
		private var txTitle:TextField;
		private var spTitleBg:Sprite;
		private var btBack:SuperBackButton;
		private var spPlaylistContainer:Sprite;
		private var txDescription:TextField;
		private var txPosition:TextField;
		private var spBottomLine:Sprite;
		private var mmMonitor:MMTest;
		private var txDescriptionLabel:TextField;
		private var spDescriptionLine:Sprite;
		private var smpPlayer:StrobeMediaPlayback;
		private var maskForSmpStageVideoHomeBackground:Sprite;
		private var maskForSmpStageVideoWhiteLeftSheet:Sprite;
		private var cbMM:CheckBox;
		private var cbPerf:CheckBox;
		private var spMask:Sprite;
		private var spNavHlder:Sprite;
		
		// UI data
		private var nCurrentPage:Number = 1;
		private var nPlaylistPages:Number = 1;
		private var maxPerPage:Number = 2;
		private var navigation:Vector.<RoundButton> = new Vector.<RoundButton>();
		private var plXMLLoader:URLLoader;
		private var xmlPlaylist:XML;
		private var arPlayListInfo:Array;
		private var arPlayListElm:Array;
		private var viewType:String = VIEW_HOME;
		private var rows:Number = 0;
		private var columns:Number = 0;
		private var nOfElm:Number;
		private var swiping:Boolean = false;
		
		private var calculatedThumbSize:Number = 0;
		private var initializeParams:Object = new Object();
		
		private var playlistCoords:Point;
		private var playlistRotation:Number = 0;
		
		private var fullscreen:Boolean = false;
		
		private const THUMB_SIZE:Number = 214;
		private const SPACING:Number = 24;
		private const TITLE_HEIGHT:Number = 68;
		private const SUBTITLE_HEIGHT:Number = 90;
		
		private const VIEW_HOME:String = "ViewHome";
		private const VIEW_VIDEO:String = "ViewVideo";
		
		private const PLAYLIST_ORIENTATION_HORIZONTAL:String = "PlaylistOrientationHorizontal";
		private const PLAYLIST_ORIENTATION_VERTICAL:String = "PlaylistOrientationVertical";
		private const PLAYLIST_ORIENTATION_NONE:String = "PlaylistOrientationNone";
		
		[Embed(source="assets/font/PlaybackSans-Regular.otf", fontFamily="Playback", embedAsCFF="false")]
		private var PlaybackFont:Class;
		[Embed(source="assets/font/PlaybackSans-Bold.otf", fontFamily="PlaybackBold", embedAsCFF="false")]
		private var PlaybackBoldFont:Class;
		[Embed(source="assets/font/PlaybackSans-Light.otf", fontFamily="PlaybackLight", embedAsCFF="false")]
		private var PlaybackLightFont:Class;
		[Embed(source="assets/font/PlaybackSans-Black.otf", fontFamily="PlaybackBlack", embedAsCFF="false")]
		private var PlaybackBlackFont:Class;
		
		public function StrobeMediaPlaybackAIR() {
			// we prepare the satge
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenHandler);
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, function (e:StageVideoAvailabilityEvent):void {});
			
			// gesture
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			
			// we create a monitor to handle MM vaidation
			monitor = new NetMonitor();
			var streams:Vector.<NetStream> = monitor.listStreams();
			monitor.addEventListener(NetMonitorEvent.NET_STREAM_CREATE, netStreamCreate);
			
			// app measurement plugin config
			configAppMeasurement();
			
			// creating design/layout components
			createBackgrounds();
			createSubTitle();
			createWhiteSheets();			
			createTitle();
			createPlaylist();
			createBottom();
			createMainVideo();			
			createDebugOptions();
			createMMMonitor();
			
			// loaing playlist
			plXMLLoader = new URLLoader();
			this.plXMLLoader.addEventListener(Event.COMPLETE, onPLXMLLoaded);
			this.plXMLLoader.addEventListener(IOErrorEvent.IO_ERROR,onPLXMLIOError);
			this.plXMLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onPLXMLSecurityError);
			plXMLLoader.load(new URLRequest(playlist + "?rand=" + Math.random()));
		}
		
		private function createBackgrounds():void {
			// max of sizes
			var squareEdgeSize:int = Math.max(stage.stageWidth, stage.stageHeight);

			// creating the mask needed to let the stage video show through all layers
			maskForSmpStageVideoHomeBackground = new Sprite();
			maskForSmpStageVideoHomeBackground.graphics.clear();
			maskForSmpStageVideoHomeBackground.graphics.beginFill(0x000000, 1);
			maskForSmpStageVideoHomeBackground.graphics.drawRect(0, 0, squareEdgeSize, squareEdgeSize);
			maskForSmpStageVideoHomeBackground.graphics.endFill();
			
			// creating the mask needed to let the stage video show through all layers
			maskForSmpStageVideoWhiteLeftSheet = new Sprite();
			maskForSmpStageVideoWhiteLeftSheet.graphics.clear();
			maskForSmpStageVideoWhiteLeftSheet.graphics.beginFill(0x000000, 1);
			maskForSmpStageVideoWhiteLeftSheet.graphics.drawRect(0, 0, squareEdgeSize, squareEdgeSize);
			maskForSmpStageVideoWhiteLeftSheet.graphics.endFill();
			
			// app background
			backgroundHomeView = new Sprite();
			backMatrix = new Matrix();
			backgroundHomeView.x = 0;
			backgroundHomeView.y = 0;
			backgroundHomeView.blendMode = BlendMode.LAYER;
			addChild(backgroundHomeView);
			
			backgroundVideoView = new Sprite();
			backgroundVideoView.visible = false;
			addChild(backgroundVideoView);
			
			arrangeBackgrounds();
		}
		
		private function createTitle():void {
			//title background
			spTitleBg = new Sprite();
			var matr:Matrix = new Matrix();
			matr.createGradientBox(TITLE_HEIGHT, TITLE_HEIGHT, Math.PI / 2, 0, 0);
			spTitleBg.graphics.beginGradientFill(GradientType.LINEAR, [0x484848,0x000000], [1,1], [0,255], matr);
			spTitleBg.graphics.drawRect(0, 0, stage.stageWidth, TITLE_HEIGHT);
			spTitleBg.x = 0;
			spTitleBg.y = 0;
			addChild(spTitleBg);
			
			//title 
			txTitle= new TextField();
			txTitle.embedFonts = true;
			txTitle.antiAliasType = AntiAliasType.ADVANCED;
			txTitle.defaultTextFormat = new TextFormat("PlaybackBlack", 24, 0xcccccc, true);
			txTitle.autoSize= "left";
			txTitle.text = "Video Player";
			txTitle.selectable= false;
			txTitle.x = SPACING;
			txTitle.y = SPACING;
			addChild (txTitle);
		}

		private function createWhiteSheets():void {
			//the white sheet that holds the playlist
			whiteSheetHomeView = new Sprite();
			whiteSheetHomeView.visible = true;
			whiteSheetHomeView.blendMode = BlendMode.LAYER;
			addChild(whiteSheetHomeView);
			
			whiteLeftSheetVideoView = new Sprite();
			whiteLeftSheetVideoView.visible = false;
			whiteLeftSheetVideoView.blendMode = BlendMode.LAYER;
			addChild(whiteLeftSheetVideoView);
			
			whiteRightSheetVideoView = new Sprite();
			whiteRightSheetVideoView.visible = false;
			addChild(whiteRightSheetVideoView);
			
			arrangeWhiteSheets();
		}
		
		private function arrangeWhiteSheets():void {
			if (whiteSheetHomeView) {
				whiteSheetHomeView.graphics.clear();
				whiteSheetHomeView.graphics.beginFill(0xffffff, 1);
				whiteSheetHomeView.graphics.drawRoundRect(SPACING, SPACING, stage.stageWidth - 2 * SPACING, stage.stageHeight - 2 * SPACING - TITLE_HEIGHT, 24, 24);
				whiteSheetHomeView.graphics.endFill();
				whiteSheetHomeView.x = 0;
				whiteSheetHomeView.y = TITLE_HEIGHT;
			}

			if (stage.stageHeight > stage.stageWidth) {
				//vertical orientation
				var availableHeight:Number = stage.stageHeight - TITLE_HEIGHT - SUBTITLE_HEIGHT;
				if (whiteLeftSheetVideoView) {
					whiteLeftSheetVideoView.graphics.clear();
					whiteLeftSheetVideoView.graphics.beginFill(0xffffff, 1);
					whiteLeftSheetVideoView.graphics.drawRoundRect(
						SPACING, 
						SPACING, 
						stage.stageWidth - 2 * SPACING, 
						availableHeight * 2 / 3 - 2 * SPACING, 
						24, 
						24
					);
					whiteLeftSheetVideoView.graphics.endFill();
					whiteLeftSheetVideoView.x = 0;
					whiteLeftSheetVideoView.y = TITLE_HEIGHT + SUBTITLE_HEIGHT;
				}
				
				if (whiteRightSheetVideoView) {
					whiteRightSheetVideoView.graphics.clear();
					whiteRightSheetVideoView.graphics.beginFill(0xffffff, 1);
					whiteRightSheetVideoView.graphics.drawRoundRect(
						SPACING, 
						SPACING,
						stage.stageWidth - 2 * SPACING, 
						availableHeight * 1 / 3 - 2 * SPACING, 
						24, 
						24
					);
					whiteRightSheetVideoView.graphics.endFill();
					whiteRightSheetVideoView.x = 0;
					whiteRightSheetVideoView.y = TITLE_HEIGHT + SUBTITLE_HEIGHT + availableHeight * 2 / 3;
				}
			} else {
				// horizontal orientation
				if (whiteLeftSheetVideoView) {
					whiteLeftSheetVideoView.graphics.clear();
					whiteLeftSheetVideoView.graphics.beginFill(0xffffff, 1);
					whiteLeftSheetVideoView.graphics.drawRoundRect(
						SPACING, 
						SPACING, 
						stage.stageWidth * 2 / 3 - 2 * SPACING, 
						stage.stageHeight - 2 * SPACING - TITLE_HEIGHT - SUBTITLE_HEIGHT, 
						24, 
						24
					);
					whiteLeftSheetVideoView.graphics.endFill();
					whiteLeftSheetVideoView.x = 0;
					whiteLeftSheetVideoView.y = TITLE_HEIGHT + SUBTITLE_HEIGHT;
				}
				
				if (whiteRightSheetVideoView) {
					whiteRightSheetVideoView.graphics.clear();
					whiteRightSheetVideoView.graphics.beginFill(0xffffff, 1);
					whiteRightSheetVideoView.graphics.drawRoundRect(
						SPACING, 
						SPACING, 
						stage.stageWidth * 1 / 3 - 2 * SPACING, 
						stage.stageHeight - 2 * SPACING - TITLE_HEIGHT - SUBTITLE_HEIGHT, 
						24, 
						24
					);
					whiteRightSheetVideoView.graphics.endFill();
					whiteRightSheetVideoView.x = stage.stageWidth * 2 / 3;
					whiteRightSheetVideoView.y = TITLE_HEIGHT + SUBTITLE_HEIGHT;
				}
			}
		}
		
		private function arrangeBackgrounds():void {
			// the background
			var squareEdgeSize:int = Math.max(stage.stageWidth, stage.stageHeight);
			if (backMatrix) {
				backMatrix.createGradientBox(squareEdgeSize, squareEdgeSize, Math.PI / 2, 0, 0);
			}
			if (backgroundHomeView) {
				backgroundHomeView.graphics.clear();
				backgroundHomeView.graphics.beginGradientFill(GradientType.LINEAR, [0x666666, 0x999999], [1, 1], [0, 255], backMatrix);
				backgroundHomeView.graphics.drawRect(0, 0, squareEdgeSize, squareEdgeSize);
				backgroundHomeView.graphics.endFill();
			}
			if (stage.stageHeight > stage.stageWidth) {
				// vertical orientation
				var availableHeight:Number = stage.stageHeight - TITLE_HEIGHT - SUBTITLE_HEIGHT;
				if (backgroundVideoView) {
					backgroundVideoView.graphics.clear();
					backgroundVideoView.graphics.beginFill(0xffffff, 0.35);
					backgroundVideoView.graphics.drawRect(0, 0, stage.stageWidth, availableHeight * 1 / 3);
					backgroundVideoView.graphics.endFill();
					backgroundVideoView.x = 0;
					backgroundVideoView.y = TITLE_HEIGHT + SUBTITLE_HEIGHT + availableHeight * 2 / 3;
				}
			} else {
				// horizontal orientation
				if (backgroundVideoView) {
					backgroundVideoView.graphics.clear();
					backgroundVideoView.graphics.beginFill(0xffffff, 0.35);
					backgroundVideoView.graphics.drawRect(0, 0, stage.stageWidth - stage.stageWidth * 2 / 3, stage.stageHeight - TITLE_HEIGHT + SUBTITLE_HEIGHT);
					backgroundVideoView.graphics.endFill();
					backgroundVideoView.x = stage.stageWidth * 2 / 3;
					backgroundVideoView.y = TITLE_HEIGHT + SUBTITLE_HEIGHT;
				}
			}			
		}
		
		private function createPlaylist():void {
			// playlist area
			spPlaylistContainer = new Sprite();
			addChild(spPlaylistContainer);
			spPlaylistContainer.addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe); 
			
			// mask
			spMask = new Sprite();
			spMask.graphics.beginFill(0xffcccc, 1);
			spMask.graphics.drawRect(0, 0, 1, 1);
			spMask.graphics.endFill();
			addChild(spMask);
			
			// arranging the playlist
			arrangePlaylistArea();
		}
		
		private function arrangePlaylistArea():void {
			
			//if the playlist.xml has not yet been loaded exit this function
			if (!arPlayListElm) {
				return;
			}
			
			// are we landscape or portrait
			var playlistOrientation:String = stage.stageWidth >= stage.stageHeight ? PLAYLIST_ORIENTATION_HORIZONTAL : PLAYLIST_ORIENTATION_VERTICAL;
			
			// this is the thumb rotation
			var thumbRotation:Number = 0;
			
			// calculate columns and lines
			if (viewType == VIEW_VIDEO) {
				if (playlistOrientation == PLAYLIST_ORIENTATION_HORIZONTAL) {
					// in this case we have only one row of thumbs
					// is a row rotated by 90 degrees
					rows = 1;
					// calculate the proper thumb size
					// we start calculating from the available width
					calculatedThumbSize = whiteRightSheetVideoView.width - 4 * SPACING;
					// calculate number of columns
					columns = Math.ceil((whiteRightSheetVideoView.height - 2 * SPACING) / ((calculatedThumbSize + SPACING)));
					// horizontally, we may get out of the box
					if (columns * (calculatedThumbSize + SPACING) > whiteRightSheetVideoView.height - 2 * SPACING) {
						calculatedThumbSize = Math.floor((whiteRightSheetVideoView.height - 2 * SPACING - (columns - 1) * SPACING) / columns);
					}
					// positioning the container
					playlistCoords = new Point(whiteRightSheetVideoView.x + 2 * SPACING, whiteRightSheetVideoView.y + 2 * SPACING);
					playlistRotation = 90;
					thumbRotation = -90;
				} else if (playlistOrientation == PLAYLIST_ORIENTATION_VERTICAL) {
					// in this case we have only one row of thumbs
					rows = 1;
					// calculate the proper thumb size
					// we start calculating from the available height
					calculatedThumbSize = whiteRightSheetVideoView.height - 4 * SPACING;
					// calculate number of columns
					columns = Math.ceil((stage.stageWidth - 4 * SPACING) / ((calculatedThumbSize + SPACING)));
					// horizontally, we may get out of the box
					if (columns * (calculatedThumbSize + SPACING) > stage.stageWidth - 4 * SPACING) {
						calculatedThumbSize = Math.floor((stage.stageWidth - 4 * SPACING - (columns - 1) * SPACING) / columns);
					}
					// positioning the container
					playlistCoords = new Point(2 * SPACING, whiteRightSheetVideoView.y + 2 * SPACING);
					playlistRotation = 0;
					thumbRotation = 0;
				}
			} else { 
				// calculate number of columns
				columns = Math.ceil((stage.stageWidth - 4 * SPACING) / ((THUMB_SIZE + SPACING)));
				// calculate the proper thumb size
				calculatedThumbSize = (stage.stageWidth - 4 * SPACING - (columns - 1) * SPACING) / columns;
				// calculate the rows
				rows = Math.floor(
					(stage.stageHeight - TITLE_HEIGHT - 3 * SPACING) / (calculatedThumbSize + SPACING)
				);
				// positioning the container
				playlistCoords = new Point(2 * SPACING, TITLE_HEIGHT + 2 * SPACING);
				playlistRotation = 0;
				thumbRotation = 0;
			}	
			
			
			if (columns > 0 && rows > 0) {
				//max number of elements per page
				maxPerPage = columns * rows;
				
				//total number of elemets
				nOfElm = arPlayListElm.length;
				
				//caluclate pages	
				nPlaylistPages = Math.ceil(nOfElm / (columns * rows));
				
				//reduce current page # if the Ui has been modified and now we have fewer pages
				if (nCurrentPage > nPlaylistPages) {
					nCurrentPage = nPlaylistPages
				}
				
				var col:int = 0;
				var row:int = 0;
				var page:int = 0;
				
				for each (var vidElm:MyVideoElement in arPlayListElm) {	
					if (col >= columns) {
						row++;
						col = 0;
					}
					if (row >= rows) {
						row = 0;
						page++;
					}
					
					// resizing the thumbs
					var thumbRatio:Number = vidElm.completeHeight / vidElm.completeWidth;
					vidElm.resize(calculatedThumbSize, calculatedThumbSize * thumbRatio);
					vidElm.rotation = thumbRotation;
					// position the thumbs
					vidElm.x = col * (calculatedThumbSize + SPACING) + page * (columns * (calculatedThumbSize + SPACING));
					vidElm.y = row * (calculatedThumbSize + SPACING);
					
					col++;
				}
				
				// positioning the playlist
				spPlaylistContainer.x = playlistCoords.x;
				spPlaylistContainer.y = playlistCoords.y;
				spPlaylistContainer.rotation = playlistRotation;
				
				// position and apply playlist mask
				if (viewType == VIEW_VIDEO) {
					if (playlistOrientation == PLAYLIST_ORIENTATION_HORIZONTAL) {
						spMask.width = calculatedThumbSize * rows + SPACING * (rows - 1) + 2 * MyVideoElement.BORDER;
					} else {
						spMask.width = calculatedThumbSize * columns + SPACING * (columns - 1) + 2 * MyVideoElement.BORDER;
					}
					spMask.x = whiteRightSheetVideoView.x + 2 * SPACING - MyVideoElement.BORDER;
					spMask.y = whiteRightSheetVideoView.y + 2 * SPACING - MyVideoElement.BORDER;
					spMask.height = whiteRightSheetVideoView.height - 2 * SPACING + 2 * MyVideoElement.BORDER;
				} else {
					spMask.width = calculatedThumbSize * columns + SPACING * (columns - 1) + 2 * MyVideoElement.BORDER;
					spMask.x = whiteSheetHomeView.x + 2 * SPACING - MyVideoElement.BORDER;
					spMask.y = whiteSheetHomeView.y + 2 * SPACING - MyVideoElement.BORDER;
					spMask.height = whiteSheetHomeView.height - 3 * SPACING;
				}
				spMask.alpha = 0.5;
				spPlaylistContainer.mask = spMask;
				
				// calculate and show "x of y elements are shown"	
				var maxNumber:Number = Math.min((rows * columns * nCurrentPage), nOfElm)	
				txPosition.text = ((maxPerPage * (nCurrentPage - 1)) + 1) + "-" + maxNumber + " of " + nOfElm + " videos";
				txPosition.x = stage.stageWidth - 2 * SPACING - txPosition.width;

				// remove previous nav
				for (var j:int = 0; j < navigation.length; j++) {
					if (navigation[j]) {
						if (spNavHlder.contains(navigation[j])) {
							spNavHlder.removeChild(navigation[j]);
						}
						navigation[j] = null;
					}
				}
				
				// draw the new navigation	
				if (nPlaylistPages > 1) {
					// if we have more elements than we can fit on a page
					for (var l:int=0; l < nPlaylistPages; l++) {	
						navigation[l] = new RoundButton();
						navigation[l].pageNumber = l + 1;
						spNavHlder.addChild(navigation[l]);
						if (viewType == VIEW_VIDEO && playlistOrientation == PLAYLIST_ORIENTATION_HORIZONTAL) {
							// calculating the vertical center and the right side position
							navigation[l].x = 0;
							navigation[l].y = (l * (navigation[l].width + 6)) - 6;
							spNavHlder.x = stage.stageWidth - 3 * SPACING;
							spNavHlder.y = whiteRightSheetVideoView.y + SPACING + (whiteRightSheetVideoView.height - spNavHlder.height) / 2;
						} else {
							// calculating the horizontal possition in the bottom 
							navigation[l].x = (l * (navigation[l].width + 6)) - 6;
							navigation[l].y = 0;
							spNavHlder.x = (stage.stageWidth - spNavHlder.width) / 2;
							spNavHlder.y = stage.stageHeight - 2 * SPACING - spNavHlder.height / 2 - 1;
						}
						navigation[l].addEventListener(MouseEvent.CLICK, onClickNavigation);
						
						if (navigation[l].pageNumber != nCurrentPage) {
							navigation[l].activate();
							
						}
					}
				}	
			}
			// moving to the current page
			gotoPageNumber(nCurrentPage);
		}
		
		private function createSubTitle():void {
			// add subtitle background
			subTitleBg = new Sprite();
			subTitleBg.graphics.clear();
			subTitleBg.graphics.beginFill(0x0099ff, 0.22);
			subTitleBg.graphics.drawRect(0, 0, stage.stageWidth, SUBTITLE_HEIGHT);
			subTitleBg.graphics.endFill();
			subTitleBg.x = 0;
			subTitleBg.y = TITLE_HEIGHT;
			subTitleBg.visible = false;
			addChild(subTitleBg);
			
			// back button
			btBack = new SuperBackButton();
			addChild(btBack);
			btBack.x = SPACING;
			btBack.y = TITLE_HEIGHT + (SUBTITLE_HEIGHT - btBack.height) / 2;
			btBack.visible = false;
			btBack.addEventListener(MouseEvent.CLICK, onClickBack);

			// creating separator
			subTitleSep = new Sprite();
			subTitleSep.graphics.clear();
			subTitleSep.graphics.lineStyle(1, 0xffffff, 0.5);
			subTitleSep.graphics.lineTo(0, SUBTITLE_HEIGHT - 2 * SPACING);
			subTitleSep.x = btBack.x + btBack.width + SPACING;
			subTitleSep.y = TITLE_HEIGHT + SPACING;
			subTitleSep.visible = false;
			addChild(subTitleSep);
			
			// add subtitle text
			subTitleTxt = new TextField();
			subTitleTxt.embedFonts = true;
			subTitleTxt.antiAliasType = AntiAliasType.ADVANCED;
			subTitleTxt.defaultTextFormat = new TextFormat("PlaybackBlack", 24, 0xffffff);
			subTitleTxt.autoSize = TextFieldAutoSize.LEFT;
			subTitleTxt.selectable = false;
			subTitleTxt.visible = false;
			// adding a text field without any character will result in a incorrect height value
			// so we use a space to get the proper height value
			subTitleTxt.text = " "; 
			subTitleTxt.x = btBack.x + btBack.width + 2 * SPACING;
			subTitleTxt.y = TITLE_HEIGHT + (SUBTITLE_HEIGHT - subTitleTxt.height) / 2;
			addChild(subTitleTxt);
		}
		
		private function createMainVideo():void {
			// initialization parameters
			initializeParams["autoPlay"] = false;
			initializeParams["skin"] = skinURL;
			initializeParams["backgroundColor"] = 0x000000;
			initializeParams["showVideoInfoOverlayOnStartUp"] = false;
			initializeParams["controlBarType"] = "tablet";
			initializeParams["controlBarMode"] = "floating";
			initializeParams["enableStageVideo"] = true;
			initializeParams["playButtonOverlay"] = false;
			initializeParams["posterScaleMode"] = ScaleMode.ZOOM;
			
			// strobe media playback
			if (!smpPlayer) {
				// we create a player
				smpPlayer = new StrobeMediaPlayback();
				smpPlayer.initialize(initializeParams, this.stage, null, null);
				smpPlayer.addEventListener(WidgetEvent.VIDEO_INFO_OVERLAY_CLOSE,
					function (event:WidgetEvent):void 
					{
						cbPerf.selected = false;
					}
				);
			}
			smpPlayer.visible = false;
			smpPlayer.x = 2 * SPACING;
			smpPlayer.y = TITLE_HEIGHT + SUBTITLE_HEIGHT + 2 * SPACING;
			
			if (!contains(smpPlayer)) {
				addChild(smpPlayer)
			}
			
			// description label text	
			txDescriptionLabel = new TextField();
			txDescriptionLabel.embedFonts = true;
			txDescriptionLabel.antiAliasType = AntiAliasType.ADVANCED;
			txDescriptionLabel.selectable = false;
			txDescriptionLabel.defaultTextFormat = new TextFormat("PlaybackBlack", 12, 0x000000);
			txDescriptionLabel.autoSize = "left";
			txDescriptionLabel.text = "Description";
			txDescriptionLabel.visible = false;
			txDescriptionLabel.x = 2 * SPACING;
			addChild(txDescriptionLabel);
			
			spDescriptionLine = new Sprite();
			spDescriptionLine.visible = false;
			spDescriptionLine.x = 2 * SPACING;
			addChild(spDescriptionLine);

			//description
			txDescription = new TextField();
			txDescription.embedFonts = true;
			txDescription.antiAliasType = AntiAliasType.ADVANCED;
			txDescription.selectable = false;
			txDescription.defaultTextFormat =  new TextFormat("PlaybackLight", 12, 0x0000);
			txDescription.autoSize = "left";
			txDescription.wordWrap = true;
			txDescription.multiline = true;
			txDescription.visible = false;
			txDescription.width = stage.stageWidth * 2 / 3 - 4 * SPACING;
			txDescription.x = 2 * SPACING;
			txDescription.text = "lipsum";
			addChild(txDescription);
			
			arrangeMainVideo();
		}
		
		private function arrangeMainVideo():void {
			if (fullscreen) {
				smpPlayer.setSize(stage.stageWidth, stage.stageHeight);
			} else {
				var width:Number;
				var height:Number;
				if (stage.stageHeight > stage.stageWidth) {
					// vertical orientation
					width = stage.stageWidth - 4 * SPACING;
					height = width * 9 / 16;
				} else {
					// horizontal orientation
					width = stage.stageWidth * 2 / 3 - 4 * SPACING;
					height = width * 9 / 16;
				}
				if (smpPlayer) {
					smpPlayer.setSize(width, height);
					smpPlayer.x = whiteLeftSheetVideoView.x + 2 * SPACING;
					smpPlayer.y = whiteLeftSheetVideoView.y + 2 * SPACING;
					if (viewType == VIEW_VIDEO) {
						if (maskForSmpStageVideoHomeBackground) {
							maskForSmpStageVideoHomeBackground.width = width;
							maskForSmpStageVideoHomeBackground.height = height;
							maskForSmpStageVideoHomeBackground.x = 2 * SPACING;
							maskForSmpStageVideoHomeBackground.y = TITLE_HEIGHT + SUBTITLE_HEIGHT + 2 * SPACING;
							maskForSmpStageVideoHomeBackground.blendMode = BlendMode.ERASE;
							backgroundHomeView.blendMode = BlendMode.LAYER;
							backgroundHomeView.addChild(maskForSmpStageVideoHomeBackground);
						}
						if (maskForSmpStageVideoWhiteLeftSheet) {
							maskForSmpStageVideoWhiteLeftSheet.width = width;
							maskForSmpStageVideoWhiteLeftSheet.height = height;
							maskForSmpStageVideoWhiteLeftSheet.x = 2 * SPACING;
							maskForSmpStageVideoWhiteLeftSheet.y = 2 * SPACING;
							maskForSmpStageVideoWhiteLeftSheet.blendMode = BlendMode.ERASE;
							whiteLeftSheetVideoView.blendMode = BlendMode.LAYER;
							whiteLeftSheetVideoView.addChild(maskForSmpStageVideoWhiteLeftSheet);
						}
					}
				}
				
				if (txDescriptionLabel) {
					txDescriptionLabel.y = TITLE_HEIGHT + SUBTITLE_HEIGHT + 2 * SPACING + height + SPACING;
				}
				if (spDescriptionLine) {
					spDescriptionLine.graphics.clear();
					spDescriptionLine.graphics.lineStyle(1, 0xcccccc, 1, true, "normal");
					spDescriptionLine.graphics.lineTo(whiteLeftSheetVideoView.width - 2 * SPACING, 0);
					spDescriptionLine.y = txDescriptionLabel. y + txDescriptionLabel.height + SPACING / 2;
				}
				if (txDescription) {
					txDescription.y = txDescriptionLabel.y + txDescriptionLabel.height + SPACING;
				}
			}
		}
		
		private function createBottom():void {
			//spNavHlder
			spNavHlder = new Sprite();
			addChild(spNavHlder);
			
			//bottom line
			spBottomLine = new Sprite();
			addChild(spBottomLine); 
			
			//playlist position text
			txPosition = new TextField();
			txPosition.embedFonts = true;
			txPosition.antiAliasType = AntiAliasType.ADVANCED;
			txPosition.defaultTextFormat = new TextFormat("Playback", 14, 0x0299FD);
			txPosition.autoSize = TextFieldAutoSize.LEFT;
			txPosition.selectable = false;
			addChild(txPosition);
			
			arrangeBottom();
		}
		
		private function arrangeBottom():void {
			if (viewType == VIEW_VIDEO && stage.stageWidth > stage.stageHeight) {
				if (spBottomLine) {
					spBottomLine.graphics.clear();
					spBottomLine.graphics.lineStyle(1, 0xcccccc, 1, true, "normal");
					spBottomLine.graphics.lineTo(0, whiteRightSheetVideoView.height - 2 * SPACING);
					spBottomLine.x = whiteRightSheetVideoView.x + whiteRightSheetVideoView.width - 2 * SPACING;
					spBottomLine.y = whiteRightSheetVideoView.y + 2 * SPACING;
				}
				if (txPosition) {
					txPosition.rotation = -90;
					txPosition.x = whiteRightSheetVideoView.x + whiteRightSheetVideoView.width - SPACING;
					txPosition.y = whiteRightSheetVideoView.y + 2 * SPACING + txPosition.textWidth;
				}
			} else {
				if (spBottomLine) {
					spBottomLine.graphics.clear();
					spBottomLine.graphics.lineStyle(1, 0xcccccc, 1, true, "normal");
					spBottomLine.graphics.lineTo(stage.stageWidth - 4 * SPACING, 0);
					spBottomLine.x = 2 * SPACING;
					spBottomLine.y = stage.stageHeight - 3 * SPACING;
				}
				if (txPosition) {
					txPosition.rotation = 0;
					txPosition.x = stage.stageWidth - 2 * SPACING - txPosition.width;
					txPosition.y = stage.stageHeight - 2 * SPACING - txPosition.height / 2;
				}
			}
		}
		
		private function createDebugOptions():void {
			//cbMM
			cbMM = new CheckBox();
			cbMM.textField.autoSize = "left";
			cbMM.label = "Show MM Info";
			cbMM.x= SPACING;
			cbMM.y= stage.stageHeight - SPACING - 20; //these components start with a wierd size so we kind of approximate their position for now
			cbMM.addEventListener(MouseEvent.CLICK, toggleMM);
			cbMM.visible = false;
			addChild(cbMM);
			
			//cbPerf
			cbPerf = new CheckBox();
			cbPerf.textField.autoSize = "left";
			cbPerf.label = "Show Performance";
			cbPerf.x = 200;
			cbPerf. y = stage.stageHeight - SPACING - 20; //these components start with a wierd size so we kind of approximate their position for now
			cbPerf.addEventListener(MouseEvent.CLICK, togglePerformance);
			cbPerf.visible = false;
			addChild(cbPerf);
		}
		
		private function createMMMonitor():void {
			//media measurement debug window and listener for the keyboard
			mmMonitor = new MMTest();
			mmMonitor.visible=false;
			mmMonitor.x= stage.stageWidth/2;
			mmMonitor.y = TITLE_HEIGHT+SPACING +5;
			addChild(mmMonitor);
		}
		
		private function changeView():void {
			if (viewType == VIEW_VIDEO) {
				// show subtitle
				subTitleBg.visible = true;
				subTitleSep.visible = true;
				subTitleTxt.visible = true;
				// show back button
				btBack.visible = true;
				// show right backgorund
				backgroundVideoView.visible = true;
				// hide home sheet
				whiteSheetHomeView.visible = false;
				// show white sheets
				whiteLeftSheetVideoView.visible = true;
				whiteRightSheetVideoView.visible = true;
				// show Strobe Media Player
				smpPlayer.visible = true;
				// show description
				txDescriptionLabel.visible = true;
				spDescriptionLine.visible = true;
				txDescription.visible = true;
				
				// TODO: Re-evaluate the plugin loading mechanism in OSMF when developing AIR applications
				//initializeParams["plugin_ads"] = "http://avchathq.com/Nail/AdvertisementPlugin.swf";

				cbMM.visible = true;
				cbPerf.visible = true;
				
			} else {
				// hide subtitle
				subTitleBg.visible = false;
				subTitleSep.visible = false;
				subTitleTxt.visible = false;
				// hide back button
				btBack.visible = false;
				// hide right backgorund
				backgroundVideoView.visible = false;
				// show home sheet
				whiteSheetHomeView.visible = true;
				// hide white sheets
				whiteLeftSheetVideoView.visible = false;
				whiteRightSheetVideoView.visible = false;
				// stopping & hiding the Strobe Media Player
				smpPlayer.player.stop()
				smpPlayer.visible = false;
				// hide description
				txDescriptionLabel.visible = false;
				spDescriptionLine.visible = false;
				txDescription.visible = false;
				
				//hide the MM monitor and performance windows
				if (mmMonitor) {
					mmMonitor.visible=false;
				}
				
				if (smpPlayer) {
					smpPlayer.showVideoInfo(false);
				}
				
				//we hide the checkboxes
				if (cbMM) {
					cbMM.selected = false;
					cbMM.visible = false;
				}
				if (cbPerf) {
					cbPerf.selected = false;
					cbPerf.visible = false;
				}
			}

			// clean the MM window			
			if (mmMonitor) {
				mmMonitor.clean()
			}
			
			// arranging zones
			arrangePlaylistArea();
			arrangeWhiteSheets();
			arrangeBackgrounds();
			arrangeMainVideo();
			arrangeBottom();
		}
		
		private function gotoPageNumber(n:Number):void {
			if (n > 0 && n <= nPlaylistPages) {
				nCurrentPage = n;
				// are we landscape or portrait
				var playlistOrientation:String = stage.stageWidth >= stage.stageHeight ? PLAYLIST_ORIENTATION_HORIZONTAL : PLAYLIST_ORIENTATION_VERTICAL;

				if (viewType == VIEW_VIDEO && playlistOrientation == PLAYLIST_ORIENTATION_HORIZONTAL)
				{
					new Tween(
						spPlaylistContainer, 
						"y", 
						Strong.easeOut, 
						spPlaylistContainer.y, 
						playlistCoords.y - (n - 1) * ((calculatedThumbSize + SPACING) * columns), 
						0.5, 
						true
					);
				} else {
					new Tween(
						spPlaylistContainer, 
						"x", 
						Strong.easeOut, 
						spPlaylistContainer.x, 
						playlistCoords.x - (n - 1) * ((calculatedThumbSize + SPACING) * columns), 
						0.5, 
						true
					);
				}
				
				//calculate and show "X of Y elements are shown"	
				var maxNumber:Number = Math.min((rows * columns * nCurrentPage), nOfElm);
				txPosition.text = ((maxPerPage * (nCurrentPage - 1)) + 1) + "-" + maxNumber + " of " + nOfElm + " videos";
				
				arrangeBottom();
				
				//activate and deactivte navigation elements to correspond to the new currentPage
				for (var j:int = 0; j < navigation.length; j++) {
					if (navigation[j] != null) {
						if (j != (nCurrentPage - 1)) {
							navigation[j].activate();
						} else {
							navigation[j].deactivate();
						}
					}
				}
			}
		}
		
		private function configAppMeasurement():void {
			s = new AppMeasurement();
			s.account = "adobedevromania";
			s.Media.autoTrackNetStreams=true;
			s.Media.autoTrack= true;
			s.Media.trackWhilePlaying = true;
			s.Media.trackSeconds=5
			s.Media.playerName="Nail iOS";
			s.debugTracking = true;
			s.trackLocal = true;
			s.trackOnLoad =  true;
			s.visitorNamespace = "adobedevelopment";
			s.trackingServer = "adobedevelopment.112.2o7.net";
			addChild(s);
		}
		
		/* ----
		 * Handlers
		 * ---- 
		 */
		private function onPLXMLLoaded(e:Event=null):void {
			xmlPlaylist = XML(e.target.data);
			var playList:XMLList = xmlPlaylist.video;
			var i:Number = -1;
			arPlayListInfo = new Array();
			arPlayListElm = new Array()
			for each (var video:XML in playList) {
				i++;
				var vidInfo:VideoInfo = new VideoInfo();
				vidInfo.videoName = video.attribute("name");
				vidInfo.videoDescription = video.attribute("description");
				vidInfo.videoThumbnailPath = video.attribute("thumbnail");
				vidInfo.videoPath = video.attribute("path");
				vidInfo.duration = video.attribute("duration")
				/* 
				// TODO: Re-evaluate the plugin loading mechanism in OSMF when developing AIR applications
				if (video.attribute("preroll") != null && video.attribute("preroll") != "undefined") {
					vidInfo.preroll = video.attribute("preroll");
				}
				if (video.attribute("postroll") != null && video.attribute("postroll") != "undefined") {
					vidInfo.postroll = video.attribute("postroll");
				}
				if (video.attribute("midroll") != null && video.attribute("midroll") != "undefined") {
					vidInfo.midroll = video.attribute("midroll");
				}
				if (video.attribute("midrollTime") != null && video.attribute("midrollTime") != "undefined") {
					vidInfo.midrollTime = video.attribute("midrollTime") as Number;
				}
				if (video.attribute("overlay") != null && video.attribute("overlay") != "undefined") {
					vidInfo.overlay = video.attribute("overlay");
				}
				if (video.attribute("overlay") != null && video.attribute("overlay") != "undefined") {
					vidInfo.overlay = video.attribute("overlay");
				}
				if (video.attribute("overlayTime") != null && video.attribute("overlayTime") != "undefined") {
					vidInfo.overlayTime = video.attribute("overlayTime") as Number;
				} */
				var vidElement:MyVideoElement = new MyVideoElement(vidInfo, THUMB_SIZE, THUMB_SIZE);
				vidElement.addEventListener(MouseEvent.CLICK, onVideoElementClick);
				spPlaylistContainer.addChild(vidElement);
				
				arPlayListElm.push(vidElement) 
				arPlayListInfo.push(vidInfo);
			}
			arrangePlaylistArea();
		}
		
		private function onVideoElementClick(e:Event):void {
			if (!swiping) {
				viewType = VIEW_VIDEO;
				changeView();
				
				subTitleTxt.text = (e.target as MyVideoElement).vidInfo.videoName;
				txDescription.text = (e.target as MyVideoElement).vidInfo.videoDescription;
				
				if (smpPlayer) {
					smpPlayer.configuration.poster = (e.target as MyVideoElement).vidInfo.videoThumbnailPath;
					smpPlayer.configuration.src = (e.target as MyVideoElement).vidInfo.videoPath;
					smpPlayer.loadMedia();
				} else {
					initializeParams["poster"] = (e.target as MyVideoElement).vidInfo.videoThumbnailPath;
					initializeParams["src"] = (e.target as MyVideoElement).vidInfo.videoPath;
					/* 
					// TODO: Re-evaluate the plugin loading mechanism in OSMF when developing AIR applications
					if ((e.target as MyVideoElement).vidInfo.preroll) {
						initializeParams["ads_preroll"] = (e.target as MyVideoElement).vidInfo.preroll;
					}
					if ((e.target as MyVideoElement).vidInfo.postroll) {
						initializeParams["ads_postroll"] = (e.target as MyVideoElement).vidInfo.postroll;
					}
					if ((e.target as MyVideoElement).vidInfo.midroll) {
						initializeParams["ads_midroll"] = (e.target as MyVideoElement).vidInfo.midroll;
					}
					if ((e.target as MyVideoElement).vidInfo.midrollTime) {
						initializeParams["ads_midrollTime"] = (e.target as MyVideoElement).vidInfo.midrollTime;
					}
					if ((e.target as MyVideoElement).vidInfo.overlay) {
						initializeParams["ads_overlay"] = (e.target as MyVideoElement).vidInfo.overlay;
					}
					if ((e.target as MyVideoElement).vidInfo.overlayTime) {
						initializeParams["ads_overlayTime"] = (e.target as MyVideoElement).vidInfo.overlayTime;
					} */
					smpPlayer.initialize(initializeParams, this.stage, null, null);
				}
				
			}
		}
		
		private function onFullScreenHandler(event:FullScreenEvent):void {
			if (event.fullScreen) {
				fullscreen = true;
				// hide all
				backgroundHomeView.visible = false;
				spTitleBg.visible = false;
				txTitle.visible = false;
				subTitleBg.visible = false;
				subTitleSep.visible = false;
				subTitleTxt.visible = false;
				btBack.visible = false;
				backgroundVideoView.visible = false;
				whiteSheetHomeView.visible = false;
				whiteLeftSheetVideoView.visible = false;
				whiteRightSheetVideoView.visible = false;
				txDescriptionLabel.visible = false;
				spDescriptionLine.visible = false;
				txDescription.visible = false;
				spBottomLine.visible = false;
				txPosition.visible = false;
				spPlaylistContainer.visible =false;
				cbPerf.visible=false;
				cbMM.visible=false;
				spNavHlder.visible = false;

				smpPlayer.x = 0;
				smpPlayer.y = 0;
				smpPlayer.setSize(stage.stageWidth, stage.stageHeight);
			} else {
				fullscreen = false;
				// show what is necessary
				backgroundHomeView.visible = true;
				spTitleBg.visible = true;
				txTitle.visible = true;
				subTitleBg.visible = true;
				subTitleSep.visible = true;
				subTitleTxt.visible = true;
				btBack.visible = true;
				backgroundVideoView.visible = true;
				whiteLeftSheetVideoView.visible = true;
				whiteRightSheetVideoView.visible = true;
				txDescriptionLabel.visible = true;
				spDescriptionLine.visible = true;
				txDescription.visible = true;
				spBottomLine.visible = true;
				txPosition.visible = true;
				spPlaylistContainer.visible = true;
				cbPerf.visible = true;
				cbMM.visible = true;
				spNavHlder.visible = true;
				
				arrangeBackgrounds();
				arrangeWhiteSheets();
				arrangePlaylistArea();
				arrangeMainVideo();
				arrangeBottom();
			}
		}; 
		
		private function onSwipe(e:TransformGestureEvent):void {
			var playlistOrientation:String = stage.stageWidth >= stage.stageHeight ? PLAYLIST_ORIENTATION_HORIZONTAL : PLAYLIST_ORIENTATION_VERTICAL;
			swiping = true;
			if (viewType == VIEW_VIDEO && playlistOrientation == PLAYLIST_ORIENTATION_HORIZONTAL) {
				if (e.offsetY >= 0) {
					// user swiped upwards
					gotoPageNumber(nCurrentPage-1);
				}
				if (e.offsetY < 0) {
					// user swiped downwards
					gotoPageNumber(nCurrentPage+1);
				}
			} else {
				if (e.offsetX >= 0) {
					// user swiped towards right
					gotoPageNumber(nCurrentPage-1);
				}
				if (e.offsetX < 0) {
					// user swiped towards left
					gotoPageNumber(nCurrentPage+1);
				} 
			}
			
			var timeOut:Number = setTimeout(cancelSwiping, 1000);
		}
		
		private function cancelSwiping():void {
			swiping = false;
		}
		
		private function netStreamCreate(e:NetMonitorEvent):void {
			var ns:NetStream = e.netStream;
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
		}
		
		private function onClickBack(e:MouseEvent):void {
			viewType = VIEW_HOME;
			changeView();
		}
		
		private function onStageResize(event:Event = null):void {
			
			// resize the top header bg
			if (spTitleBg) {
				spTitleBg.width = stage.stageWidth;
			}
			// resize the sub title
			if (subTitleBg) {
				subTitleBg.width = stage.stageWidth;
			}
			
			//arrange the playlist
			arrangeWhiteSheets();
			arrangePlaylistArea();
			arrangeBackgrounds();
			arrangeMainVideo();
			arrangeBottom();
			
			//position the checkboxes
			if (cbMM) {
				cbMM.y= stage.stageHeight - SPACING;
			}
			if (cbPerf) {
				cbPerf. y = stage.stageHeight - SPACING;
			}
		}
		
		private function onClickNavigation(e:Event):void {
			gotoPageNumber((e.target as RoundButton).pageNumber);
		}
		
		private function onPLXMLIOError(e:Event = null):void {
		}
		
		private function onPLXMLSecurityError(e:Event = null):void {
		}

		private function toggleMM(e:MouseEvent):void {
			if (!mmMonitor.visible) {
				mmMonitor.visible = true;
				addChild(mmMonitor)
			} else {
				mmMonitor.visible = false;
			}
		}
		
		private function togglePerformance(e:MouseEvent):void {
			if (smpPlayer) {
				if (cbPerf.selected) {
					smpPlayer.showVideoInfo(true);
				} else {
					smpPlayer.showVideoInfo(false);
				}
			}
		}
		
		private function get playlist():String 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1) 
			{
				return xmlURLAndroid;
			} 
			else if (Capabilities.os.indexOf("iPhone") != -1) 
			{
				return xmlURLiOS;
			}
			else 
			{
				return xmlURLDesktop;
			}
		}
		
	}
}