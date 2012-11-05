#import "DownloadItem.h"
#import "ConvertExtension.h"
#import "HelperExtension.h"
#import "YouTubeHelperExtension.h"
#import "UserDefaultsExtension.h"

@implementation DownloadItem

//------------------------------------
// initWithURLString
//------------------------------------
- (id)initWithURLString:(NSString*)watchURL
				downloadURL:(NSString*)downloadURL
				fileName:(NSString*)fileName
				fileFormatNo:(int)fileFormatNo
				interval:(float)interval
				isGetURL:(BOOL)isGetURL
{

    if (self = [super init])
	{
		if([self startDownload:watchURL
						downloadURL:downloadURL
						fileName:fileName
						fileFormatNo:fileFormatNo
						interval:interval
						isGetURL:isGetURL
			] == NO
		){
			return nil;
		}
	}
    return self;

}
//------------------------------------
// startDownload
//------------------------------------
- (BOOL)startDownload:(NSString*)watchURL
				downloadURL:(NSString*)downloadURL
				fileName:(NSString*)fileName
				fileFormatNo:(int)fileFormatNo
				interval:(float)interval
				isGetURL:(BOOL)isGetURL
{

	// init parameters
	[self setWatchURL:watchURL];
	[self setDownloadURL:downloadURL];
	[self setFileFormatNo:fileFormatNo];
	[self setIsGetURL:isGetURL];
	[self setFileName:fileName];
	[self setFilePath:@""];
	[self setFileExt:@""];
	[self setIconImage:nil];
	[self setErrorLog:@""];
	[self setReceivedLength:0];
	[self setTotalLength:0];
	[self setStatus:DOWNLOAD_INIT];
	[self setNotifyTimer:nil];
	[self cancelNotifyTimer];

	[self setRequestTimer:nil];
	[self cancelRequestTimer];

	[self cancelFetchItem];

	// fetch data
	if(isGetURL == YES || [downloadURL isEqualToString:@""]){
		[self startFetchItemByTimer:watchURL
						fileFormatNo:fileFormatNo
						interval:interval
		];
		return YES;
	}
	// direct download
	else{

		[self setFetchItem:nil];

		// create download instance
		[self setDownload:[self createDownload:downloadURL]];

		if([self download] != nil){
			return YES;
		}else{
			return NO;
		}
	}
}

//------------------------------------
// startFetchItemByTimer
//------------------------------------
- (void)startFetchItemByTimer:(NSString*)watchURL
					fileFormatNo:(int)fileFormatNo
						interval:(float)interval
{

//	NSLog(@"interval=%.2f", interval);

	[self setRequestTimer:[NSTimer scheduledTimerWithTimeInterval:interval
									target:self
									selector:@selector(startFetchItem:)
									userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																watchURL, @"watchURL",
																[NSNumber numberWithInt:fileFormatNo], @"fileFormatNo",
																nil
											]
									repeats:NO
						]
	];
	[[NSRunLoop currentRunLoop] addTimer:[self requestTimer] forMode:(NSString*)kCFRunLoopCommonModes];

}
//------------------------------------
// startFetchItem
//------------------------------------
- (void)startFetchItem:(id)sender
{

	NSDictionary *userInfo = [sender userInfo];
	NSString *watchURL = [userInfo valueForKey:@"watchURL"];
	int fileFormatNo = [[userInfo valueForKey:@"fileFormatNo"] intValue];

	[self startFetch:watchURL fileFormatNo:fileFormatNo];

}
//------------------------------------
// startFetch
//------------------------------------
- (void)startFetch:(NSString*)watchURL fileFormatNo:(int)fileFormatNo
{

	[self setFetchStatus:FETCH_ITEM_STATUS_INIT];

	// fetch data
	NSDictionary *userParams = [NSDictionary dictionaryWithObjectsAndKeys:
								watchURL, @"watchURL" ,
								[NSNumber numberWithInt:fileFormatNo], @"fileFormatNo",
								nil
							];

	[self setFetchItem:[[[FetchItem alloc] initWithURL:watchURL
												userParams:userParams
												notifTarget:self
												reqParams:nil
							] autorelease]
	];
	[self notifyDownloadItemChange:self];
}
//------------------------------------
// createDownload
//------------------------------------
- (NSURLDownload*)createDownload:(NSString*)downloadURL
{
	// download
	NSURL *URL = [NSURL URLWithString:downloadURL];
	NSURLRequest *req = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];

/*
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:URL
															cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:20.0
									];
	[req setValue:[self convertToYouTubeBaseURL] forHTTPHeaderField:@"Referer"];
//	[req setValue:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ja-jp) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10" forHTTPHeaderField:@"User-Agent"];
*/
	return [[[NSURLDownload alloc] initWithRequest:req delegate:self] autorelease];

}
//------------------------------------
// cancelDownload
//------------------------------------
- (void)cancelDownload
{

	[self cancelRequestTimer];
	[self cancelFetchItem];

//	if([self status] != DOWNLOAD_STARTED){
//		return;
//	}

	if(download_){
		[download_ cancel];
	}
	[self setStatus:DOWNLOAD_CANCELED];
	[self notifyDownloadItemChange:self];
	[self cancelNotifyTimer];
}
//------------------------------------
// didReceiveResponse
//------------------------------------
- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{

	// set file extension
	NSString *MIMEType = [response MIMEType];
//	NSLog(@"MIMEType=%@", MIMEType);

	if([MIMEType isEqualToString:@"video/flv"]){
		[self setFileExt:@"flv"];
	}
	else if([MIMEType isEqualToString:@"video/mp4"]){
		[self setFileExt:@"mp4"];
	}
	else if([MIMEType isEqualToString:@"video/mpeg"]){
		[self setFileExt:@"mpeg"];
	}
	else if([MIMEType isEqualToString:@"video/webm"]){
		[self setFileExt:@"webm"];
	}
	else if([MIMEType isEqualToString:@"video/x-msvideo"]){
		[self setFileExt:@"avi"];
	}
	else if([MIMEType isEqualToString:@"application/x-shockwave-flash"]){
		[self setFileExt:@"swf"];
	}
	else{
		[self setFileExt:@"flv"];
	}

	long long totalLength = [response expectedContentLength];
	if(totalLength != NSURLResponseUnknownLength){
		[self setTotalLength:totalLength];
	}else{
		[self setTotalLength:0];
	}
	[self setReceivedLength:0];
//	[self notifyDownloadItemChange:self];
}
//------------------------------------
// decideDestinationWithSuggestedFilename
//------------------------------------
- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{

	// create destination path
	// path => @"/Users/foo/Desktop/filename"
	NSString *path = [self defaultStringValue:@"optDownloadFolderPath"];

	// check folder is exist
	BOOL isDir;
	if( [path isEqualToString:@""] ||
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] == NO ||
		isDir == NO
		){
		// change desktop path
		path = [@"~/Desktop" stringByExpandingTildeInPath];
	}

	// change file name
	NSMutableString *muFileName;
	if([self fileName] && ![[self fileName] isEqualToString:@""]){
		muFileName = [NSMutableString stringWithString:[self fileName]];
	}else{
		muFileName = [NSMutableString stringWithString:filename];
	}
	// replace "/" -> "-"
	[muFileName replaceOccurrencesOfString:@"/" withString:@"-" options:0 range:NSMakeRange(0,[muFileName length])];

	// return replaced string
	filename = muFileName;

	// add extension with file format
	filename = [filename stringByAppendingFormat:@".%@", [self fileExt]];

	// add file name
	path = [path stringByAppendingPathComponent:filename];

//	NSLog(@"path=%@", path);

	// allow overwrite
	[download setDestination:path allowOverwrite:NO];
 
}
//------------------------------------
// didCreateDestination
//------------------------------------
- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)filePath
{
	// save file path
	[self setFilePath:filePath];

	// set file icon image
	if([[NSFileManager defaultManager] fileExistsAtPath:[self filePath]] == YES){
		NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[self filePath]];
		[image setSize:NSMakeSize(32,32)];
		[image setScalesWhenResized:YES];
		[self setIconImage:image];
	}
}
//------------------------------------
// didReceiveDataOfLength
//------------------------------------
- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length
{
	[self setReceivedLength:[self receivedLength] + length];
//	if([self receivedLength] != NSURLResponseUnknownLength){
//		NSLog(@"length=%.0f/%.0f",(double)receivedLength_, (double)totalLength_);
//	}
}
//------------------------------------
// downloadDidBegin
//------------------------------------
-(void)downloadDidBegin:(NSURLDownload *)download
{
	[self setStatus:DOWNLOAD_STARTED];
	[self notifyDownloadItemChange:self];
	[self startNotifyTimer];
}
//------------------------------------
// downloadDidFinish
//------------------------------------
- (void)downloadDidFinish:(NSURLDownload *)download
{

	[self setStatus:DOWNLOAD_COMPLETED];
	[self notifyDownloadItemChange:self];
	[self cancelNotifyTimer];

}

//------------------------------------
// didFailWithError
//------------------------------------
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{

	[self setErrorLog:[NSString stringWithFormat: @"Download failed Error - %@ %@"
										, [error localizedDescription]
										, [[error userInfo] objectForKey:NSErrorFailingURLStringKey]
						]
	];

	[self setStatus:DOWNLOAD_FAILED];
	[self cancelNotifyTimer];
	[self notifyDownloadItemChange:self];
}
//------------------------------------
// shouldDecodeSourceDataOfMIMEType
//------------------------------------
- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)aType
{
	return NO;
}
//------------------------------------
// notifyDownloadItemChange
//------------------------------------
- (void)notifyDownloadItemChange:(DownloadItem*)item
{
//	NSLog(@"notifyDownloadItemChange");
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:DOWNLOAD_ITEM_NOTIF_DID_CHANGED object:item];
}
//------------------------------------
// handleFetchItemStatusDidChanged
//------------------------------------
- (void)handleFetchItemStatusDidChanged:(NSNotification *)notification
{
	FetchItem *fetchItem = [notification object];

	if(fetchItem == nil){
		return;
	}

	int fetchStatus = [fetchItem itemStatus];
//	NSLog(@"fetchStatus=%d", fetchStatus);
	[self setFetchStatus:fetchStatus];
}
//------------------------------------
// handleFetchItemDidLoaded
//------------------------------------
- (void)handleFetchItemDidLoaded:(NSNotification *)notification
{

//	NSLog(@"handleDataItemDidLoad");

	FetchItem *fetchItem = [notification object];

	if(fetchItem == nil){
		return;
	}

	NSData *data = [fetchItem data];
	NSError *error = [fetchItem error];
	NSDictionary *userParams = [fetchItem userParams];
	NSString *watchURL = [userParams valueForKey:@"watchURL"];
	int fileFormatNo = [[userParams valueForKey:@"fileFormatNo"] intValue];
	int fileFormatMapNo = [self convertToFileFormatNoToFormatMapNo:fileFormatNo];

	NSString *errorLog = @"";

	// fetch error
	if(error != nil){
		errorLog = [NSString stringWithFormat: @"Download fetch Error - %@ %@"
										, [error localizedDescription]
										, [[error userInfo] objectForKey:NSErrorFailingURLStringKey]
					];
		[self setErrorLog:errorLog];
		[self setStatus:DOWNLOAD_FAILED];
		[self cancelNotifyTimer];
		[self notifyDownloadItemChange:self];
		return;
	}

	//
	// create html
	//
	NSStringEncoding encoding = [self getStringEncoding:data];
	NSString *html = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];

	// encoding error
	if(html == nil){
		errorLog = [NSString stringWithFormat:@"Can't get html from %@\nMaybe encoding error.", watchURL];
		[self setErrorLog:errorLog];
		[self setStatus:DOWNLOAD_FAILED];
		[self cancelNotifyTimer];
		[self notifyDownloadItemChange:self];
		return;
	}

	//
	// get formatURLMaps
	//
	NSString *errorMessage = @"";
	NSString *errorDescription = @"";
	NSMutableDictionary *formatURLMaps = [self getYouTubeFormatURLMaps:watchURL
																	html:html
															errorMessage:&errorMessage
															errorDescription:&errorDescription
										];
	// error
	if(formatURLMaps == nil){
		errorLog = [NSString stringWithFormat: @"Can not get file URLs - %@\nError = %@"
										, errorMessage
										, errorDescription
					];
		[self setErrorLog:errorLog];
		[self setStatus:DOWNLOAD_FAILED];
		[self cancelNotifyTimer];
		[self notifyDownloadItemChange:self];
		return;
	}

	// convert fileFormatNoMaps
	NSMutableDictionary *fileFormatNoMaps = [self convertToFileFormatNoMaps:formatURLMaps];
//	NSLog(@"fileFormatNoMaps=%@", [fileFormatNoMaps description]);

	// video file url
	NSString *downloadURL = [fileFormatNoMaps valueForKey:[self convertIntToString:fileFormatNo]];

//	NSLog(@"downloadURL=%@", downloadURL);

	if(!downloadURL || [downloadURL isEqualToString:@""]){

		errorLog = [NSString stringWithFormat: @"%@%@%@"
						, [NSString stringWithFormat:@"Can't find video URL from %@\n", watchURL]
						, [NSString stringWithFormat:@"May be fmt=%d video is not found.\n", fileFormatMapNo]
						, [NSString stringWithFormat:@"formatURLMaps = %@\n", [formatURLMaps description]]
					];
		[self setErrorLog:errorLog];
		[self setStatus:DOWNLOAD_FAILED];
		[self cancelNotifyTimer];
		[self notifyDownloadItemChange:self];
		return;
	}

	// create download instance
	[self setDownloadURL:downloadURL];
	[self setDownload:[self createDownload:downloadURL]];

	if([self download] == nil){
		errorLog = [NSString stringWithFormat: @"Failed creating download from %@", downloadURL];
		[self setErrorLog:errorLog];
		[self setStatus:DOWNLOAD_FAILED];
		[self cancelNotifyTimer];
		[self notifyDownloadItemChange:self];
	}

}

//------------------------------------
// download
//------------------------------------
- (void)setDownload:(NSURLDownload*)download
{
	[download retain];
	[download_ release];
	download_ = download;
}
- (NSURLDownload*)download
{
	return download_;
}
//------------------------------------
// setTotalLength
//------------------------------------
- (void)setTotalLength:(long long)totalLength
{
	totalLength_ = totalLength;
}
- (long long)totalLength
{
	return totalLength_;
}

//------------------------------------
// setReceivedLength
//------------------------------------
- (void)setReceivedLength:(long long)receivedLength
{
	receivedLength_ = receivedLength;
}
- (long long)receivedLength
{
	return receivedLength_;
}
//------------------------------------
// setStatus
//------------------------------------
- (void)setStatus:(int)status
{
	status_ = status;
}
- (int)status
{
	return status_;
}
//------------------------------------
// downloadURL
//------------------------------------
- (void)setDownloadURL:(NSString*)downloadURL
{
	[downloadURL retain];
	[downloadURL_ release];
	downloadURL_ = downloadURL;
}
- (NSString*)downloadURL
{
	return downloadURL_;
}
//------------------------------------
// watchURL
//------------------------------------
- (void)setWatchURL:(NSString*)watchURL
{
	[watchURL retain];
	[watchURL_ release];
	watchURL_ = watchURL;
}
- (NSString*)watchURL
{
	return watchURL_;
}
//------------------------------------
// fileName
//------------------------------------
- (void)setFileName:(NSString*)fileName
{
	[fileName retain];
	[fileName_ release];
	fileName_ = fileName;
}
- (NSString*)fileName
{
	return fileName_;
}
//------------------------------------
// filePath
//------------------------------------
- (void)setFilePath:(NSString*)filePath
{
	[filePath retain];
	[filePath_ release];
	filePath_ = filePath;
}
- (NSString*)filePath
{
	return filePath_;
}
//------------------------------------
// fileExt
//------------------------------------
- (void)setFileExt:(NSString*)fileExt
{
	[fileExt retain];
	[fileExt_ release];
	fileExt_ = fileExt;
}
- (NSString*)fileExt
{
	return fileExt_;
}
//------------------------------------
// fileFormatNo
//------------------------------------
- (void)setFileFormatNo:(int)fileFormatNo
{
    fileFormatNo_ = fileFormatNo;
}
- (int)fileFormatNo
{
    return fileFormatNo_;
}
//------------------------------------
// isGetURL
//------------------------------------
- (void)setIsGetURL:(BOOL)isGetURL
{
    isGetURL_ = isGetURL;
}
- (BOOL)isGetURL
{
    return isGetURL_;
}

//------------------------------------
// iconImage
//------------------------------------
- (void)setIconImage:(NSImage*)iconImage
{
	[iconImage retain];
	[iconImage_ release];
	iconImage_ = iconImage;
}
- (NSImage*)iconImage
{
	return iconImage_;
}
//------------------------------------
// errorLog
//------------------------------------
- (void)setErrorLog:(NSString*)errorLog
{
	[errorLog retain];
	[errorLog_ release];
	errorLog_ = errorLog;
}
- (NSString*)errorLog
{
	return errorLog_;
}
//------------------------------------
// fetchItem
//------------------------------------
- (void)setFetchItem:(FetchItem*)fetchItem
{
	[fetchItem retain];
	[fetchItem_ release];
	fetchItem_ = fetchItem;
}
- (FetchItem*)fetchItem
{
	return fetchItem_;
}
//------------------------------------
// cancelFetchItem
//------------------------------------
- (void)cancelFetchItem
{
//	NSLog(@"cancelFetchItem");

	FetchItem *fetchItem = [self fetchItem];
//	NSLog(@"fetchItem=%@", fetchItem);
	if(fetchItem){
		[fetchItem cancelConnection];
	}
}
//------------------------------------
// setFetchStatus
//------------------------------------
- (void)setFetchStatus:(int)fetchStatus
{
	fetchStatus_ = fetchStatus;
}
- (int)fetchStatus
{
	return fetchStatus_;
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
// notifyTimer
//------------------------------------
- (void)setNotifyTimer:(NSTimer*)notifyTimer
{
	[notifyTimer retain];
	[notifyTimer_ release];
	notifyTimer_ = notifyTimer;
}
- (NSTimer*)notifyTimer
{
	return notifyTimer_;
}
//------------------------------------
// startNotifyTimer
//------------------------------------
- (void)startNotifyTimer
{
//	NSLog(@"startNotifyTimer");
	// set timer for update
	[self setNotifyTimer:[NSTimer scheduledTimerWithTimeInterval:1.0
							target: self 
							selector:@selector(sendNotifyWithTimer:)
							userInfo:nil
							repeats: YES]
	];
	[[NSRunLoop currentRunLoop] addTimer:[self notifyTimer] forMode:(NSString*)kCFRunLoopCommonModes];

}
//------------------------------------
// cancelNotifyTimer
//------------------------------------
- (void)cancelNotifyTimer
{
	if([[self notifyTimer] isValid] == YES){
		[[self notifyTimer] invalidate];
//		NSLog(@"cancelNotifyTimer");
	}
	
}
//------------------------------------
// sendNotifyWithTimer
//------------------------------------
- (void)sendNotifyWithTimer:(NSTimer*)aTimer
{
	[self notifyDownloadItemChange:self];
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{

	[downloadURL_ release];
	[watchURL_ release];
	[fileName_ release];
	[filePath_ release];
	[fileExt_ release];
	[iconImage_ release];
	[errorLog_ release];
	[notifyTimer_ release];
	[requestTimer_ release];
	[download_ release];
	[fetchItem_ release];
	[super dealloc];
}
@end
