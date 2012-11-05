#import "MenuItemFileDownload.h"
#import "UserDefaultsExtension.h"

@implementation MenuItemFileDownload

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set action
	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"nullAction:")];

	// add submenu
	[self changeSubMenu:[self defaultVideoPlayerType]];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleVideoPlayerTypeDidChanged:) name:VIDEO_NOTIF_VIDEO_PLAYER_TYPE_DID_CHANGED object:nil];

}
//------------------------------------
// nullAction
//------------------------------------
- (IBAction)nullAction:(id)sender
{
	// null
}

//------------------------------------
// changeSubMenu
//------------------------------------
- (void)changeSubMenu:(int)playerType
{
	if(playerType == VIDEO_PLAYER_TYPE_SWF){
		[self setSubmenu:menuFileDownload];
	}
	else if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		[self setSubmenu:menuSelectFileDownload];
	}

}
//------------------------------------
// handleVideoPlayerTypeDidChanged
//------------------------------------
- (void)handleVideoPlayerTypeDidChanged:(NSNotification *)notification
{

	int playerType = [[notification object] intValue];

	[self changeSubMenu:playerType];

}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	//	none
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
