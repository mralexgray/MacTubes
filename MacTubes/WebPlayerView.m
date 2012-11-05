#import "WebPlayerView.h"
#import "ViewPlayer.h"
#import "FullScreenWindow.h"
#import "HelperExtension.h"
#import "ConvertExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"
#import "YouTubeHelperExtension.h"

static NSString *defaultKeyVideoPlayVolume = @"optPlayVolume";
static NSString *defaultKeyPlayerLiveResize = @"optPlayerLiveResize";

@implementation WebPlayerView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// WebFrameView delegate
	[super setFrameLoadDelegate:self];
	[super setUIDelegate:self];

	[self setHasVideo:NO];
	[self setPlayerType:[self defaultVideoPlayerType]];
	[self setChangeTimer:nil];

	// init swf player
	[self setSWFPlayState:SWF_PLAY_STATE_NONE];
	[self setVideoPlayState:VIDEO_PLAY_STATE_NONE];

	// set up player template
	[self setUpSWFPlayer];
	[self setUpVideoPlayer];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleWindowFullScreenDidChanged:) name:WINDOW_NOTIF_FULLSCREEN_DID_CHANGED object:nil];
//	[nc addObserver:self selector:@selector(windowDidResizePlayer:) name:NSWindowDidResizeNotification object:[self window]];
//	[nc addObserver:self selector:@selector(handleVideoPlayDidChanged:) name:VIDEO_NOTIF_PLAY_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoSizeScaleDidChanged:) name:VIDEO_NOTIF_SIZE_SCALE_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleItemSelectDidChanged:) name:CONTROL_NOTIF_PLAY_SELECT_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleItemSelectDidChanged:) name:CONTROL_NOTIF_INFO_SELECT_DID_CHANGED object:nil];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKeyPlayerLiveResize options:0 context:nil];
	[defaults addObserver:self forKeyPath:defaultKeyVideoPlayVolume options:0 context:nil];

}
//=======================================================================
// actions
//=======================================================================
//=======================================================================
// methods
//=======================================================================
//----------------------
// createPlayerView
//----------------------
- (BOOL)createPlayerView:(ContentItem*)itemObject
				videoURL:(NSString*)videoURL
				playerType:(int)playerType
				fileFormatNo:(int)fileFormatNo
{

	// null object
	if(itemObject == nil){
		return NO;
	}

	// stop loading
	[[self mainFrame] stopLoading];
	// stop playing
	[self setVideoPlay:NO];

	// clear timer
	[self clearChangeTimer];

//	NSString *videoURL = [itemObject contentURL];
	NSString *imageURL = [itemObject imageURL];

	// swf player
	if(playerType == VIDEO_PLAYER_TYPE_SWF){
		if([self createSWFPlayerView:videoURL] == NO){
			return NO;
		}
	}
	// video player
	else if(playerType == VIDEO_PLAYER_TYPE_VIDEO){
		if([self createVideoPlayerView:videoURL
								imageURL:imageURL
								fileFormatNo:fileFormatNo
			] == NO
		){
			return NO;
		}
	}

	// set value
	[self setHasVideo:YES];
	[self setPlayerType:playerType];
	[[self window] makeFirstResponder:self];

	// post notification
	[self postVideoObjectChangedNotification:YES];

	return YES;

}

//----------------------
// createSWFPlayerView
//----------------------
- (BOOL)createSWFPlayerView:(NSString*)videoURL
{

	//
	// add params
	//
	// defaults
	videoURL = [videoURL stringByAppendingString:@"&border=0&enablejsapi=1&playerapiid=player"];

	// auto play
	if( [self defaultBoolValue:@"optAutoPlay"] == YES || 
		[self defaultPlayRepeat] > PLAY_REPEAT_OFF){
		videoURL = [videoURL stringByAppendingString:@"&autoplay=1"];
	}

	// disable info
	if([self defaultBoolValue:@"optPlayerShowInfo"] == NO){ 
		videoURL = [videoURL stringByAppendingString:@"&showinfo=0"];
	}

	// disable related videos
	if([self defaultBoolValue:@"optPlayerShowRelatedVideos"] == NO){ 
		videoURL = [videoURL stringByAppendingString:@"&rel=0"];
	}else{
		// disable search box
		if([self defaultBoolValue:@"optPlayerShowSearch"] == NO){ 
			videoURL = [videoURL stringByAppendingString:@"&showsearch=0"];
		}
	}

	// disable annotations
	if([self defaultBoolValue:@"optPlayerHideAnnotation"] == YES){ 
		videoURL = [videoURL stringByAppendingString:@"&iv_load_policy=3"];
	}
	
	// hd
	if([self defaultPlayHighQuality] == YES){
		videoURL = [videoURL stringByAppendingString:@"&hd=1"];
	}

	//
	// decode url
	//
	videoURL = [self decodeToPercentEscapesString:videoURL];
//	NSLog(@"videoURL=%@", videoURL);

	//
	// set player html
	//
	NSString *playerHTML = [self swfPlayerHTML];

	if(![playerHTML isEqualToString:@""]){

		// get value
//		NSString *swfObjectPath = [self swfObjectPath];
		NSString *liveResize = @"0";
		if([self defaultBoolValue:defaultKeyPlayerLiveResize] == YES){
			liveResize = @"1";
		}

		// replace string
//		playerHTML = [self replaceCharacter:playerHTML str1:@"..swfobject_path" str2:swfObjectPath];
		playerHTML = [self replaceCharacter:playerHTML str1:@"..video_url" str2:videoURL];
		playerHTML = [self replaceCharacter:playerHTML str1:@"..liveResize" str2:liveResize];
//		NSLog(@"playerHTML=%@", playerHTML);

		[self setSWFPlayState:SWF_PLAY_STATE_NONE];
		[[self mainFrame] loadHTMLString:playerHTML baseURL:[NSURL URLWithString:[self convertToYouTubeBaseURL]]];

	}
	// not set ytplayer
	else{
		// require 10.4.11 or later
		[[self mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoURL]]];
	}

	return YES;
}
//----------------------
// createVideoPlayerView
//----------------------
- (BOOL)createVideoPlayerView:(NSString*)videoURL
						imageURL:(NSString*)imageURL
						fileFormatNo:(int)fileFormatNo
{

	//
	// set player html
	//
	NSString *playerHTML = [self videoPlayerHTML];

	if(![playerHTML isEqualToString:@""]){

		// get value
		NSString *videoType = @"video/mp4";
		NSString *loadingImageURL = [[NSBundle mainBundle] pathForResource:@"image_html5_loader" ofType:@"gif"];
		NSString *autoplay = @"0";

		int formatType = [self convertToFileFormatNoToFormatType:fileFormatNo];
		if(formatType == VIDEO_FORMAT_FILE_TYPE_FLV){
			videoType = @"video/flv";
		}
		else if(formatType == VIDEO_FORMAT_FILE_TYPE_WEBM){
			videoType = @"video/webm";
		}

		if([self defaultAutoPlay] == YES){
			autoplay = @"1";
		}

		loadingImageURL = [NSString stringWithFormat:@"file://%@", loadingImageURL];

		// replace string
		playerHTML = [self replaceCharacter:playerHTML str1:@"..video_url" str2:videoURL];
		playerHTML = [self replaceCharacter:playerHTML str1:@"..video_type" str2:videoType];
		playerHTML = [self replaceCharacter:playerHTML str1:@"..loading_image_url" str2:loadingImageURL];
//		playerHTML = [self replaceCharacter:playerHTML str1:@"..poster_url" str2:imageURL];
		playerHTML = [self replaceCharacter:playerHTML str1:@"..autoplay" str2:autoplay];
//		NSLog(@"playerHTML=%@", playerHTML);

		[self setVideoPlayState:VIDEO_PLAY_STATE_NONE];
		[[self mainFrame] loadHTMLString:playerHTML baseURL:[NSURL URLWithString:[self convertToYouTubeBaseURL]]];

	}
	// not set ytHTMLplayer
	else{
		// require 10.4.11 or later
		[[self mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoURL]]];
	}

	return YES;
}

//----------------------
// repeatPlayerView
//----------------------
- (BOOL)repeatPlayerView
{

	ContentItem *itemObject = [self itemObject];

	if(itemObject == nil){
		return NO;
	}

	[self runJavaScriptWithString:@"restart()"];
	
	return YES;

}

//----------------------
// clearPlayerView
//----------------------
- (void)clearPlayerView
{

	[self setVideoPlay:NO];
	[self setHasVideo:NO];
	[self clearChangeTimer];

	[self stopLoading];
//	[[self mainFrame] stopLoading];
//	[[self mainFrame] loadRequest:nil];
	[[self mainFrame] loadHTMLString:nil baseURL:nil];

	[self setSWFPlayState:SWF_PLAY_STATE_NONE];
	[self setVideoPlayState:VIDEO_PLAY_STATE_NONE];

}
//------------------------------------
// stopLoading
//------------------------------------
- (void)stopLoading
{
	[[self mainFrame] stopLoading];
	[[self mainFrame] loadRequest:nil];
}
//------------------------------------
// postClearNotifications
//------------------------------------
- (void)postClearNotifications
{
	[self postVideoObjectChangedNotification:NO];
	[self postVideoLoadedChangedNotification:NO];
}
//------------------------------------
// closeWindow
//------------------------------------
- (void)closeWindow
{
	if([[self window] isVisible]){
		[[self window] close];
	}
}
//------------------------------------
// changePlayItemWithTimer
//------------------------------------
- (void)changePlayItemWithTimer
{
	// clear timer
	[self clearChangeTimer];
	// set timer
	[self setChangeTimer:[NSTimer scheduledTimerWithTimeInterval:[self defaultPlayRepeatInterval]
							target:self 
							selector:@selector(changePlayItem)
							userInfo:nil
							repeats: NO]
	];
	[[NSRunLoop currentRunLoop] addTimer:[self changeTimer] forMode:(NSString*)kCFRunLoopCommonModes];
}
//------------------------------------
// changePlayItem
//------------------------------------
- (void)changePlayItem
{
	int playRepeat = [self defaultPlayRepeat];
	// next item
	if(playRepeat == PLAY_REPEAT_ALL){
		[viewPlayer changePlayItem:CONTROL_SELECT_ITEM_NEXT isLoop:YES];
	}
	// repeat one
	else if(playRepeat == PLAY_REPEAT_ONE){
		[self repeatPlayerView];
	}
}
//------------------------------------
// changeVideoSizeScale
//------------------------------------
- (void)changeVideoSizeScale:(float)scale
{

	// view rect
	NSRect rect = [self convertRect:[self frame] fromView:[[self window] contentView]];
	// flipped
	if([[[self window] contentView] isFlipped] == NO){
		rect.origin.y *= -1;
	}

	// offset height
	float offsetTopHeight = [[self window] frame].size.height - (rect.size.height + rect.origin.y);
	float offsetBottomHeight = rect.origin.y;
	float offsetTotalHeight = offsetTopHeight + offsetBottomHeight;
//	NSLog(@"offsetTopHeight=%.2f offsetBottomHeight=%.2f", offsetTopHeight, offsetBottomHeight);

	// get original movie size
	NSSize baseSize = [self videoSize]; 

	// default
	if(baseSize.width <= 0 || baseSize.height <= 0){
		baseSize.width = 480;
		baseSize.height = 280;
	}

	// scale size
	NSSize scaledSize = NSZeroSize;
	scaledSize.width = baseSize.width * scale;
	scaledSize.height = baseSize.height * scale;

	// adjust screen rect
	NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
	if(scaledSize.width > screenRect.size.width){
		scale = screenRect.size.width / scaledSize.width;
		scaledSize.width *= scale;
		scaledSize.height *= scale;
	}
	if(scaledSize.height > (screenRect.size.height - offsetBottomHeight)){
		scale = (screenRect.size.height - offsetBottomHeight) / scaledSize.height;
		scaledSize.width *= scale;
		scaledSize.height *= scale;
	}

	// adjust min size
	NSSize minSize = [[self window] minSize];
	if(scaledSize.width < minSize.width){
		scaledSize.width = minSize.width;
	}
	if(scaledSize.height < (minSize.height - offsetTotalHeight)){
		scaledSize.height = (minSize.height - offsetTotalHeight);
	}

	// get current window size
	NSRect oldRect = [NSWindow contentRectForFrameRect:[[self window] frame] styleMask:[[self window] styleMask]];

	// set point
	NSPoint newPoint;
//	newPoint.x = NSMinX(oldRect);
//	newPoint.y = NSMaxY(oldRect) - (scaledSize.height + offsetBottomHeight);
	// centering x only
	newPoint.x = NSMinX(oldRect) - ((scaledSize.width / 2) -  (oldRect.size.width / 2));
//	newPoint.y = NSMinY(oldRect) - (((scaledSize.height + offsetBottomHeight) / 2) -  (oldRect.size.height / 2));
	newPoint.y = NSMaxY(oldRect) - (scaledSize.height + offsetBottomHeight);

	// set new window size
	NSRect newRect = [NSWindow frameRectForContentRect:
											NSMakeRect( 
														newPoint.x,
														newPoint.y,
														scaledSize.width,
														scaledSize.height + offsetBottomHeight
														)
											styleMask:[[self window] styleMask]
						 ];

	[[self window] setFrame:newRect display:YES animate:[[self window] isVisible]];

}
/*
//----------------------
// setLiveResize
//----------------------
- (void)setLiveResize
{

	if( [self playerType] == VIDEO_PLAYER_TYPE_SWF &&
		[self hasVideo] == YES
	){
		int liveResize = 0;
		if([self defaultBoolValue:defaultKeyPlayerLiveResize] == YES){
			liveResize = 1;
		}

		[self runJavaScriptWithString:[NSString stringWithFormat:@"setLiveResize(%d)", liveResize]];
	}
}
*/
//------------------------------------
// viewDidEndLiveResize
//------------------------------------
- (void)viewDidEndLiveResize
{
//	NSLog(@"viewDidEndLiveResize");

/*
	// resize player
	if([self playerType] == VIDEO_PLAYER_TYPE_SWF){
		if([self defaultBoolValue:defaultKeyPlayerLiveResize] == NO){
			[self runJavaScriptWithString:@"fitToWindow(0)"];
		}
	}
*/
}
/*
//------------------------------------
// windowDidResizePlayer
//------------------------------------
-(void)windowDidResizePlayer:(NSNotification *)notification
{
}
*/
/*
//------------------------------------
// handleVideoPlayDidChanged
//------------------------------------
- (void)handleVideoPlayDidChanged:(NSNotification *)notification
{
	BOOL isPlaying = [[notification object] boolValue];
}
*/
//------------------------------------
// handleVideoSizeScaleDidChanged
//------------------------------------
- (void)handleVideoSizeScaleDidChanged:(NSNotification *)notification
{
	float scale = [[notification object] floatValue];

	if([self hasVideo] == YES){
		if([viewPlayer playerType] == VIDEO_PLAYER_TYPE_VIDEO){
			[self changeVideoSizeScale:scale];
		}
	}
}
//------------------------------------
// handleWindowFullScreenDidChanged
//------------------------------------
- (void)handleWindowFullScreenDidChanged:(NSNotification *)notification
{

	BOOL isFullScreen = [[notification object] boolValue];

	// already webview has tracking rect.
	if([self hasVideo] == YES){
		if([self playerType] == VIDEO_PLAYER_TYPE_VIDEO){
			// ful screen
			if(isFullScreen == YES){
				// start tracking
	//			[self createMouseTracking];
				[self setVideoConrols:NO];
			}
			// window
			else{
				// clear tracking
	//			[self removeMouseTracking];
	//			[self createMouseTracking];
				[self setVideoConrols:YES];
			}
		}
	}

	// resize player
//	[self runJavaScriptWithString:@"fitToWindow(0)"];

}
//------------------------------------
// handleItemSelectDidChanged
//------------------------------------
- (void)handleItemSelectDidChanged:(NSNotification *)notification
{
//	if([self hasVideo] == YES){
		[self clearChangeTimer];
//	}
}
//=======================================================================
// mouse tracking
//=======================================================================
//------------------------------------
// createMouseTracking
//------------------------------------
- (void)createMouseTracking
{

	// remove tracking
	[self removeMouseTracking];

	trackingRect_ = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];

	[[self window] setAcceptsMouseMovedEvents:YES];
	[[self window] makeFirstResponder:self]; 

}
//------------------------------------
// removeMouseTracking
//------------------------------------
- (void)removeMouseTracking
{
	// remove
	[self removeTrackingRect:trackingRect_];
	[[self window] setAcceptsMouseMovedEvents:NO];
}
//------------------------------------
// mouseMoved
//------------------------------------
- (void)mouseMoved:(NSEvent *)event
{

//	NSLog(@"mouseMoved");

	if([self playerType] == VIDEO_PLAYER_TYPE_VIDEO){
		if([(FullScreenWindow*)[self window] isFullScreen] == YES){
			if(abs([event deltaX]) > 2.0 || abs([event deltaY]) > 2.0){
				// post notification
				NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
				[nc postNotificationName:WINDOW_NOTIF_MOUSE_DID_MOVED object:self];
			}
		}else{
			[super mouseMoved:event];
		}
	}else{
		[super mouseMoved:event];
	}

}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:defaultKeyPlayerLiveResize]){
		// change resize mode
//		[self setLiveResize];
	}
	else if([keyPath isEqualToString:defaultKeyVideoPlayVolume]){
		[self setVideoVolume:[self defaultPlayVolume]];
	}
}

//=======================================================================
// webView delegate
//=======================================================================
//----------------------
// didFinishLoadForFrame
//----------------------
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
//	NSString *urlString = [[[[frame dataSource] request] URL] absoluteString];
//	NSLog(@"urlString=%@", urlString);
	// for deleting player view
	NSData *data = [[frame dataSource] data];
	if(data == nil){
		return;
	}

	int playerType = [self playerType];

	// swf player
	if(playerType == VIDEO_PLAYER_TYPE_SWF){
		// no embed play
		if([[self itemObject] isEmbedPlay] == NO){

			int playRepeat = [self defaultPlayRepeat];
			// change item
			if(playRepeat == PLAY_REPEAT_ALL){
				[self changePlayItemWithTimer];
			}
			// alert
			else{
				int result = [self displayMessage:@"alert"
										messageText:@"This video is not allowed by embed playing."
										infoText:@"Please open with browser."
										btnList:@"Cancel,Open URL"
							];
				// open url
				if(result == NSAlertSecondButtonReturn){
					[self openWatchURL:[[self itemObject] watchURL]];
				}
				return;
			}
		}
	}
}
//------------------------------------
// contextMenuItemsForElement
//------------------------------------
- (NSArray*)webView:(WebView*)sender
		contextMenuItemsForElement:(NSDictionary*)element
				defaultMenuItems:(NSArray*)defaultMenuItems
{
	return nil;
}
//------------------------------------
// didClearWindowObject(available later 10.4.11)
//------------------------------------
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)wso forFrame:(WebFrame *)frame
{
//	NSLog(@"didClearWindowObject");
	[wso setValue:self forKey:@"webPlayerView"];
}
//------------------------------------
// windowScriptObjectAvailable(available under 10.4.10)
//------------------------------------
- (void)webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)wso
{
//	NSLog(@"windowScriptObjectAvailable");
	[wso setValue:self forKey:@"webPlayerView"];
}
//------------------------------------
// webScriptNameForSelector
//------------------------------------
+ (NSString *)webScriptNameForSelector:(SEL)sel
{
	NSString *name = nil;

	// swf
	if(sel == @selector(receiveSWFLoadState:string:value:)){
		name = @"receiveSWFLoadState";
	}
	else if(sel == @selector(receiveSWFPlayState:string:)){
		name = @"receiveSWFPlayState";
	}
	// video
	else if(sel == @selector(receiveLoadState:string:)){
		name = @"receiveLoadState";
	}
	else if(sel == @selector(receivePlayState:string:)){
		name = @"receivePlayState";
	}
	else if(sel == @selector(receiveControlState:string:)){
		name = @"receiveControlState";
	}
	else if(sel == @selector(receiveTimeState:duration:)){
		name = @"receiveTimeState";
	}
	// common
	else if(sel == @selector(receiveErrorMessage:string:)){
		name = @"receiveErrorMessage";
	}
	else if(sel == @selector(receiveLogMessage:)){
		name = @"receiveLogMessage";
	}
	else if(sel == @selector(playRepeat)){
		name = @"playRepeat";
	}
	else if(sel == @selector(playRepeatInterval)){
		name = @"playRepeatInterval";
	}
	else if(sel == @selector(videoVolume)){
		name = @"videoVolume";
	}
	
	return name;
}
//----------------------
// isSelectorExcludedFromWebScript
//----------------------
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector 
{
	return NO;
}

//=======================================================================
// Javascript receiver
//=======================================================================
//------------------------------------
// receiveSWFLoadState
//------------------------------------
- (void)receiveSWFLoadState:(int)state string:(NSString*)string value:(NSString*)value
{

//	NSLog(@"load state=%d string=%@ value=%@", state, string, value);

	// buffering
	if(state == SWF_LOAD_STATE_BUFFER || state == SWF_PLAY_STATE_PLAY){
//		NSLog(@"value=%@", value);
		NSString *itemId = [self getItemIdFromURL:value];
//		NSLog(@"itemId=%@", itemId);
		// set itemObject
		if([self itemObject] != nil){
			if(![itemId isEqualToString:[[self itemObject] itemId]]){
				[viewPlayer setItemObjectWithItemId:itemId];
			}
		}
		return;
	}

	BOOL isLoaded;
	if(state == SWF_LOAD_STATE_INIT){
		isLoaded = NO;
	}
	else if(state == SWF_LOAD_STATE_CANPLAY){
		isLoaded = YES;
	}
	else{
		isLoaded = YES;
	}

	[self postVideoLoadedChangedNotification:isLoaded];

}
//------------------------------------
// receiveSWFPlayState
//------------------------------------
- (void)receiveSWFPlayState:(int)state string:(NSString*)string
{

//	NSLog(@"play state=%d string=%@", state, string);

	BOOL isPlaying = NO;
	if(state == SWF_PLAY_STATE_PLAY){
		isPlaying = YES;
	}
	else if(state == SWF_PLAY_STATE_PAUSE ||
			state == SWF_PLAY_STATE_ENDED
	){
		isPlaying = NO;
	}

	// end of duration
	if(state == SWF_PLAY_STATE_ENDED){
		int playRepeat = [self defaultPlayRepeat];
		// change item
		if(playRepeat == PLAY_REPEAT_ALL || playRepeat == PLAY_REPEAT_ONE){
			[self changePlayItemWithTimer];
		}
	}

	// changed state
	if(state != [self swfPlayState]){

//		NSLog(@"changed swfState=%d to state=%d ", [self swfPlayState], state);
		[self setSWFPlayState:state];

		// post notification
		[self postVideoPlayChangedNotification:isPlaying];
	}

}
//------------------------------------
// receiveLoadState
//------------------------------------
- (void)receiveLoadState:(int)state string:(NSString*)string
{

//	NSLog(@"state=%d string=%@", state, string);

	BOOL isLoading;
	BOOL isLoaded;
	if(state == VIDEO_LOAD_STATE_INIT){
		isLoading = YES;
		isLoaded = NO;
	}
	else if(state == VIDEO_LOAD_STATE_CANPLAY){
		isLoading = NO;
		isLoaded = YES;
	}
	else if(state == VIDEO_LOAD_STATE_ERROR){
		isLoading = NO;
		isLoaded = NO;
	}
	else{
		return;
	}

	[self postVideoLoadingChangedNotification:isLoading];
	[self postVideoLoadedChangedNotification:isLoaded];
}
//------------------------------------
// receivePlayState
//------------------------------------
- (void)receivePlayState:(int)state string:(NSString*)string
{

//	NSLog(@"state=%d string=%@", state, string);

	BOOL isPlaying;
	if(state == VIDEO_PLAY_STATE_PLAY){
		isPlaying = YES;
	}
	else if(state == VIDEO_PLAY_STATE_PAUSE ||
			state == VIDEO_PLAY_STATE_ENDED
	){
		isPlaying = NO;
	}
	else{
		return;
	}

	[self setVideoPlayState:state];

	// end of duration
	if(state == VIDEO_PLAY_STATE_ENDED){
		int playRepeat = [self defaultPlayRepeat];
		// change item
		if(playRepeat == PLAY_REPEAT_ALL || playRepeat == PLAY_REPEAT_ONE){
			[self changePlayItemWithTimer];
		}
	}

	// post notification
	[self postVideoPlayChangedNotification:isPlaying];
}
//------------------------------------
// receiveControlState
//------------------------------------
- (void)receiveControlState:(int)state string:(NSString*)string
{

//	NSLog(@"state=%d string=%@", state, string);

}
//------------------------------------
// receiveTimeState
//------------------------------------
- (void)receiveTimeState:(int)currentTime duration:(int)duration;
{

//	NSLog(@"currentTime=%d duration=%d", currentTime, duration);

	// post notification
	[self postVideoTimeChangedNotification:[NSDictionary dictionaryWithObjectsAndKeys:
												[NSNumber numberWithInt:currentTime], @"currentTime" ,
												[NSNumber numberWithInt:duration], @"duration" ,
												nil
											]
	];
}
//------------------------------------
// receiveErrorMessage
//------------------------------------
- (void)receiveErrorMessage:(int)state string:(NSString*)string
{
//	NSLog(@"state=%d string=%@", state, string);
	if(state == 150){
		return;
	}

	[self displayMessage:@"alert"
				messageText:@"An error occurred in player."
				infoText:[NSString stringWithFormat:@"error = %d : %@", state, string]
				btnList:@"Cancel"
	];
} 
//------------------------------------
// receiveLogMessage
//------------------------------------
- (void)receiveLogMessage:(NSString*)string
{
//	NSLog(@"string=%@", string);
//	NSLog(@"player says: %@", string);
} 
//------------------------------------
// runJavaScriptWithString
//------------------------------------
- (id)runJavaScriptWithString:(NSString*)string
{
	// run javascript
	return [self stringByEvaluatingJavaScriptFromString:string];
}
//------------------------------------
// setVideoPlay
//------------------------------------
- (void)setVideoPlay:(BOOL)isPlay
{
	if([self hasVideo] == YES){
		if(isPlay == YES){
			// set volume
			[self runJavaScriptWithString:@"play()"];
		}else{
			[self runJavaScriptWithString:@"pause()"];
		}
	}

}
//----------------------------------------
// setVideoConrols
//----------------------------------------
- (void)setVideoConrols:(BOOL)isControls
{
	// set controls
	if([self hasVideo] == YES){
		if(isControls == YES){
			[self runJavaScriptWithString:@"setControls(true)"];
		}else{
			[self runJavaScriptWithString:@"setControls(false)"];
		}
	}
}
//----------------------------------------
// setVideoVolume
//----------------------------------------
- (void)setVideoVolume:(float)volume
{
	// set volume
	if([self hasVideo] == YES){
		[self runJavaScriptWithString:[NSString stringWithFormat:@"setVolume(%.2f)", volume]];
	}
}
//----------------------------------------
// setVideoRate
//----------------------------------------
- (void)setVideoRate:(float)rate
{
	// set volume
	if([self hasVideo] == YES){
		[self runJavaScriptWithString:[NSString stringWithFormat:@"setRate(%.2f)", rate]];
	}
}
//------------------------------------
// videoVolume
//------------------------------------
- (float)videoVolume
{
	return [self defaultPlayVolume];
}
//------------------------------------
// videoSize
//------------------------------------
- (NSSize)videoSize
{
	int videoWidth = 0;
	int videoHeight = 0;
	if([self hasVideo] == YES){
		videoWidth = [self convertStringToIntValue:[self runJavaScriptWithString:@"videoWidth()"]];
		videoHeight = [self convertStringToIntValue:[self runJavaScriptWithString:@"videoHeight()"]];
	}

	return NSMakeSize(videoWidth, videoHeight);
}
//=======================================================================
// drag & drop
//=======================================================================
//------------------------------------
// draggingEntered
//------------------------------------
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)info
{

	// Get pboard
	NSPasteboard *pboard;
	pboard = [info draggingPasteboard];
	id draggingSource = [info draggingSource];

	if (!pboard){
		return NSDragOperationNone;
	}

	// ignore self
	if (draggingSource == self) {
		return NSDragOperationNone;
	}

	// from sting
	if ([[pboard types] containsObject:NSStringPboardType]){
		return NSDragOperationCopy;
	}

	return NSDragOperationNone;

}
//------------------------------------
// draggingExited
//------------------------------------
- (void)draggingExited:(id <NSDraggingInfo>)info
{
	// none
}
//------------------------------------
// draggingUpdated
//------------------------------------
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)info
{

	// Get pboard
	NSPasteboard *pboard;
	pboard = [info draggingPasteboard];
	id draggingSource = [info draggingSource];

	if (!pboard){
		return NSDragOperationNone;
	}

	// ignore self
	if (draggingSource == self) {
		return NSDragOperationNone;
	}

	// from sting
	if ([[pboard types] containsObject:NSStringPboardType]){
		return NSDragOperationCopy;
	}

	return NSDragOperationNone;

}
//------------------------------------
// prepareForDragOperation
//------------------------------------
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)info
{
	return YES;
}
//------------------------------------
// performDragOperation
//------------------------------------
- (BOOL)performDragOperation:(id <NSDraggingInfo>)info
{

	NSPasteboard *pboard = [info draggingPasteboard];
	id draggingSource = [info draggingSource];

	if (!pboard) {
        return NO;
	}

	// ignore self
	if (draggingSource == self) {
		return NO;
	}

	// Check pboard type
	// from string
	if ([[pboard types] containsObject:NSStringPboardType]){
		NSString *videoURL = [pboard stringForType:NSStringPboardType];
		if(!videoURL || [videoURL isEqualToString:@""]) {
			return NO;
		}
		// open player
		if([self checkIsWatchURL:videoURL] == YES){
			[viewPlayer setPlayerViewWithURL:videoURL];
			return YES;
		}
	}

	return NO;

}

//=======================================================================
// post notifications
//=======================================================================
//------------------------------------
// postVideoObjectChangedNotification
//------------------------------------
- (void)postVideoObjectChangedNotification:(BOOL)hasVideo
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_OBJECT_DID_CHANGED object:[NSNumber numberWithBool:hasVideo]];
}
//------------------------------------
// postVideoLoadingChangedNotification
//------------------------------------
- (void)postVideoLoadingChangedNotification:(BOOL)isLoading
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_LOADING_DID_CHANGED object:[NSNumber numberWithBool:isLoading]];
}
//------------------------------------
// postVideoLoadedChangedNotification
//------------------------------------
- (void)postVideoLoadedChangedNotification:(BOOL)isLoaded
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_LOADED_DID_CHANGED object:[NSNumber numberWithBool:isLoaded]];
}
//------------------------------------
// postVideoPlayChangedNotification
//------------------------------------
- (void)postVideoPlayChangedNotification:(BOOL)isPlaying
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_PLAY_DID_CHANGED object:[NSNumber numberWithBool:isPlaying]];
}
//------------------------------------
// postVideoTimeChangedNotification
//------------------------------------
- (void)postVideoTimeChangedNotification:(NSDictionary*)params
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_TIME_DID_CHANGED object:params];
}
//------------------------------------
// setUpSWFPlayer
//------------------------------------
- (void)setUpSWFPlayer
{

	// read yt_swf_player.html
	NSError *error = nil;
	NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yt_swf_player" ofType:@"html"] encoding:NSUTF8StringEncoding error:&error];

	if(error == nil && html != nil){
		[self setSWFPlayerHTML:html];
	}else{
		[self setSWFPlayerHTML:@""];
		[self displayMessage:@"alert"
					messageText:@"Can not read file \"yt_swf_player.html\" in Application."
					infoText:@"Please check file."
					btnList:@"Cancel"
		];
//		NSLog(@"error=%@", error);
	}

	[self setSWFObjectPath:@""];

}
//------------------------------------
// setUpVideoPlayer
//------------------------------------
- (void)setUpVideoPlayer
{

	// read yt_video_player.html
	NSError *error = nil;
	NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yt_video_player" ofType:@"html"] encoding:NSUTF8StringEncoding error:&error];

	if(error == nil && html != nil){
		[self setVideoPlayerHTML:html];
	}else{
		[self setVideoPlayerHTML:@""];
		[self displayMessage:@"alert"
					messageText:@"Can not read file \"yt_video_player.html\" in Application."
					infoText:@"Please check file."
					btnList:@"Cancel"
		];
//		NSLog(@"error=%@", error);
	}

}
//------------------------------------
// itemObject
//------------------------------------
- (ContentItem*)itemObject
{
	return [viewPlayer itemObject];
}
//------------------------------------
// playerType
//------------------------------------
- (void)setPlayerType:(int)playerType
{
    playerType_ = playerType;
}
- (int)playerType
{
    return playerType_;
}
//------------------------------------
// swfPlayerHTML
//------------------------------------
- (void)setSWFPlayerHTML:(NSString*)swfPlayerHTML
{
	[swfPlayerHTML retain];
	[swfPlayerHTML_ release];
	swfPlayerHTML_ = swfPlayerHTML;
}
- (NSString*)swfPlayerHTML
{
	return swfPlayerHTML_;
}
//------------------------------------
// swfObjectPath
//------------------------------------
- (void)setSWFObjectPath:(NSString*)swfObjectPath
{
	[swfObjectPath retain];
	[swfObjectPath_ release];
	swfObjectPath_ = swfObjectPath;
}
- (NSString*)swfObjectPath
{
	return swfObjectPath_;
}
//------------------------------------
// swfPlayState
//------------------------------------
- (void)setSWFPlayState:(int)swfPlayState
{
    swfPlayState_ = swfPlayState;
}
- (int)swfPlayState
{
    return swfPlayState_;
}
//------------------------------------
// videoPlayerHTML
//------------------------------------
- (void)setVideoPlayerHTML:(NSString*)videoPlayerHTML
{
	[videoPlayerHTML retain];
	[videoPlayerHTML_ release];
	videoPlayerHTML_ = videoPlayerHTML;
}
- (NSString*)videoPlayerHTML
{
	return videoPlayerHTML_;
}

//------------------------------------
// videoPlayState
//------------------------------------
- (void)setVideoPlayState:(int)videoPlayState
{
    videoPlayState_ = videoPlayState;
}
- (int)videoPlayState
{
    return videoPlayState_;
}
//------------------------------------
// changeTimer
//------------------------------------
- (void)setChangeTimer:(NSTimer*)changeTimer
{
	[changeTimer retain];
	[changeTimer_ release];
	changeTimer_ = changeTimer;
}
- (void)clearChangeTimer
{
	if([[self changeTimer] isValid] == YES){
		[[self changeTimer] invalidate];
	}
}
- (NSTimer*)changeTimer
{
	return changeTimer_;
}
//----------------------
// hasVideo
//----------------------
- (void)setHasVideo:(BOOL)hasVideo
{
	hasVideo_ = hasVideo;
}
- (BOOL)hasVideo
{
//	id state = [self runJavaScriptWithString:@"hasVideo()"];
//	return [self convertStringToBoolValue:state];
	return hasVideo_;
}

//------------------------------------
// isPlaying
//------------------------------------
- (BOOL)isPlaying
{
/*
	id state = [self runJavaScriptWithString:@"playing()"];
	BOOL isPlaying = [self convertStringToBoolValue:state];
*/
	BOOL isPlaying = NO;
	if(
		([self playerType] == VIDEO_PLAYER_TYPE_SWF && [self swfPlayState] == SWF_PLAY_STATE_PLAY) ||
		([self playerType] == VIDEO_PLAYER_TYPE_VIDEO && [self videoPlayState] == VIDEO_PLAY_STATE_PLAY)
	){
		isPlaying = YES;
	}
	return isPlaying;
}
//----------------------
// playRepeat
//----------------------
- (int)playRepeat
{
	return [self defaultPlayRepeat];
}
//----------------------
// playRepeatInterval
//----------------------
- (float)playRepeatInterval
{
	return [self defaultPlayRepeatInterval];
}
/*
//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{
//	NSLog(@"mouseDown");
	BOOL isAction = NO;

	// control click
	if([theEvent modifierFlags] & NSControlKeyMask){
		[self rightMouseDown:theEvent];
		isAction = YES;
	}

	if(isAction == NO){
		[super mouseDown:theEvent];
	}
}
//------------------------------------
// rightMouseDown
//------------------------------------
- (void)rightMouseDown:(NSEvent *)theEvent
{	

	BOOL isAction = NO;

	if(isAction == NO){
		[super rightMouseDown:theEvent];
	}

}
*/
//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKeyPlayerLiveResize];
	[defaults removeObserver:self forKeyPath:defaultKeyVideoPlayVolume];

	[self clearChangeTimer];
	[changeTimer_ release];

	[swfPlayerHTML_ release];
	[swfObjectPath_ release];

	[videoPlayerHTML_ release];
	[super dealloc];
}
@end
