#import "MenuSelectQuerySort.h"
#import "ViewMainSearch.h"
#import "ViewRelatedSearch.h"
#import "UserDefaultsExtension.h"

@implementation MenuSelectQuerySort

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[super setDelegate:self];
	[self createMenuItem];

	// set default key
	if([btnMenu tag] == 0){
		[self setDefaultQuerySortKey:@"optQuerySort"];
	}
	else if([btnMenu tag] == 1){
		[self setDefaultQuerySortKey:@"optQuerySortRelated"];
	}
	else{
		[self setDefaultQuerySortKey:@"optQuerySort"];
	}

	// set button image
	[btnMenu setImage:[self buttonImage:[self defaultIntValue:[self defaultQuerySortKey]]]];


}
//------------------------------------
// changeQuerySort
//------------------------------------
- (IBAction)changeQuerySort:(id)sender
{

	int querySort = [[sender representedObject] intValue];

	// set button image
	[btnMenu setImage:[self buttonImage:querySort]];

	// set default
	[self setDefaultIntValue:querySort key:[self defaultQuerySortKey]];

	// reload
	[viewTargetSearch reloadSearchPage:nil];	// viewMainSearch or viewRelatedSearch

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
		sel = NSSelectorFromString(@"changeQuerySort:");

		menuItem = [[[NSMenuItem alloc] initWithTitle:[cols objectAtIndex:0] action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:[NSNumber numberWithInt:[[cols objectAtIndex:1] intValue]]];

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
	int querySort;
	int i;

	NSArray *menuItems = [[self itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		querySort = [[record representedObject] intValue];

		// set state
		if(querySort == [self defaultIntValue:[self defaultQuerySortKey]]){
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
- (NSImage*)buttonImage:(int)no
{
	NSString *imageName = @"btn_query_relevance";

	switch(no){
		case QUERY_ORDER_RELEVANCE:
			imageName = @"btn_query_relevance";
			break;
		case QUERY_ORDER_PUBLISHED:
			imageName = @"btn_query_published";
			break;
		case QUERY_ORDER_VIEWS:
			imageName = @"btn_query_views";
			break;
		case QUERY_ORDER_RATING:
			imageName = @"btn_query_rating";
			break;
	}
	return [NSImage imageNamed:imageName];
}
//------------------------------------
// menuItems
//------------------------------------
- (NSArray*)menuItems
{
	// title, value, defautkey
	return [[NSArray alloc] initWithObjects: 
			[NSString stringWithFormat:@"Relevance,%d,", QUERY_ORDER_RELEVANCE],
			[NSString stringWithFormat:@"Date Added,%d,", QUERY_ORDER_PUBLISHED],
			[NSString stringWithFormat:@"View Count,%d,", QUERY_ORDER_VIEWS],
			[NSString stringWithFormat:@"Rating,%d,", QUERY_ORDER_RATING],
			nil];
}
//------------------------------------
// defaultQuerySortKey
//------------------------------------
- (void)setDefaultQuerySortKey:(NSString*)defaultQuerySortKey
{
	[defaultQuerySortKey retain];
	[defaultQuerySortKey_ release];
	defaultQuerySortKey_ = defaultQuerySortKey;
}
- (NSString*)defaultQuerySortKey
{
	return defaultQuerySortKey_;
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
	[defaultQuerySortKey_ release];
	[super dealloc];
}


@end
