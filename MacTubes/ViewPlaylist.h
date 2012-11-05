/* ViewPlaylist */

#import <Cocoa/Cocoa.h>
#import "PlaylistOutlineView.h"
#import "PlaylistItemTypes.h"

@interface ViewPlaylist : NSObject
{
	IBOutlet id viewMainSearch;
	IBOutlet id tbArrayController;
	IBOutlet id impExpManager;
	IBOutlet NSTreeController *playlistTreeController;

	IBOutlet NSWindow *mainWindow;
	IBOutlet PlaylistOutlineView *olvPlaylist;

	IBOutlet NSButton* btnAdd;
	IBOutlet NSButton* btnRemove;

}
- (IBAction)addPlaylist:(id)sender;
- (IBAction)addSearchlist:(id)sender;
- (IBAction)addFeedlist:(id)sender;
- (IBAction)addFolder:(id)sender;

- (IBAction)searchItem:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)exportItem:(id)sender;
- (IBAction)openAuthorsProfileWithBrowser:(id)sender;

- (IBAction)editItem:(id)sender;
- (IBAction)deselectItem:(id)sender;

- (IBAction)nullAction:(id)sender;

- (void)addItem:(int)itemType
					itemSubType:(int)itemSubType
					title:(NSString*)title
					keyword:(NSString*)keyword
					isFolder:(BOOL)isFolder
					isSelect:(BOOL)isSelect
					isEdit:(BOOL)isEdit;

- (void)setControlButtonEnable;

- (BOOL)isSelectItem;
- (BOOL)isSelectFolder;
- (BOOL)isSelectPlaylist;
- (BOOL)isSelectSearchKeyword;
- (BOOL)isSelectSearchAuthor;
- (BOOL)isKeyMainWindow;
- (BOOL)canAddPlaylist;
- (BOOL)isDisplayPlaylist;

@end
