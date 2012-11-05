#import "FetchItem.h"
#import "HelperExtension.h"

@implementation FetchItem
//------------------------------------
// init
//------------------------------------
- (id)initWithURL:(NSString*)requestURL
				userParams:(NSDictionary*)userParams
				notifTarget:(id)notifTarget
				reqParams:(NSDictionary*)reqParams
{
    if (self = [super init])
	{
		[self setRequestURLL:requestURL];
		[self setUserParams:userParams];
		[self setError:nil];
		notifTarget_ = notifTarget;
		itemStatus_ = FETCH_ITEM_STATUS_INIT;
		data_ = nil;

		NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
		[nc addObserver:notifTarget selector:@selector(handleFetchItemDidLoaded:) name:FETCH_ITEM_NOTIF_DID_LOADED object:self];
		[nc addObserver:notifTarget selector:@selector(handleFetchItemStatusDidChanged:) name:FETCH_ITEM_NOTIF_STATUS_DID_CHANGED object:self];

		// post status
		[self postFetchItemStatusDidChanged:self];

		if([self createConnection:requestURL reqParams:reqParams] == NO){
			itemStatus_ = FETCH_ITEM_STATUS_FAILED;

			// post status
			[self postFetchItemStatusDidChanged:self];
			[self postFetchItemDidLoaded:self];
		}

   }
    return self;
}
//------------------------------------
// createConnection
//------------------------------------
- (BOOL)createConnection:(NSString*)requestURL reqParams:(NSDictionary*)reqParams
{

//	NSLog(@"info requestURL = %@", requestURL);

	if(!requestURL){
		return NO;
	}

	// get info
	NSURL *url = [NSURL URLWithString:requestURL];
	if(url == nil){
		return NO;
	}

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:10
									];
	if(req == nil){
		return NO;
	}

//	[req setHTTPMethod:@"GET"];

	// set request params
	if(reqParams != nil){
		req = [self setRequestHeaderFields:req fields:reqParams];
	}

//	NSLog(@"header=%@", [[req allHTTPHeaderFields] description]);

	[self setConnection:[[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease]];
	if([self connection] != nil){
		return YES;
	}else{
		return NO;
	}

}

//------------------------------------
// didReceiveResponse
//------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// none
}
//------------------------------------
// didReceiveData
//------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(!data_) data_ = [[NSMutableData data] retain];
	[data_ appendData:data];
}
//------------------------------------
// didFailWithError
//------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//	NSLog(@"error=%@", [error description]);

	[self setError:error];
	itemStatus_ = FETCH_ITEM_STATUS_FAILED;

	// post status
	[self postFetchItemStatusDidChanged:self];
	[self postFetchItemDidLoaded:self];

}
//------------------------------------
// redirectResponse
//------------------------------------
-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
//	NSLog(@"redirectResponse");
//	NSLog(@"response=%@", [[redirectResponse URL] absoluteString]);
	return request;
}
//------------------------------------
// connectionDidFinishLoading
//------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	itemStatus_ = FETCH_ITEM_STATUS_COMPLETED;

	// post status
	[self postFetchItemStatusDidChanged:self];
	[self postFetchItemDidLoaded:self];
}
//------------------------------------
// postFetchItemStatusDidChanged
//------------------------------------
- (void)postFetchItemStatusDidChanged:(FetchItem*)item
{
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:FETCH_ITEM_NOTIF_STATUS_DID_CHANGED object:item];
}

//------------------------------------
// postFetchItemDidLoaded
//------------------------------------
- (void)postFetchItemDidLoaded:(FetchItem*)item
{
//	NSLog(@"notifyDownloadItemChange");
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:FETCH_ITEM_NOTIF_DID_LOADED object:item];

	// remove observer
	[self removeItemObserver:item];
}
//------------------------------------
// cancelConnection
//------------------------------------
- (void)cancelConnection
{
	if(connection_ != nil){
//		NSLog(@"FetchItem cancelConnection");
		[connection_ cancel];
	}

	// post status
	itemStatus_ = FETCH_ITEM_STATUS_CANCELED;
	[self postFetchItemStatusDidChanged:self];

	// remove observer
	[self removeItemObserver:self];

}
//------------------------------------
// removeItemObserver
//------------------------------------
- (void)removeItemObserver:(FetchItem*)item
{
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:notifTarget_ name:FETCH_ITEM_NOTIF_DID_LOADED object:item];
	[nc removeObserver:notifTarget_ name:FETCH_ITEM_NOTIF_STATUS_DID_CHANGED object:item];
}
//------------------------------------
// connection
//------------------------------------
- (void)setConnection:(NSURLConnection*)connection
{
	[connection retain];
	[connection_ release];
	connection_ = connection;
}
- (NSURLConnection*)connection
{
	return connection_;
}
//------------------------------------
// requestURL
//------------------------------------
- (void)setRequestURLL:(NSString*)requestURL
{
	[requestURL retain];
	[requestURL_ release];
	requestURL_ = requestURL;
}
- (NSString*)requestURL
{
	return requestURL_;
}
//------------------------------------
// userParams
//------------------------------------
- (void)setUserParams:(NSDictionary*)userParams
{
	[userParams retain];
	[userParams_ release];
	userParams_ = userParams;
}
- (NSDictionary*)userParams
{
	return userParams_;
}
//------------------------------------
// error
//------------------------------------
- (void)setError:(NSError*)error
{
	[error retain];
	[error_ release];
	error_ = error;
}
- (NSError*)error
{
	return error_;
}
//------------------------------------
// itemStatus
//------------------------------------
- (int)itemStatus
{
	return itemStatus_;
}
//------------------------------------
// data
//------------------------------------
- (NSData*)data
{
	return data_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{

//	NSLog(@"FetchItem dealloc=%@", requestURL_);

	[self removeItemObserver:self];

	[requestURL_ release];
	[userParams_ release];

	[data_ release];
	[error_ release];
	[connection_ release];

    [super dealloc];
}

@end
