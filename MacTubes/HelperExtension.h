/* HelperExtension */

#import <Cocoa/Cocoa.h>

@interface NSObject(helperExtension_)

- (void)openWatchURL:(NSString*)url;
- (void)openContentURL:(NSString*)url;
- (void)openAuthorsProfileURL:(NSString*)author;

- (BOOL)openItemURLWithBrowser:(NSString*)itemId;
- (BOOL)openURLWithBrowser:(NSString*)url;
- (void)copyStringToPasteboard:(NSString*)string;

- (NSString*)getEnclosedStringWithKeyString:(NSString*)string
									keyString:(NSString*)keyString
									skipString:(NSString*)skipString
									skipCheck:(BOOL)skipCheck
									beginString:(NSString*)beginString
									endString:(NSString*)endString
									withEndSet:(BOOL)withEndSet;
- (NSString*)getEnclosedString:(NSString*)string
						beginString:(NSString*)beginString
						endString:(NSString*)endString
						withEndSet:(BOOL)withEndSet;

- (NSString*)getHTMLString:(NSString*)urlString errorDescription:(NSString**)errorDescription;
- (NSData*)getHTMLData:(NSString*)urlString referer:(NSString*)referer error:(NSError**)error;
- (NSStringEncoding)getStringEncoding:(NSData*)textData;
- (NSMutableURLRequest*)setRequestHeaderFields:(NSMutableURLRequest*)req
										fields:(NSDictionary*)fields;

- (NSXMLNode*)getChildNode:(NSXMLNode*)node name:(NSString*)name;
- (NSArray*)getChildNodes:(NSXMLNode*)node;

//- (NSDictionary*)getJSONData:(NSString*)string index:(int*)index level:(int*)level;

@end
