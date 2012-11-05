#import <Cocoa/Cocoa.h>
#import "VideoItemStatus.h"
#import "VideoFormatTypes.h"
#import "VideoArgsTypes.h"

@interface VideoInfoItem : NSObject
{
	
	NSString *itemId_;
	int formatNo_;
	int notifType_;
	int itemStatus_;
	int formatMapNo_;

	id target_;

	NSMutableData *htmlData_;
	NSURLConnection *connection_;
	NSTimer *requestTimer_;

}
- (id)initWithVideo:(NSString*)itemId
				formatNo:(int)formatNo
				interval:(float)interval
				target:(id)target
				notifType:(int)notifType;

- (void)getVideoInfoByTimer:(NSString*)urlString interval:(float)interval;
- (void)getVideoInfo:(id)sender;
- (BOOL)createConnection:(NSString*)urlString;

- (void)notifyVideoInfoItemDidLoad:(VideoInfoItem*)item;
- (void)cancelConnection;
- (void)removeItemObserver:(VideoInfoItem*)item;

- (void)setConnection:(NSURLConnection*)connection;
- (NSURLConnection*)connection;
- (void)setRequestTimer:(NSTimer*)requestTimer;
- (NSTimer*)requestTimer;
- (void)cancelRequestTimer;

- (void)setItemId:(NSString*)itemId;
- (NSString*)itemId;
- (void)setFormatNo:(int)formatNo;
- (int)formatNo;

- (int)itemStatus;
- (int)formatMapNo;
- (int)notifType;

@end
