#import "YouTubeHelperExtension.h"
#import "ConvertExtension.h"
#import "HelperExtension.h"

@implementation NSObject(youTubeHelperExtension_)


//------------------------------------
// getYouTubeWatchMode
//------------------------------------
- (int)getYouTubeWatchMode:(NSString*)html
{
	int watchMode = YT_WATCH_MODE_SWF;
	NSRange rng1, rng2;

	NSString *keyFlash1 = @"class=\"flash-player\"";
	NSString *keyFlash2 = @"flashvars";
	NSString *keyVideo1 = @"class=\"html5-player\"";
//	NSString *keyVideo2 = @"setAvailableFormat";

	// flash
	rng1 = [html rangeOfString:keyFlash1];
	rng2 = [html rangeOfString:keyFlash2];
	if(rng1.length > 0 && rng2.length > 0){
		watchMode = YT_WATCH_MODE_SWF;
	}
	else{
		// video
		rng1 = [html rangeOfString:keyVideo1];
	//	rng2 = [html rangeOfString:keyVideo2];
	//	if(rng1.length > 0 && rng2.length > 0){
		if(rng1.length > 0){
			watchMode = YT_WATCH_MODE_VIDEO;
		}
	}

	return watchMode;

}
//------------------------------------
// getYouTubeFormatURLMaps
//------------------------------------
- (NSMutableDictionary*)getYouTubeFormatURLMaps:(NSString*)urlString
											html:(NSString*)html
									errorMessage:(NSString**)errorMessage
									errorDescription:(NSString**)errorDescription
{

	// get fmt_stream_map
	int formatArgsType = VIDEO_FORMAT_ARGS_TYPE_FLASHVARS;

	NSString *formatURLMap = [self getFormatArgString:html
											keyString:@"fmt_stream_map"
											formatArgsType:&formatArgsType
							];

/*
	// try JSON args
	if(!formatURLMap || [formatURLMap isEqualToString:@""]){
		formatURLMap = [self getFormatArgJSONString:html
									keyString:@"html5_fmt_map"
									formatArgsType:&formatArgsType
						];
	}
*/
	// error
	if(!formatURLMap || [formatURLMap isEqualToString:@""]){
		*errorMessage = [NSString stringWithFormat:@"Can't get video format URL from %@\n", urlString];
		*errorDescription = [NSString stringWithFormat:@"html = %@\n", html];
		return nil;
	}
//	NSLog(@"formatURLMap1=%@", formatURLMap);

	// encode
	if( formatArgsType == VIDEO_FORMAT_ARGS_TYPE_FLASHVARS ||
		formatArgsType == VIDEO_FORMAT_ARGS_TYPE_JSON
	){
		formatURLMap = [self encodeFromPercentEscapesString:formatURLMap];
	}

//	sig= -> signature=
	formatURLMap = [self replaceCharacter:formatURLMap str1:@"sig=" str2:@"signature="];

//	NSLog(@"formatArgsType=%d", formatArgsType);
//	NSLog(@"formatURLMap2=%@", formatURLMap);

	NSMutableDictionary *formatURLMaps = nil;
	if(formatArgsType == VIDEO_FORMAT_ARGS_TYPE_JSON){
		formatURLMaps = [self convertToFormatURLMapsFromJSON:formatURLMap];
	}else{
		formatURLMaps = [self convertToFormatURLMaps:formatURLMap];
	}

//	NSLog(@"formatURLMaps=%@", [formatURLMaps description]);
	return formatURLMaps;

}
//------------------------------------
// getYouTubeAvailableFormatMapNo
//------------------------------------
- (int)getYouTubeAvailableFormatMapNo:(NSString*)html
{

	int formatMapNo = VIDEO_FORMAT_MAP_NONE;
	int formatArgsType = VIDEO_FORMAT_ARGS_TYPE_FLASHVARS;

	// get fmt_list
	NSString *formatMap = [self getFormatArgString:html
										keyString:@"fmt_list"
										formatArgsType:&formatArgsType
						];

	// error
	if([formatMap isEqualToString:@""]){
		return formatMapNo;
	}

	// encode
	if(formatArgsType == VIDEO_FORMAT_ARGS_TYPE_FLASHVARS){
		formatMap = [self encodeFromPercentEscapesString:formatMap];
	}

//	NSLog(@"argsType = %d formatMap=%@", formatArgsType, formatMap);

	// get formatMapNo
	formatMapNo = [self getAvailableFormatMapNo:formatMap
										lineSep:@","
										paramSep:@"/"
					];

//	NSLog(@"formatMapNo = %d", formatMapNo);
	return formatMapNo;

}
//------------------------------------
// getFormatArgString
//------------------------------------
- (NSString*)getFormatArgString:(NSString*)html
					keyString:(NSString*)keyString
					formatArgsType:(int*)formatArgsType
{

	NSString *valueString = @"";

	// replace
	html = [self replaceCharacter:html str1:@"u0026" str2:@"&"];
	html = [self replaceCharacter:html str1:@"&amp;" str2:@"&"];
	// delete back slash
	html = [self replaceCharacter:html str1:@"\\" str2:@""];

	if([valueString isEqualToString:@""]){
		// get keyString=xxxx&;
		valueString = [self getEnclosedStringWithKeyString:html
													keyString:keyString
													skipString:@""
													skipCheck:YES
													beginString:@"="
													endString:@"&"
													withEndSet:NO
						];
		*formatArgsType = VIDEO_FORMAT_ARGS_TYPE_FLASHVARS;
//		NSLog(@"valueString1=%@", valueString);
	}

	if([valueString isEqualToString:@""]){
		// get keyString":"xxxx"
		valueString = [self getEnclosedStringWithKeyString:html
													keyString:[NSString stringWithFormat:@"%@\"", keyString]
													skipString:@":"
													skipCheck:YES
													beginString:@"\""
													endString:@"\""
													withEndSet:NO
						];
		*formatArgsType = VIDEO_FORMAT_ARGS_TYPE_CONFIG;
//		NSLog(@"valueString2=%@", valueString);
	}

	return valueString;

}
//------------------------------------
// getFormatArgJSONString
//------------------------------------
- (NSString*)getFormatArgJSONString:(NSString*)html
					keyString:(NSString*)keyString
					formatArgsType:(int*)formatArgsType
{

	NSString *valueString = @"";

	// replace
	html = [self replaceCharacter:html str1:@"&amp;" str2:@"&"];
	html = [self replaceCharacter:html str1:@"u0026" str2:@"&"];
	// delete back slash
	html = [self replaceCharacter:html str1:@"\\" str2:@""];

	if([valueString isEqualToString:@""]){
		// get "keyString":[xxxx]
		valueString = [self getEnclosedStringWithKeyString:html
													keyString:[NSString stringWithFormat:@"\"%@\"", keyString]
													skipString:@":"
													skipCheck:YES
													beginString:@"["
													endString:@"]"
													withEndSet:NO
						];
		*formatArgsType = VIDEO_FORMAT_ARGS_TYPE_JSON;
//		NSLog(@"valueString=%@", valueString);
	}

	return valueString;

}
//------------------------------------
// getAvailableFormatMapNo
//------------------------------------
- (int)getAvailableFormatMapNo:(NSString*)string
						lineSep:(NSString*)lineSep
						paramSep:(NSString*)paramSep
{
	int availableFormatMapNo = VIDEO_FORMAT_MAP_NONE;
	int formatMapNo;
	int i;
	NSString *line;
	NSString *key;
	NSArray *cols;

	NSArray *lines = [string componentsSeparatedByString:lineSep];

	for(i = 0; i < [lines count]; i++){

		line = [lines objectAtIndex:i];
//		NSLog(@"line=%@", line);

		cols = [line componentsSeparatedByString:paramSep];
		key = [cols objectAtIndex:0];
//		NSLog(@"key=%@", key);
		if([self checkIsDigitString:key] == YES){
			formatMapNo = [key intValue];
			// skip format
			if( 
//				formatMapNo == VIDEO_FORMAT_MAP_HIGH ||
				formatMapNo == VIDEO_FORMAT_MAP_HD ||
				formatMapNo == VIDEO_FORMAT_MAP_HD_1080
			){
				if(formatMapNo > VIDEO_FORMAT_MAP_NORMAL){
					if(formatMapNo > availableFormatMapNo){
						availableFormatMapNo = formatMapNo;
					}
				}
			}
		}

	}
	return availableFormatMapNo;

}
/*
//------------------------------------
// convertToFormatURLMaps
//------------------------------------
- (NSMutableDictionary*)convertToFormatURLMaps:(NSString*)string
{
	NSArray *cols;
	NSString *key;
	NSString *value;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	int i;

	// separate ","
	NSArray *lines = [string componentsSeparatedByString:@","];

	for(i = 0; i < [lines count]; i++){
		// separate "|"
		cols = [[lines objectAtIndex:i] componentsSeparatedByString:@"|"];
		if([cols count] > 1){
			key = [cols objectAtIndex:0];
			value = [[cols subarrayWithRange:NSMakeRange(1, [cols count] - 1)]
							componentsJoinedByString:@"|"
					];
//			NSLog(@"key=%@ value=%@", key, value);
			[params setValue:value forKey:key];
		}
	}
	return params;
}
*/
//------------------------------------
// convertToFormatURLMaps
//------------------------------------
- (NSMutableDictionary*)convertToFormatURLMaps:(NSString*)string
{
	NSArray *cols;
	NSString *line;
	NSString *key;
	NSString *value;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	int i;

	// separate "url="
	NSArray *lines = [string componentsSeparatedByString:@"url="];

	for(i = 0; i < [lines count]; i++){

		line = [lines objectAtIndex:i];

		line = [self convertFromURIEncodedString:line];
//		NSLog(@"line=%@", line);

		if([line isEqualToString:@""]){
			continue;
		}

		// separate "&quality="
		cols = [line componentsSeparatedByString:@"&quality="];
		value = [cols objectAtIndex:0];

		key = [self getEnclosedStringWithKeyString:value
							keyString:@""
							skipString:@""
							skipCheck:NO
							beginString:@"&itag="
							endString:@"&"
							withEndSet:NO
				];
		if(key && ![key isEqualToString:@""]){
//			NSLog(@"key=%@ value=%@", key, value);
			[params setValue:value forKey:key];
		}
	}
	return params;
}
//------------------------------------
// convertToFormatURLMapsFromJSON
//------------------------------------
- (NSMutableDictionary*)convertToFormatURLMapsFromJSON:(NSString*)JSONString
{

	NSString *line;
	NSString *videoFileURL;
	NSString *itag;
	NSString *keyUrl = @"\"url\"";
	NSRange rng;
	int i;

	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];

	NSArray *lines = [JSONString componentsSeparatedByString:@"}"];

	for(i = 0; i < [lines count]; i++){

		line = [lines objectAtIndex:i];
		rng = [line rangeOfString:keyUrl];
		if(rng.length > 0){
			videoFileURL = [self getEnclosedStringWithKeyString:line
														keyString:keyUrl
														skipString:@":"
														skipCheck:YES
														beginString:@"\""
														endString:@"\""
														withEndSet:NO
							];

//			NSLog(@"videoFileURL=%@", videoFileURL);

			// get download url
			if(videoFileURL && ![videoFileURL isEqualToString:@""]){
				itag = [self getEnclosedString:videoFileURL
										beginString:@"itag="
										endString:@"&"
										withEndSet:NO
							];
//				NSLog(@"itag=%@", itag);
				if(itag && ![itag isEqualToString:@""]){
					[params setValue:videoFileURL forKey:itag];
				}
			}
		}
	}

	return params;

}
//------------------------------------
// convertToFileFormatNoMaps
//------------------------------------
- (NSMutableDictionary*)convertToFileFormatNoMaps:(NSDictionary*)params
{

	NSString *key;
	NSString *value;
	int formatMapNo;
	int formatNo;
	NSMutableDictionary *formatNoMaps = [NSMutableDictionary dictionary];

	NSEnumerator *enumKeys = [params keyEnumerator];
	while(key = [enumKeys nextObject]) {

		if([self checkIsDigitString:key] == YES){
			formatMapNo = [key intValue];
			formatNo = [self convertToFormatMapNoToFileFormatNo:formatMapNo];
			value = [params valueForKey:key];
			[formatNoMaps setValue:value forKey:[self convertIntToString:formatNo]];
		}

	}
	return formatNoMaps;
}
//------------------------------------
// getYouTubeGetVideoURL
//------------------------------------
- (NSString*)getYouTubeGetVideoURL:(NSDictionary*)params
{
	NSString *videoURL = @"";
	NSString *videoId = @"";
	NSString *t = @"";

	// video_id
	if([params valueForKey:@"video_id"]){
		videoId = [params valueForKey:@"video_id"];
	}
	// t
	if([params valueForKey:@"t"]){
		t = [params valueForKey:@"t"];
	}
	if(![videoId isEqualToString:@""] && ![t isEqualToString:@""]){
		videoId = [self encodeFromPercentEscapesString:videoId];
		t = [self encodeFromPercentEscapesString:t];
		videoURL = [self convertToDownloadFileURL:videoId str2:t];
	}

	return videoURL;
}

//------------------------------------
// getItemIdFromURL
//------------------------------------
- (NSString*)getItemIdFromURL:(NSString*)string
{

	// trim
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	NSString *itemId = [self getEnclosedString:string
								beginString:@"watch?v="
								endString:@"&?#\""
								withEndSet:YES
						];

	// retry
	if([itemId isEqualToString:@""]){
		itemId = [self getEnclosedString:string
								beginString:@"&v="
								endString:@"&?#\""
								withEndSet:YES
				];
	}
	// null
	if([itemId isEqualToString:@""]){
		itemId = string;
	}

	return itemId;

}
//------------------------------------
// checkIsWatchURL
//------------------------------------
- (BOOL)checkIsWatchURL:(NSString*)urlString
{
	BOOL ret = NO;
	if( [self checkIsTargetURL:urlString targetString:@"watch?"] == YES &&
		[self checkIsTargetURL:urlString targetString:@"v="] == YES
	){
		ret = YES;
	}
	return ret;
}

@end