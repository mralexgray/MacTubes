/* TableColumnExtension */

#import <Cocoa/Cocoa.h>
#import "TableColumnController.h"

@interface NSObject(tableColumnExtension_)

- (void)setColumnState:(TableColumnController*)tcc sender:(id)sender;
- (void)showTableColumns:(TableColumnController*)tcc
				aTableView:(NSTableView*)aTableView
				defaultHideCols:(NSArray*)defaultHideCols
				key:(NSString*)key;
- (BOOL)isShowColumnState:(TableColumnController*)tcc identifier:(NSString*)identifier;

@end
