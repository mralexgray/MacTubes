/* PlayHistoryTableView */

#import <Cocoa/Cocoa.h>
#import "PasteboardTypes.h"

@interface PlayHistoryTableView : NSTableView
{
	IBOutlet id viewHistory;
 	IBOutlet NSArrayController *playhistoryArrayController;

	IBOutlet NSMenu *cmPlayHistory;

}

@end
