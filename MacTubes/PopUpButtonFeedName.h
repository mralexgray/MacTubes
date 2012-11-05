/* PopUpButtonFeedName */

#import <Cocoa/Cocoa.h>

@interface PopUpButtonFeedName : NSPopUpButton
{
	IBOutlet id viewMainSearch;
	NSMenu *subMenu_;
}

- (IBAction)changeFeedName:(id)sender;

- (void)createSubMenu:(NSMenu*)aMenu;
- (void)updateMenuItem:(NSMenu*)aMenu;
- (void)selectMenuItem:(NSMenu*)aMenu;

@end
