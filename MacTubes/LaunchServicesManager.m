#import "LaunchServicesManager.h"
#import "ViewPlayer.h"
#import "YouTubeHelperExtension.h"

@implementation LaunchServicesManager
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
}
//=======================================================================
// methods
//=======================================================================
//------------------------------------
// openWithURL
//------------------------------------
- (void)openWithURL:(NSPasteboard*)pboard userData:(NSString*)data error:(NSString**)error
{

	NSArray *types = [pboard types]; 

	if(![types containsObject:NSStringPboardType]) {
		*error = @"Can not open URL.";
		return;
	}

	NSString *urlString = [pboard stringForType:NSStringPboardType];

	if(!urlString) {
		*error = @"Can not open URL.";
		return;
	}

	[self openWithURLString:urlString];

}
//------------------------------------
// handleGetURLEvent
//------------------------------------
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
//	NSString *urlString = [[event descriptorForKeyword:keyDirectObject] stringValue];
	NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	[self openWithURLString:urlString];
//	NSLog(@"urlString=%@", urlString);

}
//------------------------------------
// openWithURLString
//------------------------------------
- (void)openWithURLString:(NSString*)urlString
{

	// check url
	if([self checkIsWatchURL:urlString] == YES){
		// open player
		[viewPlayer setPlayerViewWithURL:urlString];
	}
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
    [super dealloc];
}

@end
