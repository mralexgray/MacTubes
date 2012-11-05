/* ImpExpManager */

#import <Cocoa/Cocoa.h>
#import "PlaylistOutlineView.h"
#import "PlaylistItemTypes.h"
#import "ProcInfoStatus.h"

@interface ImpExpManager : NSObject
{
	IBOutlet id tbArrayController;
	IBOutlet id logStatusController;
	IBOutlet NSTreeController *playlistTreeController;
	IBOutlet PlaylistOutlineView *olvPlaylist;
	IBOutlet NSProgressIndicator *indProc;

	NSString *logString_;
}
- (IBAction)importPlaylist:(id)sender;
- (IBAction)exportPlaylist:(id)sender;

- (BOOL)importPlaylistWithString:(NSString*)xmlString;
- (BOOL)createPlaylistWithNode:(NSXMLNode*)node
					parentItem:(id)parentItem
					childItem:(id*)childItem
					indLevel:(int)indLevel
					index:(int)index;
- (void)createItemlistWithNode:(NSXMLNode*)node plistId:(NSString*)plistId indLevel:(int)indLevel;

- (BOOL)exportPlaylistWithItem:(NSManagedObject*)item title:(NSString*)title rootFolder:(BOOL)rootFolder;
- (BOOL)exportPlaylistWithItems:(NSArray*)items title:(NSString*)title rootFolder:(BOOL)rootFolder;
- (NSXMLDocument*)createXMLDocumentWithItems:(NSArray*)items
										title:(NSString*)title
										rootFolder:(BOOL)rootFolder
										isError:(BOOL*)isError;
- (NSXMLElement*)createDataInfoElement:(NSString*)title
								rootFolder:(BOOL)rootFolder
								dataType:(NSString*)dataType;
- (NSXMLElement*)createEntryElementWithItems:(NSArray*)items indLevel:(int)indLevel isError:(BOOL*)isError;

- (NSXMLElement*)createItemElementWithPlistId:(NSString*)plistId indLevel:(int)indLevel;
- (NSXMLElement*)createItemElementWithItems:(NSArray*)items indLevel:(int)indLevel;

- (NSString*)createIndentString:(int)indLevel;
- (NSString*)createPlistLogString:(NSString*)indentString
							treeString:(NSString*)treeString
							title:(NSString*)title
							description:(NSString*)description;

- (NSString*)createItemLogString:(NSString*)indentString
							treeString:(NSString*)treeString
							itemId:(NSString*)itemId
							title:(NSString*)title;

- (void)handleProcStatusChanged:(int)status;

- (void)setLogString:(NSString*)logString;
- (NSString*)logString;
- (void)appendLogString:(NSString *)logString;


@end

