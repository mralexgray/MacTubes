#import "ContentItem.h"
#import "ConvertExtension.h"

@implementation ContentItem
//------------------------------------
// initVideo
//------------------------------------
- (id)initVideo:(GDataEntryYouTubeVideo*)video
				image:(NSImage*)image
				author:(NSString*)author
				itemId:(NSString*)itemId
{
	if (self = [super init])
	{
		[self setVideo:video];
		[self setItemId:itemId];
		[self setAuthor:author];
		[self setImage:image];
	}
	return self;
}

//------------------------------------
// video
//------------------------------------
- (void)setVideo:(GDataEntryYouTubeVideo*)video
{
	[video retain];
	[video_ release];
	video_ = video;
}
- (GDataEntryYouTubeVideo*)video
{
	return video_;
}
//------------------------------------
// itemId
//------------------------------------
- (void)setItemId:(NSString*)itemId
{
	[itemId retain];
	[itemId_ release];
	itemId_ = itemId;
}
- (NSString*)itemId
{
	return itemId_;
}
//------------------------------------
// author
//------------------------------------
- (void)setAuthor:(NSString*)author
{
	[author retain];
	[author_ release];
	author_ = author;
}
- (NSString*)author
{
	return author_;
}
//------------------------------------
// image
//------------------------------------
- (void)setImage:(NSImage*)image
{
	[image retain];
	[image_ release];
	image_ = image;
}
- (NSImage*)image
{
	return image_;
}
//------------------------------------
// title
//------------------------------------
- (NSString*)title
{
	return [[[self video] title] stringValue];
}
//------------------------------------
// contentURL
//------------------------------------
- (NSString*)contentURL
{

	NSString *url = @"";  

	NSArray *array = [[[self video] mediaGroup] mediaContents];
	NSEnumerator *enumArray = [array objectEnumerator];

	// search http url
	id record;
	int fmtNumber;
	while (record = [enumArray nextObject]) {
		fmtNumber = [[record youTubeFormatNumber] intValue];
//		if(fmtNumber == kGDataYouTubeMediaContentFormatHTTPURL){
		if(fmtNumber == GDATA_YouTubeMediaContentFormatHTTPURL){
			url = [record URLString];
			break;
		}
	}

	// no url -> force convert default url
	if([url isEqualToString:@""]){
		url = [self convertToContentURL:[self itemId]];
	}

	return url;
}
//------------------------------------
// watchURL
//------------------------------------
- (NSString*)watchURL
{

	NSString *url = [[[[[self video] mediaGroup] mediaPlayers] objectAtIndex:0] URLString];

	// no url -> force convert default url
	if(!url){
		url = [self convertToWatchURL:[self itemId]];
	}
	url = [self convertToWatchURL:[self itemId]];

	return url;
}

//------------------------------------
// relatedURL
//------------------------------------
- (NSString*)relatedURL
{

	NSString *url = @"";  

	NSArray *array = [[self video] links];
	NSEnumerator *enumArray = [array objectEnumerator];

	// search related url
	id record;
	while (record = [enumArray nextObject]) {
		if([[record rel] isEqualToString:kGDataLinkYouTubeRelated]){
			url = [record href];
			break;
		}
	}

	// no url
	if([url isEqualToString:@""]){
		url = [self convertToRelatedURL:[self itemId]];
	}

	return url;
}
//------------------------------------
// imageURL
//------------------------------------
- (NSString*)imageURL
{
	NSString *imageURL = @"";
	NSArray *array = [[[self video] mediaGroup] mediaThumbnails];
	if([array count] > 0){
		imageURL = [[array objectAtIndex:0] URLString];
	}

	return imageURL;
}

//------------------------------------
// isEmbedPlay
//------------------------------------
- (BOOL)isEmbedPlay
{

	BOOL isEmbedPlay = NO;

	NSArray *array = [[[self video] mediaGroup] mediaContents];
	NSEnumerator *enumArray = [array objectEnumerator];

	// search http url
	id record;
	int fmtNumber;
	while (record = [enumArray nextObject]) {
		fmtNumber = [[record youTubeFormatNumber] intValue];
		if(fmtNumber == GDATA_YouTubeMediaContentFormatHTTPURL){
			isEmbedPlay = YES;
			break;
		}
	}

	return isEmbedPlay;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
//	NSLog(@"dealloc=%@", [self title]);

	[video_ release];
	[image_ release];
	[author_ release];
	[itemId_ release];
	[super dealloc];
}

@end
