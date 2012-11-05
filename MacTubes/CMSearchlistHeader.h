/* CMSearchlistHeader */

#import <Cocoa/Cocoa.h>
#import "SearchlistTableView.h"

@interface CMSearchlistHeader : NSMenu
{
    IBOutlet SearchlistTableView *tbvSearchlist;
}
-(void)setMenuItem;
-(NSArray*)menuItems;

@end
