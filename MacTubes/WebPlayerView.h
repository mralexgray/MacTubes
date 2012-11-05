/* WebPlayerView */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "ContentItem.h"
#import "PlayModeTypes.h"
#import "ControlTypes.h"
#import "VideoFormatTypes.h"
#import "VideoPlayerStatus.h"

@interface WebPlayerView : WebView
{

	IBOutlet id viewPlayer;

	int playerType_;
	BOOL hasVideo_;

	int swfPlayState_;
	NSString *swfPlayerHTML_;
	NSString *swfObjectPath_;

	int videoPlayState_;
	NSString *videoPlayerHTML_;

	NSTrackingRectTag trackingRect_;

	NSTimer *changeTimer_;

}

- (BOOL)createPlayerView:(ContentItem*)itemObject
				videoURL:(NSString*)videoURL
				playerType:(int)playerType
				fileFormatNo:(int)fileFormatNo;
- (BOOL)createSWFPlayerView:(NSString*)videoURL;
- (BOOL)createVideoPlayerView:(NSString*)videoURL
						imageURL:(NSString*)imageURL
						fileFormatNo:(int)fileFormatNo;
- (BOOL)repeatPlayerView;
- (void)clearPlayerView;
- (void)stopLoading;
- (void)postClearNotifications;

- (void)closeWindow;
- (void)changePlayItemWithTimer;
- (void)changePlayItem;

- (void)changeVideoSizeScale:(float)scale;
//- (void)setLiveResize;

- (void)createMouseTracking;
- (void)removeMouseTracking;

- (void)receiveSWFLoadState:(int)state string:(NSString*)string value:(NSString*)value;
- (void)receiveSWFPlayState:(int)state string:(NSString*)string;
- (void)receiveLoadState:(int)state string:(NSString*)string;
- (void)receivePlayState:(int)state string:(NSString*)string;
- (void)receiveControlState:(int)state string:(NSString*)string;
- (void)receiveTimeState:(int)currentTime duration:(int)duration;
- (void)receiveErrorMessage:(int)state string:(NSString*)string;
- (void)receiveLogMessage:(NSString*)string;
- (id)runJavaScriptWithString:(NSString*)string;

- (void)setVideoPlay:(BOOL)isPlay;
- (void)setVideoConrols:(BOOL)isControls;
- (void)setVideoVolume:(float)volume;
- (void)setVideoRate:(float)rate;
- (float)videoVolume;
- (NSSize)videoSize;

- (void)postVideoObjectChangedNotification:(BOOL)hasVideo;
- (void)postVideoLoadingChangedNotification:(BOOL)isLoading;
- (void)postVideoLoadedChangedNotification:(BOOL)isLoaded;
- (void)postVideoPlayChangedNotification:(BOOL)isPlaying;
- (void)postVideoTimeChangedNotification:(NSDictionary*)params;

- (void)setUpSWFPlayer;
- (void)setUpVideoPlayer;

- (ContentItem*)itemObject;
- (void)setPlayerType:(int)playerType;
- (int)playerType;

- (void)setSWFPlayerHTML:(NSString*)swfPlayerHTML;
- (NSString*)swfPlayerHTML;
- (void)setSWFObjectPath:(NSString*)swfObjectPath;
- (NSString*)swfObjectPath;
- (void)setSWFPlayState:(int)swfPlayState;
- (int)swfPlayState;

- (void)setVideoPlayerHTML:(NSString*)videoPlayerHTML;
- (NSString*)videoPlayerHTML;
- (void)setVideoPlayState:(int)videoPlayState;
- (int)videoPlayState;

- (void)setChangeTimer:(NSTimer*)changeTimer;
- (void)clearChangeTimer;
- (NSTimer*)changeTimer;

- (void)setHasVideo:(BOOL)hasVideo;
- (BOOL)hasVideo;
- (BOOL)isPlaying;
- (int)playRepeat;
- (float)playRepeatInterval;
@end
