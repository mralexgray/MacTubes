#import "PlayHistoryTableView.h"
#import "ViewHistory.h"
#import "CellAttributeExtension.h"
#import "ConvertExtension.h"
#import "UserDefaultsExtension.h"

@implementation PlayHistoryTableView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set delegate
	[super setDelegate:self];
	[super setDataSource:self];

	// set click action
	[self setTarget:viewHistory];
	[self setDoubleAction:@selector(playItem:)];

	// set table column state
	[self setTableColumnState:self key:@"stateTableColumnPlayHistory"];

	// set sort descriptor
	[self setArrayControllerSortDescriptor:playhistoryArrayController key:@"sortDescColumnPlayHistory"];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];

	// set registerForDraggedTypes
	[self registerForDraggedTypes:[NSArray arrayWithObjects:ItemlistPboardType, NSStringPboardType, nil]];

	// set drag operation
	[self setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];

}
//------------------------------------
// windowWillClose
//------------------------------------
-(void)windowWillClose:(NSNotification *)notification
{

	// table column state
	[self saveTableColumnState:self key:@"stateTableColumnPlayHistory"];
	// save sort descriptor
	[self saveArrayControllerSortDescriptor:playhistoryArrayController key:@"sortDescColumnPlayHistory"];

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
	// image
	if([[aTableColumn identifier] isEqualToString:@"image"]){
		return [NSImage imageNamed:@"icon_video"];
	}

	return nil;
}

//------------------------------------
// numberOfRowsInTableView
//------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[playhistoryArrayController arrangedObjects] count];
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

	NSArray *objects = [[playhistoryArrayController arrangedObjects] objectsAtIndexes:rowIndexes];
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
//		NSImage *sourceImage = [NSImage imageNamed:@"icon_file_blank"];
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
		[NSMenu popUpContextMenu:cmPlayHistory withEvent:theEvent forView:self];
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
