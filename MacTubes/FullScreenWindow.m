#import "FullScreenWindow.h"
#import "UserDefaultsExtension.h"

static const int YOUTUBE_BAR_HEIGHT = 25;
static const int CONTROL_BAR_HEIGHT = 27;

@implementation FullScreenWindow
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	[self setIsFullScreen:NO];
	[self setIsTopScreen:NO];
	[self setPlayerType:[self defaultVideoPlayerType]];

	oldRect_ = [self frame];

	// title bar height
	titleBarHeight_ = [self frame].size.height
					-([[self contentView] frame].size.height + [[self contentView] frame].origin.y);

	[self setShowYouTubeBar:YES];
	[self setShowController:YES];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleVideoPlayerTypeDidChanged:) name:VIDEO_NOTIF_VIDEO_PLAYER_TYPE_DID_CHANGED object:nil];

}
//=======================================================================
// actions
//=======================================================================
//------------------------------------
// changeFullScreen
//------------------------------------
- (IBAction)changeFullScreen:(id)sender
{

	BOOL isFullScreen;
	int playerType = [self playerType];

	// exit full screen
	if([self isFullScreen] == YES){
		isFullScreen = NO;
	}else{
		// enter full screen & show controller
		isFullScreen = YES;
		if(playerType == VIDEO_PLAYER_TYPE_SWF){
			[self setShowYouTubeBar:YES];
			[self setShowController:YES];
		}
		// hide all
		else if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
			[self setShowYouTubeBar:NO];
			[self setShowController:NO];
		}
	}

	[self setFullScreen:isFullScreen animate:YES];

}
//------------------------------------
// changeFullScreenWithHideController
//------------------------------------
- (IBAction)changeFullScreenWithHideController:(id)sender
{
	BOOL isFullScreen;
	int playerType = [self playerType];

	// change fill screen mode
	if([self isFullScreen] == YES){
/*
		// show controller 
		if([self showController] == NO){
			[self setShowController:YES];
		}
		// hide all
		else{
			[self setShowController:NO];
		}
*/
		if(playerType == VIDEO_PLAYER_TYPE_SWF){
			// show youtube bar 
			if([self showYouTubeBar] == NO && [self showController] == NO){
				[self setShowYouTubeBar:YES];
			}
			// show controller 
			else if([self showYouTubeBar] == YES && [self showController] == NO){
				[self setShowController:YES];
			}
			// hide all
			else{
				[self setShowYouTubeBar:NO];
				[self setShowController:NO];
			}
		}
		else if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
			[self setShowYouTubeBar:NO];
			[self setShowController:NO];
		}
/*
		// show all 
		if([self showYouTubeBar] == NO && [self showController] == NO){
			[self setShowYouTubeBar:YES];
			[self setShowController:YES];
		}
		// hide all
		else{
			[self setShowYouTubeBar:NO];
			[self setShowController:NO];
		}
*/
		// set frame
		[self setFrame:[[NSScreen mainScreen] frame] display:YES animate:YES];
	}else{
		// enter full screen & hide all
		isFullScreen = YES;
		[self setShowYouTubeBar:NO];
		[self setShowController:NO];
		[self setFullScreen:isFullScreen animate:YES];
	}

}
//------------------------------------
// changeTopScreen
//------------------------------------
- (IBAction)changeTopScreen:(id)sender
{
	[self changeWindowLevel];
}
//=======================================================================
// methods
//=======================================================================
//------------------------------------
// setFullScreen
//------------------------------------
- (void)setFullScreen:(BOOL)isFullScreen animate:(BOOL)animate
{

	// same style
	if([self isFullScreen] == isFullScreen){
		return;
	}

	// save oldrect
	if(isFullScreen == YES){
		if([self isFullScreen] == NO){
			oldRect_ = [self frame];
		}
	}

	[self setIsFullScreen:isFullScreen];

	if(isFullScreen == YES){
		[NSMenu setMenuBarVisible:NO];
		[self setShowsResizeIndicator:NO];
		[self setFrame:[[NSScreen mainScreen] frame] display:YES animate:animate];
		[self setLevel:NSNormalWindowLevel];
	}else{
		[NSMenu setMenuBarVisible:YES];
		[self setShowsResizeIndicator:YES];
		[self setFrame:oldRect_ display:YES animate:animate];
		[self restoreWindowLevel];
	}

//	[self setLevel:NSNormalWindowLevel];

	// post notification
	[self postWindowFullScreenChangedNotification:isFullScreen];

}
//------------------------------------
// close
//------------------------------------
- (void)close
{
	if([self isFullScreen] == YES){
		[self setFullScreen:NO animate:YES];
	}else{
		[super close];
	}
	[self restoreWindowLevel];
}

//------------------------------------
// constrainFrameRect
//------------------------------------
-(NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)aScreen
{
	if([self isFullScreen] == YES){
		NSRect screenRect = [[NSScreen mainScreen] frame];
		screenRect.size.height += titleBarHeight_;

		// adjust control bar height
		if([self showController] == NO){
			screenRect.size.height += CONTROL_BAR_HEIGHT;
			screenRect.origin.y -= CONTROL_BAR_HEIGHT;
		}
		if([self showYouTubeBar] == NO){
			screenRect.size.height += YOUTUBE_BAR_HEIGHT;
			screenRect.origin.y -= YOUTUBE_BAR_HEIGHT;
		}
		return screenRect;
	}else{
		return [super constrainFrameRect:frameRect toScreen:aScreen];
	}
}
//------------------------------------
// changeWindowLevel
//------------------------------------
- (void)changeWindowLevel
{
	if([self level] == NSNormalWindowLevel){
		[self setLevel:NSModalPanelWindowLevel];
		[self setIsTopScreen:YES];
	}else{
		[self setLevel:NSNormalWindowLevel];
		[self setIsTopScreen:NO];
	}
}
//------------------------------------
// restoreWindowLevel
//------------------------------------
- (void)restoreWindowLevel
{
	if([self isTopScreen] == YES){
		[self setLevel:NSModalPanelWindowLevel];
	}else{
		[self setLevel:NSNormalWindowLevel];
	}
}
//------------------------------------
// postWindowFullScreenChangedNotification
//------------------------------------
- (void)postWindowFullScreenChangedNotification:(BOOL)isFullScreen
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:WINDOW_NOTIF_FULLSCREEN_DID_CHANGED object:[NSNumber numberWithBool:isFullScreen]];
}
//------------------------------------
// handleVideoPlayerTypeDidChanged
//------------------------------------
- (void)handleVideoPlayerTypeDidChanged:(NSNotification *)notification
{

	int playerType = [[notification object] intValue];

	[self setPlayerType:playerType];

}
//------------------------------------
// canBecomeKeyWindow
//------------------------------------
- (BOOL)canBecomeKeyWindow
{
    return YES;
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
// isTopScreen
//------------------------------------
- (void)setIsTopScreen:(BOOL)isTopScreen
{
	isTopScreen_ = isTopScreen;
}
- (BOOL)isTopScreen
{
    return isTopScreen_;
}

//------------------------------------
// showYouTubeBar
//------------------------------------
- (void)setShowYouTubeBar:(BOOL)showYouTubeBar
{
	showYouTubeBar_ = showYouTubeBar;
}
- (BOOL)showYouTubeBar
{
    return showYouTubeBar_;
}
//------------------------------------
// showController
//------------------------------------
- (void)setShowController:(BOOL)showController
{
	showController_ = showController;
}
- (BOOL)showController
{
    return showController_;
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
// keyDown
//------------------------------------
- (void)keyDown:(NSEvent *)theEvent
{    
	BOOL isAction = NO;

	// escape key
	if([theEvent keyCode] == 53){
		if([self isFullScreen] == YES){
			[self setFullScreen:NO animate:YES];
			isAction = YES;
		}
	}

	if(isAction == NO){
		[super keyDown:theEvent];
	}
}

@end
