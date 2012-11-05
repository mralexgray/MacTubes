/* MenuSelectPlaylistSort */

#import <Cocoa/Cocoa.h>
#import "SearchQueryTypes.h"

@interface MenuSelectPlaylistSort : NSMenu
{

	IBOutlet id viewTargetSearch;
	IBOutlet NSButton *btnMenu;
}
- (IBAction)changePlaylistSort:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)createMenuItem;
- (void)updateMenuItem;
- (NSImage*)buttonImage:(NSString*)orderString;
- (NSArray*)menuItems;

@end
