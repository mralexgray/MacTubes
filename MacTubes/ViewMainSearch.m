#import "ViewMainSearch.h"
#import "ViewRelatedSearch.h"
#import "ViewPlayer.h"
#import "ViewPlaylist.h"
#import "ViewItemInfo.h"
#import "ViewFileFormat.h"
#import "TBArrayController.h"
#import "DownloadManager.h"
#import "LogStatusController.h"
#import "HelperExtension.h"
#import "ConvertExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"
#import "GDataYouTubeExtension.h"

@implementation ViewMainSearch

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// window rect
	[self setWindowRect:mainWindow key:@"rectWindowMain"];
	// split view rect
	[self setSplitViewRect:spvMain key:@"rectSplitViewMain"];
	[self setSplitViewRect:spvNavi key:@"rectSplitViewNavi"];
	[self setSplitViewRect:spvHead key:@"rectSplitViewHead"];

	// alloc itemList and set content
	itemList_ = [[NSMutableArray alloc] init];
	[searchlistArrayController setContent:itemList_];

	// recent searches
	[self setSearchFieldRecentSearches:txtSearchField key:@"arrayRecentSearches"];

	[self setSearchString:@""];
	[self setSearchType:SEARCH_WITH_STRING];
	[self setSearchURL:@""];

	[self setPlistId:@""];
	[self setStartIndex:1];
	[self setTotalResults:0];
	[self setFetchIndex:0];
	
	[self changePageButtonEnable];
	[self changeQueryMenuButtonEnable];
	[self changeTabViewSearchHeadIndex];

	[self changeTabViewSearchButtonEnable];
	[self changeTabViewSearchResultIndex];
	[self changeTabViewSearchSliderIndex];

	// set first responder
	[mainWindow makeFirstResponder:txtSearchField];

	// set key equivalent
	[btnPlay setKeyEquivalent:@" "];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(mainWindowWillClose:) name:NSWindowWillCloseNotification object:mainWindow];
	[nc addObserver:self selector:@selector(handleControlPlayItemDidChanged:) name:CONTROL_NOTIF_PLAY_ITEM_DID_CHANGED object:nil];

	// set observer
	[searchlistArrayController addObserver:self forKeyPath:@"selection" options:0 context:nil];
}
//=======================================================================
// Actions
//=======================================================================
//------------------------------------
// searchWithKeyword
//------------------------------------
- (IBAction)searchWithKeyword:(id)sender
{

	[self searchWithString:[txtSearchField stringValue] startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_STRING];

}
//------------------------------------
// changeSearchPage
//------------------------------------
- (IBAction)changeSearchPage:(id)sender
{
	int tag = [sender tag];

	int startIndex = [self startIndex];
	int totalResults = [self totalResults];
	int maxResults = [self defaultMaxResults];

	// prev
	if(tag == 0){
		if((startIndex - maxResults) > 0){
			startIndex -= maxResults;
		}else{
			startIndex = 1;
		}
	}
	// next
	else{
		if((startIndex + maxResults) <= totalResults){
			startIndex += maxResults;
		}
	}

	// reload
	[self reloadWithStartIndex:startIndex];

}
//------------------------------------
// moveSearchPage
//------------------------------------
- (IBAction)moveSearchPage:(id)sender
{
	int pageIndex = [[sender representedObject] intValue];

	int maxResults = [self defaultMaxResults];
	int startIndex = ((pageIndex - 1) * maxResults) + 1;

	// reload
	[self reloadWithStartIndex:startIndex];
}
//------------------------------------
// reloadSearchPage
//------------------------------------
- (IBAction)reloadSearchPage:(id)sender
{

	[self reloadWithStartIndex:1];

}
//------------------------------------
// playItem
//------------------------------------
- (IBAction)playItem:(id)sender
{
	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"]; 

	[viewPlayer setPlayerView:itemObject arrayNo:CONTROL_BIND_ARRAY_SEARCH];
}

//------------------------------------
// downloadItem
//------------------------------------
- (IBAction)downloadItem:(id)sender
{
	NSArray *array = [searchlistArrayController selectedObjects];
	// no select
	if([array count] <= 0){
		return;
	}
	// over count
	if([array count] > 5){
		[self displayMessage:@"alert"
					messageText:@"Can not start downloading over 5 files at the same time."
					infoText:@"Please download each files."
					btnList:@"Cancel"
		];
		return;
	}

	int i;
	id record;
	NSString *url;
	NSString *title;
	float interval;
	float requestInterval = [self defaultDownloadRequestInterval];
	ContentItem *itemObject;

	// open window
	[downloadManager openDownloadWindow:nil];

	for(i = 0; i < [array count]; i++){
		record = [array objectAtIndex:i];
		itemObject = [record objectForKey:@"itemObject"];

		// create parameter
		if(itemObject){
			title = [itemObject title];
		}else{
			title = [record valueForKey:@"title"];
		}
		// download url
		url = [self convertToDownloadURL:[record valueForKey:@"itemId"]];
		interval = i * requestInterval;
		
		// start download
		[downloadManager startDownloadItem:url
									downloadURL:@""
									fileName:title
									fileFormatNo:[sender tag]
									interval:interval
									isGetURL:YES
		];
	}

}
//------------------------------------
// addItemToPlaylist
//------------------------------------
- (IBAction)addItemToPlaylist:(id)sender
{

	NSManagedObject *targetItem = [sender representedObject];

	NSArray *objects = [searchlistArrayController selectedObjects];
 
	// no select
	if([objects count] <= 0){
		return;
	}

	// create array for itemlist
 	NSMutableArray *items = [NSMutableArray array];
	int i;
	for (i = 0; i < [objects count]; i++) {
		NSManagedObject *item = [objects objectAtIndex:i];
		[items addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				[item valueForKey:@"itemId"], @"itemId" ,
				[item valueForKey:@"title"], @"title" ,
				[item valueForKey:@"author"], @"author" ,
				nil
			]
		];
	}

	[tbArrayController createItemlist:[targetItem valueForKey:@"plistId"] items:items];

}
//------------------------------------
// addItemToSearchlist
//------------------------------------
- (IBAction)addItemToSearchlist:(id)sender
{
	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"]; 

	int itemType = ITEM_SEARCH;
	int itemSubType = ITEM_SEARCH_KEYWORD;
	NSString *title = @"";

	// keyword
	if([sender tag] == 0){
		itemSubType = ITEM_SEARCH_KEYWORD;
		title = [itemObject title];
	}
	// author
	else if([sender tag] == 1){
		itemSubType = ITEM_SEARCH_AUTHOR;
		title = [record objectForKey:@"author"];
	}

	[viewPlaylist addItem:itemType
					itemSubType:itemSubType
					title:title
					keyword:@""
					isFolder:NO
					isSelect:YES
					isEdit:YES
	];

}
//------------------------------------
// removeItem
//------------------------------------
- (IBAction)removeItem:(id)sender
{
	// remove from playlist
	if([self searchType] == SEARCH_WITH_PLAYLIST){
		[self removeItemFromPlaylist:nil];
	}
	// remove from play history
	else if([self searchType] == SEARCH_WITH_PLAYHISTORY){
		[self removeItemFromPlayHistory:nil];
	}
}
//------------------------------------
// removeItemFromPlaylist
//------------------------------------
- (IBAction)removeItemFromPlaylist:(id)sender
{
	NSArray *items = [[searchlistArrayController selectedObjects] valueForKey:@"itemId"];

	// no select
	if([items count] <= 0){
		return;
	}

	// not result from playlist
	if([self isSearchWithPlaylist] == NO){
		return;
	}
	
	// get playllist
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"plistId == %@", [self plistId]];
	NSArray *fetchedArray = [tbArrayController getObjectsWithPred:@"playlist" pred:pred];

	// not result of playllist
	if([fetchedArray count] <= 0){
		[self displayMessage:@"alert"
							messageText:@"Playlist is not found"
							infoText:@""
							btnList:@"Cancel"
		];
		return;
	}

	NSString *title = [[fetchedArray objectAtIndex:0] valueForKey:@"title"];

	int result = [self displayMessage:@"alert"
							messageText:[NSString stringWithFormat:@"Delete item from \"%@\" ?", title]
							infoText:@""
							btnList:@"Delete,Cancel"
				];

	if(result != NSAlertFirstButtonReturn){
		return;
	}

	// remove  itemlist
	[tbArrayController removeItemlistFromPlaylist:[self plistId] items:items];

	// remove searchlist
	[[searchlistArrayController content] removeObjectsInArray:[searchlistArrayController selectedObjects]];
	[searchlistArrayController removeObjects:[searchlistArrayController selectedObjects]];

	// reload searchlist
	[searchlistArrayController rearrangeObjects];

}
//------------------------------------
// removeItemFromPlayHistory
//------------------------------------
- (IBAction)removeItemFromPlayHistory:(id)sender
{
	NSArray *items = [[searchlistArrayController selectedObjects] valueForKey:@"itemId"];

	// no select
	if([items count] <= 0){
		return;
	}

	// not resunt of playllist
	if([self isSearchWithPlayHistory] == NO){
		return;
	}

	int result = [self displayMessage:@"alert"
							messageText:@"Delete item from play history?"
							infoText:@""
							btnList:@"Delete,Cancel"
				];

	if(result != NSAlertFirstButtonReturn){
		return;
	}

	// remove  itemlist
	[tbArrayController removePlayHistory:items];

	// remove searchlist
	[[searchlistArrayController content] removeObjectsInArray:[searchlistArrayController selectedObjects]];
	[searchlistArrayController removeObjects:[searchlistArrayController selectedObjects]];

	// reload searchlist
	[searchlistArrayController rearrangeObjects];

}

//------------------------------------
// openItemInfo
//------------------------------------
- (IBAction)openItemInfo:(id)sender
{
	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	if([viewItemInfo createItemInfo:CONTROL_BIND_ARRAY_SEARCH record:record] == YES){
		[viewItemInfo openInfoWindow:nil];
	}
}
//------------------------------------
// openVideoFormatItem
//------------------------------------
- (IBAction)openVideoFormatItem:(id)sender
{
	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	NSString *itemId = [record valueForKey:@"itemId"];
	NSString *title = [record valueForKey:@"title"];

	[viewFileFormat loadFileFormatList:itemId title:title];

}

//------------------------------------
// openWatchWithBrowser
//------------------------------------
- (IBAction)openWatchWithBrowser:(id)sender
{

	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"];

	// create url
	NSString *url;
	if(itemObject){
		url = [itemObject watchURL];
	}else{
		url = [self convertToWatchURL:[record valueForKey:@"itemId"]];
	}

	// open url
	[self openWatchURL:url];

}
//------------------------------------
// openContentWithBrowser
//------------------------------------
- (IBAction)openContentWithBrowser:(id)sender
{
	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"];

	// create url
	NSString *url;
	if(itemObject){
		url = [itemObject contentURL];
	}else{
		url = [self convertToContentURL:[record valueForKey:@"itemId"]];
	}

	// open url
	[self openContentURL:url];

}
//------------------------------------
// openAuthorsProfileWithBrowser
//------------------------------------
- (IBAction)openAuthorsProfileWithBrowser:(id)sender
{
	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	NSString *author = [record valueForKey:@"author"];

	// open url
	[self openAuthorsProfileURL:author];
}
//------------------------------------
// searchRelatedItem
//------------------------------------
- (IBAction)searchRelatedItem:(id)sender
{

	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"]; 

	NSString *url = @"";  
//	NSString *keyword = @"";  

	if(itemObject){
		url = [itemObject relatedURL];
		// test
//		NSArray *keywords = [[[[itemObject video] mediaGroup] mediaKeywords] keywords];
//		NSLog(@"keywords=%@", [keywords description]);
//		keyword = [keywords componentsJoinedByString:@"+"];
	}else{
		url = [self convertToRelatedURL:[record objectForKey:@"itemId"]];
	}
	// test
//	url = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/videos?related=%@&orderby=%@", [record objectForKey:@"itemId"], orderString];

	if(![url isEqualToString:@""]){
		[viewRelatedSearch openRelatedWindow:nil];
		[viewRelatedSearch searchWithURL:url startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_URL searchSubType:SEARCH_WITH_URL_RELATED];
	}

}
//------------------------------------
// searchAuthorsItem
//------------------------------------
- (IBAction)searchAuthorsItem:(id)sender
{

	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	NSString *author = [record objectForKey:@"author"];

	NSString *url = [self convertToAuthorsUploadURL:author];	

	if(![url isEqualToString:@""]){
		[viewRelatedSearch openRelatedWindow:nil];
		[viewRelatedSearch searchWithURL:url startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_URL searchSubType:SEARCH_WITH_URL_AUTHOR];
	}

}
//------------------------------------
// searchPlayHistoryItem
//------------------------------------
- (IBAction)searchPlayHistoryItem:(id)sender
{

	[mainWindow makeKeyAndOrderFront:self];
	[self searchWithPlayHistory:1];

}
//------------------------------------
// copyItemToPasteboard
//------------------------------------
- (IBAction)copyItemToPasteboard:(id)sender
{
	// no select
	if([[searchlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"]; 

	NSString *string = @"";
	NSString *url;
	NSString *title;
	NSString *author;

	if(itemObject){
		url = [itemObject watchURL];
		title = [itemObject title];
	}else{
		url = [self convertToWatchURL:[record valueForKey:@"itemId"]];
		title = [record valueForKey:@"title"];
	}
	// convert
	url = [self convertToFileFormatURL:url fileFormatNo:[self defaultPlayFileFormatNo]];
	author = [record valueForKey:@"author"];

	// url
	if([sender tag] == 0){
		string = url;
	}
	// title
	else if([sender tag] == 1){
		string = title;
	}
	// author
	else if([sender tag] == 2){
		string = author;
	}

	[self copyStringToPasteboard:string];

}
//------------------------------------
// changePreviewImage
//------------------------------------
- (IBAction)changePreviewImage:(id)sender
{
	NSImage *image = nil;
	BOOL isPlayed = NO;
	int formatMapNo = VIDEO_FORMAT_MAP_NONE;

	if([[searchlistArrayController selectedObjects] count] > 0){
		id record = [[searchlistArrayController selectedObjects] objectAtIndex:0];
		ContentItem *itemObject = [record objectForKey:@"itemObject"]; 
		image = [[itemObject image] copy];
		isPlayed = [[record valueForKey:@"isPlayed"] boolValue];
		formatMapNo = [[record valueForKey:@"formatMapNo"] intValue];
	}

	[imgPreview setImage:image];
	[imgPreview setIsPlayed:isPlayed];
	[imgPreview setFormatMapNo:formatMapNo];
}
//------------------------------------
// changeTabViewSearchResult
//------------------------------------
- (IBAction)changeTabViewSearchResult:(id)sender
{
	int index = [sender tag];
	[self setDefaultIntValue:index key:@"optTabViewSearchIndex"];
	[self changeTabViewSearchResultIndex];
	[self changeTabViewSearchSliderIndex];
	[self changeTabViewSearchButtonEnable];
}

//=======================================================================
// methods
//=======================================================================
//------------------------------------
// reloadWithStartIndex
//------------------------------------
- (void)reloadWithStartIndex:(int)startIndex
{
	if([self searchType] == SEARCH_WITH_STRING){
//		[txtSearchField setStringValue:[self searchString]];
		[self searchWithString:[self searchString] startIndex:startIndex maxResults:[self defaultMaxResults] searchType:[self searchType]];
	}
	else if([self searchType] == SEARCH_WITH_URL){
		[self searchWithURL:[self searchURL] startIndex:startIndex maxResults:[self defaultMaxResults] searchType:[self searchType]];
	}
	else if([self searchType] == SEARCH_WITH_PLAYLIST){
		[self searchWithPlaylist:[self plistId] startIndex:startIndex];
	}
	else if([self searchType] == SEARCH_WITH_PLAYHISTORY){
		[self searchWithPlayHistory:startIndex];
	}
	else if([self searchType] == SEARCH_WITH_FEED){
		[self searchWithFeedName:[self feedName] startIndex:startIndex maxResults:[self defaultMaxResults] searchType:[self searchType]];
	}
	else if([self searchType] == SEARCH_WITH_CATEGORY){
		[self searchWithCategoryName:[self categoryName] startIndex:startIndex maxResults:[self defaultMaxResults] searchType:[self searchType]];
	}
}
//------------------------------------
// searchWithString
//------------------------------------
- (void)searchWithString:(NSString*)searchString startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType
{

	if ((searchString != nil) && ([searchString length] > 0))
	{

		[self setSearchString:searchString];
		[self setSearchType:searchType];
		[self changeQueryMenuButtonEnable];
		[self changeTabViewSearchHeadIndex];
		[self setFetchIndex:0];

		NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:nil];
		GDataQueryYouTube *query = [GDataQueryYouTube youTubeQueryWithFeedURL:feedURL];

		// append filer keywords
		searchString = [self appendToSearchFilterKeywords:searchString];

		// for v1
//		[query setVideoQuery:searchString];
		// for v2
		[query setFullTextQueryString:searchString];
		[query setStartIndex:startIndex];
		[query setMaxResults:maxResults];

		// set query order
		query = [self setYouTubeQueryOrder:query queryOrder:[self defaultIntValue:@"optQuerySort"]];

		// safeSearch (for API V2)
		query = [self setYouTubeQuerySafeSearch:query safeSearchNo:[self defaultIntValue:@"optSafeSearchNo"]];

		// set time period / not enabled
//		query = [self setYouTubeQueryTimePeriod:query queryTimePeriod:[self defaultIntValue:@"optQueryTimePeriod"]];

//		NSLog(@"Query URL=%@", [query URL]);

		// query feed
		[self fetchFeedWithQuery:query queryParams:nil];

	}

}


//------------------------------------
// searchWithURL 
//------------------------------------
- (void)searchWithURL:(NSString*)url startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType
{

	if ((url != nil) && ([url length] > 0))
	{
 
		[self setSearchURL:url];
		[self setSearchType:searchType];
		[self changeQueryMenuButtonEnable];
		[self changeTabViewSearchHeadIndex];
		[self setFetchIndex:0];

		//decode
		url = [self decodeToPercentEscapesString:url];

		NSURL *feedURL = [NSURL URLWithString:url];
		GDataQueryYouTube *query = [GDataQueryYouTube youTubeQueryWithFeedURL:feedURL];

		// set filer keywords
//		NSString *searchString = [self appendToSearchFilterKeywords:@""];
//		if(![searchString isEqualToString:@""]){
//			// for v1
//			[query setVideoQuery:searchString];
//			// for v2
//			[query setFullTextQueryString:searchString];
//		}

		[query setStartIndex:startIndex];
		[query setMaxResults:maxResults];

		// set query order
		query = [self setYouTubeQueryOrder:query queryOrder:[self defaultIntValue:@"optQuerySort"]];

		// safeSearch (for API V2)
		query = [self setYouTubeQuerySafeSearch:query safeSearchNo:[self defaultIntValue:@"optSafeSearchNo"]];

//		NSLog(@"Query URL=%@", [query URL]);

		// query feed
		[self fetchFeedWithQuery:query queryParams:nil];

	}

}
//------------------------------------
// searchWithFeedName 
//------------------------------------
- (void)searchWithFeedName:(NSString*)feedName startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType
{

	if ((feedName != nil) && ([feedName length] > 0)){

		[self setFeedName:feedName];
		[self setSearchType:searchType];
		[self changeQueryMenuButtonEnable];
		[self changeTabViewSearchHeadIndex];
		[self setFetchIndex:0];

		NSString *feedString = feedName;

		// append country code
		if(![[self defaultStringValue:@"optCountryCode"] isEqualToString:@""]){
			feedString = [NSString stringWithFormat:@"%@/%@", [self defaultStringValue:@"optCountryCode"], feedString];
		}

		NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:feedString];

		GDataQueryYouTube *query = [GDataQueryYouTube youTubeQueryWithFeedURL:feedURL];
		[query setStartIndex:startIndex];
		[query setMaxResults:maxResults];

		// set query order
		query = [self setYouTubeQueryOrder:query queryOrder:[self defaultIntValue:@"optQuerySort"]];

		// safeSearch (for API V2)
		query = [self setYouTubeQuerySafeSearch:query safeSearchNo:[self defaultIntValue:@"optSafeSearchNo"]];

		// set time period
		if([self isEnabledFeedTime:feedName] == YES){
			query = [self setYouTubeQueryTimePeriod:query queryTimePeriod:[self defaultIntValue:@"optQueryTimePeriod"]];
		}

		// set restriction
//		if(![[self defaultStringValue:@"optCountryCode"] isEqualToString:@""]){
//			[query setRestriction:[self defaultStringValue:@"optCountryCode"]];
//		}

//		NSLog(@"Query URL=%@", [query URL]);

		// query feed
		[self fetchFeedWithQuery:query queryParams:nil];

	}
}
//------------------------------------
// searchWithCategoryName 
//------------------------------------
- (void)searchWithCategoryName:(NSString*)categoryName startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType
{

//	if ((categoryName != nil) && ([categoryName length] > 0)){

		[self setCategoryName:categoryName];
		[self setSearchType:searchType];
		[self changeQueryMenuButtonEnable];
		[self changeTabViewSearchHeadIndex];
		[self setFetchIndex:0];

		NSString *feedName = [self defaultQueryFeedName];
		NSString *feedString = feedName;

		// append category name
		if(![categoryName isEqualToString:@""]){
			feedString = [NSString stringWithFormat:@"%@_%@", feedString, categoryName];
		}

		// append country code
		if(![[self defaultStringValue:@"optCountryCode"] isEqualToString:@""]){
			feedString = [NSString stringWithFormat:@"%@/%@", [self defaultStringValue:@"optCountryCode"], feedString];
		}

		NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:feedString];

		GDataQueryYouTube *query = [GDataQueryYouTube youTubeQueryWithFeedURL:feedURL];
		[query setStartIndex:startIndex];
		[query setMaxResults:maxResults];

		// set query order
//		query = [self setYouTubeQueryOrder:query queryOrder:[self defaultIntValue:@"optQuerySort"]];

		// safeSearch (for API V2)
		query = [self setYouTubeQuerySafeSearch:query safeSearchNo:[self defaultIntValue:@"optSafeSearchNo"]];

		// set time period
		if([self isEnabledFeedTime:feedName] == YES){
			query = [self setYouTubeQueryTimePeriod:query queryTimePeriod:[self defaultIntValue:@"optQueryTimePeriod"]];
		}

		// set restriction
//		if(![[self defaultStringValue:@"optCountryCode"] isEqualToString:@""]){
//			[query setRestriction:[self defaultStringValue:@"optCountryCode"]];
//		}

//		NSLog(@"Query URL=%@", [query URL]);

		// query feed
		[self fetchFeedWithQuery:query queryParams:nil];

//	}
}
//------------------------------------
// searchWithPlaylist
//------------------------------------
- (void)searchWithPlaylist:(NSString*)plistId startIndex:(int)startIndex
{
	// get item
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"plistId == %@", plistId];
	NSArray *items = [tbArrayController getObjectsWithPred:@"itemlist" pred:pred];

	// Set sort descriptors
	NSString *sortString = [self defaultStringValue:@"optPlaylistSortString"];
	NSDictionary *params = [self getPlaylistSearchParams:sortString];
	NSString *key = [params objectForKey:@"key"];
	BOOL isAsc = [[params objectForKey:@"isAsc"] boolValue];
	BOOL isStr = [[params objectForKey:@"isStr"] boolValue];
//	NSLog(@"key=%@ isAsc=%d isStr=%d", key, isAsc, isStr);

	if([key isEqualToString:@""]){
		key = @"index";
	}

	NSSortDescriptor *sortDescriptor = nil;
	if(isStr == YES){
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:isAsc selector:@selector(caseInsensitiveCompare:)];
	}else{
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:isAsc];
	}
	NSArray *sortedItems = [items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];

/*
	// Set sort descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortedItems = [items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
*/

	// search
	[self setPlistId:plistId];
	[self searchWithItems:sortedItems startIndex:startIndex searchType:SEARCH_WITH_PLAYLIST];

}
//------------------------------------
// searchWithPlayHistory
//------------------------------------
- (void)searchWithPlayHistory:(int)startIndex
{
	// get item
	NSArray *items = [tbArrayController getAllObjects:@"playhistory"];

	// Set sort descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO];
	NSArray *sortedItems = [items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];

	// search
	[self searchWithItems:sortedItems startIndex:startIndex searchType:SEARCH_WITH_PLAYHISTORY];

}
//------------------------------------
// searchWithItems
//------------------------------------
- (void)searchWithItems:(NSArray*)items startIndex:(int)startIndex searchType:(int)searchType
{
	int i;

	// remove all objects
	[self removeItemList];

	int index = startIndex - 1;

	int maxResults = [self defaultMaxResults];
	int totalResults = [items count];
	int lastIndex = startIndex + maxResults - 1;
	if(lastIndex > totalResults){
		lastIndex = totalResults;
	}

	[self setSearchType:searchType];
	[self setStartIndex:startIndex];
	[self setTotalResults:[items count]];
	[self setFetchIndex:0];
	[self changePageButtonEnable];

	[self changeQueryMenuButtonEnable];
	[self changeTabViewSearchHeadIndex];

	// create searchString from itemId
	// search with searchString
	NSString *itemId;
	NSString *title;
	NSString *author;
	NSString *url;
	id record;

	for (i = startIndex - 1; i < lastIndex; i++){

		if(i < 0 || i > [items count] - 1){
			continue;
		}

		index++;
		record = [items objectAtIndex:i];

		itemId = [record valueForKey:@"itemId"];
		title = [record valueForKey:@"title"];
		author = [record valueForKey:@"author"];

		// add itemlist before search
		[itemList_ addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:index], @"rowNumber" ,
				itemId, @"itemId" ,
				title, @"title" ,
				author, @"author" ,
				@"", @"description" ,
				[NSNumber numberWithInt:0], @"playTime" ,
				[NSNumber numberWithInt:0], @"viewCount" ,
				[NSNumber numberWithInt:0], @"rating" ,
				[NSNumber numberWithInt:VIDEO_ENTRY_INIT], @"itemStatus" ,
				[NSNumber numberWithBool:NO], @"isPlayed" ,
				[NSNumber numberWithInt:VIDEO_FORMAT_MAP_NONE], @"formatMapNo" ,
				nil
			]
		];

/*
		// query entry
		url = [self decodeToPercentEscapesString:[self convertToEntryURL:itemId]];
		[self fetchFeedWithEntryURL:url queryParams:nil];
*/
	}

	// reload
	[searchlistArrayController rearrangeObjects];

	// search entry
	for (i = 0; i < [itemList_ count]; i++){

		record = [itemList_ objectAtIndex:i];

		itemId = [record valueForKey:@"itemId"];

		// create params
		NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithCapacity:1];
		[queryParams setValue:itemId forKey:@"itemId"];

		// query entry
		url = [self decodeToPercentEscapesString:[self convertToEntryURL:itemId]];
		[self fetchFeedWithEntryURL:url queryParams:queryParams];

	}

	// result string
	NSString *resultString = [self convertToResultString:startIndex lastIndex:lastIndex totalResults:totalResults];
	[txtSearchResult setStringValue:resultString];

}
//------------------------------------
// changeTabViewSearchHeadIndex
//------------------------------------
- (void)changeTabViewSearchHeadIndex
{
	int index = -1;
	int searchType = [self searchType];

	if( searchType == SEARCH_WITH_STRING ||
		searchType == SEARCH_WITH_URL ||
		searchType == SEARCH_WITH_FEED ||
		searchType == SEARCH_WITH_CATEGORY
	){
		index = 0;
	}
	else if(searchType == SEARCH_WITH_PLAYLIST){
		index = 1;
	}

	if(index >= 0){
		[tabViewSearchHead selectTabViewItemAtIndex:index];
	}

}
//------------------------------------
// changePageButtonEnable
//------------------------------------
- (void)changePageButtonEnable
{

	int startIndex = [self startIndex];
	int totalResults = [self totalResults];
	int maxResults = [self defaultMaxResults];

	// page button
/*
	if( [self searchType] == SEARCH_WITH_PLAYLIST ||
		[self searchType] == SEARCH_WITH_PLAYHISTORY ||
		[self searchType] == SEARCH_WITH_ITEMS
		){
		[btnPagePrev setEnabled:NO];
		[btnPageNext setEnabled:NO];
	}
	else{
*/		// prev
		if(startIndex > 1){
			[btnPagePrev setEnabled:YES];
		}else{
			[btnPagePrev setEnabled:NO];
		}
		// next
		if(startIndex + maxResults <= totalResults){
			[btnPageNext setEnabled:YES];
		}else{
			[btnPageNext setEnabled:NO];
		}
//	}

}
//------------------------------------
// changeQueryMenuButtonEnable
//------------------------------------
- (void)changeQueryMenuButtonEnable
{

	int searchType = [self searchType];

	// query order button
	if( searchType == SEARCH_WITH_STRING ||
		searchType == SEARCH_WITH_URL ||
		searchType == SEARCH_WITH_FEED
	){
		[btnQueryOrder setEnabled:YES];
		[btnPlaylistOrder setEnabled:NO];
		[pbtnFeedName setEnabled:NO];
		[pbtnFeedName setHidden:YES];
	}
	else if(searchType == SEARCH_WITH_CATEGORY){
		[btnQueryOrder setEnabled:NO];
		[btnPlaylistOrder setEnabled:NO];
		[pbtnFeedName setEnabled:YES];
		[pbtnFeedName setHidden:NO];
	}
	else if(searchType == SEARCH_WITH_PLAYLIST){
		[btnQueryOrder setEnabled:NO];
		[btnPlaylistOrder setEnabled:YES];
		[pbtnFeedName setEnabled:NO];
		[pbtnFeedName setHidden:YES];
	}
	else{
		[btnQueryOrder setEnabled:NO];
		[btnPlaylistOrder setEnabled:NO];
		[pbtnFeedName setEnabled:NO];
		[pbtnFeedName setHidden:YES];
	}

	// time period button
	if( (searchType == SEARCH_WITH_FEED && [self isEnabledFeedTime:[self feedName]] == YES) ||
		(searchType == SEARCH_WITH_CATEGORY && [self isEnabledFeedTime:[self defaultQueryFeedName]] == YES)
		){
		[btnQueryTimePeriod setEnabled:YES];
	}else{
		[btnQueryTimePeriod setEnabled:NO];
	}

}
//------------------------------------
// changeTabViewSearchResultIndex
//------------------------------------
- (void)changeTabViewSearchResultIndex
{
	int index = [self defaultIntValue:@"optTabViewSearchIndex"];

	[tabViewSearchResult selectTabViewItemAtIndex:index];

}
//------------------------------------
// changeTabViewSearchSliderIndex
//------------------------------------
- (void)changeTabViewSearchSliderIndex
{
	int index = [self defaultIntValue:@"optTabViewSearchIndex"];

	[tabViewSearchSlider selectTabViewItemAtIndex:index];

}
//------------------------------------
// changeTabViewSearchButtonEnable
//------------------------------------
- (void)changeTabViewSearchButtonEnable
{

	int index = [self defaultIntValue:@"optTabViewSearchIndex"];

	NSString *btnTableName = @"btn_search_table_off";
	NSString *btnGrigName = @"btn_search_grid_off";
	BOOL tableEnabled = NO;
	BOOL gridEnabled = NO;

	if(index == 0){
		gridEnabled = YES;
		btnTableName = @"btn_search_table_on";
	}
	else if(index == 1){
		tableEnabled = YES;
		btnGrigName = @"btn_search_grid_on";
	}

	[btnTabViewSearchTable setImage:[NSImage imageNamed:btnTableName]];
	[btnTabViewSearchGrid setImage:[NSImage imageNamed:btnGrigName]];

//	[btnTabViewSearchTable setEnabled:tableEnabled];
//	[btnTabViewSearchGrid setEnabled:gridEnabled];

}

//------------------------------------
// getPlaylistSearchParams
//------------------------------------
- (NSDictionary*)getPlaylistSearchParams:(NSString*)sortString
{
	NSString *key = @"";
	NSString *sort = @"at";
	NSString *order = @"d";

	BOOL isAsc = YES;
	BOOL isStr = NO;

	// separate sortString
	if(![sortString isEqualToString:@""]){
		NSArray *vars = [sortString componentsSeparatedByString:@"_"];
		sort = [vars objectAtIndex:0];
		if([vars count] > 1){
			order = [vars objectAtIndex:1];
		}
	}

//	NSLog(@"sort=%@ order=%@", sort, order);

	// sort
	if([sort isEqualToString:@"at"]){
		key = @"index";
	}
	else if([sort isEqualToString:@"tt"]){
		key = @"title";
		isStr = YES;
	}

	// order
	if([order isEqualToString:@"a"]){
		isAsc = YES;
	}
	else if([order isEqualToString:@"d"]){
		isAsc = NO;
	}

	return [NSDictionary dictionaryWithObjectsAndKeys:
				key, @"key" ,
				[NSNumber numberWithBool:isAsc], @"isAsc" ,
				[NSNumber numberWithBool:isStr], @"isStr" ,
				nil
			];

}
//------------------------------------
// removeItemList 
//------------------------------------
- (void)removeItemList
{

	int i;
	// cancel all connection
	for(i = 0; i < [itemList_ count]; i++){
		id record = [itemList_ objectAtIndex:i];
		VideoInfoItem *videoInfoItem = [record valueForKey:@"videoInfoItem"];
		if(videoInfoItem){
			[videoInfoItem cancelRequestTimer];
			[videoInfoItem cancelConnection];
		}
	}

	[itemList_ removeAllObjects];

	// reload
	[searchlistArrayController rearrangeObjects];

}
//------------------------------------
// removeArrayAllObjects 
//------------------------------------
- (void)removeArrayAllObjects:(NSArrayController*)arrayController
{

	// Remove All objects
	// use removeObjectsAtArrangedObjectIndexes?
	[[arrayController content] removeAllObjects];
	[arrayController removeObjects:[arrayController arrangedObjects]];

}

//------------------------------------
// handleQueryStatusChanged
//------------------------------------
- (void)handleQueryStatusChanged:(int)status
{
	if(status == VIDEO_QUERY_INIT){
		[indProc startAnimation:nil];
	}
	else{
		[indProc stopAnimation:nil];
	}
}
//------------------------------------
// handleQueryFeedFetchedError
//------------------------------------
- (void)handleQueryFeedFetchedError:(NSDictionary*)params
{

//	NSLog(@"handleQueryFeedFetchedError");

	if(params == nil){
		return;
	}

	int status = [[params valueForKey:@"itemStatus"] intValue];
	NSString* errorDescription = [params valueForKey:@"errorDescription"];

	// not success
	if(status != VIDEO_QUERY_SUCCESS){
		[logStatusController setLogString:[NSString stringWithFormat:@"Error %@\n", errorDescription]];

		int result = [self displayMessage:@"alert"
								messageText:@"Can not fetch feed."
								infoText:@"Please check error log"
								btnList:@"Cancel,Log"
					];

		// show error log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Error Log"];
			[logStatusController openLogWindow:nil];
		}else{
			[logStatusController setTitle:@""];
			[logStatusController setLogString:@""];
		}
		return;
	}

}
//------------------------------------
// handleQueryEntryFetchedError
//------------------------------------
- (void)handleQueryEntryFetchedError:(NSDictionary*)params
{

//	NSLog(@"handleQueryEntryFetchedError");

/*
	if(params == nil){
		return;
	}

	int status = [[params valueForKey:@"itemStatus"] intValue];
	NSString* errorDescription = [params valueForKey:@"errorDescription"];

	// not success
	if(status != VIDEO_QUERY_SUCCESS){
		[logStatusController setLogString:[NSString stringWithFormat:@"Error %@\n", errorDescription]];

		int result = [self displayMessage:@"alert"
								messageText:@"Can not fetch entry."
								infoText:@"Please check error log"
								btnList:@"Cancel,Log"
					];

		// show error log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Error Log"];
			[logStatusController openLogWindow:nil];
		}else{
			[logStatusController setTitle:@""];
			[logStatusController setLogString:@""];
		}
		return;
	}
*/

}
//------------------------------------
// handleEntryImageFetchedError
//------------------------------------
- (void)handleEntryImageFetchedError:(NSDictionary*)params
{

//	NSLog(@"handleEntryImageFetchedError");

/*
	if(params == nil){
		return;
	}

	int status = [[params valueForKey:@"itemStatus"] intValue];
	NSString* errorDescription = [params valueForKey:@"errorDescription"];

	// not success
	if(status != VIDEO_ENTRY_SUCCESS){
		[logStatusController setLogString:[NSString stringWithFormat:@"Error %@\n", errorDescription]];

		int result = [self displayMessage:@"alert"
								messageText:@"Can not fetch entry."
								infoText:@"Please check error log"
								btnList:@"Cancel,Log"
					];

		// show error log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Error Log"];
			[logStatusController openLogWindow:nil];
		}else{
			[logStatusController setTitle:@""];
			[logStatusController setLogString:@""];
		}
		return;
	}
*/

}
//------------------------------------
// handleItemObjectChange
//------------------------------------
- (void)handleItemObjectChange:(NSNotification *)notification
{

//	NSLog(@"handleItemObjectChange search");
	VideoInfoItem *videoInfoItem = [notification object];

	if(videoInfoItem == nil){
		return;
	}

	if(![videoInfoItem itemId]){
//		NSLog(@"itemId is invalid");
		return;
	}

	NSString *itemId = [videoInfoItem itemId];
	int itemStatus = [videoInfoItem itemStatus];
	int formatMapNo = [videoInfoItem formatMapNo];

	// not success
	if(itemStatus != VIDEO_ITEM_SUCCESS){
		return;
	}

	// none
	if(formatMapNo == VIDEO_FORMAT_MAP_NONE){
		return;
	}

	// fetch itemList_ with itemid
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];
	NSArray *fetchedArray = [itemList_ filteredArrayUsingPredicate:pred];
//	NSLog(@"pred=%@", [pred description]);

	// if exists, set value
	if([fetchedArray count] > 0){

		id record = [fetchedArray objectAtIndex:0];
		[record setValue:[NSNumber numberWithInt:formatMapNo] forKey:@"formatMapNo"];

		NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:VIDEO_ITEM_NOTIF_NAME_FROM_MAIN object:notification];
	}

	// reload
//	[searchlistArrayController rearrangeObjects];


}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// change review image
	if([keyPath isEqualToString:@"selection"]){
		[self changePreviewImage:nil];
	}
}
//------------------------------------
// handleControlPlayItemDidChanged
//------------------------------------
- (void)handleControlPlayItemDidChanged:(NSNotification *)notification
{
	int arrayNo = [[notification object] intValue];

	if(arrayNo == CONTROL_BIND_ARRAY_SEARCH){
		[self playItem:nil];
	}

}

//------------------------------------
// mainWindowWillClose
//------------------------------------
-(void)mainWindowWillClose:(NSNotification *)notification
{

	// save state from user default
	// window rect
	[self saveWindowRect:mainWindow key:@"rectWindowMain"];

	// split view rect
	[self saveSplitViewRect:spvMain key:@"rectSplitViewMain"];
	[self saveSplitViewRect:spvNavi key:@"rectSplitViewNavi"];
	[self saveSplitViewRect:spvHead key:@"rectSplitViewHead"];

	// recent searches
	[self saveSearchFieldRecentSearches:txtSearchField key:@"arrayRecentSearches"];

}

//------------------------------------
// searchString
//------------------------------------
- (void)setSearchString:(NSString*)searchString
{
	[searchString retain];
	[searchString_ release];
	searchString_ = searchString;
}
- (NSString*)searchString
{
	return searchString_;
}
//------------------------------------
// searchURL
//------------------------------------
- (void)setSearchURL:(NSString*)searchURL
{
	[searchURL retain];
	[searchURL_ release];
	searchURL_ = searchURL;
}
- (NSString*)searchURL
{
	return searchURL_;
}
//------------------------------------
// feedName
//------------------------------------
- (void)setFeedName:(NSString*)feedName
{
	[feedName retain];
	[feedName_ release];
	feedName_ = feedName;
}
- (NSString*)feedName
{
	return feedName_;
}
//------------------------------------
// categoryName
//------------------------------------
- (void)setCategoryName:(NSString*)categoryName
{
	[categoryName retain];
	[categoryName_ release];
	categoryName_ = categoryName;
}
- (NSString*)categoryName
{
	return categoryName_;
}

//------------------------------------
// setSearchType
//------------------------------------
- (void)setSearchType:(int)searchType
{
	searchType_ = searchType;
}
- (int)searchType
{
	return searchType_;
}
//------------------------------------
// plistId
//------------------------------------
- (void)setPlistId:(NSString*)plistId
{
	[plistId retain];
	[plistId_ release];
	plistId_ = plistId;
}
- (NSString*)plistId
{
	return plistId_;
}
//------------------------------------
// setStartIndex
//------------------------------------
- (void)setStartIndex:(int)startIndex
{
	startIndex_ = startIndex;
}
- (int)startIndex
{
	return startIndex_;
}
//------------------------------------
// setTotalResults
//------------------------------------
- (void)setTotalResults:(int)totalResults
{
	totalResults_ = totalResults;
}
- (int)totalResults
{
	return totalResults_;
}
//------------------------------------
// setFetchIndex
//------------------------------------
- (void)setFetchIndex:(int)fetchIndex
{
	fetchIndex_ = fetchIndex;
}
- (int)fetchIndex
{
	return fetchIndex_;
}
//------------------------------------
// canRemoveItem
//------------------------------------
- (BOOL)canRemoveItem
{
	if([self isKeyMainWindow] == YES &&
		([self isSearchWithPlaylist] == YES ||
		 [self isSearchWithPlayHistory] == YES)){
		return YES;
	}else{
		return NO;
	}
}
//------------------------------------
// isKeyMainWindow
//------------------------------------
- (BOOL)isKeyMainWindow
{
	return [mainWindow isKeyWindow];
}
//------------------------------------
// isSearchWithPlaylist
//------------------------------------
- (BOOL)isSearchWithPlaylist
{
	if( [self searchType] == SEARCH_WITH_PLAYLIST &&
		![[self plistId] isEqualToString:@""]){
		return YES;
	}else{
		return NO;
	}

}
//------------------------------------
// isSearchWithPlayHistory
//------------------------------------
- (BOOL)isSearchWithPlayHistory
{
	if([self searchType] == SEARCH_WITH_PLAYHISTORY){
		return YES;
	}else{
		return NO;
	}

}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[searchlistArrayController removeObserver:self forKeyPath:@"selection"];
	[searchString_ release];
	[searchURL_ release];
	[feedName_ release];
	[categoryName_ release];
	[plistId_ release];
	[itemList_ release];
	[super dealloc];
}

@end

@implementation ViewMainSearch (Private)

//////////////////////////////////////////////////////////////////////
// fetchFeedWithQuery
//////////////////////////////////////////////////////////////////////
//------------------------------------
// fetchFeedWithQuery
//------------------------------------
- (void)fetchFeedWithQuery:(GDataQueryYouTube*)query queryParams:(NSDictionary*)queryParams
{

	GDataServiceGoogleYouTube *service;
	GDataServiceTicket *ticket;

	// create params
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setValue:queryParams forKey:@"queryParams"];

	// post status notification
	[self handleQueryStatusChanged:VIDEO_QUERY_INIT];

	if(query != nil){

		service = [self youTubeService];
		ticket = [service fetchYouTubeQuery:query 
								   delegate:self
						  didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:)
							didFailSelector:@selector(entryListFetchTicket:failedWithError:)];
		[ticket setUserData:params];

	}else{
		[self fetchFeedErrorWithQuery:params];
	}

}
//------------------------------------
// fetchFeedErrorWithQuery
//------------------------------------
- (void)fetchFeedErrorWithQuery:(NSMutableDictionary*)params;
{

	int itemStatus = VIDEO_QUERY_FAILED;
	NSString *errorDescription = @"Search query is null";

	// post handle
	[self handleQueryStatusChanged:itemStatus];

	// post error handle
	[self handleQueryFeedFetchedError:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInt:itemStatus], @"itemStatus" ,
						errorDescription, @"errorDescription" ,
						nil
					]
	];

}
//////////////////////////////////////////////////////////////////////
// entryListFetchTicket
// these tree functions are for handling the response from fetching a feed
//////////////////////////////////////////////////////////////////////
//------------------------------------
// entryListFetchTicket:finishedWithFeed
//------------------------------------
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed
{

	// post handle
	[self handleQueryStatusChanged:VIDEO_QUERY_SUCCESS];

	NSMutableDictionary *params = [ticket userData];

	GDataFeedYouTubeVideo *videoFeed = (GDataFeedYouTubeVideo*)feed;
	NSDictionary *queryParams = [params valueForKey:@"queryParams"];

	int startIndex = [[feed startIndex] intValue];
	int totalResults = [[feed totalResults] intValue];
	int itemsPerPage = [[feed itemsPerPage] intValue];
	int lastIndex = (startIndex + itemsPerPage - 1);
	if(lastIndex > totalResults){
		lastIndex = totalResults;
	}

	[self setStartIndex:startIndex];
	[self setTotalResults:totalResults];
	[self changePageButtonEnable];

	// result string
	NSString *resultString = [self convertToResultString:startIndex lastIndex:lastIndex totalResults:totalResults];
	[txtSearchResult setStringValue:resultString];

	// remove all objects
	[self removeItemList];

	int i;
	int index = startIndex - 1;

	for (i = 0; i < [[videoFeed entries] count]; i++)
	{

		GDataEntryBase *entry = [[videoFeed entries] objectAtIndex:i];
		if(![entry respondsToSelector:@selector(mediaGroup)]){
			continue;
		}
		
		GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *)entry;

		NSArray *thumbnails = [[video mediaGroup] mediaThumbnails];
		if([thumbnails count] == 0){
			continue;
		}
	
		index++;

		NSString *urlString = [[thumbnails objectAtIndex:0] URLString];

		// fetch entry
		[self fetchEntryImageWithURL:urlString
								index:index
								withVideo:video
								queryParams:queryParams
								queryType:VIDEO_QUERY_TYPE_FEED
		];

	}

}
//------------------------------------
// entryListFetchTicket:failedWithError
//------------------------------------
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error
{

	int itemStatus = VIDEO_QUERY_FAILED;
	NSString *errorDescription = [NSString stringWithFormat:@"Error %@", error];

	// post handle
	[self handleQueryStatusChanged:itemStatus];

	// post error handle
	[self handleQueryFeedFetchedError:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInt:itemStatus], @"itemStatus" ,
						errorDescription, @"errorDescription" ,
						nil
					]
	];

}
//////////////////////////////////////////////////////////////////////
// fetchFeedWithEntryURL
//////////////////////////////////////////////////////////////////////
//------------------------------------
// fetchFeedWithEntryURL
//------------------------------------
- (void)fetchFeedWithEntryURL:(NSString*)urlString queryParams:(NSDictionary*)queryParams
{

	GDataServiceGoogleYouTube *service;
	GDataServiceTicket *ticket;

	// create params
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setValue:queryParams forKey:@"queryParams"];

	// post status notification
	[self handleQueryStatusChanged:VIDEO_QUERY_INIT];

	if((urlString != nil) && ([urlString length] > 0)){
 
		service = [self youTubeService];
		ticket = [service fetchYouTubeEntryWithURL:[NSURL URLWithString:urlString] 
							delegate:self
							didFinishSelector:@selector(entryFetchTicket:finishedWithFeed:)
							didFailSelector:@selector(entryFetchTicket:failedWithError:)];
		[ticket setUserData:params];
	}else{
		[self fetchFeedErrorWithEntryURL:params];
	}

}
//------------------------------------
// fetchFeedErrorWithEntryURL
//------------------------------------
- (void)fetchFeedErrorWithEntryURL:(NSMutableDictionary*)params;
{

	int itemStatus = VIDEO_QUERY_FAILED;
	NSString *errorDescription = @"Search entry is null";

	// post handle
	[self handleQueryStatusChanged:itemStatus];

	// post error handle
	[self handleQueryEntryFetchedError:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInt:itemStatus], @"itemStatus" ,
						errorDescription, @"errorDescription" ,
						nil
					]
	];
}
//////////////////////////////////////////////////////////////////////
// entryFetchTicket
// these tree functions are for handling the response from fetching a feed
//////////////////////////////////////////////////////////////////////
//------------------------------------
// entryFetchTicket:finishedWithFeed
//------------------------------------
- (void)entryFetchTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed
{

	// post handle
	[self handleQueryStatusChanged:VIDEO_QUERY_SUCCESS];

	NSMutableDictionary *params = [ticket userData];
	NSDictionary *queryParams = [params valueForKey:@"queryParams"];

	GDataEntryBase *entry = (GDataEntryBase *)feed;

	if(![entry respondsToSelector:@selector(mediaGroup)]){
		return;
	}
	
	GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *)entry;

	NSArray *thumbnails = [[video mediaGroup] mediaThumbnails];
	if([thumbnails count] == 0){
		return;
	}

	NSString *urlString = [[thumbnails objectAtIndex:0] URLString];

	// fetch entry
	[self fetchEntryImageWithURL:urlString
							index:0
							withVideo:video
							queryParams:queryParams
							queryType:VIDEO_QUERY_TYPE_ENTRY
	];

}
//------------------------------------
// entryFetchTicket:failedWithError
//------------------------------------
- (void)entryFetchTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error
{

	int itemStatus = VIDEO_QUERY_FAILED;
//	NSString *errorDescription = [NSString stringWithFormat:@"Error %@", error];

	// post handle
	[self handleQueryStatusChanged:itemStatus];

/*
	// post error handle
	[self handleQueryEntryFetchedError:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInt:itemStatus], @"itemStatus" ,
						errorDescription, @"errorDescription" ,
						nil
					]
	];
*/
	NSMutableDictionary *params = [ticket userData];
	NSDictionary *queryParams = [params valueForKey:@"queryParams"];
	NSString *itemId = [queryParams valueForKey:@"itemId"];

	if(!itemId){
		return;
	}

	// fetch itemList_ with itemid
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];
	NSArray *fetchedArray = [itemList_ filteredArrayUsingPredicate:pred];

	// if exists, update record
	if([fetchedArray count] > 0){

		id record = [fetchedArray objectAtIndex:0];

		[record setValue:[NSNumber numberWithInt:VIDEO_ENTRY_FAILED] forKey:@"itemStatus"];

	}

	// reload
	[searchlistArrayController rearrangeObjects];

}
//////////////////////////////////////////////////////////////////////
// fetchEntryImageWithURL
//////////////////////////////////////////////////////////////////////
//------------------------------------
// fetchEntryImageWithURL
//------------------------------------
- (void)fetchEntryImageWithURL:(NSString*)urlString
				index:(int)index
				withVideo:(GDataEntryYouTubeVideo *)video
				queryParams:(NSDictionary*)queryParams
				queryType:(int)queryType
{

	// create params
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setValue:[NSNumber numberWithInt:VIDEO_ENTRY_INIT] forKey:@"itemStatus"];
	[params setValue:[NSNumber numberWithInt:index] forKey:@"index"];
	[params setValue:video forKey:@"video"];
	[params setValue:queryParams forKey:@"queryParams"];
	[params setValue:[NSNumber numberWithInt:queryType] forKey:@"queryType"];

	if(urlString != nil && [urlString length] > 0){

		NSURL *url = [NSURL URLWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

	//	[fetcher setUserData:video];
		[fetcher setUserData:params];

		[fetcher beginFetchWithDelegate:self
					  didFinishSelector:@selector(imageFetcher:finishedWithData:)
			  didFailWithStatusSelector:@selector(imageFetcher:failedWithStatus:data:)
			   didFailWithErrorSelector:@selector(imageFetcher:failedWithError:)];

	}else{
		[self fetchEntryImageErrorWithURL:params];
	}

}
//------------------------------------
// fetchEntryImageErrorWithURL
//------------------------------------
- (void)fetchEntryImageErrorWithURL:(NSMutableDictionary*)params
{

	NSString *errorDescription = @"image url is null";

	// post error handle
	[self handleEntryImageFetchedError:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInt:VIDEO_ENTRY_FAILED], @"itemStatus" ,
						errorDescription, @"errorDescription" ,
						nil
					]
	];

}
//////////////////////////////////////////////////////////////////////
// imageFetcher:
// These three functions handle the responses for fetching an image
//////////////////////////////////////////////////////////////////////
//------------------------------------
// imageFetcher:finishedWithData
//------------------------------------
- (void)imageFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data
{

	NSMutableDictionary *params = [fetcher userData];

	GDataEntryYouTubeVideo *video = [params valueForKey:@"video"];
	int index = [[params valueForKey:@"index"] intValue];
	int queryType = [[params valueForKey:@"queryType"] intValue];

	// get values
	NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];

	NSDictionary *values = [self getYouTubeVideoValues:video];

	NSString *itemId = [values valueForKey:@"itemId"];
	NSString *title = [values valueForKey:@"title"];
	NSString *author = [values valueForKey:@"author"];
	NSString *description = [values valueForKey:@"description"];
	NSNumber *playTime = [values valueForKey:@"playTime"];
	NSNumber *viewCount = [values valueForKey:@"viewCount"];
	NSNumber *rating = [values valueForKey:@"rating"];
	NSDate *publishedDate = [values valueForKey:@"publishedDate"];

	// null value
	if(!itemId || [itemId isEqualToString:@""]){
		return;
	}

	// add itemList
	//
	// feed
	//
	if(queryType == VIDEO_QUERY_TYPE_FEED){
		// be careful, if object is null, can't set after objects
		NSMutableDictionary *dict = 
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
//					[[ContentItem alloc] initVideo:video image:image author:author itemId:itemId], @"itemObject" ,
					[NSNumber numberWithInt:index], @"rowNumber" ,
					itemId, @"itemId" ,
					title, @"title" ,
					author, @"author" ,
					description, @"description" ,
					playTime, @"playTime" ,
					viewCount, @"viewCount" ,
					rating, @"rating" ,
					publishedDate, @"publishedDate" ,
					[NSNumber numberWithInt:VIDEO_ENTRY_SUCCESS], @"itemStatus" ,
					[NSNumber numberWithBool:NO], @"isPlayed" ,
					[NSNumber numberWithInt:VIDEO_FORMAT_MAP_NONE], @"formatMapNo" ,
					nil
			];

		// ContentItem
		[dict setValue:[[[ContentItem alloc] initVideo:video
												image:image
												author:author
												itemId:itemId
						] autorelease]
				forKey:@"itemObject"
		];

		// videoInfoItem
		if([self defaultBoolValue:@"optSearchVideoInfo"] == YES){
			int fetchIndex = [self fetchIndex];
			float requestInterval = [self defaultVideoInfoRequestInterval];
			float fetchInterval = requestInterval * fetchIndex;
//			NSLog(@"fetchIndex=%d", fetchIndex);
			[dict setValue:[[[VideoInfoItem alloc] initWithVideo:itemId
													formatNo:VIDEO_FORMAT_NO_NONE	// not used
													interval:fetchInterval
													target:self
													notifType:VIDEO_ITEM_NOTIF_LIST
							] autorelease]
					forKey:@"videoInfoItem"
			];
			fetchIndex++;
			[self setFetchIndex:fetchIndex];
		}

		[itemList_ addObject:dict];
	}
	//
	// entry
	//
	else if(queryType == VIDEO_QUERY_TYPE_ENTRY){

		// fetch itemList_ with itemid
		NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
		pred = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];
		NSArray *fetchedArray = [itemList_ filteredArrayUsingPredicate:pred];

		// if exists, update record
		if([fetchedArray count] > 0){

			id record = [fetchedArray objectAtIndex:0];

//			[record setValue:[[ContentItem alloc] initVideo:video image:image author:author itemId:itemId] forKey:@"itemObject"];
			[record setValue:title forKey:@"title"];
			[record setValue:author forKey:@"author"];
			[record setValue:description forKey:@"description"];
			[record setValue:playTime forKey:@"playTime"];
			[record setValue:viewCount forKey:@"viewCount"];
			[record setValue:rating forKey:@"rating"];
			[record setValue:publishedDate forKey:@"publishedDate"];
			[record setValue:[NSNumber numberWithInt:VIDEO_ENTRY_SUCCESS] forKey:@"itemStatus"];
			[record setValue:[NSNumber numberWithBool:NO] forKey:@"isPlayed"];
			[record setValue:[NSNumber numberWithInt:VIDEO_FORMAT_MAP_NONE] forKey:@"formatMapNo"];

			// ContentItem
			[record setValue:[[[ContentItem alloc] initVideo:video
													image:image
													author:author
													itemId:itemId
							] autorelease]
					forKey:@"itemObject"
			];

			// set VideoInfoItem
			if([self defaultBoolValue:@"optSearchVideoInfo"] == YES){
				int fetchIndex = [self fetchIndex];
				float requestInterval = [self defaultVideoInfoRequestInterval];
				float fetchInterval = requestInterval * fetchIndex;
//				NSLog(@"fetchIndex=%d", fetchIndex);
				[record setValue:[[[VideoInfoItem alloc] initWithVideo:itemId
														formatNo:VIDEO_FORMAT_NO_NONE	// not used
														interval:fetchInterval
														target:self
														notifType:VIDEO_ITEM_NOTIF_LIST
								] autorelease]
						forKey:@"videoInfoItem"
				];
				fetchIndex++;
				[self setFetchIndex:fetchIndex];
			}

			// notification for matrix
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"ITEM_OBJECT_NOTIF_NAME_UPDATE" object:record];
		}

	}

	// reload
	[searchlistArrayController rearrangeObjects];

}
//------------------------------------
// imageFetcher:failedWithStatus
//------------------------------------
- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data
{

	NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSString *errorDescription = [NSString stringWithFormat:@"Image fetch error %d with data %@",  status, dataStr];

	// post error handle
	[self handleEntryImageFetchedError:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInt:VIDEO_ENTRY_FAILED], @"itemStatus" ,
						errorDescription, @"errorDescription" ,
						nil
					]
	];

}
//------------------------------------
// imageFetcher:failedWithError
//------------------------------------
- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error
{

	NSString *errorDescription = [NSString stringWithFormat:@"Image fetch error %@", error];

	// post error handle
	[self handleEntryImageFetchedError:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInt:VIDEO_ENTRY_FAILED], @"itemStatus" ,
						errorDescription, @"errorDescription" ,
						nil
					]
	];

}

@end

