#import "MenuItemAlwaysOnTop.h"

@implementation MenuItemAlwaysOnTop

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	[self setMenuAction];
	[self setMenuState];
}
//------------------------------------
// changeTopScreen
//------------------------------------
- (IBAction)changeTopScreen:(id)sender
{
	[playerWindow changeTopScreen:nil];
	[self setMenuState];
}
//------------------------------------
// setMenuAction
//------------------------------------
- (void)setMenuAction
{
	// set action
	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"changeTopScreen:")];

}
//------------------------------------
// setMenuState
//------------------------------------
- (void)setMenuState
{

	if([playerWindow isTopScreen] == YES){
		[self setState:1];
	}else{
		[self setState:0];
	}

}

@end
