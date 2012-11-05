#import <Cocoa/Cocoa.h>

@interface RoundImageCell : NSCell
{
	BOOL isPlayed_;
	int formatMapNo_;
}
- (void)setIsPlayed:(BOOL)isPlayed;
- (BOOL)isPlayed;
- (void)setFormatMapNo:(int)formatMapNo;
- (int)formatMapNo;
@end
