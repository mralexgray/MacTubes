#import "MenuItemFeed.h"
#import "GDataYouTubeExtension.h"
#import "ViewPlaylist.h"

@implementation MenuItemFeed

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// createSubMenu
	subMenu_ = [[[NSMenu alloc] initWithTitle:@"FeedMenu"] autorelease];
	[self createSubMenu:subMenu_];

	//set delegate menu
	[subMenu_ setDelegate:self];
}
//------------------------------------
// addFeedlist
//------------------------------------
- (IBAction)addFeedlist:(id)sender
{

	[viewPlaylist addFeedlist:sender];

}
//------------------------------------
// createSubMenu
//------------------------------------
- (void)createSubMenu:(NSMenu*)aMenu
{

	NSArray *cols;
	NSString *title;
	int i;
	int feedType;
	id record;

	// remove menuItem
	NSEnumerator *enumArray = [[aMenu itemArray] objectEnumerator];
	while (record = [enumArray nextObject]) {
		[aMenu removeItem:record];
	}

	NSArray *menuItems = [self menuItems];
	NSMenuItem *menuItem;

	for(i = 0; i < [menuItems count]; i++){

		cols = [[menuItems objectAtIndex:i] componentsSeparatedByString:@","];

		// add item separator
		if([[cols objectAtIndex:0] isEqualToString:@"-"]){
			[aMenu addItem:[NSMenuItem separatorItem]];
			continue;
		}

		feedType = [[cols objectAtIndex:0] intValue];

		// set title
		title = [self getFeedTitle:feedType];
		// set action
		SEL sel;
		sel = NSSelectorFromString(@"addFeedlist:");

		menuItem = [[[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
//		[menuItem setRepresentedObject:[NSNumber numberWithInt:[[cols objectAtIndex:1] intValue]]];
		[menuItem setTag:feedType];

		// set image
		[menuItem setImage:[NSImage imageNamed:@"icon_feed"]];

		[aMenu addItem:menuItem];
	}

	[self setSubmenu:aMenu];
	
	[menuItems release];

}
//------------------------------------
// menuItems
//------------------------------------
- (NSArray*)menuItems
{
	// feedType
	return [[NSArray alloc] initWithObjects: 
/*
			// all feeds
			@"1,",	// Top Rated
			@"2,",	// Top Favorites
			@"3,",	// Most Recent
			@"4,",	// Most Discussed
			@"5,",	// Most Viewed
			@"6,",	// Most Linked
			@"7,",	// Most Responded
			@"8,",	// Most Popular / Rising Videos
			@"9,",	// Recently Featured
//			@"10,",	// Watch On Mobile
*/
			// appears on YouTube site
			@"8,",	// Most Popular / Rising Videos
			@"5,",	// Most Viewed
			@"9,",	// Recently Featured / Spotlight Videos
			@"-,",
			@"4,",	// Most Discussed
			@"3,",	// Most Recent
			@"7,",	// Most Responded
			@"-,",
			@"2,",	// Top Favorites
			@"1,",	// Top Rated
			nil];
}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
/*
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self createSubMenu:menu];
}
*/
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[subMenu_ release];	
    [super dealloc];
}

@end
