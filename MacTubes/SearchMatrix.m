#import "SearchMatrix.h"
#import "SearchMatrixCell.h"
#import "ViewMainSearch.h"
#import "ConvertExtension.h"
#import "UserDefaultsExtension.h"
#import "CellAttributeExtension.h"

static int	CELL_PADDING_WIDTH = 5;
static int	CELL_PADDING_HEIGHT = 10;

static int KEY_ARROW_UP		= 0;
static int KEY_ARROW_DOWN	= 1;
static int KEY_ARROW_LEFT	= 2;
static int KEY_ARROW_RIGHT	= 3;

@implementation SearchMatrix

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// init
	[self setSelectedIndex:0];
	[self setPointedIndex:0];
	isChangedArray_ = NO;
	isMouseDowned_ = NO;
	isPointedCell_ = NO;

	// set cell size
	[self setCellSize:[self calcCellSize:[[self enclosingScrollView] contentSize] cols:[self maxCols]]];
	[self setIntercellSpacing:NSMakeSize(CELL_PADDING_WIDTH,CELL_PADDING_HEIGHT)];

	// set observer
	[searchlistArrayController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];
	[searchlistArrayController addObserver:self forKeyPath:@"selection" options:0 context:nil];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(frameDidResize:) name:NSViewFrameDidChangeNotification object:[self enclosingScrollView]];
	[nc addObserver:self selector:@selector(handleItemObjectChange:) name:VIDEO_ITEM_NOTIF_NAME_FROM_MAIN object:nil];

	// set registerForDraggedTypes
	[self registerForDraggedTypes:[NSArray arrayWithObjects:ItemlistPboardType, NSStringPboardType, nil]];
}
//------------------------------------
// changeMatrix
//------------------------------------
- (IBAction)changeMatrix:(id)sender
{
//	NSLog(@"changeMatrix");

	// pointed index
	if(isPointedCell_ == YES){
		[self setSelectedIndex:[self pointedIndex]];
	}else{
		[self setSelectedIndex:[searchlistArrayController selectionIndex]];
	}

	// force set pointed index
	if(isPointedCell_ == NO){
		[self setPointedIndex:[self selectedIndex]];
	}

	isPointedCell_ = NO;

	// if changed array, create maxtirx
	if(isChangedArray_ == YES){
//		[self clearMatrix];		// not used
		[self createMatrix];
		isChangedArray_ = NO;
	}

	[self updateSelectedCell];
	[self setNeedsDisplay:YES];

}
//------------------------------------
// changeCellSize
//------------------------------------
- (IBAction)changeCellSize:(id)sender
{

	// set cell size
	[self setCellSize:[self calcCellSize:[[self enclosingScrollView] contentSize] cols:[self maxCols]]];

	// retile
	[self retileMatrix];
	[self updateSelectedCell];

}
//------------------------------------
// changeMatrixCols
//------------------------------------
- (IBAction)changeMatrixCols:(id)sender
{

	// set cell size
	[self setCellSize:[self calcCellSize:[[self enclosingScrollView] contentSize] cols:[self maxCols]]];

	// retile
	[self retileMatrix];
	[self updateSelectedCell];

}
//------------------------------------
// selectAll
//------------------------------------
- (IBAction)selectAll:(id)sender
{
	NSMutableIndexSet *selectionIndexes = [NSMutableIndexSet indexSet];
	int count = [[searchlistArrayController arrangedObjects] count];

	[selectionIndexes addIndexesInRange:NSMakeRange(0, count)];
	[searchlistArrayController setSelectionIndexes:selectionIndexes];
}
//------------------------------------
// createMatrix
//------------------------------------
- (void)createMatrix
{

	int i;

	int maxCols = [self maxCols];
	int maxRows = 1;
	int col = 0;
	int row = 0;
	int itemIndex = -1;

	id record;

	// set max rows
	int dataCount = [[searchlistArrayController arrangedObjects] count];

	// null matrix
	if(dataCount <= 0){
		maxCols = 0;
		maxRows = 0;
	}
	// add row
	else if(dataCount > maxCols){
		maxRows = dataCount / maxCols;
		if((dataCount % maxCols) != 0){
			maxRows++;
		}
	}

	// reset matrix cells
	[self renewRows:maxRows columns:maxCols];

	for (i = 0; i < dataCount; i++){

		record = [[searchlistArrayController arrangedObjects] objectAtIndex:i];

		if(col > maxCols - 1){
			row++;
			col = 0;
		}

		// create image cell
		itemIndex++;
		int formatMapNo = [[record valueForKey:@"formatMapNo"] intValue];
		SearchMatrixCell *itemCell = [[SearchMatrixCell alloc] initWithItemObject:record
																	itemIndex:itemIndex
																	isEnabled:YES
																	formatMapNo:formatMapNo
									];

		//
		// tool tip
		//
		if([self defaultBoolValue:@"optShowPopupComment"] == YES){

			NSString *toolChip = @"";

			int itemStatus = [[record valueForKey:@"itemStatus"] intValue];

			if(itemStatus == VIDEO_ENTRY_SUCCESS){

				NSString *playTimeStr = @"-";
				NSString *publishedDate = @"";
				NSString *description = @"";

				// playTime
				if([record valueForKey: @"playTime"]){
					int playTime = [[record valueForKey: @"playTime"] intValue];
					playTimeStr = [self convertTimeToString:playTime];
				}
				// publishedDate
				if([record valueForKey:@"publishedDate"]){
					publishedDate = [[record valueForKey:@"publishedDate"] descriptionWithCalendarFormat:@"%Y/%m/%d - %H:%M" timeZone:nil locale:nil];
				}
				// description
				if([record valueForKey:@"description"]){
					description = [record valueForKey:@"description"];
				}

				toolChip = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",
											[record valueForKey:@"title"],
											[NSString stringWithFormat:@"Date: %@", publishedDate],
											[NSString stringWithFormat:@"Time: %@", playTimeStr],
											description
									];
			}
			else if(itemStatus == VIDEO_ENTRY_INIT){
				toolChip = [NSString stringWithFormat:@"%@\n%@",
											[record valueForKey:@"title"],
											@"Now Searching.."
									];
			}
			else{
				toolChip = [NSString stringWithFormat:@"%@\n%@",
											[record valueForKey:@"title"],
											@"Not Found"
									];
			}

			[self setToolTip:toolChip forCell:itemCell];
		}

		// put cell
		[self putCell:itemCell atRow:row column:col];
		[itemCell release];
		col++;
	}


	// null matrix cell
	for (i = col; i < maxCols; i++){

		// already null cell
		if([(SearchMatrixCell*)[self cellAtRow:row column:i] isEnabled] == NO){
			continue;
		}

		// create null cell
		SearchMatrixCell *itemCell = [[SearchMatrixCell alloc] initWithItemObject:nil
																	itemIndex:-1
																	isEnabled:NO
																	formatMapNo:VIDEO_FORMAT_MAP_NONE
									];
		[self setToolTip:nil forCell:itemCell];
		[self putCell:itemCell atRow:row column:i];
		[itemCell release];
	}

	[self sizeToCells];

}
//------------------------------------
// retileMatrix
//------------------------------------
- (void)retileMatrix
{
	int count = [[searchlistArrayController arrangedObjects] count];
	int cols = [self maxCols];
	int rows = 1;

	// same cols 
	if(cols == [self numberOfColumns]){
		[self sizeToCells];
		[self setNeedsDisplay:YES];
		return;
	}

	if(count > cols){
		rows = count / cols;
		if(count % cols > 0){
			rows++;
		}
	}
	int maxCells = cols * rows;
	[self renewRows:rows columns:cols];

	int restCells = maxCells - count;
//	NSLog(@"cols=%d, rows=%d", cols, rows);
//	NSLog(@"restCells=%d", restCells);

	// null matrix cell
	if(restCells > 0){
		int i;
		int lastRowIndex = rows - 1;
		for (i = cols - restCells; i < cols; i++){
			// create null cell
			SearchMatrixCell *itemCell = [[SearchMatrixCell alloc] initWithItemObject:nil
																		itemIndex:-1
																		isEnabled:NO
																		formatMapNo:VIDEO_FORMAT_MAP_NONE
										];
			[self setToolTip:nil forCell:itemCell];
			[self putCell:itemCell atRow:lastRowIndex column:i];
			[itemCell release];
		}
	}

	[self sizeToCells];
	[self setNeedsDisplay:YES];
}
//------------------------------------
// clearMatrix
//------------------------------------
- (void)clearMatrix
{
	int i;
	// remove matrix cells
	for (i = [self numberOfRows] - 1; i >= 0; i--){
		[self removeRow:i];
	}
}
//------------------------------------
// updateSelectedCell
//------------------------------------
- (void)updateSelectedCell
{

	NSIndexSet *selectionIndexes = [searchlistArrayController selectionIndexes];
	int pointedIndex = [self pointedIndex];
//	NSLog(@"pointedIndex=%d", pointedIndex);

	// select cell
	int col = 0;
	int row = 0;
	int maxCols = [self maxCols];
	int i;
	id record;

	for(i = 0; i < [[self cells] count]; i++){

		record = [[self cells] objectAtIndex:i];

		// null cell
		if([record isEnabled] == NO){
			continue;
		}

		// select
		if([selectionIndexes containsIndex:i]){
			[record setIsSelected:YES];
		}else{
			[record setIsSelected:NO];
		}

		// adjust scroll
		if(i == pointedIndex){
			row = i / maxCols;
			col = i % maxCols;
			[self adjustScrollPosition:NSMakePoint(col, row)];
		}
	}
}
//------------------------------------
// selectMovedCell
//------------------------------------
- (BOOL)selectMovedCell:(int)arrow isShift:(BOOL)isShift isCmd:(BOOL)isCmd
{

	int index = [self pointedIndex];
	int maxCols = [self maxCols];

	// up
	if(arrow == KEY_ARROW_UP){
		index -= maxCols;
	}
	// down
	else if(arrow == KEY_ARROW_DOWN){
		index += maxCols;
	}
	// left
	else if(arrow == KEY_ARROW_LEFT){
		index--;
	}
	// right
	else if(arrow == KEY_ARROW_RIGHT){
		index++;
	}

	// selectIndexCell
	return [self selectIndexCell:index isShift:isShift isCmd:isCmd];

}
//------------------------------------
// selectIndexCell
//------------------------------------
- (BOOL)selectIndexCell:(int)index isShift:(BOOL)isShift isCmd:(BOOL)isCmd
{

	int count = [[searchlistArrayController arrangedObjects] count];
	BOOL isSelect = NO;

	if(index >= 0 && index < count){
		isPointedCell_ = YES;
		[self changeSelectionIndexes:index isShift:isShift isCmd:isCmd];
		isSelect = YES;
	}

	return isSelect;
}
//------------------------------------
// changeSelectionIndexes
//------------------------------------
- (void)changeSelectionIndexes:(int)index
						isShift:(BOOL)isShift
						isCmd:(BOOL)isCmd
{

	[self setPointedIndex:index];

	if(isShift == YES || isCmd == YES){

		// no select
		if(isShift == YES && [[searchlistArrayController selectionIndexes] count] <= 0){
			return;
		}

		NSMutableIndexSet *selectionIndexes = [NSMutableIndexSet indexSet];
		[selectionIndexes addIndexes:[searchlistArrayController selectionIndexes]];

		if(isShift == YES){
			// less
			if(index < [selectionIndexes firstIndex]){
				[selectionIndexes addIndexesInRange:NSMakeRange(index, [selectionIndexes firstIndex]-index)];
			}
			// greater
			else if(index > [selectionIndexes lastIndex]){
				[selectionIndexes addIndexesInRange:NSMakeRange([selectionIndexes lastIndex]+1, index - [selectionIndexes lastIndex])];
			}
			// in selection
			else{
				[selectionIndexes addIndexesInRange:NSMakeRange([selectionIndexes firstIndex]+1, index - [selectionIndexes firstIndex])];
			}
		}
		if(isCmd == YES){
			// remove
			if([selectionIndexes containsIndex:index]){
				[selectionIndexes removeIndex:index];
			}
			// add
			else{
				[selectionIndexes addIndex:index];
			}
		}
//		NSLog(@"selectionIndexes=%@", [selectionIndexes description]);
		[searchlistArrayController setSelectionIndexes:selectionIndexes];
	}
	else{
		[searchlistArrayController setSelectionIndex:index];
	}

}
//------------------------------------
// adjustScrollPosition
//------------------------------------
- (void)adjustScrollPosition:(NSPoint)cellPosition
{

	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];

	NSRect clipRect = [clipView bounds];
//	NSSize cellSize = [self calcCellSize:[scrollView contentSize] cols:[self maxCols]];
	NSSize cellSize = [self cellSize];

	NSPoint cellPoint = NSZeroPoint;
	cellPoint.y = ((cellSize.height + CELL_PADDING_HEIGHT) * cellPosition.y);
//	NSLog(@"cellPoint=%f, clipRect=%f",cellPoint.y, clipRect.origin.y);
	if(cellPoint.y < clipRect.origin.y){
		[clipView scrollToPoint:cellPoint];
		[scrollView reflectScrolledClipView:clipView];
	}
	else if(cellPoint.y + cellSize.height > clipRect.origin.y + clipRect.size.height){	
//		NSLog(@"diff=%f", (cellPoint.y + cellSize.height) - (clipRect.origin.y + clipRect.size.height));
		cellPoint.y = clipRect.origin.y + ((cellPoint.y + cellSize.height) - (clipRect.origin.y + clipRect.size.height));
		[clipView scrollToPoint:cellPoint];
		[scrollView reflectScrolledClipView:clipView];
	}
}

//------------------------------------
// calcCellSize
//------------------------------------
- (NSSize)calcCellSize:(NSSize)frameSize cols:(int)cols
{
	float cellWidth = (frameSize.width - (CELL_PADDING_WIDTH * (cols - 1))) / cols;
	float cellHeight = [self defaultSearchMatrixCellSize];
	return NSMakeSize(cellWidth, cellHeight);
}
//------------------------------------
// handleItemObjectChange
//------------------------------------
-(void)handleItemObjectChange:(NSNotification *)notification
{
	isChangedArray_ = YES;
	[self changeMatrix:nil];
}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	NSLog(@"keyPath=%@", keyPath);
	if([keyPath isEqualToString:@"arrangedObjects"]){
		isChangedArray_ = YES;
//		[self changeMatrix:nil];
	}
	else if([keyPath isEqualToString:@"selection"]){
		[self changeMatrix:nil];
	}
}
//------------------------------------
// setFrame
//------------------------------------
- (void)setFrame:(NSRect)frame
{

	// set cell size
	[self setCellSize:[self calcCellSize:[[self enclosingScrollView] contentSize] cols:[self maxCols]]];
	[self sizeToCells];

//	[super setFrame:frame];

}
/*
//------------------------------------
// viewDidEndLiveResize
//------------------------------------
- (void)viewDidEndLiveResize
{
//	[self setNeedsDisplay:YES];
//	[self changeMatrix];
}
*/
//------------------------------------
// frameDidResize
//------------------------------------
-(void)frameDidResize:(NSNotification *)notification
{
	// retile
	[self retileMatrix];

}
//------------------------------------
// keyDown
//------------------------------------
- (void)keyDown:(NSEvent *)event
{

	BOOL isAction = NO;
	BOOL isShift = NO;
	BOOL isCmd = NO;

	NSString *keys = [event charactersIgnoringModifiers];

	if (keys && [keys length] > 0){

		unichar c = [keys characterAtIndex:0];

		// get modifierFlags
		if([event modifierFlags] & NSShiftKeyMask){
			isShift = YES;
		}
		if([event modifierFlags] & NSCommandKeyMask){
			isCmd = YES;
		}
		
		if(c == NSUpArrowFunctionKey){
			[self selectMovedCell:KEY_ARROW_UP isShift:isShift isCmd:isCmd];
			isAction = YES;
		}
		else if(c == NSDownArrowFunctionKey){
			[self selectMovedCell:KEY_ARROW_DOWN isShift:isShift isCmd:isCmd];
			isAction = YES;
		}
		else if(c == NSLeftArrowFunctionKey){
			[self selectMovedCell:KEY_ARROW_LEFT isShift:isShift isCmd:isCmd];
			isAction = YES;
		}
		else if(c == NSRightArrowFunctionKey){
			[self selectMovedCell:KEY_ARROW_RIGHT isShift:isShift isCmd:isCmd];
			isAction = YES;
		}
	}

	if(isAction == NO){
		[super keyDown:event];
	}

}
//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)event
{

	int row,col;
	isMouseDowned_ = NO;

	// get cell point
	NSPoint mouseDownPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	[self getRow:&row column:&col forPoint:mouseDownPoint];	

	// get clicked cell
	SearchMatrixCell *itemCell = [self cellAtRow:row column:col];

	// enabled cell
	if(itemCell != nil && [itemCell isEnabled] == YES){

		NSIndexSet *selectionIndexes = [searchlistArrayController selectionIndexes];

		int itemIndex = [itemCell itemIndex];
		BOOL isContext = NO;
		BOOL isShift = NO;
		BOOL isCmd = NO;
		BOOL isChange = NO;

		// get modifierFlags
		if([event modifierFlags] & NSShiftKeyMask){
			isShift = YES;
		}
		if([event modifierFlags] & NSCommandKeyMask){
			isCmd = YES;
		}
		if([event type] == NSRightMouseDown ||
			([event modifierFlags] & NSControlKeyMask)){
			isContext = YES;
		}
			
		// show context
		if(isContext == YES){
			// force off
			isShift = NO;
			isCmd = NO;
			// out of selectionIndexes
			if(![selectionIndexes containsIndex:itemIndex]){
				isChange = YES;
				// force extend selection
				if([selectionIndexes count] > 1){
					isCmd = YES;
				}
			}
		}
		// left click
		else{
			if(isShift == YES || isCmd == YES){
				isChange = YES;
			}
		}

		// changeSelectionIndexes
		if(isChange == YES){
			isMouseDowned_ = YES;
			isPointedCell_ = YES;
			[self changeSelectionIndexes:itemIndex
									isShift:isShift
									isCmd:isCmd
			];
		}

		// double clicked
		if([event type] == NSLeftMouseDown){
			if([event clickCount] == 2){
				[viewMainSearch playItem:nil];
			}
		}

		// context menu
		if(isContext ==YES){
			[NSMenu popUpContextMenu:cmSearchlist withEvent:event forView:self];
		}
	
	}

	// get focus
	[[self enclosingScrollView] becomeFirstResponder];

}
//------------------------------------
// mouseUp
//------------------------------------
- (void)mouseUp:(NSEvent *)event
{
	int row,col;

	// get cell point
	NSPoint mouseDownPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	[self getRow:&row column:&col forPoint:mouseDownPoint];	

	// get clicked cell
	SearchMatrixCell *itemCell = [self cellAtRow:row column:col];

	// enabled cell
	if(itemCell != nil && [itemCell isEnabled] == YES){

		int itemIndex = [itemCell itemIndex];
		BOOL isContext = NO;
		BOOL isShift = NO;
		BOOL isCmd = NO;

		// get modifierFlags
		if([event modifierFlags] & NSShiftKeyMask){
			isShift = YES;
		}
		if([event modifierFlags] & NSCommandKeyMask){
			isCmd = YES;
		}
		if([event type] == NSRightMouseDown ||
			([event modifierFlags] & NSControlKeyMask)){
			isContext = YES;
		}

		// mouse up
		if(isMouseDowned_ == NO){
			isPointedCell_ = YES;
			[self changeSelectionIndexes:itemIndex
									isShift:isShift
									isCmd:isCmd
			];
		}
	}

	isMouseDowned_ = NO;
}
//------------------------------------
// rightMouseDown
//------------------------------------
- (void)rightMouseDown:(NSEvent *)event
{
	[self mouseDown:event];

}
//------------------------------------
// mouseDragged
//------------------------------------
- (void)mouseDragged:(NSEvent *)event
{
	[super mouseDragged:event];

	int row,col,i;

	// get cell point
	NSPoint mouseDownPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	[self getRow:&row column:&col forPoint:mouseDownPoint];	

	// get clicked cell
	SearchMatrixCell *itemCell = [self cellAtRow:row column:col];

	// enabled cell
	if(itemCell != nil && [itemCell isEnabled] == YES){

		NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];

		NSMutableArray *objects = [NSMutableArray array];
 		NSMutableArray *items = [NSMutableArray array];
		NSString *videoURL = @"";

		// create source objects array
		NSIndexSet *selectionIndexes = [searchlistArrayController selectionIndexes];
		int itemIndex = [itemCell itemIndex];
		if([selectionIndexes containsIndex:itemIndex]){
			// from selectedObjects
			[objects addObjectsFromArray:[searchlistArrayController selectedObjects]];
		}else{
			// from dragged object
			[objects addObject:[itemCell itemObject]];
		}

		// create paste board objects array
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
//			videoURL = [self convertToFileFormatURL:videoURL fileFormatNo:[self defaultPlayFileFormatNo]];
		}

		[pboard declareTypes:[NSArray arrayWithObjects:ItemlistPboardType, NSStringPboardType, nil] owner:nil];
		[pboard addTypes:[NSArray arrayWithObjects:ItemlistPboardType, NSStringPboardType, nil] owner:nil];
		[pboard setPropertyList:items forType:ItemlistPboardType];        
		if(![videoURL isEqualToString:@""]){     
			[pboard setString:videoURL forType:NSStringPboardType];        
		}

		//
		// drag image
		//

		// create drag image
		NSImage	*dragImage = [[NSImage alloc] init];
		[dragImage setSize:NSMakeSize(65.0, 40.0)];
		NSSize dragImageSize = [dragImage size];

		NSPoint dragPoint; 
		dragPoint.x = mouseDownPoint.x - (dragImageSize.width) / 2;
		dragPoint.y = mouseDownPoint.y + (dragImageSize.height) / 2;

		// create source image
		NSImage *sourceImage = [[[NSImage alloc] initByReferencingFile: [[NSBundle mainBundle] pathForResource:@"icon_video" ofType:@"png"]] autorelease];
		[sourceImage setScalesWhenResized:YES];
		[sourceImage setSize:NSMakeSize(24, 24)];


		// set count label bounds
		NSString *countStr = [NSString stringWithFormat:@"%i", [items count]];
		NSRect imageBounds;
		imageBounds.origin = NSMakePoint(0.0, 0.0);
		imageBounds.size = dragImageSize;

		// draw source image
		NSPoint sourcePoint;
		sourcePoint.x = imageBounds.origin.x + ((imageBounds.size.width - [sourceImage size].width) / 2);
		sourcePoint.y = imageBounds.origin.y + ((imageBounds.size.height - [sourceImage size].height) / 2);
//		[sourceImage dissolveToPoint:NSMakePoint(0,0) fraction: 0.6]; 

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

		[sourceImage dissolveToPoint:sourcePoint fraction:0.8];

		[dragImage unlockFocus]; 

		// draw drag image
		[self dragImage:dragImage
					at:dragPoint 
					offset:NSMakeSize(0,0) 
					event:event 
					pasteboard:pboard 
					source:self 
					slideBack:YES
		]; 
	}

}
//------------------------------------
// draggingSourceOperationMaskForLocal
//------------------------------------
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if(isLocal == YES){
		return	NSDragOperationLink;
	}else{
		return	NSDragOperationLink;
	}
}
//------------------------------------
// acceptsFirstResponder
//------------------------------------
-(BOOL)acceptsFirstResponder
{
	return YES;
}
//------------------------------------
// maxCols
//------------------------------------
- (int)maxCols
{

	int cols;
	float cellWidth = [self defaultSearchMatrixCellSize];
	NSSize contentSize = [[self enclosingScrollView] contentSize];
	cols = (contentSize.width + CELL_PADDING_WIDTH) / (cellWidth + CELL_PADDING_WIDTH);
	if(cols < 1){
		cols = 1;
	}

	return cols;
}

//------------------------------------
// selectedIndex
//------------------------------------
- (void)setSelectedIndex:(int)index
{
	selectedIndex_ = index;
}
- (int)selectedIndex
{
	return selectedIndex_;

}
//------------------------------------
// setPointedIndex
//------------------------------------
- (void)setPointedIndex:(int)index
{
	pointedIndex_ = index;
}
- (int)pointedIndex
{
	return pointedIndex_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{

	[searchlistArrayController removeObserver:self forKeyPath:@"arrangedObjects"];
	[searchlistArrayController removeObserver:self forKeyPath:@"selection"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
