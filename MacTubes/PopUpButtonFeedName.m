#import "PopUpButtonFeedName.h"
#import "ViewMainSearch.h"
#import "GDataYouTubeExtension.h"
#import "UserDefaultsExtension.h"

static NSString *defaultKey = @"optDefaultLanguageIsJP";

@implementation PopUpButtonFeedName

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// createSubMenu
	subMenu_ = [[[NSMenu alloc] initWithTitle:@"FeedNameMenu"] autorelease];
	[self createSubMenu:subMenu_];

	//set delegate menu
	[subMenu_ setDelegate:self];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKey options:0 context:nil];

}
//------------------------------------
// changeFeedName
//------------------------------------
- (IBAction)changeFeedName:(id)sender
{

	// set default
	[self setDefaultStringValue:[sender representedObject] key:@"optQueryFeedName"];

	// reload search
	[viewMainSearch reloadSearchPage:nil];

}
//------------------------------------
// createSubMenu
//------------------------------------
- (void)createSubMenu:(NSMenu*)aMenu
{

	int i;
	id record;
	NSString *feedName;
	NSString *title;
	BOOL isLangJP = [self defaultLanguageIsJP];

	// remove menuItem
	while (record = [[[aMenu itemArray] objectEnumerator] nextObject]) {
		[aMenu removeItem:record];
	}

	NSArray *menuItems = [self queryFeedNameMenuItems];
	NSMenuItem *menuItem;

	for(i = 0; i < [menuItems count]; i++){

		feedName = [menuItems objectAtIndex:i];

		// add item separator
		if([feedName isEqualToString:@"-"]){
			[aMenu addItem:[NSMenuItem separatorItem]];
			continue;
		}

		// set title
		if(isLangJP == YES){
			title = [self getQueryFeedTitleJP:feedName];
		}else{
			title = [self getQueryFeedTitle:feedName];
		}

		// set action
		SEL sel;
		sel = NSSelectorFromString(@"changeFeedName:");

		menuItem = [[[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:feedName];

		// set state
		if([feedName isEqualToString:[self defaultQueryFeedName]]){
			[menuItem setState:1];
		}else{
			[menuItem setState:0];
		}

		[aMenu addItem:menuItem];
	}

	[self setMenu:aMenu];

	[menuItems release];

}

//------------------------------------
// updateMenuItem
//------------------------------------
- (void)updateMenuItem:(NSMenu*)aMenu
{

	id record;
	NSString *feedName;
	NSString *title;
	BOOL isLangJP = [self defaultLanguageIsJP];
	int i;

	NSArray *menuItems = [[aMenu itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		feedName = [record representedObject];
		// set title
		if(isLangJP == YES){
			title = [self getQueryFeedTitleJP:feedName];
		}else{
			title = [self getQueryFeedTitle:feedName];
		}
		[record setTitle:title];

		// set state
		if([feedName isEqualToString:[self defaultQueryFeedName]]){
			[record setState:1];
		}else{
			[record setState:0];
		}
	}

	[menuItems release];
}
//------------------------------------
// selectMenuItem
//------------------------------------
- (void)selectMenuItem:(NSMenu*)aMenu
{

	id record;
	NSString *feedName;
	int i;

	NSArray *menuItems = [[aMenu itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		feedName = [record representedObject];

		// select item
		if([feedName isEqualToString:[self defaultQueryFeedName]]){
			[self selectItemAtIndex:i];
			break;
		}
	}

	[menuItems release];
}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self updateMenuItem:menu];
}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

	if([keyPath isEqualToString:defaultKey]){
		[self updateMenuItem:subMenu_];
	}
	
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKey];

	[subMenu_ release];	
	[super dealloc];
}

@end
