#import "HelperExtension.h"
#import "DialogExtension.h"
#import "ConvertExtension.h"
#import "UserDefaultsExtension.h"

@implementation NSObject(helperExtension_)

//------------------------------------
// openWatchURL
//------------------------------------
- (void)openWatchURL:(NSString*)url
{
	// open item
	if([self openURLWithBrowser:url] == NO){
		[self displayMessageAlertOpenURLWithBrowser:url];
	}
}
//------------------------------------
// openContentURL
//------------------------------------
- (void)openContentURL:(NSString*)url
{
	// open item
	if([self openURLWithBrowser:url] == NO){
		[self displayMessageAlertOpenURLWithBrowser:url];
	}
}
//------------------------------------
// openAuthorsProfileURL
//------------------------------------
- (void)openAuthorsProfileURL:(NSString*)author
{

	NSString *url = [self convertToAuthorsProfileURL:author];

	// open item
	if([self openURLWithBrowser:url] == NO){
		[self displayMessageAlertOpenURLWithBrowser:url];
	}

}
//------------------------------------
// openItemURLWithBrowser
//------------------------------------
- (BOOL)openItemURLWithBrowser:(NSString*)itemId
{

	NSString *url = [self convertToWatchURL:itemId];
	// high quality
//	url = [self convertToHighQualityFormatURL:url];

	// open url
	return [self openURLWithBrowser:url];
	
}
//------------------------------------
// openURLWithBrowser
//------------------------------------
- (BOOL)openURLWithBrowser:(NSString*)url
{

	if(!url){
		return NO;
	}

	// decode
	url = [self decodeToPercentEscapesString:url];
//	NSLog(@"url=%@", url);

	// open browser
	return [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];

}
//------------------------------------
// copyStringToPasteboard
//------------------------------------
- (void)copyStringToPasteboard:(NSString*)string
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[pasteboard setString:string forType:NSStringPboardType];
}
//------------------------------------
// getEnclosedString
//------------------------------------
- (NSString*)getEnclosedString:(NSString*)string
						beginString:(NSString*)beginString
						endString:(NSString*)endString
						withEndSet:(BOOL)withEndSet
{

	return [self getEnclosedStringWithKeyString:string
										keyString:@""
										skipString:@""
										skipCheck:NO
										beginString:beginString
										endString:endString
										withEndSet:withEndSet
			];

}
//------------------------------------
// getEnclosedStringWithKeyString
//------------------------------------
- (NSString*)getEnclosedStringWithKeyString:(NSString*)string
									keyString:(NSString*)keyString
									skipString:(NSString*)skipString
									skipCheck:(BOOL)skipCheck
									beginString:(NSString*)beginString
									endString:(NSString*)endString
									withEndSet:(BOOL)withEndSet
{

	NSString *scanValue = @"";
	NSString *skipValue = @"";
	NSString *enclosedString = @"";

	if(!string){
		return enclosedString;
	}

	NSScanner *scan = [NSScanner scannerWithString:string];

	// go to keyString
	if(![keyString isEqualToString:@""]){
		if([scan scanUpToString:keyString intoString:nil] == NO){
			return enclosedString;
		}
		[scan scanString:keyString intoString:nil];
	}

	// go to beginString
	if(![beginString isEqualToString:@""]){
		[scan scanUpToString:beginString intoString:&skipValue];
		[scan scanString:beginString intoString:nil];
	}

	// not match skip string
	if(skipCheck == YES){
		if(!skipValue){
			skipValue = @"";
		}
		skipValue = [skipValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
		if(skipValue && ![skipValue isEqualToString:skipString]){
			return enclosedString;
		}
	}

	// go to endSet
	if(withEndSet == YES){
		NSCharacterSet *endSet = [NSCharacterSet characterSetWithCharactersInString:endString];
		[scan scanUpToCharactersFromSet:endSet intoString:&scanValue];
	}
	// go to endString
	else{
		[scan scanUpToString:endString intoString:&scanValue];
	}

	if(scanValue != nil){
		enclosedString = scanValue;
	}

	return enclosedString;

}
//------------------------------------
// getHTMLString
//------------------------------------
- (NSString*)getHTMLString:(NSString*)urlString errorDescription:(NSString**)errorDescription
{
	//
	// get html data
	//
	NSError *error = nil;
	NSData *data = [self getHTMLData:urlString referer:@"" error:&error];
	if(data == nil && error != nil){
		*errorDescription = [NSString stringWithFormat:@"Can't get data from url=%@ \n error=%@\n"
													, urlString
													, error];
		return nil;
	}

	//
	// init html
	//
	NSStringEncoding encoding = [self getStringEncoding:data];
	NSString *html = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];

//	NSLog(@"urlString=%@", urlString);
//	NSLog(@"html=%@", html);

	if(html == nil){
		*errorDescription = [NSString stringWithFormat:@"Can't get html from url=%@\n html is null", error];
		return nil;
	}

	return html;

}
//------------------------------------
// getHTMLData
//------------------------------------
- (NSData*)getHTMLData:(NSString*)urlString referer:(NSString*)referer error:(NSError**)error
{
	// decode
	urlString = [self decodeToPercentEscapesString:urlString];
//	NSLog(@"urlString=%@", urlString);

	// get html
	NSURL *url = [NSURL URLWithString:urlString];
	if(url == nil){
		return nil;
	}

	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:10
									];
	if(request == nil){
		return nil;
	}

	// set referer
	if(![referer isEqualToString:@""]){
		[request setValue:referer forHTTPHeaderField:@"Referer"];
	}

//	[request setValue:@"" forHTTPHeaderField:@"User-Agent"];

	[request setHTTPMethod:@"GET"];
	NSURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:request
										   returningResponse:&response
													   error:error];

/*
	// redirect url
	NSString *responseURLString = [[response URL] absoluteString];
	if((responseURLString && ![responseURLString isEqualToString:@""]) &&
		![urlString isEqualToString:responseURLString]){
		NSLog(@"urlString=%@", urlString);
		NSLog(@"response=%@", responseURLString);
		return [self getHTMLData:responseURLString referer:referer error:error];
	}else{
		NSLog(@"ok");
	}
*/
	return data;
}

//------------------------------------
// getStringEncoding
//------------------------------------
- (NSStringEncoding)getStringEncoding:(NSData*)textData
{

	NSStringEncoding encodings[] = {
			NSUTF8StringEncoding,
			NSNonLossyASCIIStringEncoding,
			NSShiftJISStringEncoding, 
			NSJapaneseEUCStringEncoding,
			NSMacOSRomanStringEncoding,
			NSWindowsCP1251StringEncoding,
			NSWindowsCP1252StringEncoding,
			NSWindowsCP1253StringEncoding,
			NSWindowsCP1254StringEncoding,
			NSWindowsCP1250StringEncoding,
			NSISOLatin1StringEncoding,
			NSUnicodeStringEncoding, 
			0
	};

	int i = 0;
	NSString *string;
	NSStringEncoding encoding;

	// may be ISO-2022-JP
	if (memchr([textData bytes], 0x1b, [textData length]) != NULL) {
		string = [[[NSString alloc] initWithData:textData 
		encoding:NSISO2022JPStringEncoding] autorelease];
		if (string != nil) 
			return NSISO2022JPStringEncoding;
	}
	// try to encoding
	while(encodings[i] != 0){
		string = [[[NSString alloc] initWithData:textData encoding:encodings[i]] autorelease];
		if (string != nil) {
			encoding = encodings[i];
			break;
		}
		i++;
	}
	return encoding;
}
//------------------------------------
// setRequestHeaderFields
//------------------------------------
- (NSMutableURLRequest*)setRequestHeaderFields:(NSMutableURLRequest*)req
										fields:(NSDictionary*)fields
{

	if(fields != nil){
		NSEnumerator *enumKeys = [fields keyEnumerator];

		NSString *key;
		NSString *value;

		while (key = [enumKeys nextObject]) {
			value = [fields valueForKey:key];
			[req setValue:value forHTTPHeaderField:key];
		}
	}

	return req;
}
//------------------------------------
// getChildNode
//------------------------------------
- (NSXMLNode*)getChildNode:(NSXMLNode*)node name:(NSString*)name
{
	NSEnumerator *e = [[node children] objectEnumerator];

	NSXMLNode *childNode;
	while (childNode = [e nextObject]){
		if ([[childNode name] isEqualToString:name]){
			return childNode;
		}
	}

	return nil;
}
//------------------------------------
// getChildNodes
//------------------------------------
- (NSArray*)getChildNodes:(NSXMLNode*)node
{
	NSMutableArray *nodes = [[NSMutableArray arrayWithCapacity:[[node children] count]] retain];
	NSEnumerator *e = [[node children] objectEnumerator];

	NSXMLNode *childNode;
	while (childNode = [e nextObject]){
		[nodes addObject:[childNode stringValue]];
	}
	return [nodes autorelease];
}
/*
//------------------------------------
// getJSONData *dont use. this is may be buggy
//------------------------------------
- (NSDictionary*)getJSONData:(NSString*)string index:(int*)index level:(int*)level
{

	int i, i_child;
	NSString *str = @"";
	NSString *strPrev = @"";
	NSString *key = @"";
	NSString *value = @"";

	NSString *quote = @"\"";
	NSString *backslash = @"\\";
	NSString *cr = @"\n";
	NSString *midopen = @"{";
	NSString *midclose = @"}";
	NSString *colon = @":";
	NSString *comma = @",";

	int countQuote = 0;
//	int countEnclose = 0;
	BOOL isKey = YES;

	NSMutableDictionary *jsonData = [NSMutableDictionary dictionary];

	for(i = *index; i < [string length]; i++){

		str = [string substringWithRange:NSMakeRange(i, 1)];

		// skip
		if([str isEqualToString:cr] || [str isEqualToString:backslash]){
			continue;
		}

		if(i > 0){
			strPrev = [string substringWithRange:NSMakeRange(i - 1, 1)];
		}

		// not escape
		if(![strPrev isEqualToString:backslash]){

			// quote
			if([str isEqualToString:quote]){
				if(countQuote <= 0){
					countQuote++;
				}else{
					countQuote--;
				}
				continue;
			}

			// out of quote
			if(countQuote <= 0){

				// midopen
				if([str isEqualToString:midopen]){
	//				countEnclose++;

					// child
					*level++;
					i_child = i + 1;

					NSDictionary *childData = [self getJSONData:string index:&i_child level:level];
					key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

					*level--;
					i = i_child;

//					NSLog(@"%@ = %@", key, [childData description]);
					if(![key isEqualToString:@""]){
						[jsonData setValue:childData forKey:key];
					}
					key = @"";
					value = @"";
					isKey = YES;
					continue;
				}
				// midclose
//				if([str isEqualToString:midclose]){
//					countEnclose--;
//					break;
//					continue;
//				}
				// colon
				if([str isEqualToString:colon]){
					// switch key <-> value
					isKey = !isKey;
					continue;
				}

				// comma / midclose
				if([str isEqualToString:comma] || [str isEqualToString:midclose]){

					key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

//					if(*level == 0){
//						NSLog(@"key=%@", key);
//						NSLog(@"value=%@", value);
//					}
					// set dictionary
					if(![key isEqualToString:@""]){
						[jsonData setValue:value forKey:key];
					}

					// reset
					key = @"";
					value = @"";
					isKey = YES;

					if([str isEqualToString:comma]){
						continue;
					}
					if([str isEqualToString:midclose]){
						break;
					}
				}
			}
		}

//		if(countQuote > 0){
			if(isKey == YES){
				key = [key stringByAppendingString:str];
			}else{
				value = [value stringByAppendingString:str];
			}
//		}

	}
	// set dictionary
	if(![key isEqualToString:@""] && ![value isEqualToString:@""]){
//		if(*level == 0){
//			NSLog(@"last key=%@", key);
//			NSLog(@"last value=%@", value);
//		}
		[jsonData setValue:value forKey:key];
	}

	// last index
	*index = i;

	return jsonData;

}
*/
@end