#import "TextFieldPlayerType.h"
#import "UserDefaultsExtension.h"

static NSString *defaultKeyName = @"optVideoPlayerType";

@implementation TextFieldPlayerType

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[self setTextFieldColor];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKeyName options:0 context:nil];

}
//------------------------------------
// setTextFieldColor
//------------------------------------
- (void)setTextFieldColor
{

	int tag = [self tag];
	int playerType = [self defaultIntValue:defaultKeyName];
	NSColor *color = [NSColor blackColor];

	// VIDEO or QUICKTIME
	if(tag == 3){
		if( playerType != VIDEO_PLAYER_TYPE_VIDEO &&
			playerType != VIDEO_PLAYER_TYPE_QUICKTIME){
			color = [NSColor grayColor];
		}
	}
	else{
		if(tag != playerType){
			color = [NSColor grayColor];
		}
	}

	[self setTextColor:color];

}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	if([keyPath isEqualToString:defaultKeyName]){
		[self setTextFieldColor];
	}
	
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKeyName];
	
	[super dealloc];
}

@end
