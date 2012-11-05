#import "ControllerWindow.h"

static const float FADE_DURATION = 0.3;
static const float CLOSE_TIMER_INTERVAL = 3.0;

@implementation ControllerWindow

//------------------------------------
// initWithContentRect
//------------------------------------
- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(unsigned int)aStyle 
				  backing:(NSBackingStoreType)bufferingType 
					defer:(BOOL)flag {
	
	if (self = [super initWithContentRect:contentRect 
										styleMask:NSBorderlessWindowMask 
										  backing:NSBackingStoreBuffered 
								   defer:NO]) {
		[self setLevel:NSStatusWindowLevel];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setAlphaValue:1.0];
		[self setOpaque:NO];
		[self setShowsResizeIndicator:NO];
		[self setHasShadow:NO];
		
		return self;
	}

	return nil;
}
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[self setWindowPosition];

	[super setDelegate:self];

	[self setIsFullScreen:NO];
	[self setIsCloseTimer:NO];
	[self setCloseTimer:nil];

	titleBarHeight_ = [self frame].size.height
					-([[self contentView] frame].size.height + [[self contentView] frame].origin.y);

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleWindowFullScreenDidChanged:) name:WINDOW_NOTIF_FULLSCREEN_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleWindowMouseDidMoved:) name:WINDOW_NOTIF_MOUSE_DID_MOVED object:nil];
//	[nc addObserver:self selector:@selector(handlePlayerWindowMouseDidMoved:) name:WINDOW_NOTIF_MOUSE_DID_MOVED object:nil];

}
//=======================================================================
// action
//=======================================================================
//------------------------------------
// openWindow
//------------------------------------
- (IBAction)openWindow:(id)sender
{

	[self open];

}
//------------------------------------
// closeWindow
//------------------------------------
- (IBAction)closeWindow:(id)sender
{
	[self closeWithFade];
}
//=======================================================================
// method
//=======================================================================
//------------------------------------
// setWindowPosition
//------------------------------------
- (void)setWindowPosition
{
	// set window size
	NSRect frame = [[NSScreen mainScreen] frame];
	NSRect rect = [self frame];

	// set window position
	rect.origin.x = (frame.size.width - rect.size.width) / 2;
//	rect.origin.y = (frame.size.height - rect.size.height) / 3;
//	rect.origin.y = frame.origin.y + 80;
	rect.origin.y = frame.origin.y + ((frame.size.height / 10)) * 0.5;

	[self setFrame:rect display:NO animate:NO];
}
//------------------------------------
// open
//------------------------------------
- (void)open
{

//	[self center];
	[self setAlphaValue:0.0];
	[self makeKeyAndOrderFront:self];
	[self fadeInWindow];

	// set cursor
	[self showCursor:YES];

	// start tracking
	[self createMouseTracking];

	// mouse location is out of controtroller
	NSPoint point = [NSEvent mouseLocation];
	if(NSPointInRect(point, [self frame]) == NO){
		[self startCloseTimer];
	}


}
//------------------------------------
// close
//------------------------------------
- (void)close
{

	if([self isVisible] == YES){
		[super close];
	}

}
//------------------------------------
// closeWithFade
//------------------------------------
- (void)closeWithFade
{

	if([self isVisible] == YES){
		[self fadeOutWindow];
	}

}
//------------------------------------
// closeWithTimer
//------------------------------------
- (void)closeWithTimer
{

//	NSLog(@"closeWithTimer");

	// close timer is enabled
	if([self isCloseTimer] == YES){
		[self closeWithFade];			
//		[self showCursor:NO];
	}
	// restart timer
	else{
		[self startCloseTimer];
	}

}
//------------------------------------
// fadeInWindow
//------------------------------------
- (void)fadeInWindow
{

	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:
											[NSArray arrayWithObject:dict]
								];
	[anim setDuration:FADE_DURATION];
	[anim setAnimationCurve:NSAnimationEaseIn];
	
	[anim startAnimation];
	[anim release];

}
//------------------------------------
// fadeOutWindow
//------------------------------------
- (void)fadeOutWindow
{

	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:
											[NSArray arrayWithObject:dict]
								];
	[anim setDuration:FADE_DURATION];
	[anim setAnimationCurve:NSAnimationEaseIn];
	[anim setDelegate:self];

	[anim startAnimation];
	[anim release];

}

//------------------------------------
// animationDidEnd
//------------------------------------
- (void)animationDidEnd:(NSAnimation *)animation
{

	[super close];

	// clear tracking
	[self removeMouseTracking];
	[self clearCloseTimer];

	// set cursor
	if([self isFullScreen] == YES){
		[self showCursor:NO];
	}else{
		[self showCursor:YES];
	}

}
//------------------------------------
// showCursor
//------------------------------------
- (void)showCursor:(BOOL)show
{
	[NSCursor setHiddenUntilMouseMoves:!show];
}
//------------------------------------
// keyDown
//------------------------------------
- (void)keyDown:(NSEvent *)theEvent
{	 
	BOOL isAction = NO;

/*
	NSString *chars = [theEvent charactersIgnoringModifiers];
//	NSLog(@"chars=%@", chars);
	if(chars && [chars length] > 0){
		// cmd + w
		if([[chars lowercaseString] isEqualToString:@"w"]){
			if([theEvent modifierFlags] & NSCommandKeyMask){
				[self closeWithFade];
				isAction = YES;
			}
		}
	}
*/
	// escape key
	if([theEvent keyCode] == 53){
		[self closeWithFade];
//		[self showCursor:NO];
		isAction = YES;
	}

	if(isAction == NO){
		[super keyDown:theEvent];
	}
}

//------------------------------------
// mouseDragged
//------------------------------------
- (void)mouseDragged:(NSEvent *)theEvent
{

	NSPoint currentLocation;
	currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];

	NSPoint newOrigin;
	NSRect screenFrame = [[NSScreen mainScreen] frame];
	NSRect windowFrame = [self frame];

	newOrigin.x = currentLocation.x - initialLocation.x;
	newOrigin.y = currentLocation.y - initialLocation.y;

//	NSLog(@"currentLocation=%.2f, %.2f", currentLocation.x, currentLocation.y);
//	NSLog(@"initialLocation=%.2f, %.2f", initialLocation.x, initialLocation.y);
//	NSLog(@"newOrigin=%.2f, %.2f", newOrigin.x, newOrigin.y);

	if( (newOrigin.y + windowFrame.size.height) > (NSMaxY(screenFrame) - [NSMenuView menuBarHeight]) ){
		// Prevent dragging into the menu bar area
		newOrigin.y = NSMaxY(screenFrame) - windowFrame.size.height - [NSMenuView menuBarHeight];
	}

/*
	if (newOrigin.y < NSMinY(screenFrame)) {
		// Prevent dragging off bottom of screen
		newOrigin.y = NSMinY(screenFrame);
	}
	if (newOrigin.x < NSMinX(screenFrame)) {
		// Prevent dragging off left of screen
		newOrigin.x = NSMinX(screenFrame);
	}
	if (newOrigin.x > NSMaxX(screenFrame) - windowFrame.size.width) {
		// Prevent dragging off right of screen
		newOrigin.x = NSMaxX(screenFrame) - windowFrame.size.width;
	}
*/

	[self setFrameOrigin:newOrigin];

}

//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{	 
	NSRect windowFrame = [self frame];
	
	// Get mouse location in global coordinates
	initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
	initialLocation.x -= windowFrame.origin.x;
	initialLocation.y -= windowFrame.origin.y;

}
//=======================================================================
// mouse tracking methods
//=======================================================================
//------------------------------------
// createMouseTracking
//------------------------------------
- (void)createMouseTracking
{
	// remove
	[self removeMouseTracking];

	// full screen mode
//	if(isFullScreen == YES){

		NSRect bounds = [[self contentView] bounds];
		NSRect rect = NSMakeRect(
									bounds.origin.x, 
									bounds.origin.y, 
									bounds.size.width, 
									bounds.size.height + titleBarHeight_
								);
//		NSLog(@"%.2f, %.2f, %.2f, %.2f, ", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

		trackingRect_ = [[self contentView] addTrackingRect:rect owner:self userData:NULL assumeInside:NO];

//	}

}
//------------------------------------
// removeMouseTracking
//------------------------------------
- (void)removeMouseTracking
{
	// remove
	[[self contentView] removeTrackingRect:trackingRect_];
}

//------------------------------------
// mouseEntered
//------------------------------------
- (void)mouseEntered:(NSEvent *)event
{
//	NSLog(@"mouse entered");

	// clear timer
	[self clearCloseTimer];

}
//------------------------------------
// mouseExited
//------------------------------------
- (void)mouseExited:(NSEvent *)event
{
//	NSLog(@"mouse exited");

	// start timer
	[self startCloseTimer];

}
/*
//------------------------------------
// mouseMoved
//------------------------------------
- (void)mouseMoved:(NSEvent *)event
{

//	NSLog(@"mouseMoved");
	if([self isCloseTimer] == YES){
		[self clearCloseTimer];
	}

}
*/
//------------------------------------
// canBecomeKeyWindow
//------------------------------------
- (BOOL)canBecomeKeyWindow
{
	return YES;
}
//------------------------------------
// windowDidMove
//------------------------------------
- (void)windowDidMove:(NSNotification *)notification
{
	[self createMouseTracking];
}
//------------------------------------
// windowDidResize
//------------------------------------
- (void)windowDidResize:(NSNotification *)notification
{
	[self createMouseTracking];
}
//------------------------------------
// handleWindowFullScreenDidChanged
//------------------------------------
- (void)handleWindowFullScreenDidChanged:(NSNotification *)notification
{

	BOOL isFullScreen = [[notification object] boolValue];
	BOOL show = YES;

	[self setIsFullScreen:isFullScreen];

	// goto full screen
	if(isFullScreen == YES){

		// start tracking
		[self createMouseTracking];

		// mouse location is out of controller
		NSPoint point = [NSEvent mouseLocation];
		if(NSPointInRect(point, [self frame]) == NO){
			[self startCloseTimer];
		}
		show = NO;
	}
	// exit full screen
	else{
		// clear tracking
		[self removeMouseTracking];
		[self clearCloseTimer];
		[self closeWithFade];
//		[self close];
		show = YES;
	}

	// set cursor
	[self showCursor:show];

}
//------------------------------------
// handleWindowMouseDidMoved
//------------------------------------
- (void)handleWindowMouseDidMoved:(NSNotification *)notification
{
	if([self isVisible] == NO){
		[self open];
	}
}
//------------------------------------
// isFullScreen
//------------------------------------
- (void)setIsFullScreen:(BOOL)isFullScreen
{
	isFullScreen_ = isFullScreen;
}
- (BOOL)isFullScreen
{
    return isFullScreen_;
}

//------------------------------------
// isCloseTimer
//------------------------------------
- (void)setIsCloseTimer:(BOOL)isCloseTimer
{
	isCloseTimer_ = isCloseTimer;
}
- (BOOL)isCloseTimer
{
    return isCloseTimer_;
}

//------------------------------------
// startCloseTimer
//------------------------------------
- (void)startCloseTimer
{

//	NSLog(@"startCloseTimer");

	// clear timer
	[self clearCloseTimer];

	// set timer
	[self setIsCloseTimer:YES];
	[self setCloseTimer:[NSTimer scheduledTimerWithTimeInterval:CLOSE_TIMER_INTERVAL
							target:self 
							selector:@selector(closeWithTimer)
							userInfo:nil
							repeats:NO]
	];
	[[NSRunLoop currentRunLoop] addTimer:[self closeTimer] forMode:(NSString*)kCFRunLoopCommonModes];

}
//------------------------------------
// closeTimer
//------------------------------------
- (void)setCloseTimer:(NSTimer*)closeTimer
{
	[closeTimer retain];
	[closeTimer_ release];
	closeTimer_ = closeTimer;
}
- (void)clearCloseTimer
{
	[self setIsCloseTimer:NO];
	if([[self closeTimer] isValid] == YES){
		[[self closeTimer] invalidate];
//		NSLog(@"clearCloseTimer");
	}
}
- (NSTimer*)closeTimer
{
	return closeTimer_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[closeTimer_ release];

	[super dealloc];
}

@end
