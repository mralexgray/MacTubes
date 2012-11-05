/* CMRelatedlistHeader */

#import <Cocoa/Cocoa.h>
#import "RelatedlistTableView.h"

@interface CMRelatedlistHeader : NSMenu
{
    IBOutlet RelatedlistTableView *tbvRelatedlist;
}
-(void)setMenuItem;
-(NSArray*)menuItems;

@end
