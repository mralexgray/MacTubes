#import "ButtonPlayMenu.h"

@implementation ButtonPlayMenu
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// delete focus ring
//	[self setFocusRingType:NSFocusRingTypeNone];

	[self setEnabled:NO];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleVideoObjectDidChanged:) name:VIDEO_NOTIF_OBJECT_DID_CHANGED object:nil];

}
//------------------------------------
// menuForEvent
//------------------------------------
- (NSMenu*)menuForEvent:(NSEvent *)theEvent
{
	return [super menuForEvent:theEvent];
}
//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:theEvent];
}
//------------------------------------
// rightMouseDown
//------------------------------------
- (void)rightMouseDown:(NSEvent *)theEvent
{
	[super mouseDown:theEvent];
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
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
