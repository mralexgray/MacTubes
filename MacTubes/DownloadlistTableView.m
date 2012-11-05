#import "DownloadlistTableView.h"
#import "DownloadManager.h"
#import "DownloadItem.h"
#import "DownloadDescTextCell.h"
#import "ConvertExtension.h"

@implementation DownloadlistTableView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// set delegate
	[super setDelegate:self];
	[super setDataSource:self];

	// set row height
//	[self setRowHeight:34.0];

	// description column
	NSTableColumn *descColumn = [self tableColumnWithIdentifier:@"description"];
	DownloadDescTextCell *descTextCell = [[[DownloadDescTextCell alloc] init] autorelease];
	[descColumn setDataCell:descTextCell];

	// status button
	NSTableColumn *statusColumn = [self tableColumnWithIdentifier:@"status"];
	NSButtonCell *statusButtonCell = [[[NSButtonCell alloc] init] autorelease];
	// set attribute
	[statusButtonCell setTitle:nil];
	[statusButtonCell setButtonType:NSMomentaryChangeButton];
	[statusButtonCell setBordered:NO];
	[statusButtonCell setImagePosition:NSImageOnly];
	[statusButtonCell setImageDimsWhenDisabled:NO];
	[statusColumn setDataCell:statusButtonCell];

	// search button
	NSTableColumn *searchColumn = [self tableColumnWithIdentifier:@"search"];
	NSButtonCell *searchButtonCell = [[[NSButtonCell alloc] init] autorelease];
	// set attribute
	[searchButtonCell setTitle:nil];
	[searchButtonCell setButtonType:NSMomentaryChangeButton];
	[searchButtonCell setBordered:NO];
	[searchButtonCell setImagePosition:NSImageOnly];
	[searchColumn setDataCell:searchButtonCell];

	// set registerForDraggedTypes
	[self registerForDraggedTypes:[NSArray arrayWithObjects:ItemlistPboardType,nil]];

	// set drag operation
//	[self setDraggingSourceOperationMask:NSDragOperationLink forLocal:YES];

}
//=======================================================================
// Event Actions
//=======================================================================

//=======================================================================
// bind to tableview column
//=======================================================================
- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex
{

	if([[downloadManager downloadList] count] <= 0){
		return nil;
	}

	id record = [[downloadManager downloadList] objectAtIndex:rowIndex];

	DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 

	// fileIcon
	if([[aTableColumn identifier] isEqualToString:@"fileIcon"]){
		return [downloadItem iconImage];
	}
	// description
	else if([[aTableColumn identifier] isEqualToString:@"description"]){
		// get value
		int status = [downloadItem status];
		double receivedLength = (double)[downloadItem receivedLength];
		double totalLength =  (double)[downloadItem totalLength];
		double percent = 0;
		if(totalLength > 0){
			percent = (receivedLength / totalLength) * 100;
		}

		// set string
		NSString *fileName = @"";
//		NSString *fileName = [[downloadItem filePath] lastPathComponent];
		if(status == DOWNLOAD_FAILED){
			fileName = [downloadItem fileName];
		}else{
			fileName = [[downloadItem filePath] lastPathComponent];
		}

		NSString *description = @"";		
		if(status == DOWNLOAD_STARTED || status == DOWNLOAD_COMPLETED){
			// known total length
			if(totalLength > 0){
				description = [NSString stringWithFormat:@"%@ / %@ - %.1f%%"
											, [self convertFileSizeToString:receivedLength]
											, [self convertFileSizeToString:totalLength]
											, percent
							];
			}
			// unknown total length
			else{
				description = [NSString stringWithFormat:@"%@"
											, [self convertFileSizeToString:receivedLength]
							];
			}
		}
		else{
			description = [self convertDownloadStatusToString:status];
		}

		DownloadDescTextCell *descTextCell = [aTableColumn dataCell];
		[descTextCell setStringValue:[NSString stringWithFormat:@"%@\t%@", fileName, description]];
		return descTextCell;
	}
	// status button cell
	else if([[aTableColumn identifier] isEqualToString:@"status"]){

		NSButtonCell *statusButtonCell = [aTableColumn dataCell];

		// set image
		int status = [downloadItem status];
		[statusButtonCell setImage:[self convertDownloadStatusToImage:status]];

		// set action
		if(status <= DOWNLOAD_STARTED){
			[statusButtonCell setTarget:downloadManager];
			[statusButtonCell setAction:@selector(cancelDownloadItem:)];
			[statusButtonCell setEnabled:YES];
		}
		else if(status == DOWNLOAD_CANCELED){
			[statusButtonCell setTarget:downloadManager];
			[statusButtonCell setAction:@selector(restartDownloadItem:)];
			[statusButtonCell setEnabled:YES];
		}
		else{
			[statusButtonCell setTarget:nil];
			[statusButtonCell setAction:nil];
			[statusButtonCell setEnabled:NO];
		}
		return statusButtonCell;
	}
	// search button cell
	else if([[aTableColumn identifier] isEqualToString:@"search"]){
		NSButtonCell *searchButtonCell = [aTableColumn dataCell];
		BOOL isExist = NO;
		if([[NSFileManager defaultManager] fileExistsAtPath:[downloadItem filePath]] == YES){
			isExist = YES;
		}
		[searchButtonCell setImage:[self convertDownloadSearchToImage:isExist]];

		// set action
//		if(status == DOWNLOAD_STARTED || status == DOWNLOAD_COMPLETED){
		if(isExist == YES){
			[searchButtonCell setTarget:downloadManager];
			[searchButtonCell setAction:@selector(searchDownloadItem:)];
			[searchButtonCell setEnabled:YES];
		}else{
			[searchButtonCell setTarget:nil];
			[searchButtonCell setAction:nil];
			[searchButtonCell setEnabled:NO];
		}
		return searchButtonCell;
	}
    return nil;
}
//------------------------------------
// bind to tableview line count
//------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[downloadManager downloadList] count];
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

	// download items
	if([items count] > 0){
//		int fileFormatNo = VIDEO_FORMAT_NO_NORMAL;
		int fileFormatNo = VIDEO_FORMAT_NO_HIGH;
		// with command key -> mp4
//		if([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSCommandKeyMask){
//			fileFormatNo = VIDEO_FORMAT_NO_HIGH;
//		}
		// download items after delay
		SEL sel = NSSelectorFromString(@"downloadItems:");
		NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
									items, @"items",
									[NSNumber numberWithInt:fileFormatNo], @"fileFormatNo",
									nil
								];								
		[downloadManager performSelector:sel withObject:object afterDelay:0.1];
		return YES;
	}

	return NO;
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
		[NSMenu popUpContextMenu:cmDownloadlist withEvent:theEvent forView:self];
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
	[super dealloc];
}
@end
