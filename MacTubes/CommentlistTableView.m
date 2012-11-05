#import "CommentlistTableView.h"
#import "CommentDescTextCell.h"
#import "UserDefaultsExtension.h"

@implementation CommentlistTableView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set delegate
	[super setDelegate:self];
	[super setDataSource:self];

	// set row height
	float rowHeight = [self defaultFloatValue:@"optCommentRowHeight"];
	[sliderRowHeight setFloatValue:rowHeight];
	[self setRowHeight:rowHeight];

	// description column
	NSTableColumn *descColumn = [self tableColumnWithIdentifier:@"description"];
	CommentDescTextCell *descTextCell = [[[CommentDescTextCell alloc] init] autorelease];
	[descColumn setDataCell:descTextCell];

	// set sort descriptor
	[self setArrayControllerSortDescriptor:commentlistArrayController key:@"sortDescColumnCommentlist"];

	// set table column state
//	[self setTableColumnState:self key:@"stateTableColumnCommentlist"];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];

}
//------------------------------------
// changeRowHeight
//------------------------------------
- (IBAction)changeRowHeight:(id)sender
{
	[self setRowHeight:[sender floatValue]];

	if([self numberOfSelectedRows] > 0){
		[self scrollRowToVisible:[self selectedRow]];
	}

}
//------------------------------------
// windowWillClose
//------------------------------------
-(void)windowWillClose:(NSNotification *)notification
{

	// table column state
//	[self saveTableColumnState:self key:@"stateTableColumnCommentlist"];
	// save sort descriptor
	[self saveArrayControllerSortDescriptor:commentlistArrayController key:@"sortDescColumnCommentlist"];

}

//=======================================================================
// bind to tableview column
//=======================================================================
//------------------------------------
// objectValueForTableColumn
//------------------------------------
- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex
{

	// get record from commentlistArrayController
	id record = [[commentlistArrayController arrangedObjects] objectAtIndex:rowIndex];

	// description
	if([[aTableColumn identifier] isEqualToString:@"description"]){

		NSString *author = [record valueForKey: @"author"];
		NSString *content = [record valueForKey: @"content"];
		// publishedDate
		NSString *dateStr = @"";
		if([record valueForKey:@"publishedDate"]){
			dateStr = [[record valueForKey:@"publishedDate"] descriptionWithCalendarFormat:@"%Y/%m/%d - %H:%M" timeZone:nil locale:nil];
		}

		CommentDescTextCell *descTextCell = [aTableColumn dataCell];
		[descTextCell setStringValue:[NSString stringWithFormat:@"%@\t%@\t%@", author, dateStr, content]];

		return descTextCell;
	}

    return nil;
}
//------------------------------------
// toolTipForCell
//------------------------------------
- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation
{
    if( [[aTableColumn identifier] isEqualToString:@"description"] &&
		[self defaultBoolValue:@"optShowPopupComment"] == YES
	){
		id record = [[commentlistArrayController arrangedObjects] objectAtIndex:row];
		return [record valueForKey:@"content"];
    }
	return nil;
}
//------------------------------------
// numberOfRowsInTableView
//------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[commentlistArrayController arrangedObjects] count];
}
/*
//------------------------------------
// heightOfRow
//------------------------------------
- (float)tableView:(NSTableView *)tableView heightOfRow:(int)rowIndex
{
//	int rowHeight = 48;
	NSTableColumn *column = [tableView tableColumnWithIdentifier:@"description"];
	CommentDescTextCell *descCell = (CommentDescTextCell*)[column dataCellForRow:rowIndex];
	NSSize textAreaSize = [descCell textAreaSize];
//	NSLog(@"row=%d w=%.2f h=%.2f", rowIndex, textAreaSize.width, textAreaSize.height);
	return textAreaSize.height;
}
*/
//------------------------------------
// tableViewSelectionDidChange
//------------------------------------
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if([self numberOfSelectedRows] == 1){
		[self scrollRowToVisible:[[self selectedRowIndexes] firstIndex]];
	}
}
//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{	
	BOOL isAction = NO;

	// control click
	if([theEvent modifierFlags] & NSControlKeyMask){
		[self rightMouseDown:theEvent];
		isAction = YES;
	}

	if(isAction == NO){
		[super mouseDown:theEvent];
	}
}
//------------------------------------
// rightMouseDown
//------------------------------------
- (void)rightMouseDown:(NSEvent *)theEvent
{	

	NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	BOOL isAction = NO;
	
	int i = [self rowAtPoint:p];
	
	if (i < [self numberOfRows]){
		// single selected
		if ([self numberOfSelectedRows] <= 1){
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
		}
		// multiple selected
		else{
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:YES];
		}
		[NSMenu popUpContextMenu:cmCommentlist withEvent:theEvent forView:self];
		isAction = YES;
	}

	if(isAction == NO){
		[super rightMouseDown:theEvent];
	}

}
//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end
