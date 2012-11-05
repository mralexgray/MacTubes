/* LaunchServicesManager */

#import <Cocoa/Cocoa.h>

@interface LaunchServicesManager : NSObject
{
    IBOutlet id viewPlayer;

}
- (void)openWithURL:(NSPasteboard*)pboard userData:(NSString*)data error:(NSString**)error;
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
- (void)openWithURLString:(NSString*)urlString;

@end
