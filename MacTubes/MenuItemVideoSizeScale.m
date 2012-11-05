#import "MenuItemVideoSizeScale.h"


@implementation MenuItemVideoSizeScale

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// set action
	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"changeVideoSizeScale:")];

}

//------------------------------------
// changeVideoSizeScale
//------------------------------------
- (IBAction)changeVideoSizeScale:(id)sender
{

	int tag = [sender tag];

	float scale = 1.0;
	if(tag == 0){
		scale = 0.5;
	}
	else if(tag == 1){
		scale = 1.0;
	}
	else if(tag == 2){
		scale = 2.0;
	}
	else if(tag == 3){
		scale = 3.0;
	}

	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_SIZE_SCALE_DID_CHANGED object:[NSNumber numberWithFloat:scale]];

}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
    [super dealloc];
}
@end
