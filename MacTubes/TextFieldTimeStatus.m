#import "TextFieldTimeStatus.h"
#import "UserDefaultsExtension.h"
#import "ConvertExtension.h"

@implementation TextFieldTimeStatus

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[self setPlayerType:[self defaultVideoPlayerType]];
	[self setIsLoaded:NO];
	[self setStringValue:@""];
	[self setTextFiledHidden];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleVideoLoadedDidChanged:) name:VIDEO_NOTIF_LOADED_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoTimeDidChanged:) name:VIDEO_NOTIF_TIME_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoPlayerTypeDidChanged:) name:VIDEO_NOTIF_VIDEO_PLAYER_TYPE_DID_CHANGED object:nil];

}
//------------------------------------
// handleVideoLoadedDidChanged
//------------------------------------
- (void)handleVideoLoadedDidChanged:(NSNotification *)notification
{
	BOOL isLoaded = [[notification object] boolValue];
	if(isLoaded == NO){
		[self setStringValue:@""];
	}
	[self setIsLoaded:isLoaded];
	
}
//------------------------------------
// handleVideoPlayDidChanged
//------------------------------------
- (void)handleVideoTimeDidChanged:(NSNotification *)notification
{

	// for closing player
	if([self isLoaded] == NO){
		return;
	}

	NSDictionary *params = [notification object];

	int currentTime = [[params valueForKey:@"currentTime"] intValue];
	int duration = [[params valueForKey:@"duration"] intValue];

	NSString *string = [NSString stringWithFormat:@"%@ / %@"
							, [self convertTimeToString:currentTime]
							, [self convertTimeToString:duration]
						];

	[self setStringValue:string];

}
//------------------------------------
// handleVideoPlayerTypeDidChanged
//------------------------------------
- (void)handleVideoPlayerTypeDidChanged:(NSNotification *)notification
{
	int playerType = [[notification object] intValue];

	[self setPlayerType:playerType];
	[self setTextFiledHidden];

}
//------------------------------------
// setTextFiledHidden
//------------------------------------
- (void)setTextFiledHidden
{
	BOOL hidden = NO;

	int playerType = [self playerType];

	if(playerType == VIDEO_PLAYER_TYPE_SWF){
		hidden = YES;
	}
	else if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		if([self frame].size.width < 60){
			hidden = YES;
		}else{
			hidden = NO;
		}
	}

	[self setHidden:hidden];

}
//------------------------------------
// viewDidEndLiveResize
//------------------------------------
- (void)viewDidEndLiveResize
{
	[self setTextFiledHidden];
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
// isLoaded
//------------------------------------
- (void)setIsLoaded:(BOOL)isLoaded
{
    isLoaded_ = isLoaded;
}
- (BOOL)isLoaded
{
	return isLoaded_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
