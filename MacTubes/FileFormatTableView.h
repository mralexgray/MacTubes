/* FileFormatTableView */

#import <Cocoa/Cocoa.h>
#import "PasteboardTypes.h"

@interface FileFormatTableView : NSTableView
{
	IBOutlet id viewFileFormat;
	IBOutlet NSMenu *cmFormatlist;
}
@end
