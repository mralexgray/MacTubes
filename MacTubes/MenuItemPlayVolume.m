#import "MenuItemPlayVolume.h"
#import "UserDefaultsExtension.h"

static NSString *DEFAULT_ACTION = @"changePlayVolume:";
static NSString *defaultKeyName = @"optPlayVolume";

@implementation MenuItemPlayVolume

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set action
	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"nullAction:")];

	// createSubMenu
	subMenu_ = [[[NSMenu alloc] initWithTitle:@"PlayVolumeMenu"] autorelease];
	[self createSubMenu:subMenu_];

	//set delegate menu
	[subMenu_ setDelegate:self];

}

//------------------------------------
// changePlayVolume
//------------------------------------
- (IBAction)changePlayVolume:(id)sender
{
	int tag = [sender tag];

	float volume = [self defaultPlayVolume];

	// mute
	if(tag == 0){
		volume = 0;
	}
	// up
	else if(tag == 1){
		volume += 0.2;
	}
	// down
	else if(tag == 2){
		volume -= 0.2;
	}

	if(volume < 0.0){
		volume = 0.0;
	}
	else if(volume > 1.0){
		volume = 1.0;
	}

	[self setDefaultFloatValue:volume key:defaultKeyName];

}
//------------------------------------
// nullAction
//------------------------------------
- (IBAction)nullAction:(id)sender
{
	// null
}
//------------------------------------
// createSubMenu
//------------------------------------
- (void)createSubMenu:(NSMenu*)aMenu
{

	NSArray *cols;
	NSString *title;
	NSString *keyEquiv;
	int tag;

	int i;
	id record;


	// remove menuItem
	while (record = [[[aMenu itemArray] objectEnumerator] nextObject]) {
		[aMenu removeItem:record];
	}

	NSArray *menuItems = [self menuItems];
	NSMenuItem *menuItem;

	for(i = 0; i < [menuItems count]; i++){

		cols = [[menuItems objectAtIndex:i] componentsSeparatedByString:@","];
		title = [cols objectAtIndex:0];
		tag = [[cols objectAtIndex:1] intValue];
		keyEquiv = [cols objectAtIndex:2];

		// set action
 		SEL sel = NSSelectorFromString(DEFAULT_ACTION);

		menuItem = [[[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:keyEquiv] autorelease];
		[menuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
		[menuItem setTarget:self];
//		[menuItem setRepresentedObject:[NSNumber numberWithInt:fileFormatNo]];
		[menuItem setTag:tag];

		[aMenu addItem:menuItem];

	}

	[self setSubmenu:aMenu];

	[menuItems release];

}

//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	// none
}
//------------------------------------
// menuItems
//------------------------------------
- (NSArray*)menuItems
{
	return [[NSArray alloc] initWithObjects:
				@"Up,1,+",
				@"Down,2,-",
				@"Mute,0,*",
				nil
			];
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
