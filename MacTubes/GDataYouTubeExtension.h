/* GDataYouTubeExtension */

#import <Cocoa/Cocoa.h>
#import "GData/GData.h"
#import "PlaylistItemTypes.h"
#import "SearchQueryTypes.h"

@interface NSObject(GDataYouTubeExtension_)

- (GDataServiceGoogleYouTube *)youTubeService;
- (NSString*)getCategoryTitle:(NSString*)name;
- (NSString*)getCategoryTitleJP:(NSString*)name;
- (NSString*)getFeedName:(int)itemSubType;
- (NSString*)getFeedTitle:(int)itemSubType;
- (NSString*)getQueryFeedTitle:(NSString*)name;
- (NSString*)getQueryFeedTitleJP:(NSString*)name;
- (int)getFeedType:(NSString*)name;
- (BOOL)isEnabledFeedTime:(NSString*)feedName;
- (BOOL)isEnabledCategory:(NSString*)categoryName;
- (NSImage*)getCountryIconImage:(NSString*)countryCode;

- (GDataQueryYouTube*)setYouTubeQueryOrder:(GDataQueryYouTube*)query queryOrder:(int)queryOrder;
- (GDataQueryYouTube*)setYouTubeQueryTimePeriod:(GDataQueryYouTube*)query queryTimePeriod:(int)queryTimePeriod;
- (GDataQueryYouTube*)setYouTubeQueryAllowRacy:(GDataQueryYouTube*)query allowRacy:(BOOL)allowRacy;
- (GDataQueryYouTube*)setYouTubeQuerySafeSearch:(GDataQueryYouTube*)query safeSearchNo:(int)safeSearchNo;

- (NSString*)appendYouTubeQueryOrderString:(NSString*)string queryOrder:(int)queryOrder addPara:(BOOL*)addPara;
- (NSString*)appendYouTubeQueryTimePeriodString:(NSString*)string queryTimePeriod:(int)queryTimePeriod addPara:(BOOL*)addPara;

- (NSString*)getYouTubeQueryOrderString:(int)queryOrder;
- (NSString*)getYouTubeSafeSearchString:(int)safeSearchNo;
- (NSString*)getTimePeriodString:(int)timePeriod;

- (NSDictionary*)getYouTubeVideoValues:(GDataEntryYouTubeVideo *)video;
- (NSDictionary*)getYouTubeEntryValues:(GDataEntryBase *)entry;

- (NSArray*)queryFeedNameMenuItems;
- (NSArray*)categoryNameMenuItems;
- (NSArray*)countryCodeMenuItems;

@end
