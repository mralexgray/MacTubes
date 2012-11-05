#import "HeadSplitView.h"

static const float HEAD_MIN_LEFT_WIDTH = 284.0;
static const float HEAD_MIN_RIGHT_WIDTH = 90.0;

@implementation HeadSplitView

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set delegate
	[super setDelegate:self];

}
//------------------------------------
// constrainSplitPosition
//------------------------------------
- (float)splitView:(NSSplitView *)sender constrainSplitPosition:(float)proposedPosition ofSubviewAt:(int)offset
{
    if(proposedPosition < HEAD_MIN_LEFT_WIDTH){
        proposedPosition = HEAD_MIN_LEFT_WIDTH;
	}
    else if(proposedPosition > NSWidth([sender frame]) - HEAD_MIN_RIGHT_WIDTH){
        proposedPosition = NSWidth([sender frame]) - HEAD_MIN_RIGHT_WIDTH;
	}
    return proposedPosition;
}

//------------------------------------
// splitViewDidResizeSubviews
//------------------------------------
-(void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	id subview0 = [[[aNotification object] subviews] objectAtIndex:0];
	id subview1 = [[[aNotification object] subviews] objectAtIndex:1];

	NSRect rect0 = [subview0 frame];
	NSRect rect1 = [subview1 frame];
	if(rect0.size.width < HEAD_MIN_LEFT_WIDTH){
		rect0.size.width = HEAD_MIN_LEFT_WIDTH;
		[subview0 setFrame:rect0];
	}
	if(rect1.size.width < HEAD_MIN_RIGHT_WIDTH){
		rect1.size.width = HEAD_MIN_RIGHT_WIDTH;
		[subview1 setFrame:rect1];
	}
}

@end
