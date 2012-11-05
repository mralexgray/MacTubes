#import <Cocoa/Cocoa.h>
#import "ContentItem.h"
#import "PasteboardTypes.h"
#import "VideoQueryStatus.h"
#import "VideoFormatTypes.h"

@interface SearchMatrix : NSMatrix
{

	IBOutlet id viewMainSearch;
	IBOutlet NSArrayController *searchlistArrayController;

	IBOutlet NSMenu *cmSearchlist;

	int selectedIndex_;
	int pointedIndex_;

	BOOL isChangedArray_;
	BOOL isMouseDowned_;
	BOOL isPointedCell_;
	
}
- (IBAction)changeMatrix:(id)sender;
- (IBAction)changeCellSize:(id)sender;
- (IBAction)changeMatrixCols:(id)sender;
- (IBAction)selectAll:(id)sender;

- (void)createMatrix;
- (void)retileMatrix;
- (void)clearMatrix;
- (void)updateSelectedCell;
- (BOOL)selectMovedCell:(int)arrow isShift:(BOOL)isShift isCmd:(BOOL)isCmd;
- (BOOL)selectIndexCell:(int)index isShift:(BOOL)isShift isCmd:(BOOL)isCmd;
- (void)changeSelectionIndexes:(int)index
						isShift:(BOOL)isShift
						isCmd:(BOOL)isCmd;
- (void)adjustScrollPosition:(NSPoint)cellPosition;
- (NSSize)calcCellSize:(NSSize)frameSize cols:(int)cols;

- (int)maxCols;
- (void)setSelectedIndex:(int)index;
- (int)selectedIndex;
- (void)setPointedIndex:(int)index;
- (int)pointedIndex;

@end
