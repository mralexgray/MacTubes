#import "ViewItemInfo.h"
#import "ViewPlayer.h"
#import "ViewItemComment.h"
#import "HelperExtension.h"
#import "ConvertExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"

@implementation ViewItemInfo

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// window rext
	[self setWindowRect:infoWindow key:@"rectWindowInfo"];

	[tabViewComment setDelegate:self];

	// set binding array no
	[self setArrayNo:CONTROL_BIND_ARRAY_NONE];

	[self setParams:nil];

	[self setButtonnCopyEnabled];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillCloseInfo:) name:NSWindowWillCloseNotification object:infoWindow];
	[nc addObserver:self selector:@selector(handleInfoSelectDidChanged:) name:CONTROL_NOTIF_INFO_SELECT_DID_CHANGED object:nil];
}
//=======================================================================
// IBAction
//=======================================================================
//------------------------------------
// openInfoWindow
//------------------------------------
- (IBAction)openInfoWindow:(id)sender
{
	[infoWindow makeKeyAndOrderFront:self];
}
//------------------------------------
// playItem
//------------------------------------
- (IBAction)playItem:(id)sender
{
	NSDictionary *params = [self params];

	// no select
	if(params == nil){
		return;
	}

	ContentItem *itemObject = [params valueForKey:@"itemObject"]; 

	[viewPlayer setPlayerView:itemObject arrayNo:[self arrayNo]];
}
//------------------------------------
// openWatchWithBrowser
//------------------------------------
- (IBAction)openWatchWithBrowser:(id)sender
{

	NSString *watchURL = [txtWatchURL stringValue];

	// open url
	[self openWatchURL:watchURL];

}
//------------------------------------
// openAuthorsProfileWithBrowser
//------------------------------------
- (IBAction)openAuthorsProfileWithBrowser:(id)sender
{

	NSString *author = [txtAuthor stringValue];

	// open url
	[self openAuthorsProfileURL:author];

}
//------------------------------------
// copyInfoToPasteboard
//------------------------------------
- (IBAction)copyInfoToPasteboard:(id)sender
{

	NSString *title = [txtTitle stringValue];
	NSString *author = [txtAuthor stringValue];
	NSString *url = [txtWatchURL stringValue];
	NSString *itemInfo = [[txtItemInfo textStorage] string];
	NSString *description = [[txtDescription textStorage] string];

	NSString *string = [NSString stringWithFormat:@"%@\n%@\n\nAuthor: %@\n%@\n%@"
							, title
							, url
							, author
							, itemInfo
							, description
					];

	[self copyStringToPasteboard:string];

}

//=======================================================================
// methods
//=======================================================================
//------------------------------------
// createItemInfoFromArray
//------------------------------------
- (void)createItemInfoFromArray
{

	int arrayNo = [self arrayNo];
	NSArrayController *arrayController = [self arrayController:arrayNo];
	if(arrayController == nil){
		return;
	}

	NSArray *fetchedArray = [arrayController selectedObjects];

	// no select
	if([fetchedArray count] != 1){
		[self displayMessage:@"alert"
									messageText:@"Item is not selected or multiple selected."
									infoText:@""
									btnList:@"Cancel"
									];
		return;
	}

	id record = [fetchedArray objectAtIndex:0];

	[self createItemInfo:arrayNo record:record];
}
//------------------------------------
// createItemInfo
//------------------------------------
- (BOOL)createItemInfo:(int)arrayNo record:(id)record
{

	// no select
	if(record == nil){
		[self displayMessage:@"alert"
									messageText:@"Item is not selected."
									infoText:@""
									btnList:@"Cancel"
									];
		return NO;
	}

	// set binding array no
	if(arrayNo != [self arrayNo]){
		[self setArrayNo:arrayNo];
		[self postControlBindArrayChangedNotification:arrayNo];
	}

	[self setParams:record];

	ContentItem *itemObject = [record valueForKey:@"itemObject"]; 

	NSImage *image = [itemObject image];
	NSString *itemId = [record valueForKey: @"itemId"];
	NSString *title = [record valueForKey: @"title"];
	NSString *author = [record valueForKey: @"author"];
	NSString *description = [record valueForKey:@"description"];

	NSString *playTimeStr = @"-";
	NSString *viewsStr = @"-";
	NSString *dateStr = @"-";
	NSString *rateStr = @"-";
	float rating = [[record valueForKey:@"rating"] floatValue];

	if(itemObject){
		playTimeStr = [self convertTimeToString:[[record valueForKey: @"playTime"] intValue]];
		viewsStr = [self convertToComma:[[record valueForKey: @"viewCount"] intValue]];
		dateStr = [[record valueForKey:@"publishedDate"] descriptionWithCalendarFormat:@"%Y/%m/%d - %H:%M" timeZone:nil locale:nil];
		rateStr = [NSString stringWithFormat:@"%.2f", rating];
	}

	NSString *watchURL = [self convertToWatchURL:itemId];
	// add formatNo
//	watchURL = [self convertToFileFormatURL:watchURL fileFormatNo:[self defaultPlayFileFormatNo]];

	// item info
	NSString *itemInfo = [NSString stringWithFormat:@"Time: %@\nDate: %@\nViews: %@\nRating: %@\n",
												playTimeStr,
												dateStr,
												viewsStr,
												rateStr
						];

	// set status
//	[infoWindow setTitle:@"Information"];
	[infoWindow setTitle:title];

	[txtTitle setStringValue:title];
	[txtWatchURL setStringValue:watchURL];
	[txtAuthor setStringValue:author];

	[txtItemInfo setString:itemInfo];
	[txtDescription setString:description];

	[imagePreview setImage:image];

	// get comments
	NSString *identifier = [[tabViewComment selectedTabViewItem] identifier];
	if([identifier isEqualToString:@"viewer"]){
		[viewItemComment searchItemCommentsWithTimer:nil];
	}

	return YES;

}
//------------------------------------
// changePlayItem
//------------------------------------
- (void)changePlayItem:(int)tag isLoop:(BOOL)isLoop
{

	// create info
	if([self selectPlayItem:tag isLoop:isLoop] == YES){
		SEL sel = NSSelectorFromString(@"createItemInfoFromArray");
		[self performSelector:sel withObject:nil afterDelay:0.1];
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
// setButtonnCopyEnabled
//------------------------------------
- (void)setButtonnCopyEnabled
{
	BOOL enabled;
	BOOL hidden;
	// check tabviewitem
	NSString *identifier = [[tabViewComment selectedTabViewItem] identifier];
	if([identifier isEqualToString:@"author"]){
		enabled = YES;
		hidden = YES;
	}else{
		enabled = NO;
		hidden = NO;
	}
	[btnCopy setEnabled:enabled];
	[txtUserCommentResults setHidden:hidden];
}

//------------------------------------
// didSelectTabViewItem
//------------------------------------
-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	// get comments
	NSString *identifier = [tabViewItem identifier];
	if([identifier isEqualToString:@"viewer"]){
		[viewItemComment searchItemCommentsWithTimer:nil];
	}
	[self setButtonnCopyEnabled];
}

//------------------------------------
// handleInfoSelectDidChanged
//------------------------------------
- (void)handleInfoSelectDidChanged:(NSNotification *)notification
{
	int tag = [[[notification object] valueForKey:@"tag"] intValue];
	BOOL isLoop = [[[notification object] valueForKey:@"isLoop"] boolValue];

	[self changePlayItem:tag isLoop:isLoop];
}
//------------------------------------
// postControlBindArrayChangedNotification
//------------------------------------
- (void)postControlBindArrayChangedNotification:(int)arrayNo
{
	NSArrayController *arrayController = [self arrayController:arrayNo];
	// post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:CONTROL_NOTIF_INFO_ARRAY_DID_CHANGED object:arrayController];
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

	return nil;
}
//------------------------------------
// params
//------------------------------------
- (void)setParams:(NSDictionary*)params
{
	[params retain];
    [params_ release];
    params_ = params;
}
- (NSDictionary*)params
{
    return params_;
}

//------------------------------------
// windowWillCloseInfo
//------------------------------------
-(void)windowWillCloseInfo:(NSNotification *)notification
{

	// save window rect
	[self saveWindowRect:infoWindow key:@"rectWindowInfo"];

}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[params_ release];

	[super dealloc];
}
@end
