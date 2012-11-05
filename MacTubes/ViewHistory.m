#import "ViewHistory.h"
#import "ViewPlayer.h"
#import "TBArrayController.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"

@implementation ViewHistory

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// window rect
	[self setWindowRect:historyWindow key:@"rectWindowHistory"];

	// set title
	[historyWindow setTitle:@"Play History"];

	// set key equivalent
	[btnPlay setKeyEquivalent:@" "];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillCloseHistory:) name:NSWindowWillCloseNotification object:historyWindow];
	[nc addObserver:self selector:@selector(handleControlPlayItemDidChanged:) name:CONTROL_NOTIF_PLAY_ITEM_DID_CHANGED object:nil];

}

//=======================================================================
// Event Actions
//=======================================================================
//------------------------------------
// openHistoryWindow Action
//------------------------------------
- (IBAction)openHistoryWindow:(id)sender;
{
	[historyWindow makeKeyAndOrderFront:self];
}
//------------------------------------
// playItem
//------------------------------------
- (IBAction)playItem:(id)sender
{
	// no select
	if([[playhistoryArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[playhistoryArrayController selectedObjects] objectAtIndex:0];
	NSString *itemId = [record valueForKey:@"itemId"]; 

	[viewPlayer setPlayerViewWithItemId:itemId arrayNo:CONTROL_BIND_ARRAY_PLAYHISTORY];

}
//------------------------------------
// addItemToPlaylist
//------------------------------------
- (IBAction)addItemToPlaylist:(id)sender
{

	NSManagedObject *targetItem = [sender representedObject];

	NSArray *objects = [playhistoryArrayController selectedObjects];
 
	// no select
	if([objects count] <= 0){
		return;
	}

	// create array for itemlist
 	NSMutableArray *items = [NSMutableArray array];
	int i;
	for (i = 0; i < [objects count]; i++) {
		NSManagedObject *item = [objects objectAtIndex:i];
		[items addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				[item valueForKey:@"itemId"], @"itemId" ,
				[item valueForKey:@"title"], @"title" ,
				[item valueForKey:@"author"], @"author" ,
				nil
			]
		];
	}

	[tbArrayController createItemlist:[targetItem valueForKey:@"plistId"] items:items];

}
//------------------------------------
// removeItem
//------------------------------------
- (IBAction)removeItem:(id)sender
{
	NSArray *items = [[playhistoryArrayController selectedObjects] valueForKey:@"itemId"];

	// no select
	if([items count] <= 0){
		return;
	}

	int result = [self displayMessage:@"alert"
							messageText:@"Delete selected items from history?"
							infoText:@""
							btnList:@"Delete,Cancel"
				];

	if(result != NSAlertFirstButtonReturn){
		return;
	}

	// remove  itemlist
	[tbArrayController removePlayHistory:items];

}
//------------------------------------
// removeAllItems
//------------------------------------
- (IBAction)removeAllItems:(id)sender
{

	NSArray *items = [[playhistoryArrayController arrangedObjects] valueForKey:@"itemId"];
	// no select
	if([items count] <= 0){
		return;
	}

	int result = [self displayMessage:@"alert"
							messageText:@"Clear all displayed items from history?"
							infoText:@""
							btnList:@"Delete,Cancel"
				];

	if(result != NSAlertFirstButtonReturn){
		return;
	}

	// remove  itemlist
	[tbArrayController removePlayHistory:items];
//	[tbArrayController removeAllObjects:@"playhistory"];
}
//------------------------------------
// handleControlPlayItemDidChanged
//------------------------------------
- (void)handleControlPlayItemDidChanged:(NSNotification *)notification
{
	int arrayNo = [[notification object] intValue];

	if(arrayNo == CONTROL_BIND_ARRAY_PLAYHISTORY){
		[self playItem:nil];
	}

}

//------------------------------------
// windowWillCloseHistory
//------------------------------------
-(void)windowWillCloseHistory:(NSNotification *)notification
{

	// window rect
	[self saveWindowRect:historyWindow key:@"rectWindowHistory"];
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
