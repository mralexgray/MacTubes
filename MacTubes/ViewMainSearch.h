/* ViewMainSearch */

#import <Cocoa/Cocoa.h>
#import "GData/GData.h"
#import "PreviewImageView.h"
#import "SearchTypes.h"
#import "VideoFormatTypes.h"
#import "ContentItem.h"
#import "VideoInfoItem.h"
#import "VideoQueryStatus.h"
#import "ControlTypes.h"
#import "PlayModeTypes.h"

@interface ViewMainSearch : NSObject
{

	IBOutlet id viewRelatedSearch;
	IBOutlet id viewPlayer;
	IBOutlet id viewPlaylist;
	IBOutlet id viewItemInfo;
	IBOutlet id viewFileFormat;
	IBOutlet id tbArrayController;
	IBOutlet id downloadManager;
	IBOutlet id logStatusController;
	IBOutlet NSArrayController *searchlistArrayController;

	IBOutlet NSWindow *mainWindow;
	
	IBOutlet NSSearchField *txtSearchField;
	IBOutlet NSTextField *txtSearchResult;
	IBOutlet NSTabView *tabViewSearchHead;
	IBOutlet NSButton *btnPagePrev;
	IBOutlet NSButton *btnPageNext;
	IBOutlet NSButton *btnPlay;
	IBOutlet NSButton *btnQueryOrder;
	IBOutlet NSButton *btnQueryTimePeriod;
	IBOutlet NSButton *btnPlaylistOrder;
	IBOutlet NSPopUpButton *pbtnFeedName;

	IBOutlet NSButton *btnTabViewSearchTable;
	IBOutlet NSButton *btnTabViewSearchGrid;
	IBOutlet NSTabView *tabViewSearchResult;
	IBOutlet NSTabView *tabViewSearchSlider;

	IBOutlet NSProgressIndicator *indProc;
	IBOutlet PreviewImageView *imgPreview;

	IBOutlet NSSplitView *spvMain;
	IBOutlet NSSplitView *spvNavi;
	IBOutlet NSSplitView *spvHead;
 
	NSMutableArray *itemList_;
 
	NSString *searchString_;
	NSString *searchURL_;
	NSString *feedName_;
	NSString *categoryName_;

	int searchType_;
	NSString *plistId_;

	int startIndex_;
	int totalResults_;

	int fetchIndex_;

}
- (IBAction)searchWithKeyword:(id)sender;
- (IBAction)changeSearchPage:(id)sender;
- (IBAction)moveSearchPage:(id)sender;
- (IBAction)reloadSearchPage:(id)sender;

- (IBAction)playItem:(id)sender;
- (IBAction)downloadItem:(id)sender;
- (IBAction)addItemToPlaylist:(id)sender;
- (IBAction)addItemToSearchlist:(id)sender;

- (IBAction)removeItem:(id)sender;
- (IBAction)removeItemFromPlaylist:(id)sender;
- (IBAction)removeItemFromPlayHistory:(id)sender;

- (IBAction)openItemInfo:(id)sender;
- (IBAction)openVideoFormatItem:(id)sender;
- (IBAction)openWatchWithBrowser:(id)sender;
- (IBAction)openContentWithBrowser:(id)sender;
- (IBAction)openAuthorsProfileWithBrowser:(id)sender;

- (IBAction)searchRelatedItem:(id)sender;
- (IBAction)searchAuthorsItem:(id)sender;
- (IBAction)searchPlayHistoryItem:(id)sender;
- (IBAction)copyItemToPasteboard:(id)sender;

- (IBAction)changePreviewImage:(id)sender;
- (IBAction)changeTabViewSearchResult:(id)sender;

- (void)reloadWithStartIndex:(int)startIndex;
- (void)searchWithString:(NSString*)searchString startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType;
- (void)searchWithURL:(NSString*)url startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType;
- (void)searchWithFeedName:(NSString*)feedName startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType;
- (void)searchWithCategoryName:(NSString*)categoryName startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType;

- (void)searchWithPlaylist:(NSString*)plistId startIndex:(int)startIndex;
- (void)searchWithPlayHistory:(int)startIndex;
- (void)searchWithItems:(NSArray*)items startIndex:(int)startIndex searchType:(int)searchType;

- (void)handleQueryStatusChanged:(int)status;
- (void)handleQueryFeedFetchedError:(NSDictionary*)params;
- (void)handleQueryEntryFetchedError:(NSDictionary*)params;
- (void)handleEntryImageFetchedError:(NSDictionary*)params;

- (void)removeArrayAllObjects:(NSArrayController*)arrayController;
- (void)changeTabViewSearchHeadIndex;
- (void)changePageButtonEnable;
- (void)changeQueryMenuButtonEnable;

- (void)changeTabViewSearchResultIndex;
- (void)changeTabViewSearchSliderIndex;
- (void)changeTabViewSearchButtonEnable;

- (NSDictionary*)getPlaylistSearchParams:(NSString*)sortString;
- (void)removeItemList;

- (void)setSearchString:(NSString*)searchString;
- (NSString*)searchString;
- (void)setSearchURL:(NSString*)searchURL;
- (NSString*)searchURL;
- (void)setFeedName:(NSString*)feedName;
- (NSString*)feedName;
- (void)setCategoryName:(NSString*)categoryName;
- (NSString*)categoryName;

- (void)setSearchType:(int)searchType;
- (int)searchType;
- (void)setPlistId:(NSString*)plistId;
- (NSString*)plistId;

- (void)setStartIndex:(int)startIndex;
- (int)startIndex;
- (void)setTotalResults:(int)totalResults;
- (int)totalResults;
- (void)setFetchIndex:(int)fetchIndex;
- (int)fetchIndex;

- (BOOL)canRemoveItem;

- (BOOL)isKeyMainWindow;
- (BOOL)isSearchWithPlaylist;
- (BOOL)isSearchWithPlayHistory;

@end

@interface ViewMainSearch (Private)

- (void)fetchFeedWithQuery:(GDataQueryYouTube*)query queryParams:(NSDictionary*)queryParams;
- (void)fetchFeedWithEntryURL:(NSString*)urlString queryParams:(NSDictionary*)queryParams;
- (void)fetchEntryImageWithURL:(NSString*)urlString
				index:(int)index
				withVideo:(GDataEntryYouTubeVideo *)video
				queryParams:(NSDictionary*)queryParams
				queryType:(int)queryType;

- (void)fetchFeedErrorWithQuery:(NSMutableDictionary*)params;
- (void)fetchFeedErrorWithEntryURL:(NSMutableDictionary*)params;
- (void)fetchEntryImageErrorWithURL:(NSMutableDictionary*)params;

@end
