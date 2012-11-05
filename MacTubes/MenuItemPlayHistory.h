/* MenuItemPlayHistory */

#import <Cocoa/Cocoa.h>
#import "ControlTypes.h"

@interface MenuItemPlayHistory : NSMenuItem
{

	IBOutlet id viewPlayer;
	IBOutlet id viewHistory;
	IBOutlet id tbArrayController;
	NSMenu *subMenu_;

}
- (IBAction)playItem:(id)sender;
- (IBAction)showAllItems:(id)sender;
- (IBAction)removeAllItems:(id)sender;

- (void)createSubMenu:(NSMenu*)aMenu;

@end
