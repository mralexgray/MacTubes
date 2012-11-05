#import "DownloadManager.h"
#import "DownloadItem.h"
#import "LogStatusController.h"
#import "HelperExtension.h"
#import "YouTubeHelperExtension.h"
#import "ConvertExtension.h"
#import "DialogExtension.h"
#import "CellAttributeExtension.h"
#import "UserDefaultsExtension.h"

@implementation DownloadManager

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// window rect
	[self setWindowRect:downloadWindow key:@"rectWindowDownload"];

	[self setLogString:@""];
	[txtStatus setStringValue:@""];

	// alloc downloadList
	downloadList_ = [[NSMutableArray alloc] init];

	// set notification
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(downloadWindowWillClose:) name:NSWindowWillCloseNotification object:downloadWindow];
	// Register to get notified when the download manager's list changes
	[nc addObserver:self selector:@selector(handleDownloadsChange:) name:DOWNLOAD_ITEM_NOTIF_DID_CHANGED object:nil];

}
//=======================================================================
// Event Actions
//=======================================================================
//------------------------------------
// openDownloadWindow
//------------------------------------
- (IBAction)openDownloadWindow:(id)sender
{
	[downloadWindow makeKeyAndOrderFront:self];
}

//------------------------------------
// restartDownloadItem
//------------------------------------
- (IBAction)restartDownloadItem:(id)sender;
{

	[indProc startAnimation:self];

	[self setLogString:@""];

	if([self restartDownload] == NO){
//		NSLog(@"Can not restart download");
		[indProc stopAnimation:self];
		int result = [self displayMessage:@"alert"
						messageText:@"Can not restart download"
						infoText:@"Please check error log"
						btnList:@"Cancel,Log"
				];

		// show error log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Error Log"];
			[logStatusController setLogString:[self logString]];
			[logStatusController openLogWindow:nil];
		}else{
			[logStatusController setTitle:@""];
			[logStatusController setLogString:@""];
		}
		return;
	}

	[indProc stopAnimation:self];
}

//------------------------------------
// cancelDownloadItem
//------------------------------------
- (IBAction)cancelDownloadItem:(id)sender
{

	if ([tbvDownloadlist numberOfSelectedRows] <= 0){
		return;
	}
	int index = [[tbvDownloadlist selectedRowIndexes] firstIndex];

	id record = [[self downloadList] objectAtIndex:index];
	DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 

	[downloadItem cancelDownload];

}
//------------------------------------
// cancelAllDownloadItem
//------------------------------------
- (IBAction)cancelAllDownloadItem:(id)sender
{
	int i;

	for(i = 0; i < [[self downloadList] count]; i++){
		id record = [[self downloadList] objectAtIndex:i];
		DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 
		[downloadItem cancelDownload];
	}

}

//------------------------------------
// searchDownloadItem
//------------------------------------
- (IBAction)searchDownloadItem:(id)sender
{

	if ([tbvDownloadlist numberOfSelectedRows] <= 0){
		return;
	}
	int index = [[tbvDownloadlist selectedRowIndexes] firstIndex];

	id record = [[self downloadList] objectAtIndex:index];
	DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 

	NSString *filePath = [downloadItem filePath];
//	NSLog(@"filePath=%@", filePath);

	if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES){
		[[NSWorkspace sharedWorkspace] selectFile:filePath inFileViewerRootedAtPath:nil];
	}else{
//		NSLog(@"downloaded file is not found");
		[self displayMessage:@"alert"
						messageText:@"Downloaded file is not found"
						infoText:@""
						btnList:@"Cancel"
		];
	}

}
//------------------------------------
// copyItemToPasteboard
//------------------------------------
- (IBAction)copyItemToPasteboard:(id)sender
{
	if([tbvDownloadlist numberOfSelectedRows] <= 0){
		return;
	}
	int index = [[tbvDownloadlist selectedRowIndexes] firstIndex];

	id record = [[self downloadList] objectAtIndex:index];
	DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 

	NSString *url = [downloadItem downloadURL];
	[self copyStringToPasteboard:url];
}
//------------------------------------
// clearFinishedItem
//------------------------------------
- (IBAction)clearFinishedItem:(id)sender
{

	NSMutableArray *array = [self downloadList];

	id record;

	int index = [array count] - 1;

	while (index >= 0){
		record = [array objectAtIndex:index];
		DownloadItem *downloadItem = [record objectForKey:@"downloadItem"];

		int status = [downloadItem status];
		if( status == DOWNLOAD_COMPLETED ||
			status == DOWNLOAD_CANCELED ||
			status == DOWNLOAD_FAILED
		){
			[array removeObject:record];
		}
		index--;
	}
	[tbvDownloadlist reloadData];

	// set status
	[self setDownloadStatus];

}
//------------------------------------
// downloadItems
//------------------------------------
- (void)downloadItems:(NSDictionary*)object
{

	NSArray *items = [object objectForKey:@"items"];
	int fileFormatNo = [[object objectForKey:@"fileFormatNo"] intValue];

	// no count
	if([items count] <= 0){
		return;
	}
	// over count
	if([items count] > 5){
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

	// open window
//	[self openDownloadWindow:nil];

	for(i = 0; i < [items count]; i++){
		record = [items objectAtIndex:i];

		title = [record valueForKey:@"title"];
		url = [self convertToDownloadURL:[record valueForKey:@"itemId"]];
		interval = i * requestInterval;

		// start download
		[self startDownloadItem:url
						downloadURL:@""
						fileName:title
						fileFormatNo:fileFormatNo
						interval:interval
						isGetURL:YES
		];
	}

}
//------------------------------------
// startDownloadItem
//------------------------------------
- (BOOL)startDownloadItem:(NSString*)watchURL
				downloadURL:(NSString*)downloadURL
				fileName:(NSString*)fileName
				fileFormatNo:(int)fileFormatNo
				interval:(float)interval
				isGetURL:(BOOL)isGetURL
{
	BOOL ret = YES;

	[indProc startAnimation:self];

	[self setLogString:@""];

	// start download
	if([self startDownload:watchURL
					downloadURL:downloadURL
					fileName:fileName
					fileFormatNo:fileFormatNo
					interval:interval
					isGetURL:isGetURL
		] == NO){

		[indProc stopAnimation:self];

		int result = [self displayMessage:@"alert"
						messageText:@"Can not start download"
						infoText:@"Please check error log"
						btnList:@"Cancel,Log"
				];

		// show error log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Error Log"];
			[logStatusController setLogString:[self logString]];
			[logStatusController openLogWindow:nil];
		}else{
			[logStatusController setTitle:@""];
			[logStatusController setLogString:@""];
		}
		ret = NO;
	}

	[indProc stopAnimation:self];

	return ret;
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

/*
	//
	// get download url
	//
	if(isGetURL == YES || [downloadURL isEqualToString:@""]){
		downloadURL = [self getYouTubeDownloadURL:watchURL fileFormatNo:fileFormatNo];
	}
//	NSLog(@"downloadURL=%@", downloadURL);
*/

/*
	if([downloadURL isEqualToString:@""]){
//		NSLog(@"Can not create parsed url");
		return NO;
	}
*/
	//
	// start download
	//
	DownloadItem *downloadItem = [[[DownloadItem alloc] initWithURLString:watchURL
														downloadURL:downloadURL
														fileName:fileName
														fileFormatNo:fileFormatNo
														interval:interval			
														isGetURL:isGetURL
									] autorelease];

	if(downloadItem == nil){
		[self appendLogString:@"Can not create download"];
//		NSLog(@"Can not create download");
		return NO;
	}

	[downloadList_ addObject:
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			downloadItem, @"downloadItem" ,
			nil
		]
	];

	[tbvDownloadlist reloadData];

	return YES;
}
//------------------------------------
// restartDownload
//------------------------------------
- (BOOL)restartDownload
{

	// no select
	if ([tbvDownloadlist numberOfSelectedRows] <= 0){
		return NO;
	}
	int index = [[tbvDownloadlist selectedRowIndexes] firstIndex];

	//
	// get player url
	//
	id record = [[self downloadList] objectAtIndex:index];
	DownloadItem *downloadItem = [record objectForKey:@"downloadItem"];
	NSString *downloadURL = [downloadItem downloadURL];
	NSString *watchURL = [downloadItem watchURL];
	NSString *fileName = [downloadItem fileName];
	int fileFormatNo = [downloadItem fileFormatNo];
	BOOL isGetURL = [downloadItem isGetURL];
	float interval = 0.0f;
	//
	// get download url
	//
/*
	if(isGetURL == YES){
		downloadURL = [self getYouTubeDownloadURL:watchURL fileFormatNo:fileFormatNo];
	}
*/
//	NSLog(@"downloadURL=%@", downloadURL);

/*
	if([downloadURL isEqualToString:@""]){
		return NO;
	}
*/
	// cancel download
	[downloadItem cancelDownload];
	
	if([downloadItem startDownload:watchURL
						downloadURL:downloadURL
						fileName:fileName
						fileFormatNo:fileFormatNo
						interval:interval
						isGetURL:isGetURL
		] == NO){
//		NSLog(@"Can not restart download");
		[self appendLogString:@"Can not start download"];
		return NO;
	}

	[tbvDownloadlist reloadData];

	return YES;
}
//------------------------------------
// setDownloadStatus
//------------------------------------
- (void)setDownloadStatus
{

	int totalCount = [downloadList_ count];
	int activeCount = 0;
	int i;
	int status;
	DownloadItem *downloadItem;

	for(i = 0; i < totalCount; i++){

		downloadItem = [[downloadList_ objectAtIndex:i] objectForKey:@"downloadItem"]; 
		if(downloadItem != nil){
			status = [downloadItem status];
			if(status == DOWNLOAD_INIT || status == DOWNLOAD_STARTED){
				activeCount++;
			}
		}
	}

	// status
	[txtStatus setStringValue:[NSString stringWithFormat:@"%d of %d", activeCount, totalCount]];

	// dock icon
	[self setDockIconWithValue:activeCount];

}
//------------------------------------
// setDockIconWithValue
//------------------------------------
- (void)setDockIconWithValue:(int)value
{

	NSImage *appIcon = [NSImage imageNamed:@"NSApplicationIcon"];
	NSImage *image = [[NSImage alloc] initWithSize:[appIcon size]];
//	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(128,128)];

	NSRect imageBounds;
	imageBounds.origin.x = 0;
	imageBounds.origin.y = 0;
	imageBounds.size = [image size];

	[image lockFocus];

	[appIcon compositeToPoint:NSZeroPoint operation:NSCompositeDestinationOver];

	if(value > 0){

		NSString *valueString = @"";
		if(value < 10){
			valueString = [NSString stringWithFormat:@" %d ", value];
		}else{
			valueString = [NSString stringWithFormat:@"%d", value];
		}

		[self drawLabelAndString:imageBounds
						withString:valueString
						fontSize:32.0
						fontColor:[NSColor whiteColor]
						labelColor:[NSColor redColor]
						align:CELL_ALIGN_LEFT
						valign:CELL_VALIGN_TOP
						hPadding:8
						vPadding:12
						radius:15
		];

	}

	[image unlockFocus];

	[NSApp setApplicationIconImage:image];
}
//------------------------------------
// getYouTubeDownloadURL
//------------------------------------
- (NSString*)getYouTubeDownloadURL:(NSString*)watchURL fileFormatNo:(int)fileFormatNo
{

//	NSString *videoURL = [self convertToFileFormatURL:watchURL fileFormatNo:fileFormatNo];
	int fileFormatMapNo = [self convertToFileFormatNoToFormatMapNo:fileFormatNo];

	NSString *errorMessage = @"";
	NSString *errorDescription = @"";

	//
	// get html
	//
	NSString *html = [self getHTMLString:watchURL errorDescription:&errorDescription];

	if(html == nil){
		[self appendLogString:[NSString stringWithFormat:@"Can't get html from %@\n", watchURL]];
		[self appendLogString:[NSString stringWithFormat:@"Error = %@\n", errorDescription]];
		return @"";
	}

	//
	// get formatURLMaps
	//
	NSMutableDictionary *formatURLMaps = [self getYouTubeFormatURLMaps:watchURL
																	html:html
															errorMessage:&errorMessage
															errorDescription:&errorDescription
										];

	if(formatURLMaps == nil){
		[self appendLogString:errorMessage];
		[self appendLogString:[NSString stringWithFormat:@"Error = %@\n", errorDescription]];
		return @"";
	}

	// convert fileFormatNoMaps
	NSMutableDictionary *fileFormatNoMaps = [self convertToFileFormatNoMaps:formatURLMaps];
//	NSLog(@"fileFormatNoMaps=%@", [fileFormatNoMaps description]);

	// download url
	NSString *downloadURL = [fileFormatNoMaps valueForKey:[self convertIntToString:fileFormatNo]];
//	NSLog(@"downloadURL=%@", downloadURL);

	if(!downloadURL || [downloadURL isEqualToString:@""]){
		[self appendLogString:[NSString stringWithFormat:@"Can't find download URL from %@\n", watchURL]];
		[self appendLogString:[NSString stringWithFormat:@"May be fmt=%d video is not found.\n", fileFormatMapNo]];
		[self appendLogString:[NSString stringWithFormat:@"formatURLMaps = %@\n", [formatURLMaps description]]];
		return @"";
	}

	return downloadURL;

}

//------------------------------------
// handleDownloadsChange
//------------------------------------
-(void)handleDownloadsChange:(NSNotification *)notification
{
//	NSLog(@"handleDownloadsChange");
	DownloadItem *downloadItem = [notification object];
	NSString *errorLog = [downloadItem errorLog];

	[tbvDownloadlist reloadData];

	// faile error
	if([downloadItem status] == DOWNLOAD_FAILED){

		int result = [self displayMessage:@"alert"
						messageText:@"Can not start download"
						infoText:@"Please check error log"
						btnList:@"Cancel,Log"
				];

		// show error log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Error Log"];
			[logStatusController setLogString:errorLog];
			[logStatusController openLogWindow:nil];
		}else{
			[logStatusController setTitle:@""];
			[logStatusController setLogString:@""];
		}
	}

	// set status
	[self setDownloadStatus];

}
//------------------------------------
// logString
//------------------------------------
- (void)setLogString:(NSString*)logString
{
	[logString retain];
	[logString_ release];
	logString_ = logString;
}
- (void)appendLogString:(NSString *)logString;
{
	[self setLogString:[[self logString] stringByAppendingString:logString]];
}
- (NSString*)logString
{
	return logString_;
}
//------------------------------------
// isSelectedRows
//------------------------------------
- (BOOL)isSelectedRows
{
	if ([tbvDownloadlist numberOfSelectedRows] > 0){
		return YES;
	}else{
		return NO;
	}
}
//------------------------------------
// isDownloading
//------------------------------------
- (BOOL)isDownloading
{

	if ([tbvDownloadlist numberOfSelectedRows] <= 0){
		return NO;
	}

	int index = [[tbvDownloadlist selectedRowIndexes] firstIndex];

	id record = [[self downloadList] objectAtIndex:index];
	DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 
	if([downloadItem status] <= DOWNLOAD_COMPLETED){
		return YES;
	}else{
		return NO;
	}

}
//------------------------------------
// hasDownloadURL
//------------------------------------
- (BOOL)hasDownloadURL
{

	if ([tbvDownloadlist numberOfSelectedRows] <= 0){
		return NO;
	}

	int index = [[tbvDownloadlist selectedRowIndexes] firstIndex];

	id record = [[self downloadList] objectAtIndex:index];
	DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 
	NSString *downloadURL = [downloadItem downloadURL];
	if(downloadURL && ![downloadURL isEqualToString:@""]){
		return YES;
	}else{
		return NO;
	}

}

//------------------------------------
// downloadList
//------------------------------------
- (NSMutableArray*)downloadList
{
	return downloadList_;
}
//------------------------------------
// anyItemIsDownloading
//------------------------------------
- (BOOL)anyItemIsDownloading
{
	BOOL ret = NO;
	int i;

	for(i = 0; i < [[self downloadList] count]; i++){
		id record = [[self downloadList] objectAtIndex:i];
		DownloadItem *downloadItem = [record objectForKey:@"downloadItem"]; 
		if([downloadItem status] <= DOWNLOAD_STARTED){
			ret = YES;
			break;
		}
	}

	return ret;

}
//------------------------------------
// mainWindowWillClose
//------------------------------------
-(void)downloadWindowWillClose:(NSNotification *)notification
{

	// save state from user default
	// window rect
	[self saveWindowRect:downloadWindow key:@"rectWindowDownload"];

}

//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[logString_ release];
	[downloadList_ release];
	[super dealloc];
}
@end
