#import "MenuItemPlaylist.h"
#import "ViewMainSearch.h"
#import "TBArrayController.h"

@implementation MenuItemPlaylist

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// createSubMenu
	subMenu_ = [[[NSMenu alloc] initWithTitle:@"PlaylistMenu"] autorelease];
	[self createSubMenu:subMenu_];

	//set delegate menu
	[subMenu_ setDelegate:self];
}


//------------------------------------
// createSubMenu
//------------------------------------
- (void)createSubMenu:(NSMenu*)aMenu
{
	id record;
	NSString *itemName;
	NSImage *iconImage;
	NSManagedObject *parentObject;
	NSManagedObject *childObject;
	NSManagedObject *targetObject;

	// remove menuItem
	NSEnumerator *enumArray = [[aMenu itemArray] objectEnumerator];
	while (record = [enumArray nextObject]) {
		[aMenu removeItem:record];
	}

/*
	// get selected object
	NSArray *selectedArray = [tbArrayController getSelectedObjects:@"itemlist"];
	NSSet *selectedSet = [NSSet setWithArray:[selectedArray valueForKey:@"plistId"]];
*/

	// get playlist
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"isFolder == NO AND itemType == %d", ITEM_PLAYLIST];
	NSArray *fetchArray = [tbArrayController getObjectsWithPred:@"playlist" pred:pred];

	// get parent item
	NSMutableArray *parentArray = [[NSMutableArray alloc] init];
	int i;
	id parentItem = nil;
	for(i = 0; i < [fetchArray count]; i++){
		parentItem = [[fetchArray objectAtIndex:i] valueForKey:@"parent"];
		if(parentItem){
			if(![parentArray containsObject:parentItem]){
				[parentArray addObject:parentItem];
			}
		}else{
			[parentArray addObject:[fetchArray objectAtIndex:i]];
		}
	}

	// sort
	NSSortDescriptor *desc1=[[[NSSortDescriptor alloc] initWithKey:@"isFolder" ascending:NO selector:nil] autorelease];
	NSSortDescriptor *desc2=[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:NSSelectorFromString(@"caseInsensitiveCompare:")] autorelease];
	NSSortDescriptor *desc3=[[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
	NSArray *sortedArray = [parentArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:desc1,desc2,nil]];

	// add item from parent
	NSEnumerator *enumParents = [sortedArray objectEnumerator];
	NSMenuItem *menuItem;
	while (parentObject = [enumParents nextObject]) {

		itemName = [parentObject valueForKey: @"title" ];

		// set action
		SEL sel;
		// playlist
		if([[parentObject valueForKey:@"isFolder"] boolValue] == NO){
			sel = NSSelectorFromString(@"addItemToPlaylist:");
			targetObject = parentObject;
			iconImage = [NSImage imageNamed:@"icon_playlist"];
		}
		// folder
		else{
			sel = nil;
			targetObject = nil;
			iconImage = [NSImage imageNamed:@"icon_folder"];
		}

		menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:viewTarget];
		[menuItem setImage:iconImage];
		[menuItem setRepresentedObject:targetObject];

/*
		// set state
		if([[parentObject valueForKey:@"plistId"] containsObject:[selectedSet anyObject]]){
			[menuItem setState:1];
		}
*/

		[aMenu addItem:menuItem];

		// add item from children
		if([parentObject valueForKey:@"children"]){
			NSArray *childrenArray = [[parentObject valueForKey:@"children"] allObjects];
			childrenArray = [childrenArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc3]];

			NSEnumerator *enumChildren = [childrenArray objectEnumerator];
			while (childObject = [enumChildren nextObject]) {

				// skip folder
				if([[childObject valueForKey:@"isFolder"] boolValue] == YES){
					continue;
				}
				// skip not playlist
				if([[childObject valueForKey:@"itemType"] intValue] != ITEM_PLAYLIST){
					continue;
				}

				itemName = [childObject valueForKey: @"title" ];

				menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:@selector(addItemToPlaylist:) keyEquivalent:@""] autorelease];
				[menuItem setIndentationLevel:1];
				[menuItem setTarget:viewTarget];
				[menuItem setRepresentedObject:childObject];
				[menuItem setImage:[NSImage imageNamed:@"icon_playlist"]];

/*
				// set state
				if([[childObject valueForKey:@"plistId"] containsObject:[selectedSet anyObject]]){
					[menuItem setState:1];
					NSLog(@"selectedSet=%@", [selectedSet description]);
				}
*/
				[aMenu addItem:menuItem];

			}
		}

		// add separator
		[aMenu addItem:[NSMenuItem separatorItem]];
	}

	[self setSubmenu:aMenu];

	[parentArray release];
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
