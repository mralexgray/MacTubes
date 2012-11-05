#import "FileFormatTableView.h"
#import "ViewFileFormat.h"
#import "CellAttributeExtension.h"
#import "UserDefaultsExtension.h"

@implementation FileFormatTableView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// set delegate
	[super setDelegate:self];
	[super setDataSource:self];

    // set click action
	[self setTarget:viewFileFormat];
	[self setDoubleAction:@selector(downloadItem:)];

	// set table column state
	[self setTableColumnState:self key:@"stateTableColumnFormatlist"];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];

	// set registerForDraggedTypes
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSStringPboardType, ItemlistPboardType, nil]];

	// set drag operation
	[self setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];

}

//=======================================================================
// bind to tableview column
//=======================================================================
- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex
{

	if([[viewFileFormat fileFormatList] count] <= 0){
		return nil;
	}

	id record = [[viewFileFormat fileFormatList] objectAtIndex:rowIndex];

	// formatMapNo
	if ([[aTableColumn identifier] isEqualToString:@"formatMapNo"]){
		return [record valueForKey:@"formatMapNo"];
//		return [NSString stringWithFormat:@"fmt=%d", [[record valueForKey:@"formatMapNo"] intValue]];
	}
	// name
	else if ([[aTableColumn identifier] isEqualToString:@"name"]){
		return [record valueForKey:@"name"];
	}
	// description
	else if ([[aTableColumn identifier] isEqualToString:@"description"]){
		return [record valueForKey:@"description"];
	}
	// downloadURL
	else if([[aTableColumn identifier] isEqualToString:@"downloadURL"]){
		return [record valueForKey:@"downloadURL"];
	}

    return nil;
}
//------------------------------------
// bind to tableview line count
//------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[viewFileFormat fileFormatList] count];
}
//------------------------------------
// toolTipForCell
//------------------------------------
- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation
{
    if( [[aTableColumn identifier] isEqualToString:@"description"] &&
		[self defaultBoolValue:@"optShowPopupComment"] == YES
	){
		id record = [[viewFileFormat fileFormatList] objectAtIndex:row];
		return [record valueForKey:@"downloadURL"];
    }
	return nil;
}

//------------------------------------
// tableViewSelectionDidChange
//------------------------------------
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{

	[viewFileFormat setButtonStatus];

}
//=======================================================================
// drag & drop method
//=======================================================================
//------------------------------------
// validateDrop
//------------------------------------
- (NSDragOperation)tableView:(NSTableView*)tableView 
        validateDrop:(id <NSDraggingInfo>)info 
        proposedRow:(int)row 
        proposedDropOperation:(NSTableViewDropOperation)operation
{
	// Get pboard
	NSPasteboard *pboard;
	pboard = [info draggingPasteboard];
	if (!pboard) {
		return NSDragOperationNone;
	}

	// Check pboard type
	if ([[pboard types] containsObject:ItemlistPboardType]) {
		return NSDragOperationCopy;
	}

	return NSDragOperationNone;

}

//------------------------------------
// acceptDrop
//------------------------------------
- (BOOL)tableView:(NSTableView*)tableView 
        acceptDrop:(id <NSDraggingInfo>)info 
        row:(int)row 
        dropOperation:(NSTableViewDropOperation)operation
{

	// Get pboard
	NSPasteboard *pboard;
	pboard = [info draggingPasteboard];
	if (!pboard) {
		return NO;
	}

	// Check pboard type
	if (![[pboard types] containsObject:ItemlistPboardType]) {
		return NO;
	}

	//
	// from itemlist
	//
	// get array for pasteboard
	NSArray *items = [pboard propertyListForType:ItemlistPboardType];

	// load items
	if([items count] > 0){
		// load items after delay
		SEL sel = NSSelectorFromString(@"loadItems:");
		NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
									items, @"items",
									nil
								];								
		[viewFileFormat performSelector:sel withObject:object afterDelay:0.1];
		return YES;
	}

	return NO;
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
		[NSMenu popUpContextMenu:cmFormatlist withEvent:theEvent forView:self];
		isAction = YES;
	}

	if(isAction == NO){
		[super rightMouseDown:theEvent];
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

	NSArray *objects = [[viewFileFormat fileFormatList] objectsAtIndexes:rowIndexes];
 	NSString *downloadURL = @"";
	// downloadURL
	if([objects count] > 0){
		downloadURL = [[objects objectAtIndex:0] valueForKey:@"downloadURL"];
		[pboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
		[pboard addTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
		[pboard setString:downloadURL forType:NSStringPboardType];
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
}
//------------------------------------
// windowWillClose
//------------------------------------
-(void)windowWillClose:(NSNotification *)notification
{

	// table column state
	[self saveTableColumnState:self key:@"stateTableColumnFormatlist"];

}

//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	[super dealloc];
}
@end
