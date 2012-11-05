/* MenuItemAlwaysOnTop */

#import <Cocoa/Cocoa.h>
#import "FullScreenWindow.h"

@interface MenuItemAlwaysOnTop : NSMenuItem
{
    IBOutlet FullScreenWindow *playerWindow;
}
- (IBAction)changeTopScreen:(id)sender;
- (void)setMenuAction;
- (void)setMenuState;

@end
