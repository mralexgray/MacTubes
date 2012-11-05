#import "MenuItemCountryCode.h"
#import "GDataYouTubeExtension.h"
#import "UserDefaultsExtension.h"

static NSString *defaultKey = @"optCountryCode";

@implementation MenuItemCountryCode

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// createSubMenu
	subMenu_ = [[[NSMenu alloc] initWithTitle:@"Country"] autorelease];
	[self createSubMenu:subMenu_];

	// set button image
	[self setImage:[self getCountryIconImage:[self defaultStringValue:defaultKey]]];

	//set delegate menu
	[subMenu_ setDelegate:self];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKey options:0 context:nil];

}
//------------------------------------
// changeCountryCode
//------------------------------------
- (IBAction)changeCountryCode:(id)sender
{

	// set default
	[self setDefaultStringValue:[sender representedObject] key:defaultKey];

	// set image
	[self setImage:[self getCountryIconImage:[self defaultStringValue:defaultKey]]];

}
//------------------------------------
// createSubMenu
//------------------------------------
- (void)createSubMenu:(NSMenu*)aMenu
{

	NSArray *cols;
	int i;
	id record;
	NSString *countryCode;

	// remove menuItem
	while (record = [[[aMenu itemArray] objectEnumerator] nextObject]) {
		[aMenu removeItem:record];
	}

	NSArray *menuItems = [self countryCodeMenuItems];
	NSMenuItem *menuItem;

	for(i = 0; i < [menuItems count]; i++){

		cols = [[menuItems objectAtIndex:i] componentsSeparatedByString:@","];

		// add item separator
		if([[cols objectAtIndex:1] isEqualToString:@"-"]){
			[aMenu addItem:[NSMenuItem separatorItem]];
			continue;
		}

		countryCode = [cols objectAtIndex:0];

		// set action
		SEL sel;
		sel = NSSelectorFromString(@"changeCountryCode:");

		menuItem = [[[NSMenuItem alloc] initWithTitle:[cols objectAtIndex:1] action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:countryCode];

		// set image
		NSImage *image = [self getCountryIconImage:countryCode];
		[menuItem setImage:image];

		// set state
		if([countryCode isEqualToString:[self defaultStringValue:defaultKey]]){
			[menuItem setState:1];
		}else{
			[menuItem setState:0];
		}

		[aMenu addItem:menuItem];
	}

	[self setSubmenu:aMenu];

	[menuItems release];

}

//------------------------------------
// updateMenuItem
//------------------------------------
- (void)updateMenuItem:(NSMenu*)aMenu
{

	id record;
	NSString *countryCode;
	int i;

	NSArray *menuItems = [[aMenu itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		countryCode = [record representedObject];

		// set state
		if([countryCode isEqualToString:[self defaultStringValue:defaultKey]]){
			[record setState:1];
		}else{
			[record setState:0];
		}
	}

	[menuItems release];
}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:defaultKey]){
		// set image
		[self setImage:[self getCountryIconImage:[self defaultStringValue:defaultKey]]];
	}
}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self updateMenuItem:menu];
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:defaultKey];
	[subMenu_ release];	
	[super dealloc];
}

@end
