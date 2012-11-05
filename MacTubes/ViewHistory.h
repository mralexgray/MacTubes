/* ViewHistory */

#import <Cocoa/Cocoa.h>
#import "ControlTypes.h"

@interface ViewHistory : NSObject
{
	IBOutlet id viewPlayer;
	IBOutlet id tbArrayController;
	IBOutlet NSArrayController *playhistoryArrayController;

	IBOutlet NSWindow *historyWindow;
	IBOutlet NSButton *btnPlay;
	
}
- (IBAction)openHistoryWindow:(id)sender;
- (IBAction)playItem:(id)sender;
- (IBAction)addItemToPlaylist:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)removeAllItems:(id)sender;

@end
