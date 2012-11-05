#import "LogStatusController.h"
#import "UserDefaultsExtension.h"

@implementation LogStatusController

//------------------------------------
// awake
//------------------------------------
- (void)awakeFromNib
{

	[self setTitle:@""];
	[self setLogString:@""];

	// set window rect
	[self setWindowRect:logWindow key:@"rectWindowLog"];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:logWindow];
}

//------------------------------------
// open Log Window
//------------------------------------
- (IBAction)openLogWindow:(id)sender
{
	NSString *logString = [NSString stringWithFormat:@"%@ v%@ / OS %@\n%@"
								, [self defaultAppName]
								, [self defaultAppVersion]
								, [self defaultOSVersion]
								, [self logString]
							];

	[logWindow setTitle:[self title]];
	[txtLogString setString:logString];
	[logWindow makeKeyAndOrderFront:self];

}

//------------------------------------
// title
//------------------------------------
- (void)setTitle:(NSString *)title
{
	[title retain];
    [title_ release];
    title_ = title;

}
- (NSString *)title
{
	return title_;
}
//------------------------------------
// logString
//------------------------------------
- (void)setLogString:(NSString *)logString
{
	[logString retain];
    [logString_ release];
    logString_ = logString;

}
- (NSString *)logString
{
	return logString_;
}
//------------------------------------
// appendLogString
//------------------------------------
- (void)appendLogString:(NSString *)logString;
{
	[self setLogString:[[self logString] stringByAppendingString:logString]];
}

//------------------------------------
// windowWillClose
//------------------------------------
-(void)windowWillClose:(NSNotification *)notification
{
	// clear log
	[txtLogString setString:@""];
	[self setLogString:@""];

	// save window rect
	[self saveWindowRect:logWindow key:@"rectWindowLog"];
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[title_ release];
	[logString_ release];
    [super dealloc];
}

@end
