/* TextFieldTimeStatus */
#import "VideoPlayerStatus.h"

#import <Cocoa/Cocoa.h>

@interface TextFieldTimeStatus : NSTextField
{
	int playerType_;
	BOOL isLoaded_;
}
- (void)handleVideoLoadedDidChanged:(NSNotification *)notification;
- (void)handleVideoTimeDidChanged:(NSNotification *)notification;
- (void)setTextFiledHidden;
- (void)setPlayerType:(int)playerType;
- (int)playerType;
- (void)setIsLoaded:(BOOL)isLoaded;
- (BOOL)isLoaded;

@end
