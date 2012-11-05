#import "PlaylistOutlineView.h"
#import "ViewPlaylist.h"
#import "TBArrayController.h"
#import "HelperExtension.h"
#import "ConvertExtension.h"
#import "GDataYouTubeExtension.h"
#import "UserDefaultsExtension.h"
#import "DialogExtension.h"
#import "ImageAndTextCell.h"

@implementation PlaylistOutlineView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set delegate
	[super setDelegate:self];
	[super setDataSource:self];

	// init drag item
	dragItem_ = nil;
	dragParentItem_ = nil;
	selectedItemAtDragging_ = nil;
	isSelectItemAtDragging_ = NO;

	// init single click rename
	canRename_ = NO;
	timer_ = nil;

	restoreLastState_ = NO;

	[self setAutoresizesOutlineColumn:YES];

	// Set table column
	NSTableColumn *tableColumn = [self tableColumnWithIdentifier: @"title"];
	ImageAndTextCell *imageAndTextCell = nil;
	imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable: NO];
	[tableColumn setDataCell:imageAndTextCell];

	// Set double click action
	[self setTarget:self];
	[self setAction:@selector(clickItem:)];
	[self setDoubleAction:@selector(doubleClickItem:)];

	// Set sort descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	[playlistTreeController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];

	// set paste board type
	[self registerForDraggedTypes:[NSArray arrayWithObjects:PlaylistPboardType, ItemlistPboardType, nil]];

	// set observer
	[playlistTreeController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];

}
//=======================================================================
// actions
//=======================================================================
//------------------------------------
// clickItem
//------------------------------------
- (IBAction)clickItem:(id)sender
{
	if (canRename_) {
		int row = [self clickedRow];
		if (row >= 0) {
			[self startTimerWithTimeInterval:0.5 selector:@selector(renameByTimer:)];
		}
	}
}

//------------------------------------
// doubleClickItem
//------------------------------------
- (IBAction)doubleClickItem:(id)sender
{

	// no select
	if([self selectedRow] < 0){
		return;
	}

	NSManagedObject *selectedItem = [[self itemAtRow:[self selectedRow]] observedObject];

	// folder
	if([[selectedItem valueForKey:@"isFolder"] boolValue] == YES){
		id selectedRowItem = [self itemAtRow:[self selectedRow]];
		// expand
		if([self isItemExpanded:selectedRowItem] == NO) {
			[self expandItem:selectedRowItem expandChildren:NO];
		}
		// collapse
		else{
			[self collapseItem:selectedRowItem];
		}
	}
	// playlist
	else{
		[viewPlaylist searchItem:nil];
	}

	[self enableClickToRenameAfterDelay];

}

//=======================================================================
// methods
//=======================================================================
//------------------------------------
// selectedRowObject
//------------------------------------
- (id)selectedRowObject
{
	id object = nil;
	if([self selectedRow] >= 0){
		object = [self itemAtRow:[self selectedRow]];
	}
	return object;
}
//------------------------------------
// selectedObservedObject
//------------------------------------
- (NSManagedObject*)selectedObservedObject
{
	NSManagedObject *object = nil;
	id rowObject = [self selectedRowObject];
	if(rowObject){
		object = [rowObject observedObject];
	}
	return object;
}
//------------------------------------
// observedObject
//------------------------------------
- (NSManagedObject*)observedObject:(id)object
{
	return [object observedObject];
}

//------------------------------------
// selectItem
//------------------------------------
- (void)selectItem:(id)item
{
	int i;
	id rowItem;
	BOOL isSelect = NO;

	for(i = 0; i < [self numberOfRows]; i++){
		rowItem = [[self itemAtRow:i] observedObject];
		if(rowItem == item){
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
			isSelect = YES;
			break;
		}
	}

}
//------------------------------------
// editSelectedItem
//------------------------------------
- (void)editSelectedItem
{
	if([[self selectedRowIndexes] firstIndex] < [self numberOfRows]){
		[self editColumn:[self columnWithIdentifier:[NSString stringWithString:@"title"]] row:[self selectedRow] withEvent:nil select:YES];
	}
}
//------------------------------------
// deselectItem
//------------------------------------
- (void)deselectItem
{
	[self deselectRow:[self selectedRow]];
}

//------------------------------------
// checkParentOfChild
//------------------------------------	  
- (BOOL)checkParentOfChild:(NSManagedObject *)parent child:(NSManagedObject *)child
{
	BOOL ret = NO;

	if(!child){
		return ret;
	}

	if(parent && child){
		if(parent == child){
			ret = YES;
		}
		else{
			id parentItem = [child valueForKey:@"parent"];
			// check parentItem == parent until parentItem == nil 
			while(parentItem){
				if(parentItem == parent){
					ret = YES;
					break;
				}
				parentItem = [parentItem valueForKey:@"parent"];
			}
		}
	}

	return ret;
}

//=======================================================================
// drag & drop datasource
//=======================================================================
//------------------------------------
// numberOfChildrenOfItem
//------------------------------------	  
- ( int )outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:( id )item
{
/*
	if(item == nil){
		return 0;
	}else{
		return [[item mutableSetValueForKey:@"children"] count];
	}
*/
	return 0;
}
//------------------------------------
// isItemExpandable
//------------------------------------	  
- ( BOOL )outlineView:(NSOutlineView *)outlineView isItemExpandable:( id )item
{
	if([[item valueForKey:@"isFolder"] boolValue] == YES){
		return YES;
	}else{
		return NO;
	}
}
//------------------------------------
// ofItem
//------------------------------------	  
- ( id )outlineView:(NSOutlineView *)outlineView child:( int )index ofItem:( id )item
{
	return [item childAtIndex:index];
//	return nil;
}
//------------------------------------
// objectValueForTableColumn
//------------------------------------	  
- ( id )outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:( id )item
{
	NSString *title;
	BOOL isFolder;
	int itemType;
	int itemSubType;
	NSImage *imgIcon;
	int labelColorNo;

	// title
	if([[tableColumn identifier] isEqualToString:@"title"]){
		id columnItem = [item observedObject];
		title = [columnItem valueForKey:@"title"];
		// label color
		if(![[self selectedRowIndexes] containsIndex:[self rowForItem:item]] &&
			[columnItem valueForKey:@"labelColorNo"]){
			labelColorNo = [[columnItem valueForKey: @"labelColorNo"] intValue];
		}else{
			labelColorNo = 0;
		}

		isFolder = [[columnItem valueForKey:@"isFolder"] boolValue];
		itemType = [[columnItem valueForKey:@"itemType"] intValue];
		itemSubType = [[columnItem valueForKey:@"itemSubType"] intValue];
		// folder
		if(isFolder == YES){
			imgIcon = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"icon_folder" ofType:@"png"]] autorelease];
//			imgIcon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode('fldr')];
		}else{
			// playlist
			if(itemType == ITEM_PLAYLIST){
				imgIcon = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"icon_playlist" ofType:@"png"]] autorelease];
			}
			// searchlist
			else if(itemType == ITEM_SEARCH){
				// keyword
				if(itemSubType == ITEM_SEARCH_KEYWORD){
					imgIcon = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"icon_search" ofType:@"png"]] autorelease];
				}
				// author
				else if(itemSubType == ITEM_SEARCH_AUTHOR){
					imgIcon = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"icon_author" ofType:@"png"]] autorelease];
				}
				else{
					imgIcon = nil;
				}
			}
			// feedlist
			else if(itemType == ITEM_FEED){
				imgIcon = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"icon_feed" ofType:@"png"]] autorelease];
			}
			// categorylist
			else if(itemType == ITEM_CATEGORY){
				imgIcon = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"icon_category" ofType:@"png"]] autorelease];
			}
			// none
			else{
				imgIcon = nil;
			}
//			[imgIcon setScalesWhenResized:YES];
//			[imgIcon setSize:NSMakeSize(14,14)];
		}
		[[tableColumn dataCell] setImage:imgIcon];
		[[tableColumn dataCell] setLabelColorNo:labelColorNo];

		return title;
	}

	return nil;
	
}
//------------------------------------
// persistentObjectForItem
//------------------------------------	  
-(id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
	return nil;
}
//------------------------------------
// toolTipForCell
//------------------------------------	  
- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn item:(id)item mouseLocation:(NSPoint)mouseLocation
{
    if ([[tableColumn identifier] isEqualToString:@"title"]) {
		return [NSString stringWithString:[cell stringValue]];
    }
	return nil;
}
//------------------------------------
// outlineViewSelectionDidChange
//------------------------------------	  
-(void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	if([self numberOfSelectedRows] > 0){
		[self scrollRowToVisible:[[self selectedRowIndexes] firstIndex]];
	}
//	NSLog(@"SelectionDidChange");

	[self enableClickToRenameAfterDelay];
}
//------------------------------------
// shouldEditTableColumn
//------------------------------------	  
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return NO;
}

/*
// collapse 
//------------------------------------
// outlineViewItemDidCollapse
//------------------------------------	  
- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	id item = [[notification userInfo] valueForKey:@"NSObject"];
	if(![self isItemExpanded:item]) {
		id columnItem = [item observedObject];
		if([[columnItem valueForKey:@"isExpand"] boolValue] == YES){
			[columnItem setValue:[NSNumber numberWithBool:NO] forKey:@"isExpand"];
//			NSLog( @"collapseItem" );
		}
	}

}
*/
/*
// expand 
//------------------------------------
// outlineViewItemDidExpand
//------------------------------------	  
- (void)outlineViewItemDidExpand:(NSNotification *)notification
{

	id item = [[notification userInfo] valueForKey:@"NSObject"];
	if([self isItemExpanded:item]) {
		id columnItem = [item observedObject];
		if([[columnItem valueForKey:@"isExpand"] boolValue] == NO){
			[columnItem setValue:[NSNumber numberWithBool:YES] forKey:@"isExpand"];
//			NSLog( @"expandItem" );
		}
	}

}
*/
//----------------------
// writeItems
//----------------------
- (BOOL)outlineView:(NSOutlineView *)outlineView 
		 writeItems:(NSArray*)items 
	   toPasteboard:(NSPasteboard*)pboard
{

	// Declare types
	[pboard declareTypes:[NSArray arrayWithObject:PlaylistPboardType] owner:nil];

	// set drag item / parent
	dragItem_ = [[items objectAtIndex:0] observedObject];
	dragParentItem_ = [dragItem_ valueForKey:@"parent"];

	// set selected item
	if([self selectedRow] >= 0){
		selectedItemAtDragging_ = [[self itemAtRow:[self selectedRow]] observedObject];
		isSelectItemAtDragging_ = YES;
	}else{
		selectedItemAtDragging_ = nil;
		isSelectItemAtDragging_ = NO;
	}

	return YES;
}

//----------------------
// validateDrop
//----------------------
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView 
				  validateDrop:(id <NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(int)index
{

	// Get pboard
	NSPasteboard *pboard;
	pboard = [info draggingPasteboard];
	if (!pboard) {
		return NSDragOperationNone;
	}

	// Check pboard type
	if (![[pboard types] containsObject:PlaylistPboardType] &&
		![[pboard types] containsObject:ItemlistPboardType]) {
		return NSDragOperationNone;
	}

	id targetItem = [item observedObject];

	//
	// from playlist
	//
	if ([[pboard types] containsObject:PlaylistPboardType]){
		// drop on (folder only)
		if(index == -1){
			// target item is not a folder
			if([[targetItem valueForKey:@"isFolder"] boolValue] == NO){
				return NSDragOperationNone;
			}
			// target folder is my child
			if([self checkParentOfChild:dragItem_ child:targetItem] == YES){
				return NSDragOperationNone;
			}
			// target folder is my parent folder
			if(dragParentItem_ && targetItem == dragParentItem_){
				return NSDragOperationNone;
			}
		}

		// drag item is folder
		if([[dragItem_ valueForKey:@"isFolder"] boolValue] == YES){
			// target place is my child
			if([self checkParentOfChild:dragItem_ child:targetItem] == YES){
				return NSDragOperationNone;
			}
		}
		return NSDragOperationMove;
	}

	//
	// from itemlist
	//
	if ([[pboard types] containsObject:ItemlistPboardType]){
		// drop on (playlist only)
		if(index == -1){
			// target item is playlist
			if( [[targetItem valueForKey:@"isFolder"] boolValue] == NO &&
				[[targetItem valueForKey:@"itemType"] intValue] == ITEM_PLAYLIST){
				return NSDragOperationCopy;
			}
		}
		return NSDragOperationNone;
	}

	return NSDragOperationNone;

}
//----------------------
// acceptDrop
//----------------------
- (BOOL)outlineView:(NSOutlineView *)outlineView 
		 acceptDrop:(id <NSDraggingInfo>)info 
			   item:(id)item
		 childIndex:(int)index
{

	// Get pboard
	NSPasteboard *pboard;
	pboard = [info draggingPasteboard];
	if (!pboard) {
		return NO;
	}

	// Check pboard type
	if (![[pboard types] containsObject:PlaylistPboardType] &&
		![[pboard types] containsObject:ItemlistPboardType]) {
		return NO;
	}


	//
	// from playlist
	//
	if ([[pboard types] containsObject:PlaylistPboardType]){

		// drop target item
		id targetItem = [item observedObject];
		BOOL maxNum = NO;

		// drop on
		if(index == -1){
			maxNum = YES;
		}
		// drop above
		else{
			maxNum = NO;
		}

		// add item to patent of target item
		[tbArrayController addItemToParent:targetItem item:dragItem_ maxNum:maxNum];

		// drop above -> reset index
		if(index != -1){
			[tbArrayController resetItemIndex:dragItem_ parentItem:dragParentItem_ targetItem:targetItem insIndex:index];
		}

		// drop on
		if(index == -1){
			// targetItem is folder
			if([[targetItem valueForKey:@"isFolder"] boolValue] == YES){
				// expand
				[self expandItem:item expandChildren:NO];
			}
		}

		[playlistTreeController rearrangeObjects];	

		// select drag item
		if(isSelectItemAtDragging_ == YES){
			[self selectItem:selectedItemAtDragging_];
		}

		return YES;

	}

	//
	// from itemlist
	//
	if ([[pboard types] containsObject:ItemlistPboardType]){

		// drop on (playlist only)
		if(index == -1){
			id targetItem = [item observedObject];
			if(targetItem){
				// target item is playlist
				if( [[targetItem valueForKey:@"isFolder"] boolValue] == NO &&
					[[targetItem valueForKey:@"itemType"] intValue] == ITEM_PLAYLIST){

					// get array for pasteboard
					NSArray *items = [pboard propertyListForType:ItemlistPboardType];

					// update items
					if([items count] > 0){
						[tbArrayController createItemlist:[targetItem valueForKey:@"plistId"] items:items];
						return YES;
					}
				}
			}
		}
	}

	return NO;

}

//------------------------------------
// becomeFirstResponder
//------------------------------------
- (BOOL)becomeFirstResponder
{
	BOOL flag = [super becomeFirstResponder];
	if (flag) {
		[self enableClickToRenameAfterDelay];
	}
	return flag;
}

//------------------------------------
// enableClickToRenameAfterDelay
//------------------------------------
- (void)enableClickToRenameAfterDelay
{
	canRename_ = NO;
	[self startTimerWithTimeInterval:0.2 selector:@selector(enableClickToRenameByTimer:)];
}

//------------------------------------
// enableClickToRenameByTimer
//------------------------------------
- (void)enableClickToRenameByTimer:(id)sender
{
	canRename_ = YES;
}

//------------------------------------
// renameByTimer
//------------------------------------
- (void)renameByTimer:(id)sender
{
	if (canRename_) {
		int row = [self selectedRow];
		if (row != -1) {
			[self editColumn:0 row:row withEvent:nil select:YES];
		}
	}
}

//------------------------------------
// startTimerWithTimeInterval
//------------------------------------
- (void)startTimerWithTimeInterval:(NSTimeInterval)seconds selector:(SEL)selector
{
	[self stopTimer];
	timer_ = [[NSTimer scheduledTimerWithTimeInterval:seconds
											  target:self
											selector:selector
											userInfo:nil
											 repeats:NO] retain];
}

//------------------------------------
// stopTimer
//------------------------------------
- (void)stopTimer
{
	if (timer_ != nil) {
		if ([timer_ isValid]) {
			[timer_ invalidate];
		}
		[timer_ release];
	}
}

//------------------------------------
// keyDown
//------------------------------------
- (void)keyDown:(NSEvent *)theEvent
{	 

	// not display
	if([self isDisplay] == NO){
		return;
	}

	BOOL isAction = NO;
	NSString *keys = [theEvent charactersIgnoringModifiers];
	int row = 0;

	if (keys && [keys length] > 0){
		unichar c = [keys characterAtIndex:0];
		if(c == NSUpArrowFunctionKey){
			if([self selectedRow] == -1){
				row = [self numberOfRows] - 1;
			}else{
				row = [self selectedRow] - 1;
			}
			if(row >= 0){
				[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
			}
			isAction = YES;
		}
		else if(c == NSDownArrowFunctionKey){
			if([self selectedRow] == -1){
				row = 0;
			}else{
				row = [self selectedRow] + 1;
			}
			if(row < [self numberOfRows]){
				[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
			}
			isAction = YES;
		}
	}

	if(isAction == NO){
		// return 
		if([theEvent keyCode] == 36){
			// shift
			if([theEvent modifierFlags] & NSShiftKeyMask){
				[viewPlaylist editItem:nil];
				isAction = YES;
			}else{
				[viewPlaylist searchItem:nil];
				isAction = YES;
			}
		}
	}

	if(isAction == NO){
		[super keyDown:theEvent];
	}

}
//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{

	BOOL isAction = NO;

	// with control key
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
	
	int i = [self rowAtPoint:p];
	
	if (i < [self numberOfRows]){
		// single selected
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
		if ([self numberOfSelectedRows] > 0){
			if ([self numberOfSelectedRows] == 1){
			}
			// multiple selected
//			else{
//				[self selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:YES];
//			}
			[NSMenu popUpContextMenu:cmPlaylist withEvent:theEvent forView:self];
		}
	}

}

//--------------------------------------
// isDisplay
//--------------------------------------
- (BOOL)isDisplay
{
	NSSize viewSize = [[self enclosingScrollView] contentSize];
//	NSLog(@"width=%f", viewSize.width);
//	NSLog(@"height=%f", viewSize.height);

	if(viewSize.width > 0 && viewSize.height > 0){
		return YES;
	}else{
		return NO;
	}
}
//------------------------------------
// storeLastState
//------------------------------------
- (void)storeLastState
{

	int i;
	int numberOfRows = [self numberOfRows];
	BOOL isExpand;

	for(i = 0; i < numberOfRows; i++){
		id item = [self itemAtRow:i];
		id columnItem = [item observedObject];
		// folder
		if([[columnItem valueForKey:@"isFolder"] boolValue] == YES){
			isExpand = [[columnItem valueForKey:@"isExpand"] boolValue];
			// expanded
			if([self isItemExpanded:item] && isExpand == NO){
				[columnItem setValue:[NSNumber numberWithBool:YES] forKey:@"isExpand"];
//				NSLog(@"expandItem");
			}
			if(![self isItemExpanded:item] && isExpand == YES){
				[columnItem setValue:[NSNumber numberWithBool:NO] forKey:@"isExpand"];
//				NSLog(@"collapseItem");
			}
		}
	}

	// save last selected index
	int selectedIndex = -1;
	if([self selectedRow] >= 0){
		selectedIndex = [self selectedRow];
	}
	[self setDefaultIntValue:selectedIndex key:@"optLastSelectedIndexForPlaylist"];

}
//------------------------------------
// restoreLastState
//------------------------------------
- (void)restoreLastState
{
	int i;
	int numberOfRows = [self numberOfRows];

	for(i = 0; i < numberOfRows; i++){
		id item = [self itemAtRow:i];
		id columnItem = [item observedObject];
		// folder
		if([[columnItem valueForKey:@"isFolder"] boolValue] == YES){
			// expand
			if([[columnItem valueForKey:@"isExpand"] boolValue] == YES){
				[self expandItem:item expandChildren:NO];
				numberOfRows = [self numberOfRows];
			}
		}

	}

	// select last index
	int selectedIndex = [self defaultIntValue:@"optLastSelectedIndexForPlaylist"];
	if(selectedIndex >= 0){
		[self selectRow:selectedIndex byExtendingSelection:NO];
		// set predicate
		[viewPlaylist searchItem:nil];			
	}

}

//------------------------------------
// textDidEndEditing
//------------------------------------
- (void)textDidEndEditing:(NSNotification *)notification
{ 
	if ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement)
	{
		NSMutableDictionary * newUserInfo;
		NSNotification * newNotification;
		newUserInfo = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]]; 
		[newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];
		newNotification = [NSNotification notificationWithName:[notification name] object:[notification object] userInfo:newUserInfo];
		[super textDidEndEditing:newNotification];
		[[self window] makeFirstResponder:self]; 
	} else {
		[super textDidEndEditing:notification]; 
	}
}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// restoreLastState at start app
	if([keyPath isEqualToString:@"arrangedObjects"]){
		if(restoreLastState_ == NO){
			// reload
			[self restoreLastState];
			restoreLastState_ = YES;
			[playlistTreeController removeObserver:self forKeyPath:@"arrangedObjects"];
		}
	}
}

//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	[playlistTreeController removeObserver:self forKeyPath:@"arrangedObjects"];

	[dragItem_ release];
	[dragParentItem_ release];
	[selectedItemAtDragging_ release];
	[self stopTimer];
	[super dealloc];
}
@end
