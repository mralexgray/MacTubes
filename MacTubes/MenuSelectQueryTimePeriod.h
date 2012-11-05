/* MenuSelectQueryTimePeriod */

#import <Cocoa/Cocoa.h>
#import "SearchQueryTypes.h"

@interface MenuSelectQueryTimePeriod : NSMenu
{

	IBOutlet id viewTargetSearch;
	IBOutlet NSButton *btnMenu;
}
- (IBAction)changeQueryTimePeriod:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)createMenuItem;
- (void)updateMenuItem;
- (NSImage*)buttonImage:(int)no;
- (NSArray*)menuItems;

@end
