/* MenuItemCategory */

#import <Cocoa/Cocoa.h>
#import "PlaylistItemTypes.h"

@interface MenuItemCategory : NSMenuItem
{

	IBOutlet id viewPlaylist;
	NSMenu *subMenu_;

}
- (IBAction)addCategorylist:(id)sender;
- (void)createSubMenu:(NSMenu*)aMenu;
- (void)updateMenuItem:(NSMenu*)aMenu;

@end
