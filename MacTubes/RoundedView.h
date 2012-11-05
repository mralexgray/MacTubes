//
//  RoundedView.h
//  RoundedFloatingPanel
//
//  Created by Matt Gemmell on Thu Jan 08 2004.
//  <http://iratescotsman.com/>
//  Customized by mametunes on 2009/02/10.
//


#import <Cocoa/Cocoa.h>

@interface RoundedView : NSView
{
	float alphaValue_;
	float radius_;
}

- (void)setViewAttr:(float)alphaValue radius:(float)radius;
- (void)setAlphaValue:(float)alphaValue;
- (float)alphaValue;
- (void)setRadius:(float)radius;
- (float)radius;

@end
