/* MenuItemFileDownload */

#import <Cocoa/Cocoa.h>
#import "VideoPlayerStatus.h"

@interface MenuItemFileDownload : NSMenuItem
{
	IBOutlet NSMenu *menuFileDownload;
	IBOutlet NSMenu *menuSelectFileDownload;

}
- (void)changeSubMenu:(int)playerType;

@end
