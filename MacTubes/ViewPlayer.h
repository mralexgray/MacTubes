/* ViewPlayer */

#import <Cocoa/Cocoa.h>
#import "WebPlayerView.h"
#import "QTPlayerView.h"
#import "FullScreenWindow.h"
#import "SearchTypes.h"
#import "VideoQueryItem.h"
#import "ContentItem.h"
#import "DownloadStatus.h"
#import "ControlTypes.h"
#import "PlayModeTypes.h"
#import "VideoPlayerStatus.h"
#import "FetchItem.h"

@interface ViewPlayer : NSObject
{

	IBOutlet id viewRelatedSearch;
	IBOutlet id viewItemInfo;
	IBOutlet id viewFileFormat;

	IBOutlet id tbArrayController;
	IBOutlet id logStatusController;
	IBOutlet id downloadManager;
	
	IBOutlet WebPlayerView *webPlayerView;
	IBOutlet QTPlayerView *qtPlayerView;
	IBOutlet NSTabView *tabViewPlayer;

	IBOutlet NSArrayController *searchlistArrayController;
	IBOutlet NSArrayController *relatedlistArrayController;
	IBOutlet NSArrayController *playhistoryArrayController;

	IBOutlet FullScreenWindow *playerWindow;
 	IBOutlet NSButton *btnFileFormatNo;
    IBOutlet NSSlider *sliderPlayVolume;
    IBOutlet NSProgressIndicator *indProc;

	IBOutlet NSWindow *enterURLWindow;
	IBOutlet NSTextField *txtURL;
	
	int arrayNo_;
	NSTimer *selectTimer_;

	ContentItem *itemObject_;
	VideoQueryItem *videoQueryItem_;
	FetchItem* fetchItem_;

	int playerType_;
	int fileFormatNo_;
	NSMutableDictionary *fileFormatNoMaps_;

	NSString *logString_;

}

- (IBAction)openPlayerWindow:(id)sender;
- (IBAction)openEnterURLWindow:(id)sender;
- (IBAction)closeEnterURLWindow:(id)sender;
- (IBAction)openPlayerViewWithURL:(id)sender;

- (IBAction)playItem:(id)sender;
- (IBAction)changeItem:(id)sender;
- (IBAction)replayItem:(id)sender;
- (IBAction)downloadItem:(id)sender;

- (IBAction)openItemInfo:(id)sender;
- (IBAction)openVideoFormatItem:(id)sender;
- (IBAction)openWatchWithBrowser:(id)sender;
- (IBAction)openContentWithBrowser:(id)sender;
- (IBAction)openAuthorsProfileWithBrowser:(id)sender;
- (IBAction)addItemToPlaylist:(id)sender;

- (IBAction)searchRelatedItem:(id)sender;
- (IBAction)searchAuthorsItem:(id)sender;
- (IBAction)copyItemToPasteboard:(id)sender;

- (BOOL)setPlayerView:(ContentItem*)itemObject arrayNo:(int)arrayNo;
- (BOOL)createPlayerView:(ContentItem*)itemObject arrayNo:(int)arrayNo;
- (BOOL)createVideoPlayer:(ContentItem*)itemObject playerType:(int)playerType;
- (BOOL)createVideoPlayerView:(NSString *)urlString params:(NSDictionary*)params;
- (void)clearPlayerView;
- (void)setPlayerValues:(ContentItem*)itemObject
			playerType:(int)playerType
			fileFormatNo:(int)fileFormatNo
			fileFormatNoMaps:(NSMutableDictionary*)fileFormatNoMaps;
- (BOOL)setPlayerViewStatus:(ContentItem*)itemObject;
- (BOOL)setPlayerViewWithURL:(NSString*)urlString;
- (void)setPlayerViewWithItemId:(NSString*)itemId arrayNo:(int)arrayNo;
- (void)setItemObjectWithItemId:(NSString*)itemId;
- (BOOL)setPlayerViewWithFormatNo:(int)fileFormatNo;
- (void)setPlayerTitle:(NSString*)title;
- (void)updateHistory:(ContentItem*)itemObject;

- (void)changePlayItem:(int)tag isLoop:(BOOL)isLoop;
- (BOOL)selectPlayItem:(int)tag isLoop:(BOOL)isLoop;
- (void)playItemWithTimer:(id)sender;

- (void)changeTabViewPlayer:(int)playerType;
- (void)changeControlsHidden:(int)playerType;

- (void)handleQueryStatusChanged:(NSDictionary*)params;
- (void)handleQueryFeedFetched:(NSDictionary*)params;
- (void)handleQueryEntryFetched:(NSDictionary*)params;
- (void)handleEntryImageFetched:(NSDictionary*)params;

- (void)postControlBindArrayChangedNotification:(int)arrayNo;
- (void)postVideoPlayerTypeNotification:(int)newPlayerType oldPlayerType:(int)oldPlayerType;
- (void)postVideoStatusChangedNotification:(NSDictionary*)params;

- (void)openModalSheet:(NSWindow*)childindow parentWindow:(NSWindow*)parentWindow;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)setFetchItem:(FetchItem*)fetchItem;
- (FetchItem*)fetchItem;
- (void)cancelFetchItem;

- (void)setItemObject:(ContentItem*)itemObject;
- (ContentItem*)itemObject;
- (void)setPlayerType:(int)playerType;
- (int)playerType;
- (void)setFileFormatNo:(int)fileFormatNo;
- (int)fileFormatNo;
- (void)setFileFormatNoMaps:(NSMutableDictionary*)fileFormatNoMaps;
- (NSMutableDictionary*)fileFormatNoMaps;

- (void)setArrayNo:(int)arrayNo;
- (int)arrayNo;
- (NSArrayController*)arrayController:(int)arrayNo;

- (void)setSelectTimer:(NSTimer*)selectTimer;
- (void)clearSelectTimer;
- (NSTimer*)selectTimer;
- (void)setLogString:(NSString*)logString;
- (void)appendLogString:(NSString*)logString;
- (NSString*)logString;

- (BOOL)isVisiblePlayerWindow;
- (BOOL)isMainPlayerWindow;
- (BOOL)isFullScreenPlayerWindow;
- (BOOL)canChangeFullScreenPlayerWindow;
- (BOOL)canChangeFullScreenHidePlayerWindow;
- (BOOL)canChangeVideoScale;
- (BOOL)canChangeVideoVolume;
- (BOOL)canChangeVideoFormat;
- (BOOL)canChangePlayerType;
- (BOOL)canSelectNextItem;
- (BOOL)canSelectPreviousItem;
- (BOOL)hasPlayHistory;
- (BOOL)hasItemObject;

@end
