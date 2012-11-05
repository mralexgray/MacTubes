#import "SearchFilterTableView.h"
#import "ViewPrefs.h"

@implementation SearchFilterTableView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// set delegate
	[super setDelegate:self];
	[super setDataSource:self];

	// set double clicked action
	[self setTarget:self];
	[self setAction:@selector(clickItem:)];
	[self setDoubleAction:@selector(doubleClickItem:)];

	// set sort descriptor
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	[searchFilterArrayController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];


}
//=======================================================================
// Event Actions
//=======================================================================
//------------------------------------
// clickItem
//------------------------------------
- (IBAction)clickItem:(id)sender
{
	// disabled
	if([self isEnabled] == NO){
		return;
	}

	int row = [self clickedRow];
	int col = [self clickedColumn];
	if (row >= 0 && col >= 0) {
		id column = [[self tableColumns] objectAtIndex:col];
		if (canRename_) {
			if([column isEditable]){
				[self startTimerWithTimeInterval:0.5 selector:@selector(renameByTimer:) row:row col:col];
			}
		}
		if([[column identifier] isEqualToString:@"enabled"]){
			// save
			[viewPrefs saveSearchFilterList:nil];
		}
	}
}

//------------------------------------
// doubleClickItem
//------------------------------------
- (IBAction)doubleClickItem:(id)sender
{
	// disabled
	if([self isEnabled] == NO){
		return;
	}

	[self enableClickToRenameAfterDelay];

}
/*
//=======================================================================
// bind to tableview column
//=======================================================================
- (id)tableView:(NSTableView *)aTableView
        objectValueForTableColumn:(NSTableColumn *)aTableColumn
        row:(int)rowIndex
{

	if([[viewPrefs searchFilterList] count] <= 0){
		return nil;
	}

	id record = [[viewPrefs searchFilterList] objectAtIndex:rowIndex];

	// keyword
	if([[aTableColumn identifier] isEqualToString:@"keyword"]){
		return [record valueForKey:@"keyword"];
	}
	// enabled
	else if([[aTableColumn identifier] isEqualToString:@"enabled"]){
		return [[record valueForKey:@"enabled"] boolValue];
	}

    return nil;
}
//------------------------------------
// numberOfRowsInTableView
//------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[viewPrefs searchFilterList] count];
}
*/
//------------------------------------
// shouldEditTableColumn
//------------------------------------
-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
	return NO;
}
//------------------------------------
// tableViewSelectionDidChange
//------------------------------------
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self enableClickToRenameAfterDelay];
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
	[self startTimerWithTimeInterval:0.2 selector:@selector(enableClickToRenameByTimer:) row:-1 col:-1];
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
		id dict = [sender userInfo];
		int row = [[dict valueForKey:@"row"] intValue];
		int col = [[dict valueForKey:@"col"] intValue];
		if (row != -1 && col != -1) {
//			NSString *identifier = [[[self tableColumns] objectAtIndex:col] identifier];
			if([[[self tableColumns] objectAtIndex:col] isEditable]){
				[self editColumn:col row:row withEvent:nil select:YES];
			}
		}
	}
}

//------------------------------------
// startTimerWithTimeInterval
//------------------------------------
- (void)startTimerWithTimeInterval:(NSTimeInterval)seconds selector:(SEL)selector row:(int)row col:(int)col
{
	[self stopTimer];

	// timer set
	NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:row], @"row",
							[NSNumber numberWithInt:col], @"col",
							nil
						];
	timer_ = [[NSTimer scheduledTimerWithTimeInterval:seconds
											  target:self
											selector:selector
											userInfo:dict
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

	// save
	[viewPrefs saveSearchFilterList:nil];

}
//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	[self stopTimer];
	[super dealloc];
}
@end
