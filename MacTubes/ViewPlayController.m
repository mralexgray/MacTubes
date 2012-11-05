#import "ViewPlayController.h"
#import "UserDefaultsExtension.h"

@implementation ViewPlayController

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// window rect
//	[self setWindowPosition:controllerWindow key:@"rectWindowController"];

	// set notification
//	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
//	[nc addObserver:self selector:@selector(windowWillCloseController:) name:NSWindowWillCloseNotification object:controllerWindow];

}

//=======================================================================
// Event Actions
//=======================================================================
//------------------------------------
// openControllerWindow
//------------------------------------
- (IBAction)openControllerWindow:(id)sender;
{
	[controllerWindow openWindow:nil];
}
//------------------------------------
// closeControllerWindow
//------------------------------------
- (IBAction)closeControllerWindow:(id)sender
{
	[controllerWindow closeWindow:nil];
}
//=======================================================================
// methods
//=======================================================================
//------------------------------------
// windowWillCloseController
//------------------------------------
-(void)windowWillCloseController:(NSNotification *)notification
{

	// window rect
//	[self saveWindowRect:controllerWindow key:@"rectWindowController"];

}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
//	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

@end
