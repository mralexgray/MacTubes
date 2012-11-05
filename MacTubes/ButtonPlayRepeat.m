#import "ButtonPlayRepeat.h"
#import "UserDefaultsExtension.h"

static NSString *defaultKey = @"optPlayRepeat";

@implementation ButtonPlayRepeat
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[self setTarget:self];
	[self setAction:NSSelectorFromString(@"changePlayRepeat:")];

	// delete focus ring
	[self setFocusRingType:NSFocusRingTypeNone];
//	[self setEnabled:NO];

	[self changeButtonImage];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKey options:0 context:nil];

	// set notification
//	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
//	[nc addObserver:self selector:@selector(handleVideoObjectDidChanged:) name:VIDEO_NOTIF_OBJECT_DID_CHANGED object:nil];

}
//=======================================================================
// action
//=======================================================================
//------------------------------------
// changePlayRepeat
//------------------------------------
- (IBAction)changePlayRepeat:(id)sender
{
	int playRepeat = [self defaultPlayRepeat];

	playRepeat++;
	if(playRepeat > PLAY_REPEAT_ONE){
		playRepeat = PLAY_REPEAT_OFF;
	}

	[self setDefaultIntValue:playRepeat key:defaultKey];

//	[self changePlayRepeatButtonImage];

}
//----------------------------------------
// changeButtonImage
//----------------------------------------
- (void)changeButtonImage
{

	NSImage *image = [NSImage imageNamed:@"btn_repeat_off"];
	NSString *title = @"";
	NSString *toolTip = @"";

	// playRepeat
	switch([self defaultPlayRepeat]){
		case PLAY_REPEAT_OFF:
			image = [NSImage imageNamed:@"btn_repeat_off"];
			title = @"Now Repeat Off. Next is Repeat All.";
			toolTip = @"Repeat Off";
			break;
		case PLAY_REPEAT_ALL:
			image = [NSImage imageNamed:@"btn_repeat_all"];
			title = @"Now Repeat All. Next is Repeat One.";
			toolTip = @"Repeat All";
			break;
		case PLAY_REPEAT_ONE:
			image = [NSImage imageNamed:@"btn_repeat_one"];
			title = @"Now Repeat One. Next is Repeat Off.";
			toolTip = @"Repeat One";
			break;
	}

	[self setImage:image];
	[self setTitle:title];
	[self setImagePosition:NSImageOnly];
	[self setToolTip:toolTip];

}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

	if([keyPath isEqualToString:defaultKey]){
		[self changeButtonImage];
	}
	
}
//------------------------------------
// handleVideoObjectDidChanged
//------------------------------------
- (void)handleVideoObjectDidChanged:(NSNotification *)notification
{
	BOOL hasVideo = [[notification object] boolValue];

	[self setEnabled:hasVideo];
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKey];
//	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}
@end
