/* MenuItemFeed */

#import <Cocoa/Cocoa.h>
#import "PlaylistItemTypes.h"

@interface MenuItemFeed : NSMenuItem
{

	IBOutlet id viewPlaylist;
	NSMenu *subMenu_;

}
- (IBAction)addFeedlist:(id)sender;
- (void)createSubMenu:(NSMenu*)aMenu;
- (NSArray*)menuItems;

@end
