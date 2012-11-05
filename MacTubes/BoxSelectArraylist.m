#import "BoxSelectArraylist.h"

@implementation BoxSelectArraylist

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

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
