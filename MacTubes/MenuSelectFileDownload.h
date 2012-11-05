/* MenuSelectFileDownload */

#import <Cocoa/Cocoa.h>
#import "VideoFormatTypes.h"

@interface MenuSelectFileDownload : NSMenu
{
	IBOutlet id viewPlayer;
}
- (IBAction)downloadItem:(id)sender;
- (IBAction)openVideoFormatItem:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)createMenuItem;
- (void)updateMenuItem;
- (NSArray*)menuItems;

@end
