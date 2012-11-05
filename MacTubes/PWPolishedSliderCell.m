//
//  PWPolishedSliderCell.m
//  Play MiTunes
//
//  Created by Collin Henderson on 08/09/07.
//  Copyright 2007 Hendosoft. All rights reserved.
//  Modified MacTubes.
//

#import "PWPolishedSliderCell.h"

@implementation PWPolishedSliderCell

/*
//------------------------------------
// drawBarInside
//------------------------------------
- (void)drawBarInside:(NSRect)cellFrame flipped:(BOOL)flipped
{
	NSImage *leftImage = [NSImage imageNamed:@"sliderleft.png"];
	NSImage *fillImage = [NSImage imageNamed:@"sliderfill.png"];
	NSImage *rightImage = [NSImage imageNamed:@"sliderright.png"];
				
	NSSize size = [leftImage size];
	float addX = size.width / 2.0;
	float y = NSMaxY(cellFrame) - (cellFrame.size.height-size.height)/2.0 ;
	float x = cellFrame.origin.x+addX;
	float fillX = x + size.width;
	float fillWidth = cellFrame.size.width - size.width - addX;
	
	[leftImage compositeToPoint:NSMakePoint(x, y) operation:NSCompositeSourceOver];

	size = [rightImage size];
	addX = size.width / 2.0;
	x = NSMaxX(cellFrame) - size.width - addX;
	fillWidth -= size.width+addX;
	
	[rightImage compositeToPoint:NSMakePoint(x, y) operation:NSCompositeSourceOver];
	
	[fillImage setScalesWhenResized:YES];
	[fillImage setSize:NSMakeSize(fillWidth, [fillImage size].height)];
	[fillImage compositeToPoint:NSMakePoint(fillX, y) operation:NSCompositeSourceOver];
}
*/
//------------------------------------
// drawKnob
//------------------------------------
- (void)drawKnob:(NSRect)rect
{
	NSImage *knob;
	
	if([self numberOfTickMarks] == 0){
		knob = [self knobImage:[self controlSize] isEnabled:[self isEnabled] isMouseDown:isMouseDown_];
	}

	float x = rect.origin.x + (rect.size.width - [knob size].width) / 2;
	float y = NSMaxY(rect) - (rect.size.height - [knob size].height) / 2 ;
	
	[knob compositeToPoint:NSMakePoint(x, y) operation:NSCompositeSourceOver];
}

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

//------------------------------------
// startTrackingAt
//------------------------------------
- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
//	NSLog(@"mouseIsDown?");
	isMouseDown_ = YES;
	return [super startTrackingAt:startPoint inView:controlView];
}
//------------------------------------
// stopTracking
//------------------------------------
- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];

	if(flag == YES){
		isMouseDown_ = NO;
//		NSLog(@"mouseIsUp");
	}
}
//------------------------------------
// knobImage
//------------------------------------
- (NSImage*)knobImage:(int)controlSize isEnabled:(BOOL)isEnabled isMouseDown:(BOOL)isMouseDown
{
	NSImage *image;

	// mini
/*
	if(controlSize == NSMiniControlSize){
		if(isEnabled == YES){
			if(isMouseDown == YES){
				image = [NSImage imageNamed:@"btn_slider_mini_on"];
			}else{
				image = [NSImage imageNamed:@"btn_slider_mini_off"];
			}
		}else{
			image = [NSImage imageNamed:@"btn_slider_mini_disabled"];
		}
	}
	// small or regular
	else{
*/
		if(isEnabled == YES){
			if(isMouseDown == YES){
//				if([self tag] == 0){
					image = [NSImage imageNamed:@"btn_slider_small_on"];
//				}else{
//					image = [NSImage imageNamed:@"btn_slider_grid_on"];
//				}
			}else{
//				if([self tag] == 0){
					image = [NSImage imageNamed:@"btn_slider_small_off"];
//				}else{
//					image = [NSImage imageNamed:@"btn_slider_grid_off"];
//				}
			}
		}else{
			image = [NSImage imageNamed:@"btn_slider_small_disabled"];
		}
//	}

	return image;

}
@end
