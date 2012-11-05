/* ConvertExtension */

#import <Cocoa/Cocoa.h>
#import "DownloadStatus.h"
#import "VideoFormatTypes.h"

@interface NSObject(convertExtension_)

- (NSString*)convertToYouTubeBaseURL;
- (NSString*)convertToYouTubeComURL;
- (NSString*)convertToGdataBaseURL;

- (NSString*)convertToEntryURL:(NSString*)itemId;
- (NSString*)convertToWatchURL:(NSString*)itemId;
- (NSString*)convertToContentURL:(NSString*)itemId;
- (NSString*)convertToDownloadURL:(NSString*)itemId;
- (NSString*)convertToFileFormatURL:(NSString*)url fileFormatNo:(int)fileFormatNo;

- (NSString*)convertToRelatedURL:(NSString*)itemId;
- (NSString*)convertToCommentsURL:(NSString*)itemId;
- (NSString*)convertToCommentsEntryURL:(NSString*)itemId commentId:(NSString*)commentId;
- (NSString*)convertToAuthorsUploadURL:(NSString*)author;
- (NSString*)convertToAuthorsProfileURL:(NSString*)author;
- (NSString*)convertToDownloadFileURL:(NSString*)str1 str2:(NSString*)str2;
- (NSString*)convertToResultString:(int)startIndex lastIndex:(int)lastIndex totalResults:(int)totalResults;

//- (NSString*)convertToFileFormatTitle:(NSString*)title fileFormatNo:(int)fileFormatNo;
- (int)convertToFileFormatNoToFormatMapNo:(int)formatNo;
- (int)convertToFormatMapNoToFileFormatNo:(int)formatMapNo;
- (int)convertToFormatMapNoOrder:(int)formatMapNo;

- (NSString*)convertToFormatMapNoTitle:(int)formatMapNo;
- (NSString*)convertToFormatMapNoDescription:(int)formatMapNo;
- (int)convertToFileFormatNoToFormatType:(int)formatNo;
- (NSColor*)convertToFormatMapNoLabelColor:(int)formatMapNo;

- (NSString*)decodeToPercentEscapesString:(NSString*)string;
- (NSString*)encodeFromPercentEscapesString:(NSString*)string;
- (NSString*)convertToURIEncodedString:(NSString*)string;
- (NSString*)convertFromURIEncodedString:(NSString*)string;
- (NSArray*)percentChars;
- (NSArray*)escapeChars;
- (NSString*)convertToShiftJISString:(char*)string;

- (NSString*)convertDownloadStatusToString:(int)status;
- (NSImage*)convertDownloadStatusToImage:(int)status;
- (NSImage*)convertDownloadSearchToImage:(BOOL)isExist;

- (NSString*)convertIntToString:(int)intValue;
- (int)convertStringToIntValue:(id)value;
- (BOOL)convertStringToBoolValue:(id)value;
- (NSString*)convertFileSizeToString:(double)fileSize;
- (NSString*)convertTimeToString:(int)sec;
- (NSString*)convertToComma:(int)value;
- (NSString*)convertToZeroFormat:(int)value;

- (NSString*)appendToSearchFilterKeywords:(NSString*)string;
- (NSString*)appendToFilterKeywords:(NSString*)string keywords:(NSArray*)keywords;

- (NSString*)replaceCharacter:(NSString*)string str1:(NSString*)str1 str2:(NSString*)str2;

- (NSString*)getLastSeparatedString:(NSString*)str sep:(NSString*)sep;
- (BOOL)checkIsDigitString:(NSString*)string;
- (BOOL)checkIsLetterString:(NSString*)string;
- (BOOL)checkIsTargetURL:(NSString*)urlString targetString:(NSString*)targetString;

@end
