#import "MenuSelectQueryTimePeriod.h"
#import "ViewMainSearch.h"
#import "UserDefaultsExtension.h"

@implementation MenuSelectQueryTimePeriod

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[super setDelegate:self];
	[self createMenuItem];

	// set button image
	[btnMenu setImage:[self buttonImage:[self defaultIntValue:@"optQueryTimePeriod"]]];


}
//------------------------------------
// changeQueryTimePeriod
//------------------------------------
- (IBAction)changeQueryTimePeriod:(id)sender
{

	int queryTimePeriod = [[sender representedObject] intValue];

	// set button image
	[btnMenu setImage:[self buttonImage:queryTimePeriod]];

	// set default
	[self setDefaultIntValue:queryTimePeriod key:@"optQueryTimePeriod"];

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
		sel = NSSelectorFromString(@"changeQueryTimePeriod:");

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
	int queryTimePeriod;
	int i;

	NSArray *menuItems = [[self itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		queryTimePeriod = [[record representedObject] intValue];

		// set state
		if(queryTimePeriod == [self defaultIntValue:@"optQueryTimePeriod"]){
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
		case TIME_PERIOD_TODAY:
			imageName = @"btn_time_period_today";
			break;
		case TIME_PERIOD_THIS_WEEK:
			imageName = @"btn_time_period_this_week";
			break;
		case TIME_PERIOD_THIS_MONTH:
			imageName = @"btn_time_period_this_month";
			break;
		case TIME_PERIOD_ALL_TIME:
			imageName = @"btn_time_period_all_time";
			break;
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
			[NSString stringWithFormat:@"Today,%d,", TIME_PERIOD_TODAY],
			[NSString stringWithFormat:@"This Week,%d,", TIME_PERIOD_THIS_WEEK],
			[NSString stringWithFormat:@"This Month,%d,", TIME_PERIOD_THIS_MONTH],
			[NSString stringWithFormat:@"All Time,%d,", TIME_PERIOD_ALL_TIME],
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
