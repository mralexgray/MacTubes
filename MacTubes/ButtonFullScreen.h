/* ButtonFullScreen */

#import <Cocoa/Cocoa.h>
#import "VideoPlayerStatus.h"
#import "WindowInfoStatus.h"

@interface ButtonFullScreen : NSButton
{
}
- (void)handleVideoObjectDidChanged:(NSNotification *)notification;
- (void)handleFullScreenDidChanged:(NSNotification *)notification;
@end
