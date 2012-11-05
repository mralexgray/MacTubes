/* MenuSelectFileFormatNo */

#import <Cocoa/Cocoa.h>
#import "VideoFormatTypes.h"

@interface MenuSelectFileFormatNo : NSMenu
{
	IBOutlet id viewPlayer;
	IBOutlet id viewPrefs;
}
- (IBAction)changeFileFormatNo:(id)sender;
- (IBAction)openPrefsWindow:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)createMenuItem;
- (void)updateMenuItem;
- (NSArray*)menuItems;

@end
