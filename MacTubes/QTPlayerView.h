/* QTPlayerView */

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "ContentItem.h"
#import "PlayModeTypes.h"
#import "ControlTypes.h"
#import "VideoFormatTypes.h"
#import "VideoPlayerStatus.h"

@interface QTPlayerView : QTMovieView
{

	IBOutlet id viewPlayer;

	int playerType_;

	NSString *errorDescription_;

	NSTrackingRectTag trackingRect_;
//	NSTrackingRectTag movieTrackingRect_;

	NSTimer *controllerTimer_;
	NSTimer *timeStatusTimer_;
	NSTimer *changeTimer_;

}

- (BOOL)createPlayerView:(ContentItem*)itemObject
				videoURL:(NSString*)videoURL
				playerType:(int)playerType
				fileFormatNo:(int)fileFormatNo;
- (BOOL)createQTPlayerView:(NSString*)videoURL;
//- (void)playWithTimer:(NSTimer*)aTimer;

- (BOOL)repeatPlayerView;
- (void)clearPlayerView;
- (void)postClearNotifications;

- (void)closeWindow;
- (void)changePlayItemWithTimer;
- (void)changePlayItem;

- (void)changeVideoSizeScale:(float)scale;
- (void)setVideoPlay:(BOOL)isPlay;
- (void)setVideoVolume:(float)volume;
- (void)setVideoControllerVisible:(NSTimer*)aTimer;

- (void)startControllerTimer:(BOOL)isShow;
- (BOOL)checkControllerTimer:(BOOL)isShow;

- (void)startTimeStatusTimer;
- (void)updateTimeStatus;

- (void)createMouseTracking;
- (void)removeMouseTracking;
- (BOOL)isMousePointInMovieRect;

- (void)postVideoObjectChangedNotification:(BOOL)hasVideo;
- (void)postVideoLoadingChangedNotification:(BOOL)isLoading;
- (void)postVideoLoadedChangedNotification:(BOOL)isLoaded;
- (void)postVideoPlayChangedNotification:(BOOL)isPlaying;
- (void)postVideoTimeChangedNotification:(NSDictionary*)params;

- (ContentItem*)itemObject;
- (void)setPlayerType:(int)playerType;
- (int)playerType;

- (void)setControllerTimer:(NSTimer*)controllerTimer;
- (void)clearControllerTimer;
- (NSTimer*)controllerTimer;
- (void)setTimeStatusTimer:(NSTimer*)timeStatusTimer;
- (void)clearTimeStatusTimer;
- (NSTimer*)timeStatusTimer;
- (void)setChangeTimer:(NSTimer*)changeTimer;
- (void)clearChangeTimer;
- (NSTimer*)changeTimer;

- (void)setErrorDescription:(NSString*)errorDescription;
- (NSString*)errorDescription;

- (BOOL)hasVideo;
- (BOOL)isPlaying;
- (BOOL)isFullScreen;
@end
