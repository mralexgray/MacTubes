/* MenuItemPlayRepeat */

#import <Cocoa/Cocoa.h>

@interface MenuItemPlayRepeat : NSMenuItem
{
}
- (IBAction)changePlayRepeat:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)setMenuAction:(NSMenu*)aMenu;
- (void)updateMenuItem:(NSMenu*)aMenu;

@end
