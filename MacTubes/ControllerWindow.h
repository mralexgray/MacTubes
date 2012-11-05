/* ControllerWindow */

#import <Cocoa/Cocoa.h>
#import "WindowInfoStatus.h"

@interface ControllerWindow: NSWindow

{

	BOOL isFullScreen_;

	float titleBarHeight_;
	NSPoint initialLocation;
	
	BOOL isCloseTimer_;
	NSTimer *closeTimer_;

	NSTrackingRectTag trackingRect_;

}
- (IBAction)openWindow:(id)sender;
- (IBAction)closeWindow:(id)sender;

- (void)setWindowPosition;
- (void)open;
- (void)close;
- (void)closeWithFade;
- (void)closeWithTimer;

- (void)fadeInWindow;
- (void)fadeOutWindow;
- (void)showCursor:(BOOL)show;

- (void)createMouseTracking;
- (void)removeMouseTracking;

- (void)setIsFullScreen:(BOOL)isFullScreen;
- (BOOL)isFullScreen;

- (void)setIsCloseTimer:(BOOL)isCloseTimer;
- (BOOL)isCloseTimer;

- (void)startCloseTimer;
- (void)setCloseTimer:(NSTimer*)closeTimer;
- (void)clearCloseTimer;
- (NSTimer*)closeTimer;

@end