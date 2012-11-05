#import <Cocoa/Cocoa.h>
#import "GData/GData.h"
#import "GDataYouTubeStatus.h"
#import "ContentItemStatus.h"

@interface ContentItem : NSObject
{
    GDataEntryYouTubeVideo *video_;
	NSString *itemId_;	
	NSString *author_;
    NSImage *image_;
}
- (id)initVideo:(GDataEntryYouTubeVideo*)video
				image:(NSImage*)image
				author:(NSString*)author
				itemId:(NSString*)itemId;

- (void)setVideo:(GDataEntryYouTubeVideo*)video;
- (GDataEntryYouTubeVideo*)video;

- (void)setItemId:(NSString*)itemId;
- (NSString*)itemId;

- (void)setAuthor:(NSString*)author;
- (NSString*)author;

- (void)setImage:(NSImage*)image;
- (NSImage*)image;

- (NSString*)title;
- (NSString*)contentURL;
- (NSString*)watchURL;
- (NSString*)relatedURL;
- (NSString*)imageURL;
- (BOOL)isEmbedPlay;


@end
