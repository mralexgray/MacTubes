#import "TextFieldFileFormatNo.h"
#import "UserDefaultsExtension.h"

static NSString *defaultKeyNamePlayerType = @"optVideoPlayerType";
static NSString *defaultKeyNameCanSelectFLV = @"optCanSelectFLVFormat";

@implementation TextFieldFileFormatNo

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[self setTextFieldColor];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKeyNamePlayerType options:0 context:nil];
	[defaults addObserver:self forKeyPath:defaultKeyNameCanSelectFLV options:0 context:nil];

}
//------------------------------------
// setTextFieldColor
//------------------------------------
- (void)setTextFieldColor
{

	int fileFormatType = [self tag];
	int playerType = [self defaultBoolValue:defaultKeyNamePlayerType];
	BOOL isSelectFLV = [self defaultBoolValue:defaultKeyNameCanSelectFLV];
	NSColor *color = [NSColor blackColor];

	if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		// FLV
		if(fileFormatType == VIDEO_FORMAT_FILE_TYPE_FLV &&
			isSelectFLV == NO
		){
			color = [NSColor grayColor];
		}
	}
	else{
		color = [NSColor grayColor];
	}

	[self setTextColor:color];

}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	if( [keyPath isEqualToString:defaultKeyNamePlayerType] ||
		[keyPath isEqualToString:defaultKeyNameCanSelectFLV]
	){
		[self setTextFieldColor];
	}
	
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKeyNamePlayerType];
	[defaults removeObserver:self forKeyPath:defaultKeyNameCanSelectFLV];
	
	[super dealloc];
}

@end
