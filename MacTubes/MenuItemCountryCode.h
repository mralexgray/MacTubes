/* MenuItemCountryCode */

#import <Cocoa/Cocoa.h>

@interface MenuItemCountryCode : NSMenuItem
{
	NSMenu *subMenu_;
}

- (IBAction)changeCountryCode:(id)sender;

- (void)createSubMenu:(NSMenu*)aMenu;
- (void)updateMenuItem:(NSMenu*)aMenu;

@end
