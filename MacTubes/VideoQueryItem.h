/* VideoQueryItem */

#import <Cocoa/Cocoa.h>
#import "GData/GData.h"
#import "VideoQueryStatus.h"

@interface VideoQueryItem : NSObject
{

	id target_;
	
}
- (id)initWithTarget:(id)target;

- (void)fetchFeedWithQuery:(GDataQueryYouTube*)query queryParams:(NSDictionary*)queryParams;
- (void)fetchFeedWithEntryURL:(NSString*)urlString queryParams:(NSDictionary*)queryParams;
- (void)fetchEntryImageWithURL:(NSString*)urlString
				index:(int)index
				withVideo:(GDataEntryYouTubeVideo *)video
				queryParams:(NSDictionary*)queryParams
				queryType:(int)queryType;

- (void)fetchFeedErrorWithQuery:(NSMutableDictionary*)params;
- (void)fetchFeedErrorWithEntryURL:(NSMutableDictionary*)params;
- (void)fetchEntryImageErrorWithURL:(NSMutableDictionary*)params;

- (void)postQueryStatusHandle:(NSMutableDictionary*)params;
- (void)postQueryFeedHandle:(NSMutableDictionary*)params;
- (void)postQueryEntryHandle:(NSMutableDictionary*)params;
- (void)postEntryImageHandle:(NSMutableDictionary*)params;

@end

