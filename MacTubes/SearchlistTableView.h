/* SearchlistTableView */

#import <Cocoa/Cocoa.h>
#import "PasteboardTypes.h"

@class TableColumnController;

@interface SearchlistTableView : NSTableView
{
	IBOutlet id viewMainSearch;
	IBOutlet NSArrayController *searchlistArrayController;

	IBOutlet NSMenu *cmSearchlist;
	IBOutlet NSMenu *cmSearchlistHeader;
	IBOutlet NSSlider *sliderRowHeight;

	TableColumnController *tcc_;
}
- (IBAction)changeRowHeight:(id)sender;
- (IBAction)changeColumnState:(id)sender;

- (BOOL)isShowColumn:(NSString*)identifier;


@end
