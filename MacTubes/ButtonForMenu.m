#import "ButtonForMenu.h"

@implementation ButtonForMenu
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

	// disabled
	if([self isEnabled] == NO){
		return;
	}

	// set menu point
	NSPoint point = NSMakePoint([self frame].origin.x, [self frame].origin.y);

	// add point from parentview
	id parentView = [self superview];
	while(parentView){
		point.x += [parentView frame].origin.x;
		point.y += [parentView frame].origin.y;
		parentView = [parentView superview];
	}

//	NSPoint aMenuLoc = NSMakePoint(rect.origin.x + 2, rect.origin.y - 4);
	NSPoint aMenuLoc = NSMakePoint(point.x + 2, point.y - 4);

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
//------------------------------------
// rightMouseDown
//------------------------------------
- (void)rightMouseDown:(NSEvent *)theEvent
{
	[self mouseDown:theEvent];
}
@end
