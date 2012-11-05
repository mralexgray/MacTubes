/* MenuSelectPageIndex */

#import <Cocoa/Cocoa.h>

@interface MenuSelectPageIndex : NSMenu
{
	IBOutlet id viewTargetSearch;
}
- (IBAction)changePageIndex:(id)sender;
- (IBAction)nullAction:(id)sender;

- (void)createMenuItem;

@end
