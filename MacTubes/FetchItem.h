#import <Cocoa/Cocoa.h>
#import "FetchItemStatus.h"

@interface FetchItem : NSObject
{
	
	NSString *requestURL_;
	NSDictionary *userParams_;
	NSError *error_;

	id notifTarget_;
	int itemStatus_;

	NSMutableData *data_;
	NSURLConnection *connection_;

}
- (id)initWithURL:(NSString*)requestURL
				userParams:(NSDictionary*)userParams
				notifTarget:(id)notifTarget
				reqParams:(NSDictionary*)reqParams;

- (BOOL)createConnection:(NSString*)requestURL
				reqParams:(NSDictionary*)reqParams;

- (void)postFetchItemStatusDidChanged:(FetchItem*)item;
- (void)postFetchItemDidLoaded:(FetchItem*)item;
- (void)cancelConnection;
- (void)removeItemObserver:(FetchItem*)item;

- (void)setConnection:(NSURLConnection*)connection;
- (NSURLConnection*)connection;

- (void)setRequestURLL:(NSString*)requestURL;
- (NSString*)requestURL;
- (void)setUserParams:(NSDictionary*)userParams;
- (NSDictionary*)userParams;
- (void)setError:(NSError*)error;
- (NSError*)error;

- (int)itemStatus;
- (NSData*)data;

@end
