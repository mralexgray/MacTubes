/* MenuItemPlayerType */

#import <Cocoa/Cocoa.h>

@interface MenuItemPlayerType : NSMenuItem
{
}
- (IBAction)changePlayerType:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)setMenuAction:(NSMenu*)aMenu;
- (void)updateMenuItem:(NSMenu*)aMenu;

@end
