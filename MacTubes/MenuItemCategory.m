#import "MenuItemCategory.h"
#import "GDataYouTubeExtension.h"
#import "UserDefaultsExtension.h"
#import "ViewPlaylist.h"

static NSString *defaultKey = @"optDefaultLanguageIsJP";

@implementation MenuItemCategory

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// createSubMenu
	subMenu_ = [[[NSMenu alloc] initWithTitle:@"CategoryMenu"] autorelease];
	[self createSubMenu:subMenu_];

	//set delegate menu
	[subMenu_ setDelegate:self];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKey options:0 context:nil];
}
//------------------------------------
// addCategorylist
//------------------------------------
- (IBAction)addCategorylist:(id)sender
{

	[viewPlaylist addCategorylist:sender];

}
//------------------------------------
// createSubMenu
//------------------------------------
- (void)createSubMenu:(NSMenu*)aMenu
{

	NSArray *cols;
	NSString *title;
	int i;
	NSString *categoryName;
	id record;
	BOOL isLangJP = [self defaultLanguageIsJP];

	// remove menuItem
	NSEnumerator *enumArray = [[aMenu itemArray] objectEnumerator];
	while (record = [enumArray nextObject]) {
		[aMenu removeItem:record];
	}

	NSArray *menuItems = [self categoryNameMenuItems];
	NSMenuItem *menuItem;

	for(i = 0; i < [menuItems count]; i++){

		cols = [[menuItems objectAtIndex:i] componentsSeparatedByString:@","];

		// add item separator
		if([[cols objectAtIndex:0] isEqualToString:@"-"]){
			[aMenu addItem:[NSMenuItem separatorItem]];
			continue;
		}

		categoryName = [cols objectAtIndex:0];
		// set title
		if(isLangJP == YES){
			title = [self getCategoryTitleJP:categoryName];
		}else{
			title = [self getCategoryTitle:categoryName];
		}
		// set action
		SEL sel;
		sel = NSSelectorFromString(@"addCategorylist:");

		menuItem = [[[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:categoryName];

		// set image
		[menuItem setImage:[NSImage imageNamed:@"icon_category"]];

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
	NSString *categoryName;
	NSString *title;
	BOOL isLangJP = [self defaultLanguageIsJP];
	int i;

	NSArray *menuItems = [[aMenu itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		categoryName = [record representedObject];
		// set title
		if(isLangJP == YES){
			title = [self getCategoryTitleJP:categoryName];
		}else{
			title = [self getCategoryTitle:categoryName];
		}
		[record setTitle:title];
	}

	[menuItems release];
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
