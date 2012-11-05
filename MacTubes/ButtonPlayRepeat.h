/* ButtonPlayRepeat */

#import <Cocoa/Cocoa.h>
#import "VideoPlayerStatus.h"
#import "PlayModeTypes.h"

@interface ButtonPlayRepeat : NSButton
{
}
- (IBAction)changePlayRepeat:(id)sender;
- (void)changeButtonImage;
- (void)handleVideoObjectDidChanged:(NSNotification *)notification;
@end
