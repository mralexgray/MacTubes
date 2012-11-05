//
//  RoundedView.m
//  RoundedFloatingPanel
//
//  Created by Matt Gemmell on Thu Jan 08 2004.
//  <http://iratescotsman.com/>
//  Customized by mametunes on 2009/02/10.
//


#import "RoundedView.h"

@implementation RoundedView

//=======================================================================
// awakeFromNib
//=======================================================================
- (void)awakeFromNib
{

	// default attribute
	[self setViewAttr:0.7 radius:20.0];
//	[self setAlphaValue:0.7];
//	[self setRadius:20.0];

}

//=======================================================================
// method
//=======================================================================
//------------------------------------
// drawRect
//------------------------------------
- (void)drawRect:(NSRect)rect
{

	float alpha = [self alphaValue];
	float radius = [self radius];
	float BORDER_WIDTH = 1.5;

	NSColor *bgColor = [NSColor colorWithCalibratedWhite:0.0 alpha:alpha];
	NSRect bgRect = [self frame];

	NSBezierPath *bgPath = [NSBezierPath bezierPath];

	bgRect.origin.x += BORDER_WIDTH;
	bgRect.origin.y += BORDER_WIDTH;
	bgRect.size.width -= (BORDER_WIDTH * 2);
	bgRect.size.height -= (BORDER_WIDTH * 2);

	int minX = NSMinX(bgRect);
	int midX = NSMidX(bgRect);
	int maxX = NSMaxX(bgRect);
	int minY = NSMinY(bgRect);
	int midY = NSMidY(bgRect);
	int maxY = NSMaxY(bgRect);

	// Bottom edge and bottom-right curve
	[bgPath moveToPoint:NSMakePoint(midX, minY)];
	[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
									 toPoint:NSMakePoint(maxX, midY) 
									  radius:radius];

	// Right edge and top-right curve
	[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
									 toPoint:NSMakePoint(midX, maxY) 
									  radius:radius];

	// Top edge and top-left curve
	[bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
									 toPoint:NSMakePoint(minX, midY) 
									  radius:radius];

	// Left edge and bottom-left curve
	[bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
									 toPoint:NSMakePoint(midX, minY) 
									  radius:radius];


	[bgPath closePath];

	[bgColor set];
	[bgPath fill];

	//
	// draw border
	//
	NSColor *bdColor = [NSColor colorWithCalibratedWhite:1.0 alpha:alpha];
	NSBezierPath *bdPath = bgPath;
	[bdPath setLineWidth:BORDER_WIDTH];
	[bdColor set];
	[bdPath stroke];

}
//------------------------------------
// setViewAttr
//------------------------------------
- (void)setViewAttr:(float)alphaValue radius:(float)radius
{
	[self setAlphaValue:alphaValue];
	[self setRadius:radius];
	[self setNeedsDisplay:YES];
}
/*
//------------------------------------
// acceptsFirstResponder
//------------------------------------
-(BOOL)acceptsFirstResponder
{
	return YES;
}
//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)event
{
	[[self window] mouseDown:event];
}	
//------------------------------------
// mouseDragged
//------------------------------------
- (void)mouseDragged:(NSEvent *)event
{
	[[self window] mouseDragged:event];
}
*/
//------------------------------------
// alphaValue
//------------------------------------
- (void)setAlphaValue:(float)alphaValue
{
	alphaValue_ = alphaValue;
}
- (float)alphaValue
{
	return alphaValue_;
}
//------------------------------------
// radius
//------------------------------------
- (void)setRadius:(float)radius
{
	radius_ = radius;
}
- (float)radius
{
	return radius_;
}

@end
