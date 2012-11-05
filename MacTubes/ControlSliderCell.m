#import "ControlSliderCell.h"
#import "CellAttributeExtension.h"

@implementation ControlSliderCell

//=======================================================================
// awakeFromNib
//=======================================================================
- (void)awakeFromNib
{
	[self setLoadStatus:0.0];

}
//=======================================================================
// method
//=======================================================================
//------------------------------------
// drawBarInside
//------------------------------------
- (void)drawBarInside:(NSRect)cellFrame flipped:(BOOL)flipped
{

	float BAR_MARGIN = 5.0;
//	float BAR_MARGIN_HEIGHT = 5.0;
//	float BORDER_WIDTH = 1.0;
	float radius = 2.0;

	NSColor *bgColor = [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];

	NSRect bgRect = cellFrame;

	if([self isVertical] == NO){
//		bgRect.origin.x += 2.0;
		bgRect.origin.y += BAR_MARGIN;
//		bgRect.size.width -= (2.0 * 2);
		bgRect.size.height -= (BAR_MARGIN * 2);
	}else{
		bgRect.origin.x += BAR_MARGIN;
//		bgRect.origin.y += 2.0;
		bgRect.size.width -= (BAR_MARGIN * 2);
//		bgRect.size.height -= (2.0 * 2);
	}

/*
	bgRect.origin.x += BORDER_WIDTH;
	bgRect.origin.y += BORDER_WIDTH;
	bgRect.size.width -= (BORDER_WIDTH * 2);
	bgRect.size.height -= (BORDER_WIDTH * 2);
*/

	// rounded path
	NSBezierPath *bgPath = [self setRoundPathForRect:bgRect radius:radius];

//	NSBezierPath *bgPath = [NSBezierPath bezierPathWithRect:bgRect];

	[bgPath closePath];
	[bgColor set];
//	[bgPath stroke];
	[bgPath fill];

/*
	NSColor *bdColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
	NSBezierPath *bdPath = bgPath;
	[bdPath setLineWidth:BORDER_WIDTH];
	[bdColor set];
	[bdPath stroke];
*/

/*
	// now disabled
	//
	// draw loadStatus
	//
	float loadStatus = [self loadStatus];
	if([self tag] == 0){

		NSColor *lsColor = [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];

		if(loadStatus > 1.0){
			loadStatus = 1.0;
		}

		// rounded path
		NSRect lsRect = bgRect;
		lsRect.size.width *= loadStatus;

		// rounded path
		NSBezierPath *lsPath = [self setRoundPathForRect:lsRect radius:radius];

		[lsPath closePath];
		[lsColor set];
		[lsPath fill];
	}
*/

}
//------------------------------------
// drawKnob
//------------------------------------
- (void)drawKnob:(NSRect)rect
{

	float KNOB_MARGIN = 2.0;
//	float BORDER_WIDTH = 2.0;

	NSColor *knobColor;
	if([self isEnabled] == YES){
		knobColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
	}else{
		knobColor = [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];
	}

	NSRect knobRect = rect;
	knobRect.origin.x += KNOB_MARGIN;
	knobRect.origin.y += KNOB_MARGIN;
	knobRect.size.width -= (KNOB_MARGIN * 2);
	knobRect.size.height -= (KNOB_MARGIN * 2);

/*
	knobRect.origin.x += BORDER_WIDTH;
	knobRect.origin.y += BORDER_WIDTH;
	knobRect.size.width -= (BORDER_WIDTH * 2);
	knobRect.size.height -= (BORDER_WIDTH * 2);
*/

	NSBezierPath *knobPath = [NSBezierPath bezierPathWithOvalInRect:knobRect];

	[knobColor set];

	[knobPath fill];
//	[knobPath setLineWidth:BORDER_WIDTH];
//	[knobPath stroke];

}

/*
//------------------------------------
// knobRectFlipped
//------------------------------------
-(NSRect)knobRectFlipped:(BOOL)flipped
{
	NSRect rect = [super knobRectFlipped:flipped];
	if([self numberOfTickMarks] > 0){
		rect.size.height+=2;
		return NSOffsetRect(rect, 0, flipped ? 2 : -2);
	}
	return rect;
}

//------------------------------------
// _usesCustomTrackImage
//------------------------------------
- (BOOL)_usesCustomTrackImage
{
	return NO;
}
*/

//------------------------------------
// startTrackingAt
//------------------------------------
- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
//	NSLog(@"mouseIsDown?");
//	isMouseDown_ = YES;
	// slider type is seeking 
//	if([self tag] == 0){
//		[self postMovieProcDidChangedNotification:YES];
//	}
	return [super startTrackingAt:startPoint inView:controlView];
}
//------------------------------------
// stopTracking
//------------------------------------
- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];

	if(flag == YES){
//		isMouseDown_ = NO;
//		NSLog(@"mouseIsUp");
		// slider type is seeking 
//		if([self tag] == 0){
//			[self postMovieProcDidChangedNotification:NO];
//		}
	}
}
//------------------------------------
// setLoadStatus
//------------------------------------
- (void)setLoadStatus:(float)loadStatus
{
	loadStatus_ = loadStatus;
}
- (float)loadStatus
{
	return loadStatus_;
}

@end
