/* ViewPlayController */

#import <Cocoa/Cocoa.h>
#import "ControllerWindow.h"

@interface ViewPlayController : NSObject
{

	IBOutlet ControllerWindow *controllerWindow;

}

- (IBAction)openControllerWindow:(id)sender;
- (IBAction)closeControllerWindow:(id)sender;

@end
