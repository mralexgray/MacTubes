#import "ButtonSelectArraylist.h"

@implementation ButtonSelectArraylist

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// delete focus ring
	[self setFocusRingType:NSFocusRingTypeNone];

}
//------------------------------------
// scrollWheel
//------------------------------------
- (void)scrollWheel:(NSEvent *)theEvent
{
	int wheelDelta;

	wheelDelta = [theEvent deltaY];

	if(wheelDelta <= 0){
		[targetArrayController selectNext:nil];
	}else{
		[targetArrayController selectPrevious:nil];
	}
}

@end
