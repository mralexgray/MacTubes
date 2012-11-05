#import "MenuItemPlayHistory.h"
#import "ViewPlayer.h"
#import "ViewHistory.h"
#import "TBArrayController.h"

@implementation MenuItemPlayHistory

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// createSubMenu
	subMenu_ = [[[NSMenu alloc] initWithTitle:@"PlayHistoryMenu"] autorelease];
	[self createSubMenu:subMenu_];

	//set delegate menu
	[subMenu_ setDelegate:self];
}

//------------------------------------
// playItem
//------------------------------------
- (IBAction)playItem:(id)sender
{
	NSString *itemId = [sender representedObject]; 

	[viewPlayer setPlayerViewWithItemId:itemId arrayNo:CONTROL_BIND_ARRAY_NONE];

}
//------------------------------------
// showAllItems
//------------------------------------
- (IBAction)showAllItems:(id)sender
{
	[viewHistory openHistoryWindow:nil];
}
//------------------------------------
// removeAllItems
//------------------------------------
- (IBAction)removeAllItems:(id)sender
{
	[tbArrayController removeAllObjects:@"playhistory"];
}

//------------------------------------
// createSubMenu
//------------------------------------
- (void)createSubMenu:(NSMenu*)aMenu
{
	id record;
	NSString *itemId;
	NSString *title;

	// remove menuItem
	NSEnumerator *enumArray = [[aMenu itemArray] objectEnumerator];
	while (record = [enumArray nextObject]) {
		[aMenu removeItem:record];
	}

	// get item
	NSArray *fetchedArray = [tbArrayController getAllObjects:@"playhistory"];

	// Set sort descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playDate" ascending:NO];
	fetchedArray = [fetchedArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];

	int i;
	NSMenuItem *menuItem;
	// create menu item
	for(i = 0; i < [fetchedArray count] && i < 10; i++){

		record = [fetchedArray objectAtIndex:i];

		itemId = [record valueForKey:@"itemId"];
		title = [record valueForKey:@"title"];

		menuItem = [[[NSMenuItem alloc] initWithTitle:title action:@selector(playItem:) keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:itemId];

		[aMenu addItem:menuItem];

	}

	// add separator
	if([fetchedArray count] > 0){
		[aMenu addItem:[NSMenuItem separatorItem]];
	}

	// show all menu
	// clear menu
	menuItem = [[[NSMenuItem alloc] initWithTitle:@"Show All Items" action:@selector(showAllItems:) keyEquivalent:@""] autorelease];
	[menuItem setTarget:self];
	[menuItem setRepresentedObject:nil];
	[aMenu addItem:menuItem];

/*
	// add separator
	[aMenu addItem:[NSMenuItem separatorItem]];

	// clear menu
	menuItem = [[[NSMenuItem alloc] initWithTitle:@"Clear" action:@selector(removeAllItems:) keyEquivalent:@""] autorelease];
	[menuItem setTarget:self];
	[menuItem setRepresentedObject:nil];
	[aMenu addItem:menuItem];
*/

	[self setSubmenu:aMenu];

}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self createSubMenu:menu];
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[subMenu_ release];	
    [super dealloc];
}

@end
