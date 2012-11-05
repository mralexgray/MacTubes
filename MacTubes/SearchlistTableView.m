#import "SearchlistTableView.h"
#import "ViewMainSearch.h"
#import "ContentItem.h"
#import "RoundImageCell.h"
#import "ItemDescTextCell.h"
#import "TableColumnController.h"
#import "TableColumnExtension.h"
#import "ConvertExtension.h"
#import "CellAttributeExtension.h"
#import "UserDefaultsExtension.h"

@implementation SearchlistTableView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set delegate
	[super setDelegate:self];
	[super setDataSource:self];

	// set row height
	float rowHeight = [self defaultFloatValue:@"optSearchRowHeight"];
	[sliderRowHeight setFloatValue:rowHeight];
	[self setRowHeight:rowHeight];


	// image column
	NSTableColumn *imageColumn = [self tableColumnWithIdentifier:@"image"];
	RoundImageCell *imageCell = [[[RoundImageCell alloc] init] autorelease];
	[imageColumn setDataCell:imageCell];

	// description column
	NSTableColumn *descColumn = [self tableColumnWithIdentifier:@"description"];
	ItemDescTextCell *descTextCell = [[[ItemDescTextCell alloc] init] autorelease];
	[descColumn setDataCell:descTextCell];

    // set click action
	[self setTarget:viewMainSearch];
	[self setDoubleAction:@selector(playItem:)];

	// set table column state
	[self setTableColumnState:self key:@"stateTableColumnSearchlist"];

	// init column controller
	if (tcc_ == nil) {
		tcc_ = [[TableColumnController alloc] initWithTable:self];
	}

	// showTableColumns
	// set default hide columns
	NSArray *defaultHideCols = [NSArray arrayWithObjects:
									nil
								];
	[self showTableColumns:tcc_ aTableView:self defaultHideCols:defaultHideCols key:@"stateTableColumnSearchlist"];

	// set sort descriptor
	[self setArrayControllerSortDescriptor:searchlistArrayController key:@"sortDescColumnSearchlist"];

	// set header menu
	[[self headerView] setMenu:cmSearchlistHeader];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
	[nc addObserver:self selector:@selector(handleItemObjectChange:) name:VIDEO_ITEM_NOTIF_NAME_FROM_MAIN object:nil];

	// set registerForDraggedTypes
	[self registerForDraggedTypes:[NSArray arrayWithObjects:ItemlistPboardType, NSStringPboardType, nil]];

	// set drag operation
	[self setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];

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
// change table column state
//------------------------------------
- (IBAction)changeColumnState:(id)sender;
{
	[self setColumnState:tcc_ sender:sender];
}
//------------------------------------
// isShowColumn
//------------------------------------
- (BOOL)isShowColumn:(NSString*)identifier
{
	return [self isShowColumnState:tcc_ identifier:identifier];
}
//------------------------------------
// handleItemObjectChange
//------------------------------------
-(void)handleItemObjectChange:(NSNotification *)notification
{
	[self reloadData];
}
//------------------------------------
// windowWillClose
//------------------------------------
-(void)windowWillClose:(NSNotification *)notification
{

	// table column state
	[self saveTableColumnState:self key:@"stateTableColumnSearchlist"];
	// save sort descriptor
	[self saveArrayControllerSortDescriptor:searchlistArrayController key:@"sortDescColumnSearchlist"];

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

	// get record from searchlistArrayController
	id record = [[searchlistArrayController arrangedObjects] objectAtIndex:rowIndex];

	// image
	if([[aTableColumn identifier] isEqualToString:@"image"]){
		ContentItem *itemObject = [record objectForKey:@"itemObject"]; 
		BOOL isPlayed = [[record valueForKey:@"isPlayed"] boolValue];
		int formatMapNo = [[record valueForKey:@"formatMapNo"] intValue];

		RoundImageCell *imageCell = [aTableColumn dataCell];
		[imageCell setImage:[itemObject image]];
		[imageCell setIsPlayed:isPlayed];
		[imageCell setFormatMapNo:formatMapNo];
//		return imageCell;
//		return [itemObject image];
	}
	// description
	else if([[aTableColumn identifier] isEqualToString:@"description"]){

		NSString *playTimeStr = @"-";
		NSString *viewsStr = @"-";
		NSString *dateStr = @"";

		// playTime
		if([record valueForKey: @"playTime"]){
			int playTime = [[record valueForKey: @"playTime"] intValue];
			playTimeStr = [self convertTimeToString:playTime];
		}
		// viewCount
		if([record valueForKey: @"viewCount"]){
			int viewCount = [[record valueForKey: @"viewCount"] intValue];
			viewsStr = [self convertToComma:viewCount];
		}
		// publishedDate
		if([record valueForKey:@"publishedDate"]){
			dateStr = [[record valueForKey:@"publishedDate"] descriptionWithCalendarFormat:@"%Y/%m/%d - %H:%M" timeZone:nil locale:nil];
		}

		// itemStatus
		int itemStatus = [[record valueForKey:@"itemStatus"] intValue];

		NSString *desc1 = [NSString stringWithFormat:@"Time: %@  Date: %@", playTimeStr, dateStr];
		NSString *desc2 = [NSString stringWithFormat:@"Author: %@  Views: %@", [record valueForKey:@"author"], viewsStr];
		ItemDescTextCell *descTextCell = [aTableColumn dataCell];
		[descTextCell setStringValue:[NSString stringWithFormat:@"%@\t%@\t%@", [record valueForKey:@"title"], desc1, desc2]];
		[descTextCell setItemStatus:itemStatus];

		return descTextCell;
	}
	// playTime
	else if([[aTableColumn identifier] isEqualToString:@"playTime"]){
		NSString *playTimeStr = @"-";
		// playTime
		if([record valueForKey: @"playTime"]){
			int playTime = [[record valueForKey: @"playTime"] intValue];
			playTimeStr = [self convertTimeToString:playTime];
		}
		return playTimeStr;
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
		id record = [[searchlistArrayController arrangedObjects] objectAtIndex:row];
		return [record valueForKey:@"description"];
    }
	return nil;
}
//------------------------------------
// numberOfRowsInTableView
//------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[searchlistArrayController arrangedObjects] count];
}
//------------------------------------
// tableViewSelectionDidChange
//------------------------------------
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if([self numberOfSelectedRows] == 1){
		[self scrollRowToVisible:[[self selectedRowIndexes] firstIndex]];
	}
}
//=======================================================================
// drag & drop method
//=======================================================================
//------------------------------------
// writeRowsWithIndexes
//------------------------------------
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {

    BOOL success = NO;

	NSArray *objects = [[searchlistArrayController arrangedObjects] objectsAtIndexes:rowIndexes];

	// create array for pasteboard
 	NSMutableArray *items = [NSMutableArray array];
 	NSString *videoURL = @"";
	int i;
	for (i = 0; i < [objects count]; i++) {
		NSManagedObject *item = [objects objectAtIndex:i];
		[items addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				[item valueForKey:@"itemId"], @"itemId" ,
				[item valueForKey:@"title"], @"title" ,
				[item valueForKey:@"author"], @"author" ,
				nil
			]
		];
	}
	// videoURL for other app
	if([objects count] > 0){
		videoURL = [self convertToWatchURL:[[objects objectAtIndex:0] valueForKey:@"itemId"]];
//		videoURL = [self convertToFileFormatURL:videoURL fileFormatNo:[self defaultPlayFileFormatNo]];
	}

	[pboard declareTypes:[NSArray arrayWithObjects:ItemlistPboardType, NSStringPboardType, nil] owner:nil];
	[pboard addTypes:[NSArray arrayWithObjects:ItemlistPboardType, NSStringPboardType, nil] owner:nil];
//	[pboard setString:[items componentsJoinedByString:@","] forType:ItemlistPboardType];        
	[pboard setPropertyList:items forType:ItemlistPboardType];        
	if(![videoURL isEqualToString:@""]){     
		[pboard setString:videoURL forType:NSStringPboardType];        
	}

	if([items count] > 0){
		success = YES;
	}

	return success;

}
//------------------------------------
// dragImageForRowsWithIndexes
//------------------------------------
- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet*)dragRows
							tableColumns:(NSArray*)tableColumns
							event:(NSEvent*)dragEvent
							offset:(NSPointPointer)dragImageOffset
{
	// one item
/*
	if ([dragRows count] == 1){
		return [super dragImageForRowsWithIndexes:dragRows tableColumns:tableColumns event:dragEvent offset:dragImageOffset];
	}
	// many items
	else{
*/
		// create drag image
		NSImage	*dragImage = [[NSImage alloc] init];
		[dragImage setSize:NSMakeSize(65.0, 40.0)];

		// set count label bounds
		NSString *countStr = [NSString stringWithFormat:@"%i", [dragRows count]];
		NSRect imageBounds;
		imageBounds.origin = NSMakePoint(0, 0);
		imageBounds.size = [dragImage size];

		// create source image
		NSImage *sourceImage = [[[NSImage alloc] initByReferencingFile: [[NSBundle mainBundle] pathForResource:@"icon_video" ofType:@"png"]] autorelease];

		[sourceImage setScalesWhenResized:YES];
		[sourceImage setSize:NSMakeSize(24, 24)];

		NSPoint sourcePoint;
		sourcePoint.x = imageBounds.origin.x + ((imageBounds.size.width - [sourceImage size].width) / 2);
		sourcePoint.y = imageBounds.origin.y + ((imageBounds.size.height - [sourceImage size].height) / 2);

		[dragImage lockFocus];

		// draw label
		[self drawLabelAndString:imageBounds
						withString:countStr
						fontSize:LABEL_DRAG_FSIZE
						fontColor:[NSColor whiteColor]
						labelColor:[NSColor redColor]
						align:CELL_ALIGN_RIGHT
						valign:CELL_VALIGN_TOP
						hPadding:LABEL_DRAG_HPADDING
						vPadding:LABEL_DRAG_VPADDING
						radius:LABEL_DRAG_RADIUS
		];

		// draw source image
		[sourceImage compositeToPoint:sourcePoint operation:NSCompositeDestinationOver fraction:0.8];

		[dragImage unlockFocus];

		return [dragImage autorelease];
//	}
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
		[NSMenu popUpContextMenu:cmSearchlist withEvent:theEvent forView:self];
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
