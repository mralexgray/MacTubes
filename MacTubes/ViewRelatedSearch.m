#import "ViewRelatedSearch.h"
#import "ViewPlayer.h"
#import "ViewItemInfo.h"
#import "ViewFileFormat.h"
#import "TBArrayController.h"
#import "DownloadManager.h"
#import "LogStatusController.h"
#import "ConvertExtension.h"
#import "HelperExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"
#import "GDataYouTubeExtension.h"

@implementation ViewRelatedSearch

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// window rect
	[self setWindowRect:relatedWindow key:@"rectWindowRelated"];

	// alloc itemList and set content
	itemList_ = [[NSMutableArray alloc] init];
	[relatedlistArrayController setContent:itemList_];

	[self setSearchURL:@""];
	[self setSearchType:SEARCH_WITH_URL];
	[self setSearchSubType:SEARCH_WITH_URL_RELATED];
	[self changeWindowTitle:SEARCH_WITH_URL searchSubType:SEARCH_WITH_URL_RELATED];

	[self setStartIndex:1];
	[self setTotalResults:0];
	[self setFetchIndex:0];
	[self changePageButtonEnable];
	[self changeQueryMenuButtonEnable];

	// set key equivalent
	[btnPlay setKeyEquivalent:@" "];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(relatedWindowWillClose:) name:NSWindowWillCloseNotification object:relatedWindow];
	[nc addObserver:self selector:@selector(handleControlPlayItemDidChanged:) name:CONTROL_NOTIF_PLAY_ITEM_DID_CHANGED object:nil];

}
//=======================================================================
// Actions
//=======================================================================
//------------------------------------
// openRelatedWindow 
//------------------------------------
- (IBAction)openRelatedWindow:(id)sender
{
	[relatedWindow makeKeyAndOrderFront:self];
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
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"]; 

	[viewPlayer setPlayerView:itemObject arrayNo:CONTROL_BIND_ARRAY_RELATED];
}

//------------------------------------
// downloadItem
//------------------------------------
- (IBAction)downloadItem:(id)sender
{
	NSArray *array = [relatedlistArrayController selectedObjects];
	// no select
	if([array count] <= 0){
		return;
	}
	// over count
	if([array count] > 5){
		[self displayMessage:@"alert"
					messageText:@"Can not download over 5 files at the same time."
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

	NSArray *objects = [relatedlistArrayController selectedObjects];
 
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
// openItemInfo
//------------------------------------
- (IBAction)openItemInfo:(id)sender
{
	// no select
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
	if([viewItemInfo createItemInfo:CONTROL_BIND_ARRAY_RELATED record:record] == YES){
		[viewItemInfo openInfoWindow:nil];
	}
}
//------------------------------------
// openVideoFormatItem
//------------------------------------
- (IBAction)openVideoFormatItem:(id)sender
{
	// no select
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
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
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
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
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
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
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
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
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
	ContentItem *itemObject = [record objectForKey:@"itemObject"]; 

	NSString *url = @"";  

	if(itemObject){
		url = [itemObject relatedURL];
	}else{
		url = [self convertToRelatedURL:[record objectForKey:@"itemId"]];
	}

	if(![url isEqualToString:@""]){
		[self openRelatedWindow:nil];
		[self searchWithURL:url startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_URL searchSubType:SEARCH_WITH_URL_RELATED];
	}

}
//------------------------------------
// searchAuthorsItem
//------------------------------------
- (IBAction)searchAuthorsItem:(id)sender
{

	// no select
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
	NSString *author = [record objectForKey:@"author"];

	NSString *url = [self convertToAuthorsUploadURL:author];	

	if(![url isEqualToString:@""]){
		[self openRelatedWindow:nil];
		[self searchWithURL:url startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_URL searchSubType:SEARCH_WITH_URL_AUTHOR];
	}

}
//------------------------------------
// copyItemToPasteboard
//------------------------------------
- (IBAction)copyItemToPasteboard:(id)sender
{
	// no select
	if([[relatedlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[relatedlistArrayController selectedObjects] objectAtIndex:0];
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

//=======================================================================
// methods
//=======================================================================
//------------------------------------
// reloadWithStartIndex
//------------------------------------
- (void)reloadWithStartIndex:(int)startIndex
{
	if([self searchType] == SEARCH_WITH_URL){
		[self searchWithURL:[self searchURL] startIndex:startIndex maxResults:[self defaultMaxResults] searchType:[self searchType] searchSubType:[self searchSubType]];
	}
}
//------------------------------------
// searchWithItems
//------------------------------------
- (void)searchWithItems:(NSDictionary*)params
{
	// get params
	NSArray *items = [params objectForKey:@"items"];
	int searchType = [[params objectForKey:@"searchType"] intValue];
	int searchSubType = [[params objectForKey:@"searchSubType"] intValue];
	
	// no item
	if([items count] <= 0){
		return;
	}

	id record = [items objectAtIndex:0];
	NSString *url = @"";

	// related
	if(searchSubType == SEARCH_WITH_URL_RELATED){
		url = [self convertToRelatedURL:[record valueForKey:@"itemId"]];	
	}
	// author
	else if(searchSubType == SEARCH_WITH_URL_AUTHOR){
		url = [self convertToAuthorsUploadURL:[record objectForKey:@"author"]];	
	}

	if(![url isEqualToString:@""]){
		[self openRelatedWindow:nil];
		[self searchWithURL:url startIndex:1 maxResults:[self defaultMaxResults] searchType:searchType searchSubType:searchSubType];
	}

}
//------------------------------------
// searchWithURL 
//------------------------------------
- (void)searchWithURL:(NSString*)url startIndex:(int)startIndex maxResults:(int)maxResults searchType:(int)searchType searchSubType:(int)searchSubType
{

	if ((url != nil) && ([url length] > 0))
	{

		[self setSearchURL:url];
		[self setSearchType:searchType];
		[self setSearchSubType:searchSubType];
		[self changeQueryMenuButtonEnable];
		[self changeWindowTitle:searchType searchSubType:searchSubType];
		[self setFetchIndex:0];

		// decode
		url = [self decodeToPercentEscapesString:url];
//		NSLog(@"url=%@", url);

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
		if(searchSubType == SEARCH_WITH_URL_AUTHOR){
			query = [self setYouTubeQueryOrder:query queryOrder:[self defaultIntValue:@"optQuerySortRelated"]];
		}

		// safeSearch (for API V2)
		query = [self setYouTubeQuerySafeSearch:query safeSearchNo:[self defaultIntValue:@"optSafeSearchNo"]];

//		NSLog(@"Query URL=%@", [query URL]);

		// query feed
		[self fetchFeedWithQuery:query queryParams:nil];

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
	if([self searchType] == SEARCH_WITH_ITEMS){
		[btnPagePrev setEnabled:NO];
		[btnPageNext setEnabled:NO];
	}
	else{
		// prev
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
	}
	
}
//------------------------------------
// changeQueryMenuButtonEnable
//------------------------------------
- (void)changeQueryMenuButtonEnable
{

	// query order button
	if([self searchSubType] == SEARCH_WITH_URL_AUTHOR){
		[btnQueryOrder setEnabled:YES];
	}else{
		[btnQueryOrder setEnabled:NO];
	}

}
//------------------------------------
// changeWindowTitle
//------------------------------------
- (void)changeWindowTitle:(int)searchType searchSubType:(int)searchSubType
{
	NSString *title = @"Related Search";

	if(searchType == SEARCH_WITH_URL){
		if(searchSubType == SEARCH_WITH_URL_RELATED){
			title = @"Related Video";
		}
		else if(searchSubType == SEARCH_WITH_URL_AUTHOR){
			title = @"Authors Video";
		}
	}

	[self setWindowTitle:title];

}
//------------------------------------
// setWindowTitle
//------------------------------------
- (void)setWindowTitle:(NSString*)title
{
	[relatedWindow setTitle:title];
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
	[relatedlistArrayController rearrangeObjects];

}
//------------------------------------
// removeArrayAllObjects 
//------------------------------------
- (void)removeArrayAllObjects:(NSArrayController*)arrayController
{
	// Remove All objects
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

//	NSLog(@"handleItemObjectChange related");
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
		[nc postNotificationName:VIDEO_ITEM_NOTIF_NAME_FROM_RELATED object:notification];
	}

	// reload
//	[relatedlistArrayController rearrangeObjects];

}
//------------------------------------
// handleControlPlayItemDidChanged
//------------------------------------
- (void)handleControlPlayItemDidChanged:(NSNotification *)notification
{
	int arrayNo = [[notification object] intValue];

	if(arrayNo == CONTROL_BIND_ARRAY_RELATED){
		[self playItem:nil];
	}

}

//------------------------------------
// relatedWindowWillClose
//------------------------------------
-(void)relatedWindowWillClose:(NSNotification *)notification
{

	// save state from user default
	// window rect
	[self saveWindowRect:relatedWindow key:@"rectWindowRelated"];

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
// setSearchSubType
//------------------------------------
- (void)setSearchSubType:(int)searchSubType
{
	searchSubType_ = searchSubType;
}
- (int)searchSubType
{
	return searchSubType_;
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
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[searchURL_ release];
	[itemList_ release];
	[super dealloc];
}

@end

@implementation ViewRelatedSearch (Private)

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
	int itemStatus = VIDEO_ENTRY_FAILED;
	NSString *errorDescription = @"image url is null";

	[params setValue:[NSNumber numberWithInt:itemStatus] forKey:@"itemStatus"];
	[params setValue:errorDescription forKey:@"errorDescription"];

	// post handle
	[self handleEntryImageFetchedError:params];
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
//	int queryType = [[params valueForKey:@"queryType"] intValue];

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
//	if(queryType == VIDEO_QUERY_TYPE_FEED){
		// be careful, if object is null, can't set after objects
		NSMutableDictionary *dict = 
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
//				[[ContentItem alloc] initVideo:video image:image author:author itemId:itemId], @"itemObject" ,
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
													formatNo:VIDEO_FORMAT_NO_NONE // not used
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
//	}

	// reload
	[relatedlistArrayController rearrangeObjects];

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

