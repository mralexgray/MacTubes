#import "MenuItemPlayRepeat.h"
#import "UserDefaultsExtension.h"

static NSString *defaultKey = @"optPlayRepeat";

@implementation MenuItemPlayRepeat

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	//set delegate menu
	NSMenu *playRepeatMenu = [self submenu];
	[playRepeatMenu setDelegate:self];

	// set menu action
	[self setMenuAction:playRepeatMenu];

	// set action
	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"nullAction:")];

}
//------------------------------------
// changePlayRepeat
//------------------------------------
- (IBAction)changePlayRepeat:(id)sender
{
	int playRepeat = [sender tag];
	[self setDefaultIntValue:playRepeat key:defaultKey];
}
//------------------------------------
// nullAction
//------------------------------------
- (IBAction)nullAction:(id)sender
{
	// null action
}
//------------------------------------
// setMenuAction
//------------------------------------
- (void)setMenuAction:(NSMenu*)aMenu
{

	id record;
	int i;

	SEL sel = NSSelectorFromString(@"changePlayRepeat:");

	NSArray *menuItems = [[aMenu itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];
		[record setTarget:self];
		[record setAction:sel];

	}

	[menuItems release];

}
//------------------------------------
// updateMenuItem
//------------------------------------
- (void)updateMenuItem:(NSMenu*)aMenu
{

	id record;
	int tag;
	int i;

	int playRepeat = [self defaultIntValue:defaultKey];

	NSArray *menuItems = [[aMenu itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		tag = [record tag];

		// set state
		if(tag == playRepeat){
			[record setState:1];
		}else{
			[record setState:0];
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


@end
