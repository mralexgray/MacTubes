#import "ButtonForContextMenu.h"

@implementation ButtonForContextMenu

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// delete focus ring
	[self setFocusRingType:NSFocusRingTypeNone];

}
//------------------------------------
// menuForEvent
//------------------------------------
- (NSMenu*)menuForEvent:(NSEvent *)theEvent
{
	// disabled
	if([self isEnabled] == NO){
		return nil;
	}else{
		return [self menu];
	}
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
	// disabled
	if([self isEnabled] == NO){
		return;
	}

	// set menu point
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//	NSPoint point = NSMakePoint([self frame].origin.x, [self frame].origin.y);

	// add point fom parentview
	id parentView = [self superview];
	while(parentView){
		point.x += [parentView frame].origin.x;
		point.y += [parentView frame].origin.y;
		parentView = [parentView superview];
	}

//	NSPoint aMenuLoc = NSMakePoint(point.x + 2, point.y - 4);
	NSPoint aMenuLoc = NSMakePoint(point.x, point.y);

	// menu event
	NSEvent *aMenuEvent = [NSEvent mouseEventWithType:[theEvent type]
										location: aMenuLoc
										modifierFlags:[theEvent modifierFlags]
										timestamp:[theEvent timestamp]
										windowNumber:[theEvent windowNumber]
										context:[theEvent context]
										eventNumber:[theEvent eventNumber]
										clickCount:[theEvent clickCount]
										pressure:[theEvent pressure]];

	[self highlight:YES];

	[NSMenu popUpContextMenu:[self menu] withEvent:aMenuEvent forView:self];

	[self highlight:NO];

}
@end
