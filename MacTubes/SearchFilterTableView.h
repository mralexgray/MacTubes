/* SearchFilterTableView */

#import <Cocoa/Cocoa.h>

@interface SearchFilterTableView : NSTableView
{
	IBOutlet id viewPrefs;
	IBOutlet NSArrayController *searchFilterArrayController;

	BOOL canRename_;
	NSTimer *timer_;
}

- (IBAction)clickItem:(id)sender;
- (IBAction)doubleClickItem:(id)sender;

- (void)enableClickToRenameAfterDelay;
- (void)enableClickToRenameByTimer:(id)sender;
- (void)renameByTimer:(id)sender;
- (void)startTimerWithTimeInterval:(NSTimeInterval)seconds selector:(SEL)selector row:(int)row col:(int)col;
- (void)stopTimer;

@end
