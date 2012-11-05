/* ButtonPlayMenu */

#import <Cocoa/Cocoa.h>
#import "ButtonForMenu.h"
#import "VideoPlayerStatus.h"

@interface ButtonPlayMenu : ButtonForMenu
{
}
- (void)handleVideoObjectDidChanged:(NSNotification *)notification;
@end
