/* MenuItemPlaylist */

#import <Cocoa/Cocoa.h>

@interface MenuItemPlaylist : NSMenuItem
{

	IBOutlet id viewTarget;
	IBOutlet id tbArrayController;
	NSMenu *subMenu_;

}
- (void)createSubMenu:(NSMenu*)aMenu;

@end
