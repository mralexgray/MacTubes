/* ViewFileFormat */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "FetchItem.h"

@interface ViewFileFormat : NSObject
{

	IBOutlet id downloadManager;
	IBOutlet id logStatusController;

	IBOutlet NSWindow *fileFormatWindow;
	IBOutlet NSTableView *tbvFileFormat;

	IBOutlet NSTextField *txtVideoTitle;
	IBOutlet NSButton *btnDownload;
	IBOutlet NSProgressIndicator *indProc;

	FetchItem* fetchItem_;

	NSMutableArray *fileFormatList_;
	NSString *title_;
	NSString *watchURL_;
	NSString *logString_;
}

- (IBAction)openFileFormatWindow:(id)sender;
- (IBAction)downloadItem:(id)sender;
- (IBAction)copyLinkToPasteboard:(id)sender;

- (void)loadItems:(NSDictionary*)object;
- (void)loadFileFormatList:(NSString*)itemId
					title:(NSString*)title;
- (void)setFileFormatList:(NSString*)itemId
					title:(NSString*)title
					fileFormatNoMaps:(NSDictionary*)fileFormatNoMaps;
- (void)addFileFormatList:(NSDictionary*)formatNoMaps;

- (void)setButtonStatus;

- (void)setFetchItem:(FetchItem*)fetchItem;
- (FetchItem*)fetchItem;
- (void)cancelFetchItem;

- (NSMutableArray*)fileFormatList;

- (BOOL)isSelectedRows;
- (void)setWatchURL:(NSString*)watchURL;
- (NSString*)watchURL;
- (void)setTitle:(NSString*)title;
- (NSString*)title;
- (void)setLogString:(NSString*)logString;
- (void)appendLogString:(NSString *)logString;
- (NSString*)logString;

@end
