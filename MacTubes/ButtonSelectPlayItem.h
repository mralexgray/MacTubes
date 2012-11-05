/* ButtonSelectPlayItem */

#import <Cocoa/Cocoa.h>
#import "ControlTypes.h"

@interface ButtonSelectPlayItem : NSButton
{

}
- (IBAction)selectPlayItem:(id)sender;
- (void)setBindButtonEnabled:(NSArrayController*)arrayController;

@end
