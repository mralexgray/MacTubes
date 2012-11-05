#import "ConvertExtension.h"
#import "HelperExtension.h"
#import "UserDefaultsExtension.h"

@implementation NSObject(convertExtension_)

//------------------------------------
// convertToYouTubeBaseURL
//------------------------------------
- (NSString*)convertToYouTubeBaseURL
{
//	return @"http://www.youtube.com";
	return [self defaultStringValue:@"optBaseURL"];
}
//------------------------------------
// convertToYouTubeComURL
//------------------------------------
- (NSString*)convertToYouTubeComURL
{
//	return @"http://youtube.com";
	return [self defaultStringValue:@"optBaseComURL"];

}
//------------------------------------
// convertToGdataBaseURL
//------------------------------------
- (NSString*)convertToGdataBaseURL
{
	return @"http://gdata.youtube.com";
}
//------------------------------------
// convertToEntryURL
//------------------------------------
- (NSString*)convertToEntryURL:(NSString*)itemId
{
	return [NSString stringWithFormat:@"%@/feeds/api/videos/%@", [self convertToGdataBaseURL], itemId];
}
//------------------------------------
// convertToWatchURL
//------------------------------------
- (NSString*)convertToWatchURL:(NSString*)itemId
{
	return [NSString stringWithFormat:@"%@/watch?v=%@", [self convertToYouTubeBaseURL], itemId];
}
//------------------------------------
// convertToContentURL
//------------------------------------
- (NSString*)convertToContentURL:(NSString*)itemId
{
	return [NSString stringWithFormat:@"%@/v/%@", [self convertToYouTubeBaseURL], itemId];
}
//------------------------------------
// convertToDownloadURL
//------------------------------------
- (NSString*)convertToDownloadURL:(NSString*)itemId
{
//	return [NSString stringWithFormat:@"%@/watch?v=%@", [self convertToYouTubeComURL], itemId];
	return [NSString stringWithFormat:@"%@/watch?v=%@", [self convertToYouTubeBaseURL], itemId];
}
//------------------------------------
// convertToFileFormatURL
//------------------------------------
- (NSString*)convertToFileFormatURL:(NSString*)url fileFormatNo:(int)fileFormatNo
{
	// formatNo -> formatMapNo
	int formatMapNo = [self convertToFileFormatNoToFormatMapNo:fileFormatNo];

	if(formatMapNo != VIDEO_FORMAT_MAP_NONE){
		return [url stringByAppendingFormat:@"&fmt=%d", formatMapNo];
	}else{
		return url;
	}
}

//------------------------------------
// convertToRelatedURL
//------------------------------------
- (NSString*)convertToRelatedURL:(NSString*)itemId
{
	return [NSString stringWithFormat:@"%@/feeds/api/videos/%@/related", [self convertToGdataBaseURL], itemId];
}
//------------------------------------
// convertToCommentsURL
//------------------------------------
- (NSString*)convertToCommentsURL:(NSString*)itemId
{
	return [NSString stringWithFormat:@"%@/feeds/api/videos/%@/comments", [self convertToGdataBaseURL], itemId];
}
//------------------------------------
// convertToCommentsEntryURL
//------------------------------------
- (NSString*)convertToCommentsEntryURL:(NSString*)itemId commentId:(NSString*)commentId
{
	return [NSString stringWithFormat:@"%@/feeds/api/videos/%@/comments/%@", [self convertToGdataBaseURL], itemId, commentId];
}
//------------------------------------
// convertToAuthorsProfileURL
//------------------------------------
- (NSString*)convertToAuthorsProfileURL:(NSString*)author
{
	return [NSString stringWithFormat:@"%@/user/%@", [self convertToYouTubeBaseURL], author];
}
//------------------------------------
// convertToAuthorsUploadURL
//------------------------------------
- (NSString*)convertToAuthorsUploadURL:(NSString*)author
{
	return [NSString stringWithFormat:@"%@/feeds/api/users/%@/uploads/", [self convertToGdataBaseURL], author];
}
//------------------------------------
// convertToDownloadFileURL
//------------------------------------
- (NSString*)convertToDownloadFileURL:(NSString*)str1 str2:(NSString*)str2
{
	return [NSString stringWithFormat:@"%@/get_video?video_id=%@&t=%@"
				, [self convertToYouTubeBaseURL]
				, str1
				, str2
			];

}
//------------------------------------
// convertToResultString
//------------------------------------
- (NSString*)convertToResultString:(int)startIndex lastIndex:(int)lastIndex totalResults:(int)totalResults
{
	
	return [NSString stringWithFormat:@"Results %@ - %@ of %@",
								[self convertToComma:startIndex],
								[self convertToComma:lastIndex],
								[self convertToComma:totalResults]
			];
}

//------------------------------------
// convertToFileFormatNoToFormatMapNo
//------------------------------------
- (int)convertToFileFormatNoToFormatMapNo:(int)formatNo
{
	int formatMapNo = VIDEO_FORMAT_MAP_NONE;

	// NORMAL
	if(formatNo == VIDEO_FORMAT_NO_NORMAL){
		formatMapNo = VIDEO_FORMAT_MAP_NORMAL;
	}
	// HQ
	else if(formatNo == VIDEO_FORMAT_NO_HQ){
		formatMapNo = VIDEO_FORMAT_MAP_HQ;
	}
	// HIGH
	else if(formatNo == VIDEO_FORMAT_NO_HIGH){
		formatMapNo = VIDEO_FORMAT_MAP_HIGH;
	}
	// HD
	else if(formatNo == VIDEO_FORMAT_NO_HD){
		formatMapNo = VIDEO_FORMAT_MAP_HD;
	}
	// FMT34
	else if(formatNo == VIDEO_FORMAT_NO_FMT_34){
		formatMapNo = VIDEO_FORMAT_MAP_FMT_34;
	}
	// FMT35
	else if(formatNo == VIDEO_FORMAT_NO_FMT_35){
		formatMapNo = VIDEO_FORMAT_MAP_FMT_35;
	}
	// HD_1080
	else if(formatNo == VIDEO_FORMAT_NO_HD_1080){
		formatMapNo = VIDEO_FORMAT_MAP_HD_1080;
	}
	// WEBM_43
	else if(formatNo == VIDEO_FORMAT_NO_WEBM_43){
		formatMapNo = VIDEO_FORMAT_MAP_WEBM_43;
	}
	// WEBM_44
	else if(formatNo == VIDEO_FORMAT_NO_WEBM_44){
		formatMapNo = VIDEO_FORMAT_MAP_WEBM_44;
	}
	// WEBM_45
	else if(formatNo == VIDEO_FORMAT_NO_WEBM_45){
		formatMapNo = VIDEO_FORMAT_MAP_WEBM_45;
	}
	// WEBM_46
	else if(formatNo == VIDEO_FORMAT_NO_WEBM_46){
		formatMapNo = VIDEO_FORMAT_MAP_WEBM_46;
	}
	// ORIGINAL
	else if(formatNo == VIDEO_FORMAT_NO_ORIGINAL){
		formatMapNo = VIDEO_FORMAT_MAP_ORIGINAL;
	}

	return formatMapNo;
}
//------------------------------------
// convertToFormatMapNoToFileFormatNo
//------------------------------------
- (int)convertToFormatMapNoToFileFormatNo:(int)formatMapNo
{
	int fileFormatNo = VIDEO_FORMAT_NO_NORMAL;

	// NORMAL
	if(formatMapNo == VIDEO_FORMAT_MAP_NORMAL){
		fileFormatNo = VIDEO_FORMAT_NO_NORMAL;
	}
	// HQ
	else if(formatMapNo == VIDEO_FORMAT_MAP_HQ){
		fileFormatNo = VIDEO_FORMAT_NO_HQ;
	}
	// MP4
	else if(formatMapNo == VIDEO_FORMAT_MAP_HIGH){
		fileFormatNo = VIDEO_FORMAT_NO_HIGH;
	}
	// HD
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD){
		fileFormatNo = VIDEO_FORMAT_NO_HD;
	}
	// FMT34
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_34){
		fileFormatNo = VIDEO_FORMAT_NO_FMT_34;
	}
	// FMT35
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_35){
		fileFormatNo = VIDEO_FORMAT_NO_FMT_35;
	}
	// HD / 1080
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD_1080){
		fileFormatNo = VIDEO_FORMAT_NO_HD_1080;
	}
	// WEBM_43
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_43){
		fileFormatNo = VIDEO_FORMAT_NO_WEBM_43;
	}
	// WEBM_44
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_44){
		fileFormatNo = VIDEO_FORMAT_NO_WEBM_44;
	}
	// WEBM_45
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_45){
		fileFormatNo = VIDEO_FORMAT_NO_WEBM_45;
	}
	// WEBM_46
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_46){
		fileFormatNo = VIDEO_FORMAT_NO_WEBM_46;
	}
	// ORIGINAL
	else if(formatMapNo == VIDEO_FORMAT_MAP_ORIGINAL){
		fileFormatNo = VIDEO_FORMAT_NO_ORIGINAL;
	}

	return fileFormatNo;
}
//------------------------------------
// convertToFormatMapNoOrder
//------------------------------------
- (int)convertToFormatMapNoOrder:(int)formatMapNo
{
	int order = VIDEO_FORMAT_ORDER_NORMAL;

	// NORMAL
	if(formatMapNo == VIDEO_FORMAT_MAP_NORMAL){
		order = VIDEO_FORMAT_ORDER_NORMAL;
	}
	// HQ
	else if(formatMapNo == VIDEO_FORMAT_MAP_HQ){
		order = VIDEO_FORMAT_ORDER_HQ;
	}
	// MP4
	else if(formatMapNo == VIDEO_FORMAT_MAP_HIGH){
		order = VIDEO_FORMAT_ORDER_HIGH;
	}
	// HD
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD){
		order = VIDEO_FORMAT_ORDER_HD;
	}
	// FMT34
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_34){
		order = VIDEO_FORMAT_ORDER_FMT_34;
	}
	// FMT35
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_35){
		order = VIDEO_FORMAT_ORDER_FMT_35;
	}
	// HD / 1080
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD_1080){
		order = VIDEO_FORMAT_ORDER_HD_1080;
	}
	// WEBM_43
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_43){
		order = VIDEO_FORMAT_ORDER_WEBM_43;
	}
	// WEBM_44
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_44){
		order = VIDEO_FORMAT_ORDER_WEBM_44;
	}
	// WEBM_45
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_45){
		order = VIDEO_FORMAT_ORDER_WEBM_45;
	}
	// WEBM_46
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_46){
		order = VIDEO_FORMAT_ORDER_WEBM_46;
	}
	// ORIGINAL
	else if(formatMapNo == VIDEO_FORMAT_MAP_ORIGINAL){
		order = VIDEO_FORMAT_ORDER_ORIGINAL;
	}

	return order;
}
//------------------------------------
// convertToFormatMapNoTitle
//------------------------------------
- (NSString*)convertToFormatMapNoTitle:(int)formatMapNo
{
	NSString *title = @"";

	// NORMAL
	if(formatMapNo == VIDEO_FORMAT_MAP_NORMAL){
		title = VIDEO_FORMAT_NAME_NORMAL;
	}
	// HQ
	else if(formatMapNo == VIDEO_FORMAT_MAP_HQ){
		title = VIDEO_FORMAT_NAME_HQ;
	}
	// MP4
	else if(formatMapNo == VIDEO_FORMAT_MAP_HIGH){
		title = VIDEO_FORMAT_NAME_HIGH;
	}
	// HD
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD){
		title = VIDEO_FORMAT_NAME_HD;
	}
	// FMT34
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_34){
		title = VIDEO_FORMAT_NAME_FMT_34;
	}
	// FMT35
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_35){
		title = VIDEO_FORMAT_NAME_FMT_35;
	}
	// HD_1080
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD_1080){
		title = VIDEO_FORMAT_NAME_HD_1080;
	}
	// WEBM_43
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_43){
		title = VIDEO_FORMAT_NAME_WEBM_43;
	}
	// WEBM_44
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_44){
		title = VIDEO_FORMAT_NAME_WEBM_44;
	}
	// WEBM_45
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_45){
		title = VIDEO_FORMAT_NAME_WEBM_45;
	}
	// WEBM_46
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_46){
		title = VIDEO_FORMAT_NAME_WEBM_46;
	}
	// ORIGINAL
	else if(formatMapNo == VIDEO_FORMAT_MAP_ORIGINAL){
		title = VIDEO_FORMAT_NAME_ORIGINAL;
	}
	return title;

}

//------------------------------------
// convertToFormatMapNoDescription
//------------------------------------
- (NSString*)convertToFormatMapNoDescription:(int)formatMapNo
{
	NSString *description = @"";

	// NORMAL
	if(formatMapNo == VIDEO_FORMAT_MAP_NORMAL){
		description = VIDEO_FORMAT_DESC_NORMAL;
	}
	// HQ
	else if(formatMapNo == VIDEO_FORMAT_MAP_HQ){
		description = VIDEO_FORMAT_DESC_HQ;
	}
	// MP4
	else if(formatMapNo == VIDEO_FORMAT_MAP_HIGH){
		description = VIDEO_FORMAT_DESC_HIGH;
	}
	// HD
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD){
		description = VIDEO_FORMAT_DESC_HD;
	}
	// FMT34
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_34){
		description = VIDEO_FORMAT_DESC_FMT_34;
	}
	// FMT35
	else if(formatMapNo == VIDEO_FORMAT_MAP_FMT_35){
		description = VIDEO_FORMAT_DESC_FMT_35;
	}
	// HD_1080
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD_1080){
		description = VIDEO_FORMAT_DESC_HD_1080;
	}
	// WEBM_43
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_43){
		description = VIDEO_FORMAT_DESC_WEBM_43;
	}
	// WEBM_44
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_44){
		description = VIDEO_FORMAT_DESC_WEBM_44;
	}
	// WEBM_45
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_45){
		description = VIDEO_FORMAT_DESC_WEBM_45;
	}
	// WEBM_46
	else if(formatMapNo == VIDEO_FORMAT_MAP_WEBM_46){
		description = VIDEO_FORMAT_DESC_WEBM_46;
	}
	// ORIGINAL
	else if(formatMapNo == VIDEO_FORMAT_MAP_ORIGINAL){
		description = VIDEO_FORMAT_DESC_ORIGINAL;
	}
	return description;

}
//------------------------------------
// convertToFileFormatNoToFormatType
//------------------------------------
- (int)convertToFileFormatNoToFormatType:(int)formatNo
{
	// NORMAL
	int formatType = VIDEO_FORMAT_TYPE_NORMAL;

	// HQ
	if(formatNo == VIDEO_FORMAT_NO_HQ){
		formatType = VIDEO_FORMAT_TYPE_HQ;
	}
	// HIGH
	else if(formatNo == VIDEO_FORMAT_NO_HIGH){
		formatType = VIDEO_FORMAT_TYPE_HIGH;
	}
	// HD
	else if(formatNo == VIDEO_FORMAT_NO_HD){
		formatType = VIDEO_FORMAT_TYPE_HD;
	}
	// FMT34
	else if(formatNo == VIDEO_FORMAT_NO_FMT_34){
		formatType = VIDEO_FORMAT_TYPE_FMT_34;
	}
	// FMT35
	else if(formatNo == VIDEO_FORMAT_NO_FMT_35){
		formatType = VIDEO_FORMAT_TYPE_FMT_35;
	}
	// HD_1080
	else if(formatNo == VIDEO_FORMAT_NO_HD_1080){
		formatType = VIDEO_FORMAT_TYPE_HD_1080;
	}
	// WEBM_43
	else if(formatNo == VIDEO_FORMAT_NO_WEBM_43){
		formatType = VIDEO_FORMAT_TYPE_WEBM_43;
	}
	// WEBM_45
	else if(formatNo == VIDEO_FORMAT_NO_WEBM_45){
		formatType = VIDEO_FORMAT_TYPE_WEBM_45;
	}
	// WEBM_46
	else if(formatNo == VIDEO_FORMAT_NO_WEBM_46){
		formatType = VIDEO_FORMAT_TYPE_WEBM_46;
	}
	// ORIGINAL
	else if(formatNo == VIDEO_FORMAT_NO_ORIGINAL){
		formatType = VIDEO_FORMAT_TYPE_ORIGINAL;
	}

	return formatType;
}

//------------------------------------
// convertToFormatMapNoLabelColor
//------------------------------------
- (NSColor*)convertToFormatMapNoLabelColor:(int)formatMapNo
{

	NSColor *color = [NSColor blackColor];

	// HQ / yellow
	if(formatMapNo == VIDEO_FORMAT_MAP_HQ){
		color = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:0.8];
	}
	// MP4 / blue
	else if(formatMapNo == VIDEO_FORMAT_MAP_HIGH){
		color = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.8];
	}
	// HD / red
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD){
		color = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.8];
	}
	// HD_1080 / red
	else if(formatMapNo == VIDEO_FORMAT_MAP_HD_1080){
		color = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.8];
	}

	return color;

}
//------------------------------------
// decodeToPercentEscapesString
//------------------------------------
- (NSString*)decodeToPercentEscapesString:(NSString*)string
{
	// %XX -> char
	NSString *encodedStr = [self encodeFromPercentEscapesString:string];

	// char -> %XX
	NSString *decodedStr = (NSString *) CFURLCreateStringByAddingPercentEscapes(
				kCFAllocatorDefault,
				(CFStringRef) encodedStr,
				nil,
				nil,
				kCFStringEncodingUTF8);

	return decodedStr;
}
//------------------------------------
// encodeFromPercentEscapesString
//------------------------------------
- (NSString*)encodeFromPercentEscapesString:(NSString*)string
{
	// %XX -> char
	NSString *encodedStr = (NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
				kCFAllocatorDefault,
				(CFStringRef) string,
				CFSTR(""),
				kCFStringEncodingUTF8);

	return encodedStr;
}
//------------------------------------
// convertToURIEncodedString
//------------------------------------
- (NSString*)convertToURIEncodedString:(NSString*)string
{
	NSArray *escapeChars = [self escapeChars];
	NSArray *percentChars = [self percentChars];

	int len = [escapeChars count];

	NSMutableString *temp = [string mutableCopy];

	int i;
	for(i = 0; i < len; i++){
		[temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
									withString:[percentChars objectAtIndex:i]
									options:NSLiteralSearch
									range:NSMakeRange(0, [temp length])];
	}

	NSString *out = [NSString stringWithString: temp];

	return out;
}
//------------------------------------
// convertFromURIEncodedString
//------------------------------------
- (NSString*)convertFromURIEncodedString:(NSString*)string
{

	NSArray *percentChars = [self percentChars];
	NSArray *escapeChars = [self escapeChars];

	int len = [percentChars count];

	// replace %25 -> %
	string = [self replaceCharacter:string str1:@"\%25" str2:@"\%"];

	NSMutableString *temp = [string mutableCopy];

	int i;
	for(i = 0; i < len; i++){
		[temp replaceOccurrencesOfString: [percentChars objectAtIndex:i]
									withString:[escapeChars objectAtIndex:i]
									options:NSLiteralSearch
									range:NSMakeRange(0, [temp length])];
	}

	NSString *out = [NSString stringWithString: temp];

	return out;
}
//------------------------------------
// percentChars
//------------------------------------
- (NSArray*)percentChars
{
	return [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" , @"%3A" , 
									@"%40" , @"%26" , @"%3D" , @"%2B" , 
									@"%24" , @"%2C" , @"%5B" , @"%5D", 
									@"%23", @"%21", @"%27", @"%28", 
									@"%29", @"%2A", @"%252C", @"%253A",
									@"%253D",
									nil];
}
//------------------------------------
// escapeChars
//------------------------------------
- (NSArray*)escapeChars
{
	return [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
									@"@" , @"&" , @"=" , @"+" ,
									@"$" , @"," , @"[" , @"]",
									@"#", @"!", @"'", @"(", 
									@")", @"*", @",", @":",
									@"=",
									nil];
}
//------------------------------------
// convertToShiftJISString
//------------------------------------
- (NSString*)convertToShiftJISString:(char*)string
{
	return [NSString stringWithCString:string encoding:NSShiftJISStringEncoding];
}

//------------------------------------
// convertDownloadStatusToString
//------------------------------------
- (NSString*)convertDownloadStatusToString:(int)status
{
	NSString *string = @"";

	if(status == DOWNLOAD_INIT){
		string = @"Initializing..";
	}
	else if(status == DOWNLOAD_STARTED ||
			status == DOWNLOAD_COMPLETED){
		// none
	}
	else if(status == DOWNLOAD_CANCELED){
		string = @"Canceled";
	}
	else if(status == DOWNLOAD_FAILED){
		string = @"Failed";
	}

	return string;

}
//------------------------------------
// convertDownloadStatusToImage
//------------------------------------
- (NSImage*)convertDownloadStatusToImage:(int)status
{
	NSImage *image;

	// init, started
	if( status == DOWNLOAD_INIT ||
		status == DOWNLOAD_STARTED){
		image = [NSImage imageNamed:@"icon_download_cancel"];
	}
	// completed
	else if(status == DOWNLOAD_COMPLETED){
		image = [NSImage imageNamed:@"icon_download_completed"];
	}
	// canceled
	else if(status == DOWNLOAD_CANCELED){
		image = [NSImage imageNamed:@"icon_download_restart"];
	}
	// failed, other
	else{
		image = [NSImage imageNamed:@"icon_download_failed"];
	}
	return image;
}
//------------------------------------
// convertDownloadSearchToImage
//------------------------------------
- (NSImage*)convertDownloadSearchToImage:(BOOL)isExist
{
	NSImage *image = nil;
	if(isExist == YES){
		image = [NSImage imageNamed:@"icon_download_search"];
	}
	return image;
}
//------------------------------------
// convertIntToString
//------------------------------------
- (NSString*)convertIntToString:(int)intValue
{
	NSNumber *number = [NSNumber numberWithInt:intValue];
	return [number stringValue];
}
//------------------------------------
// convertStringToIntValue
//------------------------------------
- (int)convertStringToIntValue:(id)value
{
	int intValue = 0;

	if(value && [value isKindOfClass:[NSString class]] == YES){
		if([self checkIsDigitString:value] == YES){
			intValue = [value intValue];
		}
	}
	return intValue;
}
//------------------------------------
// convertStringToBoolValue
//------------------------------------
- (BOOL)convertStringToBoolValue:(id)value
{
	BOOL boolValue = NO;

	if(value && [value isKindOfClass:[NSString class]] == YES){
		if([value isEqualToString:@"true"]){
			boolValue = YES;
		}
	}
	return boolValue;
}
//------------------------------------
// convert file size string
//------------------------------------
- (NSString*)convertFileSizeToString:(double)fileSize
{
	NSString *fileSizeName = @"";

	// fileSize < 1MB
/*
	if(fileSize < 1024){
		fileSize = fileSize / 1024;
		fileSizeName = @"KB";
	}
*/
	if(fileSize < (1024 * 1024)){
		fileSize = fileSize / 1024;
		fileSizeName = @"KB";
	}
	// fileSize < 1GB
	else if(fileSize < (1024 * 1024 * 1024)){
		fileSize = fileSize / (1024 * 1024);
		fileSizeName = @"MB";
	}
	else{
		fileSize = fileSize / (1024 * 1024 * 1024);
		fileSizeName = @"GB";
	}

	return [NSString stringWithFormat: @"%.1f %@",fileSize,fileSizeName];

}
//------------------------------------
// convertTimeToString
//------------------------------------
- (NSString*)convertTimeToString:(int)sec
{

	int hour = 0;
	int min = 0;

	if(sec >= 3600){
		hour = sec / 3600;
		sec = sec % 3600;
	}

	if(sec >= 60){
		min = sec / 60;
		sec = sec % 60;
	}

	// time format
	if(hour > 0){
		return [NSString stringWithFormat:@"%02d:%02d:%02d",hour, min, sec];
	}else{
		return [NSString stringWithFormat:@"%d:%02d", min, sec];
	}

}
//------------------------------------
// convertToComma
//------------------------------------
- (NSString*)convertToComma:(int)value
{
	NSNumber *number=[NSNumber numberWithInt:value];
	NSNumberFormatter *formatter=[[[NSNumberFormatter alloc] init] autorelease];

//	[formatter setThousandSeparator:@","];
//	[formatter setHasThousandSeparators:YES];
	[formatter setFormat:@"#,##0;0;-#,##0"];

	return [formatter stringForObjectValue:number];
}
//------------------------------------
// convertToZeroFormat
//------------------------------------
- (NSString*)convertToZeroFormat:(int)value
{
	NSNumber *number=[NSNumber numberWithInt:value];
	NSNumberFormatter *formatter=[[[NSNumberFormatter alloc] init] autorelease];

	[formatter setFormat:@"00000000;00000000;-00000000"];

	return [formatter stringForObjectValue:number];
}
//------------------------------------
// appendToSearchFilterKeywords
//------------------------------------
- (NSString*)appendToSearchFilterKeywords:(NSString*)string
{

	// filter enabled
	if([self defaultBoolValue:@"optSearchFilterEnable"] == YES){
		NSArray *items = [self defaultArrayValue:@"optSearchFilterItems"];

		if(items != nil){
			// fetch enabled items 
			NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
			pred = [NSPredicate predicateWithFormat:@"keyword != NULL AND enabled == YES"];
			NSArray *fetchedArray = [items filteredArrayUsingPredicate:pred];

			NSArray *keywords = [fetchedArray valueForKey:@"keyword"];

			// append filter keywords
			string = [self appendToFilterKeywords:string keywords:keywords];
		}

	}

	return string;

}
//------------------------------------
// appendToFilterKeywords
//------------------------------------
- (NSString*)appendToFilterKeywords:(NSString*)string keywords:(NSArray*)keywords
{
	int i;

	for(i = 0; i < [keywords count]; i++){
		if([keywords objectAtIndex:i] && ![[keywords objectAtIndex:i] isEqualToString:@""]){
			string = [string stringByAppendingString:[NSString stringWithFormat:@" -\"%@\"", [keywords objectAtIndex:i]]];
		}
	}

	return string;

}
//------------------------------------
// replaceCharacters
//------------------------------------
- (NSString*)replaceCharacter:(NSString*)string str1:(NSString*)str1 str2:(NSString*)str2
{
	NSMutableString *muString = [NSMutableString stringWithString:string];

	[muString replaceOccurrencesOfString:str1 withString:str2 options:0 range:NSMakeRange(0,[muString length])];

	return muString;
}
//------------------------------------
// getLastSeparatedString
//------------------------------------
- (NSString*)getLastSeparatedString:(NSString*)str sep:(NSString*)sep
{
	NSString *retStr = str;

	NSArray *cols = [str componentsSeparatedByString:sep];
	if([cols count] > 0){
		retStr = [cols objectAtIndex:[cols count] - 1];
	}

	return retStr;
}
//------------------------------------
// checkIsDigitString
//------------------------------------
- (BOOL)checkIsDigitString:(NSString*)string
{
	BOOL ret = YES;
	NSCharacterSet *invertedSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	NSRange rng = [string rangeOfCharacterFromSet:invertedSet];
	if(rng.length > 0){
		ret = NO;
	}
	return ret;
}
//------------------------------------
// checkIsLetterString
//------------------------------------
- (BOOL)checkIsLetterString:(NSString*)string
{
	BOOL ret = YES;
	NSCharacterSet *invertedSet = [[NSCharacterSet letterCharacterSet] invertedSet];
	NSRange rng = [string rangeOfCharacterFromSet:invertedSet];
	if(rng.length > 0){
		ret = NO;
	}
	return ret;
}
//------------------------------------
// checkIsTargetURL
//------------------------------------
- (BOOL)checkIsTargetURL:(NSString*)urlString targetString:(NSString*)targetString
{
	BOOL ret = NO;

	NSRange rng = [urlString rangeOfString:targetString];
	if(rng.length > 0){
		ret = YES;
	}

	return ret;
}
@end