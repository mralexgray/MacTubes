#import "QTPlayerView.h"
#import "ViewPlayer.h"
#import "FullScreenWindow.h"
#import "HelperExtension.h"
#import "ConvertExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"
#import "YouTubeHelperExtension.h"

static NSString *defaultKeyVideoPlayVolume = @"optPlayVolume";

@implementation QTPlayerView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[self setMovie:nil];

	// controller properties
	[self setControllerVisible:NO];
//	[self setStepButtonsVisible:NO];
//	[self setVolumeButtonVisible:NO];

	[self setPlayerType:[self defaultVideoPlayerType]];
	[self setControllerTimer:nil];
	[self setTimeStatusTimer:nil];
	[self setChangeTimer:nil];

	[self setErrorDescription:@""];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleWindowFullScreenDidChanged:) name:WINDOW_NOTIF_FULLSCREEN_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoPlayDidChanged:) name:VIDEO_NOTIF_PLAY_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoSizeScaleDidChanged:) name:VIDEO_NOTIF_SIZE_SCALE_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleItemSelectDidChanged:) name:CONTROL_NOTIF_PLAY_SELECT_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleItemSelectDidChanged:) name:CONTROL_NOTIF_INFO_SELECT_DID_CHANGED object:nil];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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

	// clear timer
	[self clearChangeTimer];
	[self setErrorDescription:@""];

	[self postVideoLoadedChangedNotification:NO];
	[self postVideoLoadingChangedNotification:YES];

	// player
	BOOL ret = [self createQTPlayerView:videoURL];

	[self postVideoLoadingChangedNotification:NO];

	if(ret == NO){
		return NO;
	}

	// set value
	[self setPlayerType:playerType];
	[[self window] makeFirstResponder:self];

	// post notification
	[self postVideoObjectChangedNotification:YES];
	[self postVideoLoadedChangedNotification:YES];

	return YES;

}

//----------------------
// createQTPlayerView
//----------------------
- (BOOL)createQTPlayerView:(NSString*)videoURL
{

	if(!videoURL || [videoURL isEqualToString:@""]){
		[self setErrorDescription:[NSString stringWithFormat:@"Can't create URL from %@ ", videoURL]];
		return NO;
	}

	NSURL *movieURL = [NSURL URLWithString:videoURL];
	if(!movieURL){
		[self setErrorDescription:[NSString stringWithFormat:@"Can't create URL from %@ ", videoURL]];
		return NO;
	}

//	if([QTMovie canInitWithURL:movieURL] == NO){
//		NSLog(@"Can't init movie from %@ ", videoURL);
//		return NO;
//	}

	NSError *error = nil;
	QTMovie *movie = [QTMovie movieWithURL:movieURL error:&error];
	if(error != nil){
		[self setErrorDescription:[NSString stringWithFormat:@"Can't create movie error= %@ ", error]];
		return NO;
	}

	// set movie
    [self setMovie:movie];
//	[self setStepButtonsVisible:NO];
//	[self setVolumeButtonVisible:NO];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleMoviePlayDidChanged:) name:QTMovieRateDidChangeNotification object:movie];
	[nc addObserver:self selector:@selector(handleMoviePlayDidEnded:) name:QTMovieDidEndNotification object:movie];
	[nc addObserver:self selector:@selector(handleMovieVolumeDidChanged:) name:QTMovieVolumeDidChangeNotification object:movie];
	[nc addObserver:self selector:@selector(handleMovieLoadStateDidChanged:) name:QTMovieLoadStateDidChangeNotification object:movie];

/*
	// play with timer
	BOOL isPlay = [self defaultAutoPlay];
	float volume = [self defaultPlayVolume];
	NSDictionary *params =[NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithBool:isPlay], @"isPlay",
							[NSNumber numberWithFloat:volume], @"volume",
							nil
						];
	[NSTimer scheduledTimerWithTimeInterval:2.0
								target:self 
								selector:@selector(playWithTimer:)
								userInfo:params
								repeats:NO
	];
*/
	return YES;
}
//------------------------------------
// playWithTimer
//------------------------------------
/*
- (void)playWithTimer:(NSTimer*)aTimer
{
	NSDictionary *params = [aTimer userInfo];
	BOOL isPlay = [[params valueForKey:@"isPlay"] boolValue];
	float volume = [[params valueForKey:@"volume"] floatValue];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleMoviePlayDidChanged:) name:QTMovieRateDidChangeNotification object:[self movie]];
	[nc addObserver:self selector:@selector(handleMoviePlayDidEnded:) name:QTMovieDidEndNotification object:[self movie]];
	[nc addObserver:self selector:@selector(handleMovieVolumeDidChanged:) name:QTMovieVolumeDidChangeNotification object:[self movie]];
	[nc addObserver:self selector:@selector(handleMovieLoadStateDidChanged:) name:QTMovieLoadStateDidChangeNotification object:[self movie]];

	[self setVideoVolume:volume];
	[self setVideoPlay:isPlay];
}
*/
//----------------------
// repeatPlayerView
//----------------------
- (BOOL)repeatPlayerView
{

	ContentItem *itemObject = [self itemObject];

	if(itemObject == nil){
		return NO;
	}

	[[self movie] gotoBeginning];
	[self setVideoPlay:YES];

	return YES;

}

//----------------------
// clearPlayerView
//----------------------
- (void)clearPlayerView
{

	[self setVideoPlay:NO];
	[self clearChangeTimer];
	[self clearTimeStatusTimer];
	[self setTimeStatusTimer:nil];

	[self setMovie:nil];

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
	NSSize baseSize = [[[self movie] attributeForKey:QTMovieNaturalSizeAttribute] sizeValue]; 

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
//------------------------------------
// setVideoPlay
//------------------------------------
- (void)setVideoPlay:(BOOL)isPlay
{
	if([self hasVideo] == YES){
		if(isPlay == YES){
			// set volume
			[self setVideoVolume:[self defaultPlayVolume]];
			[[self movie] play];
		}else{
			[[self movie] stop];
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
		[[self movie] setVolume:volume];
	}
}
//------------------------------------
// setVideoControllerVisible
//------------------------------------
- (void)setVideoControllerVisible:(NSTimer*)aTimer
{
	NSDictionary *params = [aTimer userInfo];
	BOOL isShow = [[params valueForKey:@"isShow"] boolValue];
	[self setControllerVisible:isShow];
}
//------------------------------------
// startControllerTimer
//------------------------------------
- (void)startControllerTimer:(BOOL)isShow
{

	// same timer is running
	if([self checkControllerTimer:isShow] == YES){
//		NSLog(@"same timer");
		return;
	}

	// reverse timer is running
	if([self checkControllerTimer:!isShow] == YES){
//		NSLog(@"reverse timer");
		[self clearControllerTimer];
		return;
	}

//	NSLog(@"startControllerTimer");

	NSDictionary *params =[NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithBool:isShow], @"isShow",
							nil
						];

	// set timer for update time status
	[self setControllerTimer:[NSTimer scheduledTimerWithTimeInterval:0.5
								target:self 
								selector:@selector(setVideoControllerVisible:)
								userInfo:params
								repeats:NO
							]
	];
	[[NSRunLoop currentRunLoop] addTimer:[self controllerTimer] forMode:(NSString*)kCFRunLoopCommonModes];

}
//------------------------------------
// checkControllerTimer
//------------------------------------
- (BOOL)checkControllerTimer:(BOOL)isShow
{

	BOOL ret = NO;

	NSTimer *timer = [self controllerTimer];

	// running
	if(timer && [timer isValid] == YES){
		BOOL isShowInTimer = [[[timer userInfo] valueForKey:@"isShow"] boolValue];
		if(isShow == isShowInTimer){
			ret = YES;
		}
	}

	return ret;

}

//------------------------------------
// startTimeStatusTimer
//------------------------------------
- (void)startTimeStatusTimer
{

//	NSLog(@"startTimeStatusTimer");
	// clear timer
	[self clearTimeStatusTimer];

	if([self hasVideo] == YES){
		// set timer for update time status
		[self setTimeStatusTimer:[NSTimer scheduledTimerWithTimeInterval:1.0
									target:self 
									selector:@selector(updateTimeStatus)
									userInfo:nil
									repeats:YES
								]
		];
		[[NSRunLoop currentRunLoop] addTimer:[self timeStatusTimer] forMode:(NSString*)kCFRunLoopCommonModes];
	}else{
		[self setTimeStatusTimer:nil];
	}

}
//------------------------------------
// updateTimeStatus
//------------------------------------
- (void)updateTimeStatus
{

//	NSLog(@"updateTimeStatus");
	QTTime qtCurrentTime = [[self movie] currentTime];
	QTTime qtDuration    = [[self movie] duration];

	int currentTime = qtCurrentTime.timeValue / qtCurrentTime.timeScale;
	int duration = qtDuration.timeValue / qtDuration.timeScale;

//	NSLog(@"updateTimeStatus currentTime=%d duration=%d", currentTime, duration);
	[self postVideoTimeChangedNotification:[NSDictionary dictionaryWithObjectsAndKeys:
												[NSNumber numberWithInt:currentTime], @"currentTime" ,
												[NSNumber numberWithInt:duration], @"duration" ,
												nil
											]
	];

}
//------------------------------------
// handleVideoPlayDidChanged
//------------------------------------
- (void)handleVideoPlayDidChanged:(NSNotification *)notification
{
	BOOL isPlaying = [[notification object] boolValue];

	if([self hasVideo] == YES){

		// time status
		if(isPlaying == YES){
			[self startTimeStatusTimer];
		}else{
			[self clearTimeStatusTimer];
			[self updateTimeStatus];
		}

		// show / hide controller
		if([self isFullScreen] == NO){
			if([self isMousePointInMovieRect] == NO){
				[self clearControllerTimer];
				[self setControllerVisible:!isPlaying];
			}
		}

	}
}
//------------------------------------
// handleVideoSizeScaleDidChanged
//------------------------------------
- (void)handleVideoSizeScaleDidChanged:(NSNotification *)notification
{
	float scale = [[notification object] floatValue];

	if([self hasVideo] == YES){
		if([viewPlayer playerType] == VIDEO_PLAYER_TYPE_QUICKTIME){
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

	if([self hasVideo] == YES){
		// ful screen
		if(isFullScreen == YES){
			// start tracking
//			[self createMouseTracking];
			[self setControllerVisible:NO];
		}
		// window
		else{
			// clear tracking
//			[self removeMouseTracking];
		}
	}
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
/*
- (void)viewDidMoveToWindow
{
	movieTrackingRect_ = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
}
- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[self removeTrackingRect:movieTrackingRect_];
	movieTrackingRect_ = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
}
- (void)mouseEntered:(NSEvent *)theEvent
{
//	NSLog(@"mouseEntered");
}
- (void)mouseExited:(NSEvent *)theEvent
{
//	NSLog(@"mouseExited");
}
*/
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
// isMousePointInMovieRect
//------------------------------------
- (BOOL)isMousePointInMovieRect
{
	NSPoint point = [NSEvent mouseLocation];
	NSRect rect = [self convertRect:[self frame] fromView:nil];
	// flipped
	if([self isFlipped] == NO){
		rect.origin.y *= -1;
	}
	// add window origin point
	rect.origin.x += [[self window] frame].origin.x;
	rect.origin.y += [[self window] frame].origin.y;

	// enter movie rect
	return NSPointInRect(point, rect);
}

//------------------------------------
// mouseMoved
//------------------------------------
- (void)mouseMoved:(NSEvent *)event
{
//	NSLog(@"qt mouseMoved");

	if([self isFullScreen] == YES){
		if(abs([event deltaX]) > 2.0 || abs([event deltaY]) > 2.0){
			// post notification
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotificationName:WINDOW_NOTIF_MOUSE_DID_MOVED object:self];
		}
	}else{
		// show / hide controller
		if([self hasVideo] == YES){
			if(abs([event deltaX]) > 2.0 || abs([event deltaY]) > 2.0){
/*
				NSPoint point = [NSEvent mouseLocation];
				NSRect rect = [self convertRect:[self frame] fromView:nil];
				// flipped
				if([self isFlipped] == NO){
					rect.origin.y *= -1;
				}
				// add window origin point
				rect.origin.x += [[self window] frame].origin.x;
				rect.origin.y += [[self window] frame].origin.y;
*/
				// enter movie rect
				if([self isMousePointInMovieRect] == YES){
					[self startControllerTimer:YES];
				}else{
					[self startControllerTimer:NO];
				}
			}
		}
	}
	[super mouseMoved:event];
}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([self hasVideo] == YES){
		if([keyPath isEqualToString:defaultKeyVideoPlayVolume]){
			[self setVideoVolume:[self defaultPlayVolume]];
		}
	}
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

//------------------------------------
// handleMoviePlayDidChanged
//------------------------------------
- (void)handleMoviePlayDidChanged:(NSNotification *)aNotification
{
	BOOL isPlaying = [self isPlaying];

	// post notification
	[self postVideoPlayChangedNotification:isPlaying];

}
//------------------------------------
// handleMoviePlayDidEnded
//------------------------------------
- (void)handleMoviePlayDidEnded:(NSNotification *)aNotification
{

	int playRepeat = [self defaultPlayRepeat];
	// change item
	if(playRepeat == PLAY_REPEAT_ALL || playRepeat == PLAY_REPEAT_ONE){
		[self changePlayItemWithTimer];
	}

}

//------------------------------------
// handleMovieVolumeDidChanged
//------------------------------------
- (void)handleMovieVolumeDidChanged:(NSNotification *)aNotification
{

//	NSLog(@"handleMovieVolumeDidChanged");
	float volume = [[self movie] volume];

	[self setDefaultFloatValue:volume key:defaultKeyVideoPlayVolume];

}
//------------------------------------
// handleMovieLoadStateDidChanged
//------------------------------------
- (void)handleMovieLoadStateDidChanged:(NSNotification *)aNotification
{

//	NSLog(@"handleMovieLoadStateDidChanged");

	QTMovie *movie = [aNotification object];

	long loadState = [[movie attributeForKey:QTMovieLoadStateAttribute] longValue];

	// kMovieLoadStatePlaythroughOK / 20000
	if (loadState >= kMovieLoadStatePlaythroughOK){
		// set control
		[self setVideoVolume:[self defaultPlayVolume]];
		[self setVideoPlay:[self defaultAutoPlay]];
		// remove notification
		NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
		[nc removeObserver:self name:QTMovieLoadStateDidChangeNotification object:movie];
	}
	// kMovieLoadStatePlayable / 10000
	else if (loadState >= kMovieLoadStatePlayable){
	}
	// error
	else if (loadState == -1){
	}
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
// controllerTimer
//------------------------------------
- (void)setControllerTimer:(NSTimer*)controllerTimer
{
	[controllerTimer retain];
	[controllerTimer_ release];
	controllerTimer_ = controllerTimer;
}
- (void)clearControllerTimer
{
	if([[self controllerTimer] isValid] == YES){
		[[self controllerTimer] invalidate];
	}
}
- (NSTimer*)controllerTimer
{
	return controllerTimer_;
}

//------------------------------------
// timeStatusTimer
//------------------------------------
- (void)setTimeStatusTimer:(NSTimer*)timeStatusTimer
{
	[timeStatusTimer retain];
	[timeStatusTimer_ release];
	timeStatusTimer_ = timeStatusTimer;
}
- (void)clearTimeStatusTimer
{
	if([[self timeStatusTimer] isValid] == YES){
		[[self timeStatusTimer] invalidate];
	}
}
- (NSTimer*)timeStatusTimer
{
	return timeStatusTimer_;
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
//------------------------------------
// errorDescription
//------------------------------------
- (void)setErrorDescription:(NSString*)errorDescription
{
	[errorDescription retain];
	[errorDescription_ release];
	errorDescription_ = errorDescription;
}
- (NSString*)errorDescription
{
	return errorDescription_;
}

//----------------------
// hasVideo
//----------------------
- (BOOL)hasVideo
{
	if([self movie] != nil){
		return YES;
	}else{
		return NO;
	}
}
//------------------------------------
// isPlaying
//------------------------------------
- (BOOL)isPlaying
{
	return ([self movie] != nil) && ([[self movie] rate] != 0);
}
//------------------------------------
// isFullScreen
//------------------------------------
- (BOOL)isFullScreen
{
	return [(FullScreenWindow*)[self window] isFullScreen];
}

//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKeyVideoPlayVolume];

	[self clearChangeTimer];
	[self clearControllerTimer];
	[controllerTimer_ release];
	[timeStatusTimer_ release];
	[changeTimer_ release];
	[errorDescription_ release];

	[super dealloc];
}
@end
