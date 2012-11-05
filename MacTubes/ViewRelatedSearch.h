/* ViewRelatedSearch */

#import <Cocoa/Cocoa.h>
#import "GData/GData.h"
#import "SearchTypes.h"
#import "VideoFormatTypes.h"
#import "ContentItem.h"
#import "VideoQueryStatus.h"
#import "VideoInfoItem.h"
#import "ControlTypes.h"

@interface ViewRelatedSearch : NSObject
{

	IBOutlet id viewPlayer;
	IBOutlet id viewItemInfo;
	IBOutlet id viewFileFormat;
	IBOutlet id tbArrayController;
	IBOutlet id downloadManager;
	IBOutlet id logStatusController;
	IBOutlet NSArrayController *relatedlistArrayController;

	IBOutlet NSWindow *relatedWindow;
	IBOutlet NSTextField *txtSearchResult;
	IBOutlet NSButton *btnPagePrev;
	IBOutlet NSButton *btnPageNext;
	IBOutlet NSButton *btnPlay;
	IBOutlet NSButton *btnQueryOrder;
	IBOutlet NSProgressIndicator *indProc;

	NSMutableArray *itemList_;

	NSString *searchURL_;

	int searchType_;
	int searchSubType_;
	int startIndex_;
	int totalResults_;
	int fetchIndex_;

}
- (IBAction)openRelatedWindow:(id)sender;
- (IBAction)changeSearchPage:(id)sender;
- (IBAction)moveSearchPage:(id)sender;
- (IBAction)reloadSearchPage:(id)sender;

- (IBAction)playItem:(id)sender;
- (IBAction)downloadItem:(id)sender;
- (IBAction)addItemToPlaylist:(id)sender;

- (IBAction)openItemInfo:(id)sender;
- (IBAction)openVideoFormatItem:(id)sender;
- (IBAction)openWatchWithBrowser:(id)sender;
- (IBAction)openContentWithBrowser:(id)sender;
- (IBAction)openAuthorsProfileWithBrowser:(id)sender;

- (IBAction)searchRelatedItem:(id)sender;
- (IBAction)searchAuthorsItem:(id)sender;
- (IBAction)copyItemToPasteboard:(id)sender;

- (void)reloadWithStartIndex:(int)startIndex;
- (void)searchWithItems:(NSDictionary*)params;

- (void)searchWithURL:(NSString*)url startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType searchSubType:(int)searchSubType;

- (void)handleQueryStatusChanged:(int)status;
- (void)handleQueryFeedFetchedError:(NSDictionary*)params;
- (void)handleEntryImageFetchedError:(NSDictionary*)params;

- (void)removeItemList;
- (void)removeArrayAllObjects:(NSArrayController*)arrayController;
- (void)changePageButtonEnable;
- (void)changeQueryMenuButtonEnable;
- (void)changeWindowTitle:(int)searchType searchSubType:(int)searchSubType;
- (void)setWindowTitle:(NSString*)title;

- (void)setSearchURL:(NSString*)searchURL;
- (NSString*)searchURL;
- (void)setSearchType:(int)searchType;
- (int)searchType;
- (void)setSearchSubType:(int)searchSubType;
- (int)searchSubType;
- (void)setStartIndex:(int)startIndex;
- (int)startIndex;
- (void)setTotalResults:(int)totalResults;
- (int)totalResults;
- (void)setFetchIndex:(int)fetchIndex;
- (int)fetchIndex;

@end

@interface ViewRelatedSearch (Private)

- (void)fetchFeedWithQuery:(GDataQueryYouTube*)query queryParams:(NSDictionary*)queryParams;
- (void)fetchEntryImageWithURL:(NSString*)urlString
				index:(int)index
				withVideo:(GDataEntryYouTubeVideo *)video
				queryParams:(NSDictionary*)queryParams
				queryType:(int)queryType;

- (void)fetchFeedErrorWithQuery:(NSMutableDictionary*)params;
- (void)fetchEntryImageErrorWithURL:(NSMutableDictionary*)params;

@end
