#import "VideoInfoItem.h"
#import "ConvertExtension.h"
#import "HelperExtension.h"
#import "YouTubeHelperExtension.h"

@implementation VideoInfoItem
//------------------------------------
// init
//------------------------------------
- (id)initWithVideo:(NSString*)itemId
				formatNo:(int)formatNo
				interval:(float)interval
				target:(id)target
				notifType:(int)notifType
{
    if (self = [super init])
	{
		[self setItemId:itemId];
		[self setFormatNo:formatNo];

		notifType_ = notifType;
		itemStatus_ = VIDEO_ITEM_INIT;
		formatMapNo_ = VIDEO_FORMAT_MAP_NONE;
		target_ = target;

		NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
		if(notifType_ == VIDEO_ITEM_NOTIF_LIST){
			[nc addObserver:target selector:@selector(handleItemObjectChange:) name:VIDEO_ITEM_NOTIF_NAME_LIST object:self];
		}
		else if(notifType_ == VIDEO_ITEM_NOTIF_ITEM){
			[nc addObserver:target selector:@selector(handleItemObjectChange:) name:VIDEO_ITEM_NOTIF_NAME_ITEM object:self];
		}
		else if(notifType_ == VIDEO_ITEM_NOTIF_INFO){
			[nc addObserver:target selector:@selector(handleItemObjectInfo:) name:VIDEO_ITEM_NOTIF_NAME_INFO object:self];
		}

		NSString *urlString = [self convertToWatchURL:itemId];
//		urlString = [self convertToFileFormatURL:urlString fileFormatNo:formatNo];
/*
		if([self createConnection:urlString] == NO){
			itemStatus_ = VIDEO_ITEM_FAILED;
			[self notifyVideoInfoItemDidLoad:self];
		}
*/
		[self getVideoInfoByTimer:urlString interval:interval];
   }
    return self;
}
//------------------------------------
// getVideoInfoByTimer
//------------------------------------
- (void)getVideoInfoByTimer:(NSString*)urlString interval:(float)interval
{

//	NSLog(@"interval=%.2f", interval);

	[self setRequestTimer:[NSTimer scheduledTimerWithTimeInterval:interval
									target:self
									selector:@selector(getVideoInfo:)
									userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																urlString, @"urlString",
																nil
											]
									repeats:NO
						]
	];
	[[NSRunLoop currentRunLoop] addTimer:[self requestTimer] forMode:(NSString*)kCFRunLoopCommonModes];

}
//------------------------------------
// getVideoInfo
//------------------------------------
- (void)getVideoInfo:(id)sender
{

	NSDictionary *userInfo = [sender userInfo];
	NSString *urlString = [userInfo valueForKey:@"urlString"];

	if([self createConnection:urlString] == NO){
		itemStatus_ = VIDEO_ITEM_FAILED;
		[self notifyVideoInfoItemDidLoad:self];
	}

}
//------------------------------------
// createConnection
//------------------------------------
- (BOOL)createConnection:(NSString*)urlString
{

//	NSLog(@"urlString = %@", urlString);

	// get html
	NSURL *url = [NSURL URLWithString:urlString];
	if(url == nil){
		return NO;
	}

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:10
									];
	if(request == nil){
		return NO;
	}

	[request setHTTPMethod:@"GET"];

	[self setConnection:[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease]];
	if([self connection] != nil){
		return YES;
	}else{
		return NO;
	}

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

//	NSURLRequest *newRequest = request;
/*
	if(redirectResponse) {
		newRequest = nil;
	}
*/
	return request;
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
	if(!htmlData_) htmlData_ = [[NSMutableData data] retain];
	[htmlData_ appendData:data];
}
//------------------------------------
// didFailWithError
//------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	itemStatus_ = VIDEO_ITEM_FAILED;
	[self notifyVideoInfoItemDidLoad:self];
}
//------------------------------------
// connectionDidFinishLoading
//------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	NSString *html = [[[NSString alloc] initWithData:htmlData_ encoding:NSUTF8StringEncoding] autorelease];

	if(html == nil){
		itemStatus_ = VIDEO_ITEM_FAILED;
		return;
	}

	itemStatus_ = VIDEO_ITEM_SUCCESS;
	// get formatMapNo
	formatMapNo_ = [self getYouTubeAvailableFormatMapNo:html];

	[self notifyVideoInfoItemDidLoad:self];

}
//------------------------------------
// notifyDownloadItemChange
//------------------------------------
- (void)notifyVideoInfoItemDidLoad:(VideoInfoItem*)item
{
//	NSLog(@"notifyDownloadItemChange");
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	if(notifType_ == VIDEO_ITEM_NOTIF_LIST){
		[nc postNotificationName:VIDEO_ITEM_NOTIF_NAME_LIST object:item];
	}
	else if(notifType_ == VIDEO_ITEM_NOTIF_ITEM){
		[nc postNotificationName:VIDEO_ITEM_NOTIF_NAME_ITEM object:item];
	}
	else if(notifType_ == VIDEO_ITEM_NOTIF_INFO){
		[nc postNotificationName:VIDEO_ITEM_NOTIF_NAME_INFO object:item];
	}
	// remove observer
	[self removeItemObserver:item];
}
//------------------------------------
// cancelConnection
//------------------------------------
- (void)cancelConnection
{
	if(connection_ != nil){
		[connection_ cancel];
	}
	itemStatus_ = VIDEO_ITEM_NOT_FOUND;

	// remove observer
	[self removeItemObserver:self];

}
//------------------------------------
// removeItemObserver
//------------------------------------
- (void)removeItemObserver:(VideoInfoItem*)item
{
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	if(notifType_ == VIDEO_ITEM_NOTIF_LIST){
		[nc removeObserver:target_ name:VIDEO_ITEM_NOTIF_NAME_LIST object:item];
	}
	else if(notifType_ == VIDEO_ITEM_NOTIF_ITEM){
		[nc removeObserver:target_ name:VIDEO_ITEM_NOTIF_NAME_ITEM object:item];
	}
	else if(notifType_ == VIDEO_ITEM_NOTIF_INFO){
		[nc removeObserver:target_ name:VIDEO_ITEM_NOTIF_NAME_INFO object:item];
	}
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
// requestTimer
//------------------------------------
- (void)setRequestTimer:(NSTimer*)requestTimer
{
	[requestTimer retain];
	[requestTimer_ release];
	requestTimer_ = requestTimer;
}
- (NSTimer*)requestTimer
{
	return requestTimer_;
}
//------------------------------------
// cancelRequestTimer
//------------------------------------
- (void)cancelRequestTimer
{
	if([[self requestTimer] isValid] == YES){
		[[self requestTimer] invalidate];
//		NSLog(@"clearRequestTimer");
	}
}
//------------------------------------
// itemId
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
// formatNo
//------------------------------------
- (void)setFormatNo:(int)formatNo
{
	formatNo_ = formatNo;
}
- (int)formatNo
{
	return formatNo_;
}
//------------------------------------
// formatMapNo
//------------------------------------
- (int)formatMapNo
{
	return formatMapNo_;
}
//------------------------------------
// itemStatus
//------------------------------------
- (int)itemStatus;
{
	return itemStatus_;
}
//------------------------------------
// notifType
//------------------------------------
- (int)notifType;
{
	return notifType_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{

//	NSLog(@"dealloc=%@", itemId_);

	[self removeItemObserver:self];

	[itemId_ release];

	[htmlData_ release];
	[connection_ release];
	[requestTimer_ release];

    [super dealloc];
}

@end
