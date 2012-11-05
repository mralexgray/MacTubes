//
//  PWPolishedSliderCell.h
//  Play MiTunes
//
//  Created by Collin Henderson on 08/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//  Modified MacTubes.
//

#import <Cocoa/Cocoa.h>


@interface PWPolishedSliderCell : NSSliderCell {

	BOOL isMouseDown_;

}
- (NSImage*)knobImage:(int)controlSize isEnabled:(BOOL)isEnabled isMouseDown:(BOOL)isMouseDown;

@end
