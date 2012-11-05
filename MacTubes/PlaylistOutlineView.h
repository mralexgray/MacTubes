/* PlaylistOutlineView */

#import <Cocoa/Cocoa.h>
#import "PasteboardTypes.h"
#import "PlaylistItemTypes.h"

@interface _NSArrayControllerTreeNode : NSObject
{
	// none
}
- (unsigned int)count;
- (id)observedObject;
- (id)parentNode;
- (id)nodeAtIndexPath:(id)fp8;
- (id)subnodeAtIndex:(unsigned int)fp8;
- (BOOL)isLeaf;
- (id)indexPath;
- (id)objectAtIndexPath:(id)fp8;
@end

@interface PlaylistOutlineView : NSOutlineView
{
	
	IBOutlet id viewPlaylist;
	IBOutlet id tbArrayController;
    IBOutlet NSTreeController *playlistTreeController;

	IBOutlet NSMenu* cmPlaylist;

	id dragItem_;
	id dragParentItem_;
	id selectedItemAtDragging_;
	BOOL isSelectItemAtDragging_;

	BOOL restoreLastState_;

	BOOL canRename_;
	NSTimer *timer_;

}

- (IBAction)clickItem:(id)sender;
- (IBAction)doubleClickItem:(id)sender;

- (id)selectedRowObject;
- (NSManagedObject*)selectedObservedObject;
- (NSManagedObject*)observedObject:(id)object;

- (void)selectItem:(id)item;
- (void)editSelectedItem;
- (void)deselectItem;
- (BOOL)checkParentOfChild:(NSManagedObject *)parent child:(NSManagedObject *)child;

- (void)enableClickToRenameAfterDelay;
- (void)enableClickToRenameByTimer:(id)sender;
- (void)renameByTimer:(id)sender;
- (void)startTimerWithTimeInterval:(NSTimeInterval)seconds selector:(SEL)selector;
- (void)stopTimer;

- (BOOL)isDisplay;

- (void)storeLastState;
- (void)restoreLastState;

@end
