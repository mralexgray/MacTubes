#import "ViewItemComment.h"
#import "ViewItemInfo.h"
#import "LogStatusController.h"
#import "HelperExtension.h"
#import "ConvertExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"
#import "GDataYouTubeExtension.h"

@implementation ViewItemComment

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	[self setItemId:@""];
	[self setStartIndex:0];
	[self setMaxResults:25];
	[self setTotalResults:0];
	[self setSelectTimer:nil];

	[self changePageButtonEnable];

	[txtSearchResult setStringValue:@""];

	// alloc commentList and set content
	commentList_ = [[NSMutableArray alloc] init];
	[commentlistArrayController setContent:commentList_];

}
//------------------------------------
// searchItemComments
//------------------------------------
- (IBAction)searchItemComments:(id)sender
{
	NSDictionary *params = [viewItemInfo params];
	NSString *itemId = @"";

	if(params != nil){
		itemId = [params valueForKey:@"itemId"];
	}

	if(![itemId isEqualToString:@""] && ![itemId isEqualToString:[self itemId]]){
		[self searchWithItemId:itemId startIndex:1];
	}
}
//------------------------------------
// searchItemCommentsWithTimer
//------------------------------------
- (IBAction)searchItemCommentsWithTimer:(id)sender
{
	// clear timer
	[self clearSelectTimer];

	// set timer
	[self setSelectTimer:[NSTimer scheduledTimerWithTimeInterval:0.5
							target:self 
							selector:@selector(searchItemComments:)
							userInfo:nil
							repeats: NO]
	];
	[[NSRunLoop currentRunLoop] addTimer:[self selectTimer] forMode:(NSString*)kCFRunLoopCommonModes];

}
//------------------------------------
// reloadSearchPage
//------------------------------------
- (IBAction)reloadSearchPage:(id)sender
{
	[self searchWithItemId:[self itemId] startIndex:1];
}
//------------------------------------
// changeSearchPage
//------------------------------------
- (IBAction)changeSearchPage:(id)sender
{
	int tag = [sender tag];

	int startIndex = [self startIndex];
	int totalResults = [self totalResults];
	int maxResults = [self maxResults];

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
// copyCommentToPasteboard
//------------------------------------
- (IBAction)copyCommentToPasteboard:(id)sender
{
	// no select
	if([[commentlistArrayController selectedObjects] count] <= 0){
		return;
	}

	id record = [[commentlistArrayController selectedObjects] objectAtIndex:0];
	NSString *author = [record valueForKey: @"author"];
	NSString *content = [record valueForKey: @"content"];
	// publishedDate
	NSString *dateStr = @"";
	if([record valueForKey:@"publishedDate"]){
		dateStr = [[record valueForKey:@"publishedDate"] descriptionWithCalendarFormat:@"%Y/%m/%d - %H:%M" timeZone:nil locale:nil];
	}

	NSString *string = [NSString stringWithFormat:@"%@  %@\n\n%@"
							, author
							, dateStr
							, content
					];

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
	[self searchWithItemId:[self itemId] startIndex:startIndex];
}
//------------------------------------
// searchWithItemId
//------------------------------------
- (void)searchWithItemId:(NSString*)itemId startIndex:(int)startIndex
{

	if ((itemId != nil) && ([itemId length] > 0))
	{

		[self setItemId:itemId];
		[self setStartIndex:startIndex];

		//decode
		NSString *urlString = [self convertToCommentsURL:itemId];
		urlString = [self decodeToPercentEscapesString:urlString];

		NSURL *feedURL = [NSURL URLWithString:urlString];
		GDataQueryYouTube *query = [GDataQueryYouTube youTubeQueryWithFeedURL:feedURL];

		[query setStartIndex:startIndex];
		[query setMaxResults:50];

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
	int maxResults = [self maxResults];

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
//------------------------------------
// removeCommentList 
//------------------------------------
- (void)removeCommentList
{

	[commentList_ removeAllObjects];

	// reload
	[commentlistArrayController rearrangeObjects];

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
// setItemId
//------------------------------------
- (void)setItemId:(NSString*)itemId
{
	[itemId retain];
    [itemId_ release];
    itemId_ = itemId;
}
- (NSString*)itemId
{
    return itemId_;
}
//------------------------------------
// startIndex
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
// maxResults
//------------------------------------
- (void)setMaxResults:(int)maxResults
{
	maxResults_ = maxResults;
}
- (int)maxResults
{
	return maxResults_;
}
//------------------------------------
// totalResults
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
// selectTimer
//------------------------------------
- (void)setSelectTimer:(NSTimer*)selectTimer
{
	[selectTimer retain];
	[selectTimer_ release];
	selectTimer_ = selectTimer;
}
- (void)clearSelectTimer
{
	if([[self selectTimer] isValid] == YES){
		[[self selectTimer] invalidate];
	}
}
- (NSTimer*)selectTimer
{
	return selectTimer_;
}
//------------------------------------
// windowWillCloseInfo
//------------------------------------
-(void)windowWillCloseInfo:(NSNotification *)notification
{
	// none
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[itemId_ release];
	[commentList_ release];
	[self clearSelectTimer];
	[selectTimer_ release];

	[super dealloc];
}
@end

@implementation ViewItemComment (Private)

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

//	NSMutableDictionary *params = [ticket userData];

	GDataFeedYouTubeComment *commentFeed = (GDataFeedYouTubeComment*)feed;
//	NSDictionary *queryParams = [params valueForKey:@"queryParams"];

	int startIndex = [[feed startIndex] intValue];
	int totalResults = [[feed totalResults] intValue];
	int itemsPerPage = [[feed itemsPerPage] intValue];
	int lastIndex = (startIndex + itemsPerPage - 1);
	if(lastIndex > totalResults){
		lastIndex = totalResults;
	}

	[self setStartIndex:startIndex];
	[self setMaxResults:itemsPerPage];
	[self setTotalResults:totalResults];
	[self changePageButtonEnable];

	// result string
	NSString *resultString = [self convertToResultString:startIndex lastIndex:lastIndex totalResults:totalResults];
	[txtSearchResult setStringValue:resultString];

	// remove all objects
	[self removeCommentList];

	int i;
	int index = startIndex - 1;

	for (i = 0; i < [[commentFeed entries] count]; i++)
	{

		GDataEntryBase *entry = [[commentFeed entries] objectAtIndex:i];
//		NSLog(@"entry=%@", [entry description]);

		NSDictionary *values = [self getYouTubeEntryValues:entry];
		index++;

		NSString *itemId = [self itemId];
		NSString *title = [values valueForKey:@"title"];
		NSString *content = [values valueForKey:@"content"];
		NSString *author = [values valueForKey:@"author"];
		NSString *authorLink = [values valueForKey:@"authorLink"];
		NSDate *publishedDate = [values valueForKey:@"publishedDate"];

/*
		NSLog(@"title=%@", title);
		NSLog(@"content=%@", content);
		NSLog(@"author=%@", author);
		NSLog(@"authorLink=%@", authorLink);
		NSLog(@"publishedDate=%@", [publishedDate description]);
*/

		// null value
		if(!itemId || [itemId isEqualToString:@""]){
			continue;
		}
		if(!title){title = @"";}
		if(!content){content = @"";}
		if(!author){author = @"";}
		if(!authorLink){authorLink = @"";}

		// add commentList
		// be careful, if object is null, can't set after objects
		NSMutableDictionary *dict = 
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:index], @"rowNumber" ,
					itemId, @"itemId" ,
					title, @"title" ,
					content, @"content" ,
					author, @"author" ,
					authorLink, @"authorLink" ,
					publishedDate, @"publishedDate" ,
					nil
			];

		[commentList_ addObject:dict];

	}

	// reload
	[commentlistArrayController rearrangeObjects];

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

@end
