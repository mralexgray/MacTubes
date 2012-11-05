/* YouTubeHelperExtension */

#import <Cocoa/Cocoa.h>
#import "VideoFormatTypes.h"
#import "VideoArgsTypes.h"

@interface NSObject(youTubeHelperExtension_)

- (int)getYouTubeWatchMode:(NSString*)html;
- (NSMutableDictionary*)getYouTubeFormatURLMaps:(NSString*)urlString
											html:(NSString*)html
									errorMessage:(NSString**)errorMessage
									errorDescription:(NSString**)errorDescription;
- (NSString*)getFormatArgString:(NSString*)html
					keyString:(NSString*)keyString
					formatArgsType:(int*)formatArgsType;
- (NSString*)getFormatArgJSONString:(NSString*)html
					keyString:(NSString*)keyString
					formatArgsType:(int*)formatArgsType;

- (int)getYouTubeAvailableFormatMapNo:(NSString*)html;
- (int)getAvailableFormatMapNo:(NSString*)string
						lineSep:(NSString*)lineSep
						paramSep:(NSString*)paramSep;

- (NSMutableDictionary*)convertToFormatURLMaps:(NSString*)string;
- (NSMutableDictionary*)convertToFormatURLMapsFromJSON:(NSString*)JSONString;
- (NSMutableDictionary*)convertToFileFormatNoMaps:(NSDictionary*)params;

- (NSString*)getYouTubeGetVideoURL:(NSDictionary*)params;
- (NSString*)getItemIdFromURL:(NSString*)string;
- (BOOL)checkIsWatchURL:(NSString*)urlString;

@end
