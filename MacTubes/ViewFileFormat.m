#import "ViewFileFormat.h"
#import "DownloadManager.h"
#import "LogStatusController.h"
#import "DialogExtension.h"
#import "ConvertExtension.h"
#import "YouTubeHelperExtension.h"
#import "HelperExtension.h"
#import "UserDefaultsExtension.h"

@implementation ViewFileFormat

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	// window position
	[self setWindowRect:fileFormatWindow key:@"rectWindowFileFormat"];

	[self setWatchURL:@""];
	[self setTitle:@""];
	[self setLogString:@""];
	[self setFetchItem:nil];

	[txtVideoTitle setStringValue:@""];
	[self setButtonStatus];

	fileFormatList_ = [[NSMutableArray alloc] init];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:fileFormatWindow];

}

//=======================================================================
// actions
//=======================================================================
//------------------------------------
// openFileFormatWindow
//------------------------------------
- (IBAction)openFileFormatWindow:(id)sender
{
	[fileFormatWindow makeKeyAndOrderFront:self];
}

//------------------------------------
// downloadItem
//------------------------------------
- (IBAction)downloadItem:(id)sender
{

	NSArray *items = [fileFormatList_ objectsAtIndexes:[tbvFileFormat selectedRowIndexes]];

	// no select
	if([items count] <= 0){
		return;
	}

	// open window
	[downloadManager openDownloadWindow:nil];

	NSString *title = [self title];
	NSString *watchURL = [self watchURL];

	NSString *downloadURL;
	int fileFormatNo;
	int i;
	id record;

	for(i = 0; i < [items count]; i++){

		record = [items objectAtIndex:i];

		downloadURL = [record valueForKey:@"downloadURL"];
		fileFormatNo = [[record valueForKey:@"fileFormatNo"] intValue];

		[downloadManager startDownloadItem:watchURL
									downloadURL:downloadURL
									fileName:title
									fileFormatNo:fileFormatNo
									interval:0.0f
									isGetURL:NO
		];
	}

}
//------------------------------------
// loadItems
//------------------------------------
- (void)loadItems:(NSDictionary*)object
{

	NSArray *items = [object objectForKey:@"items"];

	// no count
	if([items count] <= 0){
		return;
	}

	id record = [items objectAtIndex:0];
	NSString *itemId = [record valueForKey:@"itemId"];
	NSString *title = [record valueForKey:@"title"];

	[self loadFileFormatList:itemId title:title];

}
//------------------------------------
// copyLinkToPasteboard
//------------------------------------
- (IBAction)copyLinkToPasteboard:(id)sender
{

	NSArray *items = [fileFormatList_ objectsAtIndexes:[tbvFileFormat selectedRowIndexes]];

	// no select
	if([items count] <= 0){
		return;
	}

	// get first
	id record = [items objectAtIndex:0];

	NSString *downloadURL = [record valueForKey:@"downloadURL"];

	[self copyStringToPasteboard:downloadURL];

}

//=======================================================================
// methods
//=======================================================================
//----------------------
// loadFileFormatList
//----------------------
- (void)loadFileFormatList:(NSString*)itemId
					title:(NSString*)title
{

	if([itemId isEqualToString:@""]){
		return;
	}

	[self openFileFormatWindow:nil];

	// fetch data
	NSString *watchURL = [self convertToWatchURL:itemId];
	NSDictionary *userParams = [NSDictionary dictionaryWithObjectsAndKeys:
								itemId, @"itemId" ,
								title, @"title" ,
								watchURL, @"watchURL" ,
								[NSNumber numberWithInt:VIDEO_FORMAT_NO_HIGH], @"fileFormatNo" ,
								nil
							];

	[self cancelFetchItem];
	[self setFetchItem:[[[FetchItem alloc] initWithURL:watchURL
												userParams:userParams
												notifTarget:self
												reqParams:nil
							] autorelease]
	];

}
//----------------------
// setFileFormatList
//----------------------
- (void)setFileFormatList:(NSString*)itemId
					title:(NSString*)title
					fileFormatNoMaps:(NSDictionary*)fileFormatNoMaps
{

	[self openFileFormatWindow:nil];

	// add list
	[self addFileFormatList:fileFormatNoMaps];

	NSString *watchURL = [self convertToWatchURL:itemId];
	[self setWatchURL:watchURL];
	[self setTitle:title];
	[txtVideoTitle setStringValue:title];

}
//----------------------
// addFileFormatList
//----------------------
- (void)addFileFormatList:(NSDictionary*)formatNoMaps
{

	// remove all list
	[fileFormatList_ removeAllObjects];

	// add list
	NSString *key;
	NSString *value;
	NSString *name;
	NSString *description;
	int fileFormatNo;
	int fileFormatMapNo;
	int fileFormatOrder;
//	int i;


	// add to items
	NSMutableArray *items = [NSMutableArray array];

	NSEnumerator *enumKeys = [formatNoMaps keyEnumerator];
	while (key = [enumKeys nextObject]) {

		value = [formatNoMaps valueForKey:key];
		fileFormatNo = [key intValue];
		fileFormatMapNo = [self convertToFileFormatNoToFormatMapNo:fileFormatNo];
		fileFormatOrder = [self convertToFormatMapNoOrder:fileFormatMapNo];
		name = [self convertToFormatMapNoTitle:fileFormatMapNo];
		description = [self convertToFormatMapNoDescription:fileFormatMapNo];

		[items addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:fileFormatNo], @"formatNo" ,
				[NSNumber numberWithInt:fileFormatMapNo], @"formatMapNo" ,
				[NSNumber numberWithInt:fileFormatOrder], @"fileFormatOrder" ,
				name, @"name" ,
				description, @"description" ,
				value, @"downloadURL" ,
				nil
			]
		];
	}

	// sort items by formatNo
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fileFormatOrder" ascending:YES];
	NSArray *sortedItems = [items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];

	// add itrems to list
	[fileFormatList_ addObjectsFromArray:sortedItems];
//	for(i = 0; i < [sortedItems count]; i++){
//		[fileFormatList_ addObject:[sortedItems objectAtIndex:i];
//	}

	[tbvFileFormat reloadData];

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

	int itemStatus = [fetchItem itemStatus];

	if(itemStatus == FETCH_ITEM_STATUS_INIT){
		[indProc startAnimation:nil];
	}else{
		[indProc stopAnimation:nil];
	}

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
	NSString *title = [userParams valueForKey:@"title"];

	[self setLogString:@""];

	// fetch error
	if(error != nil){
		[self appendLogString:[NSString stringWithFormat:@"Can't get html from %@\n", watchURL]];
		[self appendLogString:[NSString stringWithFormat:@"Error = %@\n", [error description]]];
		[self displayMessageAlertWithOpenLog:@"Can not get file URLs"
							logString:[self logString]
							target:logStatusController
		];
		return;
	}

	//
	// create html
	//
	NSStringEncoding encoding = [self getStringEncoding:data];
	NSString *html = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];

	// encoding error
	if(html == nil){
		[self appendLogString:[NSString stringWithFormat:@"Can't get html from %@\n", watchURL]];
		[self appendLogString:@"Maybe encoding error."];
		[self displayMessageAlertWithOpenLog:@"Can not get file URLs"
							logString:[self logString]
							target:logStatusController
		];
		return;
	}

	//
	// get formatURLMaps
	//
	NSString *errorMessage = @"";
	NSString *errorDescription = @"";
	NSDictionary *formatURLMaps = [self getYouTubeFormatURLMaps:watchURL
															html:html
													errorMessage:&errorMessage
													errorDescription:&errorDescription
										];
	// error
	if(formatURLMaps == nil){
		[self appendLogString:errorMessage];
		[self appendLogString:[NSString stringWithFormat:@"Error = %@\n", errorDescription]];
		[self displayMessageAlertWithOpenLog:@"Can not get file URLs"
							logString:[self logString]
							target:logStatusController
		];
		return;
	}

	// convert to fileFormatNoMaps
	NSDictionary *fileFormatNoMaps = [self convertToFileFormatNoMaps:formatURLMaps];

	// add list
	[self addFileFormatList:fileFormatNoMaps];

	[self setWatchURL:watchURL];
	[self setTitle:title];
	[txtVideoTitle setStringValue:title];

}
//------------------------------------
// setButtonStatus
//------------------------------------
- (void)setButtonStatus
{
	BOOL enabled = [self isSelectedRows];

	[btnDownload setEnabled:enabled];
}
//------------------------------------
// windowWillClose
//------------------------------------
- (void)windowWillClose:(NSNotification *)notification
{

	[self cancelFetchItem];

	// save window rect
	if([notification object] == fileFormatWindow){
		[self saveWindowRect:fileFormatWindow key:@"rectWindowFileFormat"];
	}

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
	FetchItem *fetchItem = [self fetchItem];
	if(fetchItem){
		[fetchItem cancelConnection];
	}
}

//------------------------------------
// fileFormatList
//------------------------------------
- (NSMutableArray*)fileFormatList
{
	return fileFormatList_;
}
//------------------------------------
// isSelectedRows
//------------------------------------
- (BOOL)isSelectedRows
{
	if ([tbvFileFormat numberOfSelectedRows] > 0){
		return YES;
	}else{
		return NO;
	}
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
// title
//------------------------------------
- (void)setTitle:(NSString*)title
{
	[title retain];
	[title_ release];
	title_ = title;
}
- (NSString*)title
{
	return title_;
}
//------------------------------------
// setLogString
//------------------------------------
- (void)setLogString:(NSString*)logString
{
	[logString retain];
	[logString_ release];
	logString_ = logString;
}
- (void)appendLogString:(NSString *)logString
{
	[self setLogString:[[self logString] stringByAppendingString:logString]];
}
- (NSString*)logString
{
	return logString_;
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[fileFormatList_ release];
	[title_ release];
	[watchURL_ release];
	[logString_ release];
	[fetchItem_ release];

	[super dealloc];
}

@end
