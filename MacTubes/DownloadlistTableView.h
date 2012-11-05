/* DownloadlistTableView */

#import <Cocoa/Cocoa.h>
#import "DownloadItem.h"
#import "VideoFormatTypes.h"
#import "PasteboardTypes.h"

@interface DownloadlistTableView : NSTableView
{
	IBOutlet id downloadManager;
	IBOutlet NSMenu *cmDownloadlist;

}
@end
