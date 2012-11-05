/* RelatedlistTableView */

#import <Cocoa/Cocoa.h>
#import "PasteboardTypes.h"

@class TableColumnController;

@interface RelatedlistTableView : NSTableView
{
	IBOutlet id viewRelatedSearch;
 	IBOutlet NSArrayController *relatedlistArrayController;

	IBOutlet NSMenu *cmRelatedlist;
	IBOutlet NSMenu *cmRelatedlistHeader;
	IBOutlet NSSlider *sliderRowHeight;

	TableColumnController *tcc_;
}
- (IBAction)changeColumnState:(id)sender;
- (IBAction)changeRowHeight:(id)sender;

- (BOOL)isShowColumn:(NSString*)identifier;

@end
