/* ControlSliderCell */

#import <Cocoa/Cocoa.h>

@interface ControlSliderCell : NSSliderCell {

	BOOL isMouseDown_;
	float loadStatus_;
}
- (void)setLoadStatus:(float)loadStatus;
- (float)loadStatus;

@end
