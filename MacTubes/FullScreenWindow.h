/* FullScreenWindow */

#import <Cocoa/Cocoa.h>
#import "WindowInfoStatus.h"
#import "VideoPlayerStatus.h"

@interface FullScreenWindow: NSWindow

{
	BOOL isFullScreen_;
	NSRect oldRect_;
	int titleBarHeight_;
	BOOL showYouTubeBar_;
	BOOL showController_;
	BOOL isTopScreen_;
	int playerType_;

}
- (IBAction)changeFullScreen:(id)sender;
- (IBAction)changeFullScreenWithHideController:(id)sender;
- (IBAction)changeTopScreen:(id)sender;

- (void)setFullScreen:(BOOL)isFullScreen animate:(BOOL)animate;

- (void)changeWindowLevel;
- (void)restoreWindowLevel;

- (void)postWindowFullScreenChangedNotification:(BOOL)isFullScreen;

- (void)setIsFullScreen:(BOOL)isFullScreen;
- (BOOL)isFullScreen;

- (void)setIsTopScreen:(BOOL)isTopScreen;
- (BOOL)isTopScreen;

- (void)setShowYouTubeBar:(BOOL)showYouTubeBar;
- (BOOL)showYouTubeBar;

- (void)setShowController:(BOOL)showController;
- (BOOL)showController;

- (void)setPlayerType:(int)playerType;
- (int)playerType;

@end


