#import "ButtonFullScreen.h"

@implementation ButtonFullScreen
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// delete focus ring
//	[self setFocusRingType:NSFocusRingTypeNone];

	[self setEnabled:NO];
	[self setTitle:@"Enter Full Screen"];
	[self setImagePosition:NSImageOnly];
	[self setToolTip:@"Enter Full Screen"];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleVideoObjectDidChanged:) name:VIDEO_NOTIF_OBJECT_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleFullScreenDidChanged:) name:WINDOW_NOTIF_FULLSCREEN_DID_CHANGED object:nil];

}
//------------------------------------
// handleVideoObjectDidChanged
//------------------------------------
- (void)handleVideoObjectDidChanged:(NSNotification *)notification
{
	BOOL hasVideo = [[notification object] boolValue];

	[self setEnabled:hasVideo];
}
//------------------------------------
// handleFullScreenDidChanged
//------------------------------------
- (void)handleFullScreenDidChanged:(NSNotification *)notification
{
	BOOL isFullScreen = [[notification object] boolValue];
	int tag = [self tag];

	NSImage *image = nil;
	NSString *title = @"";

	if(tag == 0){
		if(isFullScreen == NO){
			image = [NSImage imageNamed:@"btn_window_full_on"];
		}else{
			image = [NSImage imageNamed:@"btn_window_full_off"];
		}
	}
	else if(tag == 1){
		if(isFullScreen == NO){
			image = [NSImage imageNamed:@"btn_hud_full_on"];
		}else{
			image = [NSImage imageNamed:@"btn_hud_full_off"];
		}
	}

	// title / tooltip
	if(isFullScreen == NO){
		title = @"Enter Full Screen";
	}else{
		title = @"Exit Full Screen";
	}

	[self setImage:image];
	[self setTitle:title];
	[self setImagePosition:NSImageOnly];
	[self setToolTip:title];
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
