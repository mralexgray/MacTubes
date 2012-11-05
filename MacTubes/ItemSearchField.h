/* ItemSearchField */

#import <Cocoa/Cocoa.h>

@interface ItemSearchField : NSSearchField
{
	IBOutlet NSArrayController *targetArrayController;

	NSString *searchFormat_;
	NSString *searchFormatAll_;
	NSMenu *searchTextMenu_;
}
- (IBAction)searchWithField:(id)sender;
- (IBAction)changeSearchFormat:(id)sender;

- (void)createSearchTextMenu;

- (NSArray*)createSearchTextArray;
- (NSString*)createSearchFormatAll:(NSArray*)searchTextArray;

- (void)clearSearchText;
- (NSString *)getSearchFormat;
- (NSString *)getSearchFormatAll;
- (void)setSearchFormat:(NSString *)newFormat;
- (void)setSearchFormatAll:(NSString *)newFormat;
@end
