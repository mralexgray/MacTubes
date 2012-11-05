/* CommentlistTableView */

#import <Cocoa/Cocoa.h>

@interface CommentlistTableView : NSTableView
{
	IBOutlet NSArrayController *commentlistArrayController;

	IBOutlet NSMenu *cmCommentlist;
	IBOutlet NSSlider *sliderRowHeight;

}
- (IBAction)changeRowHeight:(id)sender;


@end
