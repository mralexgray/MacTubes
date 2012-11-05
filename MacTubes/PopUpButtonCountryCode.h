/* PopUpButtonCountryCode */

#import <Cocoa/Cocoa.h>

@interface PopUpButtonCountryCode : NSPopUpButton
{
	NSMenu *subMenu_;
}

- (IBAction)changeCountryCode:(id)sender;

- (void)createSubMenu:(NSMenu*)aMenu;
- (void)updateMenuItem:(NSMenu*)aMenu;
- (void)selectMenuItem:(NSMenu*)aMenu;

@end
