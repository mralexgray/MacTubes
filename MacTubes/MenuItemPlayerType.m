#import "MenuItemPlayerType.h"
#import "ViewPlayer.h"
#import "UserDefaultsExtension.h"

static NSString *defaultKey = @"optVideoPlayerType";

@implementation MenuItemPlayerType

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	//set delegate menu
	NSMenu *playerTypeMenu = [self submenu];
	[playerTypeMenu setDelegate:self];

	// set menu action
	[self setMenuAction:playerTypeMenu];

	// set action
	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"nullAction:")];

}
//------------------------------------
// changePlayerType
//------------------------------------
- (IBAction)changePlayerType:(id)sender
{
	int playerType = [sender tag];
	[self setDefaultIntValue:playerType key:defaultKey];

	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_DEFAULT_PLAYER_TYPE_DID_CHANGED object:[NSNumber numberWithInt:playerType]];

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

	SEL sel = NSSelectorFromString(@"changePlayerType:");

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

	int playerType = [self defaultIntValue:defaultKey];

	NSArray *menuItems = [[aMenu itemArray] retain];

	for(i = 0; i < [menuItems count]; i++){

		record = [menuItems objectAtIndex:i];

		tag = [record tag];

		// set state
		if(tag == playerType){
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
