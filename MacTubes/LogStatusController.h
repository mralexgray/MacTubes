/* LogStatusController */

#import <Cocoa/Cocoa.h>

@interface LogStatusController : NSObject
{
    IBOutlet NSWindow *logWindow;
    IBOutlet NSTextView *txtLogString;

	NSString *title_;
	NSString *logString_;

}
- (IBAction)openLogWindow:(id)sender;

- (void)setTitle:(NSString *)title;
- (NSString *)title;
- (void)setLogString:(NSString *)logString;
- (NSString *)logString;
- (void)appendLogString:(NSString *)logString;

@end

