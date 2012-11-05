#import "ButtonPlayVideo.h"

@implementation ButtonPlayVideo
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// delete focus ring
//	[self setFocusRingType:NSFocusRingTypeNone];

	// set key equivalent
	[self setKeyEquivalent:@" "];
	[self setTitle:@"Play Video"];
	[self setImagePosition:NSImageOnly];
	[self setToolTip:@"Play Video"];

	[self setEnabled:NO];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleVideoLoadedDidChanged:) name:VIDEO_NOTIF_LOADED_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoPlayDidChanged:) name:VIDEO_NOTIF_PLAY_DID_CHANGED object:nil];

}
//------------------------------------
// handleVideoLoadedDidChanged
//------------------------------------
- (void)handleVideoLoadedDidChanged:(NSNotification *)notification
{
	BOOL enable = [[notification object] boolValue];

	[self setEnabled:enable];
}
//------------------------------------
// handleVideoPlayDidChanged
//------------------------------------
- (void)handleVideoPlayDidChanged:(NSNotification *)notification
{
	BOOL isPlaying = [[notification object] boolValue];
	int tag = [self tag];

	NSImage *image = nil;
	NSString *title = @"";

	if(tag == 0){
		if(isPlaying == YES){
			image = [NSImage imageNamed:@"btn_ctrl_stop"];
		}else{
			image = [NSImage imageNamed:@"btn_ctrl_play"];
		}
	}
	else if(tag == 1){
		if(isPlaying == YES){
			image = [NSImage imageNamed:@"btn_hud_stop"];
		}else{
			image = [NSImage imageNamed:@"btn_hud_play"];
		}
	}

	// title / tooltip
	if(isPlaying == YES){
		title = @"Stop Video";
	}else{
		title = @"Play Video";
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
