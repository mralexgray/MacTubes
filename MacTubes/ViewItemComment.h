/* ViewItemComment */

#import <Cocoa/Cocoa.h>
#import "GData/GData.h"
#import "VideoQueryStatus.h"

@interface ViewItemComment : NSObject
{

	IBOutlet id viewItemInfo;
	IBOutlet id logStatusController;
	IBOutlet NSArrayController *commentlistArrayController;

	IBOutlet NSTextField *txtSearchResult;
	IBOutlet NSButton *btnReload;
	IBOutlet NSButton *btnPageNext;
	IBOutlet NSButton *btnPagePrev;
	IBOutlet NSProgressIndicator *indProc;

	NSString *itemId_;
	int startIndex_;
	int maxResults_;
	int totalResults_;
	NSTimer *selectTimer_;

	NSMutableArray *commentList_;
}

- (IBAction)searchItemComments:(id)sender;
- (IBAction)searchItemCommentsWithTimer:(id)sender;
- (IBAction)reloadSearchPage:(id)sender;
- (IBAction)changeSearchPage:(id)sender;
- (IBAction)copyCommentToPasteboard:(id)sender;

- (void)reloadWithStartIndex:(int)startIndex;
- (void)searchWithItemId:(NSString*)itemId startIndex:(int)startIndex;
- (void)changePageButtonEnable;
- (void)removeCommentList;

- (void)handleQueryStatusChanged:(int)status;
- (void)handleQueryFeedFetchedError:(NSDictionary*)params;

- (void)setItemId:(NSString*)itemId;
- (NSString*)itemId;
- (void)setStartIndex:(int)startIndex;
- (int)startIndex;
- (void)setMaxResults:(int)maxResults;
- (int)maxResults;
- (void)setTotalResults:(int)totalResults;
- (int)totalResults;
- (void)setSelectTimer:(NSTimer*)selectTimer;
- (void)clearSelectTimer;
- (NSTimer*)selectTimer;

@end

@interface ViewItemComment (Private)

- (void)fetchFeedWithQuery:(GDataQueryYouTube*)query queryParams:(NSDictionary*)queryParams;
- (void)fetchFeedErrorWithQuery:(NSMutableDictionary*)params;

@end