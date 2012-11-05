#import <Cocoa/Cocoa.h>
#import "VideoFormatTypes.h"

@interface PreviewImageView : NSImageView
{
	IBOutlet id viewMainSearch;
	IBOutlet NSArrayController *searchlistArrayController;
	BOOL isPlayed_;
	int formatMapNo_;
}
- (void)setIsPlayed:(BOOL)isPlayed;
- (BOOL)isPlayed;
- (void)setFormatMapNo:(int)formatMapNo;
- (int)formatMapNo;
@end
