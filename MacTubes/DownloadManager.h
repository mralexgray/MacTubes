/* DownloadManager */

#import <Cocoa/Cocoa.h>
#import "DownloadItem.h"
#import "VideoArgsTypes.h"

@interface DownloadManager : NSObject
{
    IBOutlet id logStatusController;

	IBOutlet NSWindow *downloadWindow;
	IBOutlet NSTableView *tbvDownloadlist;
	IBOutlet NSProgressIndicator *indProc;
	IBOutlet NSTextField *txtStatus;

	NSString *logString_;

	NSMutableArray *downloadList_;

}
- (IBAction)openDownloadWindow:(id)sender;
- (IBAction)restartDownloadItem:(id)sender;
- (IBAction)cancelDownloadItem:(id)sender;
- (IBAction)cancelAllDownloadItem:(id)sender;
- (IBAction)searchDownloadItem:(id)sender;
- (IBAction)copyItemToPasteboard:(id)sender;
- (IBAction)clearFinishedItem:(id)sender;

- (void)downloadItems:(NSDictionary*)object;

- (BOOL)startDownloadItem:(NSString*)watchURL
				downloadURL:(NSString*)downloadURL
				fileName:(NSString*)fileName
				fileFormatNo:(int)fileFormatNo
				interval:(float)interval
				isGetURL:(BOOL)isGetURL;
- (BOOL)startDownload:(NSString*)watchURL
				downloadURL:(NSString*)downloadURL
				fileName:(NSString*)fileName
				fileFormatNo:(int)fileFormatNo
				interval:(float)interval
				isGetURL:(BOOL)isGetURL;
- (BOOL)restartDownload;

- (void)setDownloadStatus;
- (void)setDockIconWithValue:(int)value;

- (NSString*)getYouTubeDownloadURL:(NSString*)watchURL fileFormatNo:(int)fileFormatNo;

- (void)setLogString:(NSString*)logString;
- (void)appendLogString:(NSString *)logString;
- (NSString*)logString;

- (BOOL)isDownloading;
- (BOOL)hasDownloadURL;
- (BOOL)isSelectedRows;
- (NSMutableArray*)downloadList;
- (BOOL)anyItemIsDownloading;

@end
