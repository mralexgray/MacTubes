/* MenuItemPlayVolume */

#import <Cocoa/Cocoa.h>

@interface MenuItemPlayVolume : NSMenuItem
{

	NSMenu *subMenu_;

}
- (IBAction)changePlayVolume:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)createSubMenu:(NSMenu*)aMenu;
- (NSArray*)menuItems;

@end
