#import <Cocoa/Cocoa.h>
#import "ContentItem.h"
#import "VideoQueryStatus.h"
#import "VideoFormatTypes.h"

@interface SearchMatrixCell : NSImageCell
{

	id itemObject_;

	int itemIndex_;
	NSSize imageSize_;

	BOOL isEnabled_;
	BOOL isSelected_;
	int formatMapNo_;

}
- (id)initWithItemObject:(id)itemObject
				itemIndex:(int)itemIndex
				isEnabled:(BOOL)isEnabled
				formatMapNo:(int)formatMapNo;

- (void)setItemObject:(id)itemObject;
- (id)itemObject;

- (void)setItemIndex:(int)itemIndex;
- (int)itemIndex;

- (void)setImageSize:(NSSize)imageSize;
- (NSSize)imageSize;

- (void)setIsEnabled:(BOOL)isEnabled;
- (BOOL)isEnabled;
- (void)setIsSelected:(BOOL)isSelected;
- (BOOL)isSelected;
- (void)setFormatMapNo:(int)formatMapNo;
- (int)formatMapNo;

@end
