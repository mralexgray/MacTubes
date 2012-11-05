#import "ViewPlayer.h"
#import "ViewRelatedSearch.h"
#import "ViewItemInfo.h"
#import "ViewFileFormat.h"
#import "TBArrayController.h"
#import "LogStatusController.h"
#import "DownloadManager.h"
#import "ContentItem.h"
#import "ConvertExtension.h"
#import "HelperExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"
#import "GDataYouTubeExtension.h"
#import "YouTubeHelperExtension.h"

@implementation ViewPlayer

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// window rect
	[self setWindowRect:playerWindow key:@"rectWindowPlayer"];

	// alloc video query
	if(videoQueryItem_ == nil){
		videoQueryItem_ = [[VideoQueryItem alloc] initWithTarget:self];
	}

	[self setPlayerType:[self defaultVideoPlayerType]];
	[self setFileFormatNo:VIDEO_FORMAT_NO_NORMAL];
	[self setFileFormatNoMaps:nil];

	[self setItemObject:nil];
	[self setFetchItem:nil];
	[self setLogString:@""];

	[self setArrayNo:CONTROL_BIND_ARRAY_NONE];
	[self setSelectTimer:nil];
	[self changeControlsHidden:[self defaultVideoPlayerType]];
	[self changeTabViewPlayer:[self defaultVideoPlayerType]];

	// set binding array

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClosePlayer:) name:NSWindowWillCloseNotification object:playerWindow];
//	[nc addObserver:self selector:@selector(handleDownloadStatusDidChanged:) name:CONNECTION_DOWNLOAD_NOTIF_STATUS_DID_CHANGED object:nil];
//	[nc addObserver:self selector:@selector(handleDownloadItemDidChanged:) name:CONNECTION_DOWNLOAD_NOTIF_ITEM_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoLoadingDidChanged:) name:VIDEO_NOTIF_LOADING_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoFileFormatDidChanged:) name:VIDEO_NOTIF_FILE_FORMAT_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleDefaultPlayerTypeDidChanged:) name:VIDEO_NOTIF_DEFAULT_PLAYER_TYPE_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoPlayerTypeDidChanged:) name:VIDEO_NOTIF_VIDEO_PLAYER_TYPE_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handlePlaySelectDidChanged:) name:CONTROL_NOTIF_PLAY_SELECT_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoObjectDidChanged:) name:VIDEO_NOTIF_OBJECT_DID_CHANGED object:nil];

}

//=======================================================================
// Event Actions
//=======================================================================
//------------------------------------
// openPlayerWindow
//------------------------------------
- (IBAction)openPlayerWindow:(id)sender;
{
	[playerWindow makeKeyAndOrderFront:self];
}
//------------------------------------
// openEnterURLWindow
//------------------------------------
- (IBAction)openEnterURLWindow:(id)sender;
{
	[playerWindow makeKeyAndOrderFront:self];
	[self openModalSheet:enterURLWindow parentWindow:playerWindow];
}

//------------------------------------
// closeEnterURLWindow
//------------------------------------
- (IBAction)closeEnterURLWindow:(id)sender
{

	[[NSApplication sharedApplication] endSheet:enterURLWindow];

}
//------------------------------------
// openPlayerViewWithURL
//------------------------------------
- (IBAction)openPlayerViewWithURL:(id)sender
{

	[self closeEnterURLWindow:nil];

	NSString *urlString = [txtURL stringValue];

	[self setPlayerViewWithURL:urlString];

}
//------------------------------------
// playItem
//------------------------------------
- (IBAction)playItem:(id)sender
{
	if([self hasItemObject] == NO){
		return;
	}

	int playerType = [self playerType];

	if(playerType == VIDEO_PLAYER_TYPE_SWF || playerType == VIDEO_PLAYER_TYPE_VIDEO){
		[webPlayerView setVideoPlay:![webPlayerView isPlaying]];
	}
	else if(playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		[qtPlayerView setVideoPlay:![qtPlayerView isPlaying]];
	}

}
//----------------------
// changeItem
//----------------------
- (IBAction)changeItem:(id)sender
{
	[self changePlayItem:[sender tag] isLoop:NO];
}

//----------------------
// replayItem
//----------------------
- (IBAction)replayItem:(id)sender
{

	ContentItem *itemObject = [self itemObject];
	if(itemObject == nil){
		return;
	}

	[self setPlayerView:itemObject arrayNo:[self arrayNo]];

}
//------------------------------------
// downloadItem
//------------------------------------
- (IBAction)downloadItem:(id)sender
{

	ContentItem *itemObject = [self itemObject];
	if(itemObject == nil){
		return;
	}

	int fileFormatNo = [sender tag];
	int playerType = [self playerType];

	// create parameter
	NSString *watchURL = [self convertToDownloadURL:[itemObject itemId]];
	NSString *title = [itemObject title];
	NSString *downloadURL = @"";
	BOOL isGetURL = YES;

	// video / quicktime player
	if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		NSMutableDictionary *fileFormatNoMaps = [self fileFormatNoMaps];
		NSString *fileFormatStr = [self convertIntToString:fileFormatNo];
		downloadURL = [fileFormatNoMaps valueForKey:fileFormatStr];
		if(downloadURL && ![downloadURL isEqualToString:@""]){
			isGetURL = NO;
		}else{
			downloadURL = @"";
		}
	}

	// start download
	[downloadManager openDownloadWindow:nil];
	[downloadManager startDownloadItem:watchURL
								downloadURL:downloadURL
								fileName:title
								fileFormatNo:fileFormatNo
								interval:0.0f
								isGetURL:isGetURL
	];

}
//------------------------------------
// openItemInfo
//------------------------------------
- (IBAction)openItemInfo:(id)sender
{

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 

	GDataEntryYouTubeVideo *video = [itemObject video];

	// no video
	if(video == nil){ 
		return;
	} 

	// get values
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

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
								itemObject, @"itemObject" ,
								itemId, @"itemId" ,
								title, @"title" ,
								author, @"author" ,
								description, @"description" ,
								playTime, @"playTime" ,
								viewCount, @"viewCount" ,
								publishedDate, @"publishedDate" ,
								rating, @"rating" ,
								[NSNumber numberWithInt:VIDEO_ENTRY_SUCCESS], @"itemStatus" ,
								[NSNumber numberWithBool:NO], @"isPlayed" ,
								[NSNumber numberWithInt:VIDEO_FORMAT_MAP_NONE], @"formatMapNo" ,
								nil
							];

	if([viewItemInfo createItemInfo:[self arrayNo] record:params] == YES){
		[viewItemInfo openInfoWindow:nil];
	}
}
//------------------------------------
// openVideoFormatItem
//------------------------------------
- (IBAction)openVideoFormatItem:(id)sender
{
	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 

	GDataEntryYouTubeVideo *video = [itemObject video];

	// no video
	if(video == nil){ 
		return;
	} 

	// get values
	NSDictionary *values = [self getYouTubeVideoValues:video];

	NSString *itemId = [values valueForKey:@"itemId"];
	NSString *title = [values valueForKey:@"title"];

	int playerType = [self playerType];
	// video / quicktime player
	if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		NSDictionary *fileFormatNoMaps = [self fileFormatNoMaps];
		[viewFileFormat setFileFormatList:itemId title:title fileFormatNoMaps:fileFormatNoMaps];
	}
	// flash player
	else{
		[viewFileFormat loadFileFormatList:itemId title:title];
	}

}

//------------------------------------
// openWatchWithBrowser
//------------------------------------
- (IBAction)openWatchWithBrowser:(id)sender
{

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 
	NSString *url = [itemObject watchURL];

	// open url
	[self openWatchURL:url];

}
//------------------------------------
// openContentWithBrowser
//------------------------------------
- (IBAction)openContentWithBrowser:(id)sender
{

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 
	NSString *url = [itemObject contentURL];

	// open url
	[self openContentURL:url];

}
//------------------------------------
// openAuthorsProfileWithBrowser
//------------------------------------
- (IBAction)openAuthorsProfileWithBrowser:(id)sender
{

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 
	NSString *author = [itemObject author];

	// open url
	[self openAuthorsProfileURL:author];
}
//------------------------------------
// addItemToPlaylist
//------------------------------------
- (IBAction)addItemToPlaylist:(id)sender
{

	NSManagedObject *targetItem = [sender representedObject];

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){
		return;
	}

	NSString *itemId = [itemObject itemId];
	NSString *title = [itemObject title];
	NSString *author = [itemObject author];

	// error
	if( [itemId isEqualToString:@""] ||
		[title isEqualToString:@""] ||
		[author isEqualToString:@""]
	){
		[self displayMessage:@"alert"
					messageText:@"Can not add video to playlist."
					infoText:@""
					btnList:@"Cancel"
		];
		return;
	}

	// create array for itemlist
 	NSMutableArray *items = [NSMutableArray array];
	[items addObject:
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			itemId, @"itemId" ,
			title, @"title" ,
			author, @"author" ,
			nil
		]
	];

	[tbArrayController createItemlist:[targetItem valueForKey:@"plistId"] items:items];

}
//------------------------------------
// searchRelatedItem
//------------------------------------
- (IBAction)searchRelatedItem:(id)sender
{

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 

	NSString *url = [itemObject relatedURL];

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

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 

	NSString *author = [itemObject author];
	NSString *url = [self convertToAuthorsUploadURL:author];    

	if(![url isEqualToString:@""]){
		[viewRelatedSearch openRelatedWindow:nil];
		[viewRelatedSearch searchWithURL:url startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_URL searchSubType:SEARCH_WITH_URL_AUTHOR];
	}

}
//------------------------------------
// copyItemToPasteboard
//------------------------------------
- (IBAction)copyItemToPasteboard:(id)sender
{

	ContentItem *itemObject = [self itemObject]; 
	if(itemObject == nil){ 
		return;
	} 

	NSString *string = @"";
	// url
	if([sender tag] == 0){
		string = [itemObject watchURL];
		// convert
		string = [self convertToFileFormatURL:string fileFormatNo:[self defaultPlayFileFormatNo]];
	}
	// title
	else if([sender tag] == 1){
		string = [itemObject title];
	}
	// author
	else if([sender tag] == 2){
		string = [itemObject author];
	}

	[self copyStringToPasteboard:string];

}
//=======================================================================
// methods
//=======================================================================
//------------------------------------
// setPlayerView
//------------------------------------
- (BOOL)setPlayerView:(ContentItem*)itemObject arrayNo:(int)arrayNo
{
	BOOL isHidden = NO;
	int playerType = [self defaultVideoPlayerType];
	if( (playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME) &&
//		([NSApp isHidden] == YES || [playerWindow isMiniaturized] == YES)
		([NSApp isHidden] == YES)
	){
		isHidden = YES;
	}
	if(isHidden == NO){
		[self openPlayerWindow:nil];
	}

	if([self createPlayerView:itemObject arrayNo:arrayNo] == NO){

//		int playRepeat = [self defaultPlayRepeat];
//		// next item
//		if(playRepeat == PLAY_REPEAT_ALL){
//			[self changePlayItem:CONTROL_SELECT_ITEM_NEXT isLoop:YES];
//			return NO;
//		}

		int result = [self displayMessageAlertOpenVideo:[itemObject watchURL]];
		// show error log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setLogString:[self logString]];
			[logStatusController setTitle:@"Error Log"];
			[logStatusController openLogWindow:nil];
		}
		// open video
		else if(result == NSAlertThirdButtonReturn){
			[self openWatchURL:[itemObject watchURL]];
		}
		[logStatusController setTitle:@""];
		[logStatusController setLogString:@""];
		return NO;

	}
	return YES;
}
//------------------------------------
// createPlayerView
//------------------------------------
- (BOOL)createPlayerView:(ContentItem*)itemObject arrayNo:(int)arrayNo
{

	[self setLogString:@""];

	// null object
	if(itemObject == nil){
		[self appendLogString:@"Error = Video item is not found.\n"];
		return NO;
	}

	// post notification
	if(arrayNo != CONTROL_BIND_ARRAY_NONE && arrayNo != [self arrayNo]){
		[self setArrayNo:arrayNo];
		[self postControlBindArrayChangedNotification:arrayNo];
	}

	int playerType = [self defaultVideoPlayerType];

	// same object
	if(itemObject == [self itemObject] &&
		playerType == [self playerType]
	){
		return YES;
	}

	// stop
	[webPlayerView setVideoPlay:NO];
	[webPlayerView stopLoading];
	[qtPlayerView setVideoPlay:NO];

	// clear
//	[self clearConnection];

	NSString *videoURL = [itemObject contentURL];
	int fileFormatNo = VIDEO_FORMAT_NO_NORMAL;
	BOOL ret = NO;;

	// swf player
	if(playerType == VIDEO_PLAYER_TYPE_SWF){
		// create player view
		ret = [webPlayerView createPlayerView:itemObject
								videoURL:videoURL
								playerType:playerType
								fileFormatNo:fileFormatNo
				];
		if(ret == YES){
			// change values
			[self setPlayerValues:itemObject
							playerType:playerType
							fileFormatNo:fileFormatNo
							fileFormatNoMaps:nil
			];

			// update history
			[self updateHistory:itemObject];
		}else{
			[self appendLogString:@"Error = failed creating swf player.\n"];
		}
	}
	// video / quicktime player
	else if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		ret = [self createVideoPlayer:itemObject playerType:playerType];
	}

//	if(ret == YES){
//		[self changeTabViewPlayer:playerType];
//	}

	return ret;

}
//------------------------------------
// createVideoPlayer
//------------------------------------
- (BOOL)createVideoPlayer:(ContentItem*)itemObject playerType:(int)playerType
{

	if(itemObject == nil){
		[self appendLogString:@"Error = Video item is not found.\n"];
		return NO;
	}

	NSString *videoId = [itemObject itemId];
	NSString *videoURL = [self convertToWatchURL:videoId];

	// fetch data
	NSDictionary *userParams = [NSDictionary dictionaryWithObjectsAndKeys:
								videoId, @"videoId" ,
								videoURL, @"videoURL" ,
								itemObject, @"itemObject" ,
								[NSNumber numberWithInt:playerType], @"playerType" ,
								nil
							];

	[self cancelFetchItem];
	[self setFetchItem:[[[FetchItem alloc] initWithURL:videoURL
												userParams:userParams
												notifTarget:self
												reqParams:nil
							] autorelease]
	];

	return YES;

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

	NSString *videoURL = [userParams valueForKey:@"videoURL"];
	ContentItem *itemObject = [userParams valueForKey:@"itemObject"];
	int playerType = [[userParams valueForKey:@"playerType"] intValue];

	[self setLogString:@""];

	// fetch error
	if(error != nil){
		[self appendLogString:[NSString stringWithFormat:@"Can't get html from %@\n", videoURL]];
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
		[self appendLogString:[NSString stringWithFormat:@"Can't get html from %@\n", videoURL]];
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
	NSMutableDictionary *formatURLMaps = [self getYouTubeFormatURLMaps:videoURL
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

	// mp4 format for video playing
	int fileFormatNoForVideo = VIDEO_FORMAT_NO_HIGH;
	int fileFormatMapNoForVideo = [self convertToFileFormatNoToFormatMapNo:fileFormatNoForVideo];

/*
	// reget formatURLMaps from original videoURL
	if(
		(![formatURLMaps valueForKey:[self convertIntToString:fileFormatMapNoForVideo]])
	){

		// append formatNo
		videoURL = [self convertToFileFormatURL:videoURL fileFormatNo:fileFormatNoForVideo];

		//
		// get html
		//
		html = [self getHTMLString:videoURL errorDescription:&errorDescription];

		[indProc stopAnimation:nil];

		if(html == nil){
			[self appendLogString:[NSString stringWithFormat:@"Can't get html from %@\n", videoURL]];
			[self appendLogString:[NSString stringWithFormat:@"Error = %@\n", errorDescription]];
			[self displayMessageAlertWithOpenLog:@"Can not get file URLs"
								logString:[self logString]
								target:logStatusController
			];
			return;
		}

		NSMutableDictionary *formatURLMapsForVideo = [self getYouTubeFormatURLMaps:html
																errorMessage:&errorMessage
																errorDescription:&errorDescription
											];

//		NSLog(@"formatURLMapsForVideo=%@", [formatURLMapsForVideo description]);
		// add to formatURLMaps
		if(formatURLMapsForVideo != nil){
			[formatURLMaps addEntriesFromDictionary:formatURLMapsForVideo];
		}
	}

*/

	// convert fileFormatNoMaps
	NSMutableDictionary *fileFormatNoMaps = [self convertToFileFormatNoMaps:formatURLMaps];
//	NSLog(@"fileFormatNoMaps=%@", [fileFormatNoMaps description]);

	// video file url
	NSString *videoFileURL = [fileFormatNoMaps valueForKey:[self convertIntToString:fileFormatNoForVideo]];

//	NSLog(@"videoFileURL=%@", videoFileURL);

	if(!videoFileURL || [videoFileURL isEqualToString:@""]){
		[self appendLogString:[NSString stringWithFormat:@"Can't find video URL from %@\n", videoURL]];
		[self appendLogString:[NSString stringWithFormat:@"May be fmt=%d video is not found.\n", fileFormatMapNoForVideo]];
		[self appendLogString:[NSString stringWithFormat:@"formatURLMaps = %@\n", [formatURLMaps description]]];
		[self displayMessageAlertWithOpenLog:@"Can not get file URLs"
							logString:[self logString]
							target:logStatusController
		];
		return;
	}

	//
	// create player view
	//
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
								videoURL, @"videoURL" ,
								itemObject, @"itemObject" ,
								[NSNumber numberWithInt:playerType], @"playerType" ,
								[NSNumber numberWithInt:fileFormatNoForVideo], @"fileFormatNo" ,
								fileFormatNoMaps, @"fileFormatNoMaps" ,
								nil
			];

	[self createVideoPlayerView:videoFileURL params:params];

}
//------------------------------------
// createVideoPlayerView
//------------------------------------
- (BOOL)createVideoPlayerView:(NSString *)urlString params:(NSDictionary*)params
{

	ContentItem *itemObject = [params valueForKey:@"itemObject"]; 

	NSMutableDictionary *fileFormatNoMaps = [params valueForKey:@"fileFormatNoMaps"];
	int playerType = [[params valueForKey:@"playerType"] intValue];
	int fileFormatNo = [[params valueForKey:@"fileFormatNo"] intValue];
	NSString *fileFormatNoStr = [self convertIntToString:fileFormatNo];
	BOOL ret = NO;

	// add to formatNo 18
	if(fileFormatNo == VIDEO_FORMAT_NO_HIGH){
		if(![fileFormatNoMaps valueForKey:fileFormatNoStr]){
			[fileFormatNoMaps setValue:urlString forKey:fileFormatNoStr];
		}
	}

	// change to HD video format
	BOOL isPlayHighQuality = [self defaultPlayHighQuality];
	if(isPlayHighQuality == YES){
		// HD
		fileFormatNoStr = [self convertIntToString:VIDEO_FORMAT_NO_HD];
		if([fileFormatNoMaps valueForKey:fileFormatNoStr]){
			urlString = [fileFormatNoMaps valueForKey:fileFormatNoStr];
			fileFormatNo = VIDEO_FORMAT_NO_HD;
		}
		else{
			// HD1080
			fileFormatNoStr = [self convertIntToString:VIDEO_FORMAT_NO_HD_1080];
			if([fileFormatNoMaps valueForKey:fileFormatNoStr]){
				urlString = [fileFormatNoMaps valueForKey:fileFormatNoStr];
				fileFormatNo = VIDEO_FORMAT_NO_HD_1080;
			}
		}
	}

	//
	// create player view
	//
	// video
	//
	if(playerType == VIDEO_PLAYER_TYPE_VIDEO){
		ret = [webPlayerView createPlayerView:itemObject
								videoURL:urlString
								playerType:playerType
								fileFormatNo:fileFormatNo
				];
	}
	//
	// quicktime
	//
	else if(playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		ret = [qtPlayerView createPlayerView:itemObject
								videoURL:urlString
								playerType:playerType
								fileFormatNo:fileFormatNo
				];
	}

	// success
	if(ret == YES){
		// change values
		[self setPlayerValues:itemObject
						playerType:playerType
						fileFormatNo:fileFormatNo
						fileFormatNoMaps:fileFormatNoMaps
		];

		// update history
		[self updateHistory:itemObject];

	}

	return ret;

}
//------------------------------------
// clearPlayerView
//------------------------------------
- (void)clearPlayerView
{
	[webPlayerView clearPlayerView];
	[webPlayerView postClearNotifications];

	[qtPlayerView clearPlayerView];
	[qtPlayerView postClearNotifications];

//	[self clearConnection];
	[self setItemObject:nil];

	[self setFileFormatNo:VIDEO_FORMAT_NO_NORMAL];
	[self setFileFormatNoMaps:nil];
	[self setPlayerTitle:@"Player"];

}
//------------------------------------
// setPlayerValues
//------------------------------------
- (void)setPlayerValues:(ContentItem*)itemObject
			playerType:(int)playerType
			fileFormatNo:(int)fileFormatNo
			fileFormatNoMaps:(NSMutableDictionary*)fileFormatNoMaps
{
	if(itemObject == nil){
		return;
	}

	int oldPlayerType = [self playerType];
	NSString *title = [itemObject title];

	[self setItemObject:itemObject];
	[self setPlayerType:playerType];
	[self setFileFormatNo:fileFormatNo];
	[self setFileFormatNoMaps:fileFormatNoMaps];

	[self setPlayerTitle:title];

	// post notification
	[self postVideoPlayerTypeNotification:playerType oldPlayerType:oldPlayerType];
	[self postVideoStatusChangedNotification:
				[NSDictionary dictionaryWithObjectsAndKeys:
										title, @"title",
										nil
				]
	];


}

//------------------------------------
// setPlayerViewStatus
//------------------------------------
- (BOOL)setPlayerViewStatus:(ContentItem*)itemObject
{

	if(itemObject == nil){
		return NO;
	}

	// update history
	[self updateHistory:itemObject];

	// set itemObject
	[self setItemObject:itemObject];

	NSString *title = [itemObject title];
	[self setPlayerTitle:title];

	// post notification
	[self postVideoStatusChangedNotification:
				[NSDictionary dictionaryWithObjectsAndKeys:
										title, @"title",
										nil
				]
	];

	return YES;

}
//----------------------
// setPlayerTitle
//----------------------
- (void)setPlayerTitle:(NSString*)title
{
	[playerWindow setTitle:title];
}

//------------------------------------
// setPlayerViewWithURL
//------------------------------------
- (BOOL)setPlayerViewWithURL:(NSString*)urlString
{

	// null error
	if(!urlString || [urlString isEqualToString:@""]){
		return NO;
	}

	// get last id (watch?v=NbvQN7B6PcY -> NbvQN7B6PcY)
	NSString *itemId = [self getItemIdFromURL:urlString];
	[self setPlayerViewWithItemId:itemId arrayNo:CONTROL_BIND_ARRAY_NONE];

	return YES;

}
//------------------------------------
// setPlayerViewWithItemId
//------------------------------------
- (void)setPlayerViewWithItemId:(NSString*)itemId arrayNo:(int)arrayNo
{

	// set binding array no
	if(arrayNo != CONTROL_BIND_ARRAY_NONE && arrayNo != [self arrayNo]){
		[self setArrayNo:arrayNo];
		[self postControlBindArrayChangedNotification:arrayNo];
	}

	// set params
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								itemId, @"itemId" ,
								[NSNumber numberWithBool:YES], @"isPlay" ,
								nil
							];

	// query entry
	NSString *url = [self decodeToPercentEscapesString:[self convertToEntryURL:itemId]];
	[videoQueryItem_ fetchFeedWithEntryURL:url queryParams:queryParams];

}
//------------------------------------
// setItemObjectWithItemId
//------------------------------------
- (void)setItemObjectWithItemId:(NSString*)itemId
{
	// set params
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								itemId, @"itemId" ,
								[NSNumber numberWithBool:NO], @"isPlay" ,
								nil
							];

	// query entry
	NSString *url = [self decodeToPercentEscapesString:[self convertToEntryURL:itemId]];

	[videoQueryItem_ fetchFeedWithEntryURL:url queryParams:queryParams];


}
//------------------------------------
// setPlayerViewWithFormatNo
//------------------------------------
- (BOOL)setPlayerViewWithFormatNo:(int)fileFormatNo
{

	ContentItem *itemObject = [self itemObject];
	if(itemObject == nil){
		return NO;
	}

	// same formatNo
	if(fileFormatNo == [self fileFormatNo]){
		return YES;		
	}

	NSMutableDictionary *fileFormatNoMaps = [self fileFormatNoMaps];
	NSString *fileFormatStr = [self convertIntToString:fileFormatNo];
	int playerType = [self playerType];

	// found
	if([fileFormatNoMaps valueForKey:fileFormatStr]){

		NSString *urlString = [fileFormatNoMaps valueForKey:fileFormatStr];
		BOOL ret = NO;

		// create player view
		if(playerType == VIDEO_PLAYER_TYPE_VIDEO){
			ret = [webPlayerView createPlayerView:itemObject
									videoURL:urlString
									playerType:playerType
									fileFormatNo:fileFormatNo
					];
		}
		else if(playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
			ret = [qtPlayerView createPlayerView:itemObject
									videoURL:urlString
									playerType:playerType
									fileFormatNo:fileFormatNo
					];
		}
		if(ret == YES){
			// set property
			[self setFileFormatNo:fileFormatNo];
		}
		return ret;
	}
	// retry getting video
	else{
		return [self setPlayerView:itemObject arrayNo:[self arrayNo]];
	}

	return NO;

}
//------------------------------------
// updateHistory
//------------------------------------
- (void)updateHistory:(ContentItem*)itemObject
{
	// update history
	NSString *itemId = [itemObject itemId];
	NSString *title = [itemObject title];
	NSString *author = [itemObject author];
	[tbArrayController createPlayHistory:itemId title:title author:author];

}
//------------------------------------
// changePlayItem
//------------------------------------
- (void)changePlayItem:(int)tag isLoop:(BOOL)isLoop
{

	// clear timer
	[self clearSelectTimer];

	// select
	if([self selectPlayItem:tag isLoop:isLoop] == YES){

		// play with timer
		[self setSelectTimer:[NSTimer scheduledTimerWithTimeInterval:0.5
								target:self 
								selector:@selector(playItemWithTimer:)
								userInfo:nil
								repeats: NO]
		];
		[[NSRunLoop currentRunLoop] addTimer:[self selectTimer] forMode:(NSString*)kCFRunLoopCommonModes];
	}

}
//------------------------------------
// selectPlayItem
//------------------------------------
- (BOOL)selectPlayItem:(int)tag isLoop:(BOOL)isLoop
{

	BOOL isSelect = NO;

	NSArrayController *arrayController = [self arrayController:[self arrayNo]];

	// no objects
	if( arrayController == nil ||
		[[arrayController arrangedObjects] count] <= 0){
		return isSelect;
	}

	int count = [[arrayController arrangedObjects] count];

	// previous
	if(tag == CONTROL_SELECT_ITEM_PREVIOUS){
		if([arrayController canSelectPrevious] == YES){
			[arrayController selectPrevious:nil];
			isSelect = YES;
		}else{
			// go to last
			if(isLoop == YES && count > 0){
				[arrayController setSelectionIndex:(count - 1)];
				isSelect = YES;
			}
		}

	}
	// next
	else if(tag == CONTROL_SELECT_ITEM_NEXT){
		if([arrayController canSelectNext] == YES){
			[arrayController selectNext:nil];
			isSelect = YES;
		}else{
			// go to top
			if(isLoop == YES && count > 0){
				[arrayController setSelectionIndex:0];
				isSelect = YES;
			}
		}
	}

	return isSelect;
}
//------------------------------------
// playItemWithTimer
//------------------------------------
- (void)playItemWithTimer:(id)sender
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:CONTROL_NOTIF_PLAY_ITEM_DID_CHANGED object:[NSNumber numberWithInt:[self arrayNo]]];

}
//------------------------------------
// changeTabViewPlayer
//------------------------------------
- (void)changeTabViewPlayer:(int)playerType
{
	int index = 0;
	if(playerType == VIDEO_PLAYER_TYPE_SWF || playerType == VIDEO_PLAYER_TYPE_VIDEO){
		// clear player view
		if([qtPlayerView hasVideo] == YES){
			[qtPlayerView clearPlayerView];
		}
		index = 0;
	}
	else if(playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		// clear player view
		if([webPlayerView hasVideo] == YES){
			[webPlayerView clearPlayerView];
		}
		index = 1;
	}

	if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		[self cancelFetchItem];
	}

	[tabViewPlayer selectTabViewItemAtIndex:index];

}

//------------------------------------
// changeControlsHidden
//------------------------------------
- (void)changeControlsHidden:(int)playerType
{
	BOOL hidden = NO;
	if(playerType == VIDEO_PLAYER_TYPE_SWF){
		hidden = YES;
	}

//	[sliderPlayVolume setHidden:hidden];
	[btnFileFormatNo setHidden:hidden];

}

//------------------------------------
// handleQueryStatusChanged
//------------------------------------
- (void)handleQueryStatusChanged:(NSDictionary*)params
{
//	NSLog(@"handleQueryStatusChanged");
	// none
}
//------------------------------------
// handleQueryFeedFetched
//------------------------------------
- (void)handleQueryFeedFetched:(NSDictionary*)params
{
//	NSLog(@"handleQueryFeedFetched");
	// none 
}
//------------------------------------
// handleQueryEntryFetched
//------------------------------------
- (void)handleQueryEntryFetched:(NSDictionary*)params
{

//	NSLog(@"handleQueryEntryFetched");

	if(params == nil){
		return;
	}

	GDataFeedBase *feed = [params valueForKey:@"feed"];
	GDataEntryBase *entry = (GDataEntryBase *)feed;
	int status = [[params valueForKey:@"itemStatus"] intValue];
	NSDictionary *queryParams = [params valueForKey:@"queryParams"];
	NSString* errorDescription = [params valueForKey:@"errorDescription"];

//	NSLog(@"status=%d", status);

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
	[videoQueryItem_ fetchEntryImageWithURL:urlString
								index:0
								withVideo:video
								queryParams:queryParams
								queryType:VIDEO_QUERY_TYPE_ENTRY
	];

}
//------------------------------------
// handleEntryImageFetched
//------------------------------------
- (void)handleEntryImageFetched:(NSDictionary*)params
{

//	NSLog(@"handleEntryImageFetched");

	if(params == nil){
		return;
	}

	GDataEntryYouTubeVideo *video = [params valueForKey:@"video"];
//	NSImage *image = [params valueForKey:@"image"];
	NSData *imageData = [params valueForKey:@"imageData"];
	int status = [[params valueForKey:@"itemStatus"] intValue];
	NSDictionary *queryParams = [params valueForKey:@"queryParams"];
	NSString* errorDescription = [params valueForKey:@"errorDescription"];
	int result;

	// not success
	if(status != VIDEO_ENTRY_SUCCESS){

		[logStatusController setLogString:[NSString stringWithFormat:@"Error %@\n", errorDescription]];

		result = [self displayMessage:@"alert"
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

	// create itemObject
	NSImage *image = [[[NSImage alloc] initWithData:imageData] autorelease];

	// get values
	NSDictionary *values = [self getYouTubeVideoValues:video];

	NSString *itemId = [values valueForKey:@"itemId"];
	NSString *author = [values valueForKey:@"author"];

	// null value
	if(!itemId || [itemId isEqualToString:@""]){
		[logStatusController setLogString:@"Error videoID is not found\n"];

		result = [self displayMessage:@"alert"
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

	ContentItem *itemObject = [[[ContentItem alloc] initVideo:video image:image author:author itemId:itemId] autorelease];

	// query params
	BOOL isPlay = [[queryParams objectForKey:@"isPlay"] boolValue];

	// set player view or status
	if(isPlay == YES){
		[self setPlayerView:itemObject arrayNo:[self arrayNo]];
	}else{
		[self setPlayerViewStatus:itemObject];
	}

}


//------------------------------------
// handleVideoLoadingDidChanged
//------------------------------------
- (void)handleVideoLoadingDidChanged:(NSNotification *)notification
{
	BOOL isLoading = [[notification object] boolValue];

	if(isLoading == YES){
		[indProc startAnimation:nil];
	}
	else{
		[indProc stopAnimation:nil];
	}

}
//------------------------------------
// handleVideoFileFormatDidChanged
//------------------------------------
- (void)handleVideoFileFormatDidChanged:(NSNotification *)notification
{
	int fileFormatNo = [[notification object] intValue];

	[self setPlayerViewWithFormatNo:fileFormatNo];

}
//------------------------------------
// handleDefaultPlayerTypeDidChanged
//------------------------------------
- (void)handleDefaultPlayerTypeDidChanged:(NSNotification *)notification
{
//	int playerType = [[notification object] intValue];

	[self replayItem:nil];

}
//------------------------------------
// handleVideoPlayerTypeDidChanged
//------------------------------------
- (void)handleVideoPlayerTypeDidChanged:(NSNotification *)notification
{

	int playerType = [[notification object] intValue];

	[self changeControlsHidden:playerType];
	[self changeTabViewPlayer:playerType];

}
//------------------------------------
// handlePlaySelectDidChanged
//------------------------------------
- (void)handlePlaySelectDidChanged:(NSNotification *)notification
{
	int tag = [[[notification object] valueForKey:@"tag"] intValue];
	BOOL isLoop = [[[notification object] valueForKey:@"isLoop"] boolValue];

	[self changePlayItem:tag isLoop:isLoop];
}
//------------------------------------
// handleVideoObjectDidChanged
//------------------------------------
- (void)handleVideoObjectDidChanged:(NSNotification *)notification
{
	BOOL hasVideo = [[notification object] boolValue];

	[sliderPlayVolume setEnabled:hasVideo];
}

//------------------------------------
// postControlBindArrayChangedNotification
//------------------------------------
- (void)postControlBindArrayChangedNotification:(int)arrayNo
{
	NSArrayController *arrayController = [self arrayController:arrayNo];
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:CONTROL_NOTIF_PLAY_ARRAY_DID_CHANGED object:arrayController];
}
//------------------------------------
// postVideoPlayerTypeNotification
//------------------------------------
- (void)postVideoPlayerTypeNotification:(int)newPlayerType oldPlayerType:(int)oldPlayerType
{
	// post notification
	if(newPlayerType != oldPlayerType){
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:VIDEO_NOTIF_VIDEO_PLAYER_TYPE_DID_CHANGED object:[NSNumber numberWithInt:newPlayerType]];
	}
}
//------------------------------------
// postVideoStatusChangedNotification
//------------------------------------
- (void)postVideoStatusChangedNotification:(NSDictionary*)params
{
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:VIDEO_NOTIF_STATUS_DID_CHANGED object:params];
}

//------------------------------------
// openModalSheet
//------------------------------------
- (void)openModalSheet:(NSWindow*)childindow parentWindow:(NSWindow*)parentWindow
{
	[[NSApplication sharedApplication] beginSheet:childindow
									modalForWindow:parentWindow
									modalDelegate:self
									didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
									contextInfo: nil
	];
}
//------------------------------------
// showCustomSheet
//------------------------------------
- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
}
//------------------------------------
// windowWillClosePlayer
//------------------------------------
-(void)windowWillClosePlayer:(NSNotification *)notification
{
	[self cancelFetchItem];
	[self clearPlayerView];

	// window rect
	[self saveWindowRect:playerWindow key:@"rectWindowPlayer"];

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
// itemObject
//------------------------------------
- (void)setItemObject:(ContentItem*)itemObject
{
	[itemObject retain];
	[itemObject_ release];
	itemObject_ = itemObject;
}
- (ContentItem*)itemObject
{
	return itemObject_;
}
//------------------------------------
// playerType
//------------------------------------
- (void)setPlayerType:(int)playerType
{
	playerType_ = playerType;
}
- (int)playerType
{
	return playerType_;
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
// setFileFormatNoMaps
//------------------------------------
- (void)setFileFormatNoMaps:(NSMutableDictionary*)fileFormatNoMaps
{
	[fileFormatNoMaps retain];
	[fileFormatNoMaps_ release];
	fileFormatNoMaps_ = fileFormatNoMaps;
}
- (NSMutableDictionary*)fileFormatNoMaps
{
	return fileFormatNoMaps_;
}

//------------------------------------
// setArrayNo
//------------------------------------
- (void)setArrayNo:(int)arrayNo
{
	arrayNo_ = arrayNo;
}
- (int)arrayNo
{
	return arrayNo_;
}
//------------------------------------
// arrayController
//------------------------------------
- (NSArrayController*)arrayController:(int)arrayNo
{

	if(arrayNo == CONTROL_BIND_ARRAY_SEARCH){
		return searchlistArrayController;
	}
	else if(arrayNo == CONTROL_BIND_ARRAY_RELATED){
		return relatedlistArrayController;
	}
	else if(arrayNo == CONTROL_BIND_ARRAY_PLAYHISTORY){
		return playhistoryArrayController;
	}

	return nil;
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
// setLogString
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
// isVisiblePlayerWindow
//------------------------------------
- (BOOL)isVisiblePlayerWindow
{
	return [playerWindow isVisible];
}
//------------------------------------
// isMainPlayerWindow
//------------------------------------
- (BOOL)isMainPlayerWindow
{
	BOOL ret = NO;

	// main window / visible
	if( [playerWindow isMainWindow] == YES ||
		[self isVisiblePlayerWindow] == YES
	){
		ret = YES;
	}
	return ret;
}
//------------------------------------
// isFullScreenPlayerWindow
//------------------------------------
- (BOOL)isFullScreenPlayerWindow
{
	return [playerWindow isFullScreen];
}

//------------------------------------
// canChangeFullScreenPlayerWindow
//------------------------------------
- (BOOL)canChangeFullScreenPlayerWindow
{
	BOOL ret = NO;
	if( [self hasItemObject] == YES &&
		[self isMainPlayerWindow] == YES
	){
		ret = YES;
	}
	return ret;
}
//------------------------------------
// canChangeFullScreenHidePlayerWindow
//------------------------------------
- (BOOL)canChangeFullScreenHidePlayerWindow
{
	BOOL ret = NO;
	if( [self hasItemObject] == YES &&
		[self playerType] == VIDEO_PLAYER_TYPE_SWF
	){
		ret = YES;
	}
	return ret;
}
//------------------------------------
// canChangeVideoScale
//------------------------------------
- (BOOL)canChangeVideoScale
{
	BOOL ret = NO;
	if( [self hasItemObject] == YES &&
		[self isMainPlayerWindow] == YES &&
		[self isFullScreenPlayerWindow] == NO &&
	   ([self playerType] == VIDEO_PLAYER_TYPE_VIDEO || [self playerType] == VIDEO_PLAYER_TYPE_QUICKTIME)
	){
		ret = YES;
	}
	return ret;
}
//------------------------------------
// canChangeVideoVolume
//------------------------------------
- (BOOL)canChangeVideoVolume
{
	BOOL ret = NO;
	if( [self hasItemObject] == YES
//		[self playerType] == VIDEO_PLAYER_TYPE_VIDEO
	){
		ret = YES;
	}
	return ret;
}
//------------------------------------
// canChangeVideoFormat
//------------------------------------
- (BOOL)canChangeVideoFormat
{
	BOOL ret = NO;
	if( [self hasItemObject] == YES &&
	   ([self playerType] == VIDEO_PLAYER_TYPE_VIDEO || [self playerType] == VIDEO_PLAYER_TYPE_QUICKTIME)
	){
		ret = YES;
	}
	return ret;
}
//------------------------------------
// canChangePlayerType
//------------------------------------
- (BOOL)canChangePlayerType
{
	return ![self isFullScreenPlayerWindow];
}

//------------------------------------
// canSelectNextItem
//------------------------------------
- (BOOL)canSelectNextItem
{
	BOOL canSelect = NO;

	NSArrayController *arrayController = [self arrayController:[self arrayNo]];
	if(arrayController != nil){
		canSelect = [arrayController canSelectNext];
	}
	return canSelect;
}
//------------------------------------
// canSelectPreviousItem
//------------------------------------
- (BOOL)canSelectPreviousItem
{
	BOOL canSelect = NO;
	NSArrayController *arrayController = [self arrayController:[self arrayNo]];
	if(arrayController != nil){
		canSelect = [arrayController canSelectPrevious];
	}
	return canSelect;
}

//------------------------------------
// hasPlayHistory
//------------------------------------
- (BOOL)hasPlayHistory
{
	if([[tbArrayController getArrangedObjects:@"playhistory"] count] > 0){
		return YES;
	}else{
		return NO;
	}

}
//------------------------------------
// hasItemObject
//------------------------------------
- (BOOL)hasItemObject
{
	if([self itemObject] != nil){
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

	[self clearSelectTimer];
	[selectTimer_ release];

	[itemObject_ release];
	[videoQueryItem_ release];
	[fetchItem_ release];

	[fileFormatNoMaps_ release];
	[logString_ release];

    [super dealloc];
}

@end
