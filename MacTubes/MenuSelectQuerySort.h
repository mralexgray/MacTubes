/* MenuSelectQuerySort */

#import <Cocoa/Cocoa.h>
#import "SearchQueryTypes.h"

@interface MenuSelectQuerySort : NSMenu
{

	IBOutlet id viewTargetSearch;
	IBOutlet NSButton *btnMenu;
	NSString *defaultQuerySortKey_;

}
- (IBAction)changeQuerySort:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)createMenuItem;
- (void)updateMenuItem;
- (NSImage*)buttonImage:(int)no;
- (NSArray*)menuItems;

- (void)setDefaultQuerySortKey:(NSString*)defaultQuerySortKey;
- (NSString*)defaultQuerySortKey;

@end
