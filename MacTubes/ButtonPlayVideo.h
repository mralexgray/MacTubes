/* ButtonPlayVideo */

#import <Cocoa/Cocoa.h>
#import "VideoPlayerStatus.h"

@interface ButtonPlayVideo : NSButton
{
}
- (void)handleVideoLoadedDidChanged:(NSNotification *)notification;
- (void)handleVideoPlayDidChanged:(NSNotification *)notification;
@end
