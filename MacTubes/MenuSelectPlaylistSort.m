#import "MenuSelectPlaylistSort.h"
#import "ViewMainSearch.h"
#import "UserDefaultsExtension.h"

@implementation MenuSelectPlaylistSort

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[super setDelegate:self];
	[self createMenuItem];

	// set button image
	[btnMenu setImage:[self buttonImage:[self defaultStringValue:@"optPlaylistSortString"]]];


}
//------------------------------------
// changePlaylistSort
//------------------------------------
- (IBAction)changePlaylistSort:(id)sender
{

	NSString *orderString = [sender representedObject];

	// set button image
	[btnMenu setImage:[self buttonImage:orderString]];

	// set default
	[self setDefaultStringValue:orderString key:@"optPlaylistSortString"];

	// reload
	[viewTargetSearch reloadSearchPage:nil];	// viewMainSearch

}
//------------------------------------
// nullAction
//------------------------------------
- (IBAction)nullAction:(id)sender
{
	// nullAction
}
//------------------------------------
// createMenuItem
//------------------------------------
- (void)createMenuItem
{

	NSArray *cols;
	int i;
	id record;

	// remove menuItem
	 while (record = [[[self itemArray] objectEnumerator] nextObject]) {
		[self removeItem:record];
	}

	NSArray *menuItems = [self menuItems];
	NSMenuItem *menuItem;

	for(i = 0; i < [menuItems count]; i++){

		cols = [[menuItems objectAtIndex:i] componentsSeparatedByString:@","];

		// add item separator
		if([[cols objectAtIndex:0] isEqualToString:@"-"]){
			[self addItem:[NSMenuItem separatorItem]];
			continue;
		}

		// set action
		SEL sel;
		sel = NSSelectorFromString(@"changePlaylistSort:");

		menuItem = [[[NSMenuItem alloc] initWithTitle:[cols objectAtIndex:0] action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:[cols objectAtIndex:1]];

		[self addItem:menuItem];
	}

	[menuItems release];

}

//------------------------------------
// updateMenuItem
//------------------------------------
- (void)updateMenuItem
{

	id record;
	NSString *orderString;
	int i;

	NSArray *menuItems = [[self itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		orderString = [record representedObject];

		// set state
		if([orderString isEqualToString:[self defaultStringValue:@"optPlaylistSortString"]]){
			[record setState:1];
		}else{
			[record setState:0];
		}
	}

	[menuItems release];
}

//------------------------------------
// buttonImage
//------------------------------------
- (NSImage*)buttonImage:(NSString*)orderString
{
	NSString *imageName = @"btn_plist_add_dsc";

	if([orderString isEqualToString:PLIST_ORDER_ADD_ASC]){
		imageName = @"btn_plist_add_asc";
	}
	else if([orderString isEqualToString:PLIST_ORDER_ADD_DSC]){
		imageName = @"btn_plist_add_dsc";
	}
	else if([orderString isEqualToString:PLIST_ORDER_TITLE_ASC]){
		imageName = @"btn_plist_title_asc";
	}
	else if([orderString isEqualToString:PLIST_ORDER_TITLE_DSC]){
		imageName = @"btn_plist_title_dsc";
	}

	return [NSImage imageNamed:imageName];
}
//------------------------------------
// menuItems
//------------------------------------
- (NSArray*)menuItems
{
	// title, value,
	return [[NSArray alloc] initWithObjects: 
			[NSString stringWithFormat:@"Added Newly,%@,", PLIST_ORDER_ADD_DSC],
			[NSString stringWithFormat:@"Added Older,%@,", PLIST_ORDER_ADD_ASC],
			[NSString stringWithFormat:@"Title Ascending,%@,", PLIST_ORDER_TITLE_ASC],
			[NSString stringWithFormat:@"Title Descending,%@,", PLIST_ORDER_TITLE_DSC],
			nil];
}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self updateMenuItem];
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[super dealloc];
}


@end
