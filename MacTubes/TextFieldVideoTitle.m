#import "TextFieldVideoTitle.h"
#import "UserDefaultsExtension.h"
#import "ConvertExtension.h"

@implementation TextFieldVideoTitle

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[self setStringValue:@""];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleVideoObjectDidChanged:) name:VIDEO_NOTIF_OBJECT_DID_CHANGED object:nil];
	[nc addObserver:self selector:@selector(handleVideoStatusDidChanged:) name:VIDEO_NOTIF_STATUS_DID_CHANGED object:nil];

}
//------------------------------------
// handleVideoObjectDidChanged
//------------------------------------
- (void)handleVideoObjectDidChanged:(NSNotification *)notification
{
	BOOL hasVideo = [[notification object] boolValue];

	if(hasVideo == NO){
		[self setStringValue:@""];
	}
}
//------------------------------------
// handleVideoStatusDidChanged
//------------------------------------
- (void)handleVideoStatusDidChanged:(NSNotification *)notification
{

	NSDictionary *params = [notification object];

	NSString *title = [params valueForKey:@"title"];

	if(!title){title = @"";}

	[self setStringValue:title];

}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
