#import "ButtonSelectPlayItem.h"

@implementation ButtonSelectPlayItem

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// delete focus ring
	[self setFocusRingType:NSFocusRingTypeNone];

	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"selectPlayItem:")];
	[self setEnabled:NO];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleControlBindArrayDidChanged:) name:CONTROL_NOTIF_PLAY_ARRAY_DID_CHANGED object:nil];

}

//=======================================================================
// IBAction
//=======================================================================
- (IBAction)selectPlayItem:(id)sender
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:CONTROL_NOTIF_PLAY_SELECT_DID_CHANGED
					object:[NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithInt:[self tag]], @"tag",
										[NSNumber numberWithBool:NO], @"isLoop",
										nil
							]
	];

}
//=======================================================================
// methods
//=======================================================================
//------------------------------------
// setBindButtonEnabled
//------------------------------------
- (void)setBindButtonEnabled:(NSArrayController*)arrayController
{
	int tag = [self tag];

	if(arrayController != nil){
		if(tag == CONTROL_SELECT_ITEM_PREVIOUS){
			[self bind:@"enabled" toObject:arrayController withKeyPath:@"canSelectPrevious" options:nil];
		}
		else if(tag == CONTROL_SELECT_ITEM_NEXT){
			[self bind:@"enabled" toObject:arrayController withKeyPath:@"canSelectNext" options:nil];
		}
	}else{
		[self setEnabled:NO];
	}
}

//=======================================================================
// handler
//=======================================================================
//------------------------------------
// handleControlBindArrayDidChanged
//------------------------------------
- (void)handleControlBindArrayDidChanged:(NSNotification *)notification
{

	NSArrayController *arrayController = [notification object];
	[self setBindButtonEnabled:arrayController];

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
