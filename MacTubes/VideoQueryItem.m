#import "VideoQueryItem.h"
//#import "ViewMainSearch.h"
//#import "ViewRelatedSearch.h"
#import "ViewPlayer.h"
#import "GDataYouTubeExtension.h"

@implementation VideoQueryItem
//------------------------------------
// init
//------------------------------------
- (id)initWithTarget:(id)target
{
    if (self = [super init])
	{
		target_ = target;
	}
    return self;
}

//=======================================================================
// methods
//=======================================================================
//------------------------------------
// fetchFeedWithQuery
//------------------------------------
- (void)fetchFeedWithQuery:(GDataQueryYouTube*)query queryParams:(NSDictionary*)queryParams
{

	GDataServiceGoogleYouTube *service;
	GDataServiceTicket *ticket;

	// create params
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_INIT] forKey:@"itemStatus"];
	[params setValue:queryParams forKey:@"queryParams"];

	// post status notification
	[self postQueryStatusHandle:params];

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
// fetchFeedWithEntryURL
//------------------------------------
- (void)fetchFeedWithEntryURL:(NSString*)urlString queryParams:(NSDictionary*)queryParams
{

	GDataServiceGoogleYouTube *service;
	GDataServiceTicket *ticket;

	// create params
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_INIT] forKey:@"itemStatus"];
	[params setValue:queryParams forKey:@"queryParams"];

	// post status notification
	[self postQueryStatusHandle:params];

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
//////////////////////////////////////////////////////////////////////
// entryListFetchTicket
// these tree functions are for handling the response from fetching a feed
//////////////////////////////////////////////////////////////////////
//------------------------------------
// entryListFetchTicket:finishedWithFeed
//------------------------------------
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed
{

	NSMutableDictionary *params = [ticket userData];

	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_SUCCESS] forKey:@"itemStatus"];
	[params setValue:feed forKey:@"feed"];

	// post handle
	[self postQueryStatusHandle:params];
	[self postQueryFeedHandle:params];

}
//------------------------------------
// entryListFetchTicket:failedWithError
//------------------------------------
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error
{

	NSMutableDictionary *params = [ticket userData];

	NSString *errorDescription = [NSString stringWithFormat:@"Error %@", error];
	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_FAILED] forKey:@"itemStatus"];
	[params setValue:errorDescription forKey:@"errorDescription"];

	// post handle
	[self postQueryStatusHandle:params];
	[self postQueryFeedHandle:params];

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

	NSMutableDictionary *params = [ticket userData];

	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_SUCCESS] forKey:@"itemStatus"];
	[params setValue:feed forKey:@"feed"];

	// post handle
	[self postQueryStatusHandle:params];
	[self postQueryEntryHandle:params];

}
//------------------------------------
// entryFetchTicket:failedWithError
//------------------------------------
- (void)entryFetchTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error
{

	NSMutableDictionary *params = [ticket userData];

	NSString *errorDescription = [NSString stringWithFormat:@"Error %@", error];
	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_FAILED] forKey:@"itemStatus"];
	[params setValue:errorDescription forKey:@"errorDescription"];

	// post handle
	[self postQueryStatusHandle:params];
	[self postQueryEntryHandle:params];

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

	[params setValue:[NSNumber numberWithInt:VIDEO_ENTRY_SUCCESS] forKey:@"itemStatus"];
//	[params setValue:[[[NSImage alloc] initWithData:data] autorelease] forKey:@"image"];
	[params setValue:data forKey:@"imageData"];

	// post handle
	[self postEntryImageHandle:params];

}
//------------------------------------
// imageFetcher:failedWithStatus
//------------------------------------
- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data
{

	NSMutableDictionary *params = [fetcher userData];

	NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSString *errorDescription = [NSString stringWithFormat:@"Image fetch error %d with data %@",  status, dataStr];

	[params setValue:[NSNumber numberWithInt:VIDEO_ENTRY_FAILED] forKey:@"itemStatus"];
	[params setValue:errorDescription forKey:@"errorDescription"];

	// post handle
	[self postEntryImageHandle:params];

}
//------------------------------------
// imageFetcher:failedWithError
//------------------------------------
- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error
{

	NSMutableDictionary *params = [fetcher userData];

	NSString *errorDescription = [NSString stringWithFormat:@"Image fetch error %@", error];

	[params setValue:[NSNumber numberWithInt:VIDEO_ENTRY_FAILED] forKey:@"itemStatus"];
	[params setValue:errorDescription forKey:@"errorDescription"];

	// post handle
	[self postEntryImageHandle:params];

}
//------------------------------------
// fetchFeedErrorWithQuery
//------------------------------------
- (void)fetchFeedErrorWithQuery:(NSMutableDictionary*)params;
{
	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_FAILED] forKey:@"itemStatus"];
	[params setValue:@"Search query is null" forKey:@"errorDescription"];

	// post handle
	[self postQueryStatusHandle:params];
	[self postQueryFeedHandle:params];
}
//------------------------------------
// fetchFeedErrorWithEntryURL
//------------------------------------
- (void)fetchFeedErrorWithEntryURL:(NSMutableDictionary*)params;
{
	[params setValue:[NSNumber numberWithInt:VIDEO_QUERY_FAILED] forKey:@"itemStatus"];
	[params setValue:@"Search entry is null" forKey:@"errorDescription"];

	// post handle
	[self postQueryStatusHandle:params];
	[self postQueryEntryHandle:params];
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
	[self postEntryImageHandle:params];
}
//////////////////////////////////////////////////////////////////////
// postHandle
//////////////////////////////////////////////////////////////////////
//------------------------------------
// postQueryStatusHandle
//------------------------------------
- (void)postQueryStatusHandle:(NSMutableDictionary*)params
{
	[target_ handleQueryStatusChanged:params];
}
//------------------------------------
// postQueryFeedHandle
//------------------------------------
- (void)postQueryFeedHandle:(NSMutableDictionary*)params
{
	[target_ handleQueryFeedFetched:params];
}
//------------------------------------
// postQueryEntryHandle
//------------------------------------
- (void)postQueryEntryHandle:(NSMutableDictionary*)params
{
	[target_ handleQueryEntryFetched:params];
}
//------------------------------------
// postEntryImageHandle
//------------------------------------
- (void)postEntryImageHandle:(NSMutableDictionary*)params
{
	[target_ handleEntryImageFetched:params];
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
//	NSLog(@"query dealloc");
	[super dealloc];
}

@end

