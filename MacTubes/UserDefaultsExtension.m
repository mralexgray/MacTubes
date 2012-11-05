#import "UserDefaultsExtension.h"

@implementation NSObject(userDefaultsExtension_)

//------------------------------------
// setWindowRect 
//------------------------------------
- (void)setWindowRect:(NSWindow*)aWindow key:(NSString*)key
{
	
	if(aWindow == nil || [key isEqualToString:@""]){
		return;
	}

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// set rect string
	NSString *recStrWindow = [defaults stringForKey:key];
	if(recStrWindow){
		NSRect rectWindow = NSRectFromString(recStrWindow);
		[aWindow setFrame:rectWindow display:YES animate:YES];
	}else{
		[aWindow center];
	}

}
//------------------------------------
// setWindowPosition 
//------------------------------------
- (void)setWindowPosition:(NSWindow*)aWindow key:(NSString*)key
{

	if(aWindow == nil || [key isEqualToString:@""]){
		return;
	}

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// set rect string
	NSString *recStrWindow = [defaults stringForKey:key];
	if(recStrWindow){
		NSRect rectWindow = NSRectFromString(recStrWindow);
		[aWindow setFrameOrigin:NSMakePoint(rectWindow.origin.x,rectWindow.origin.y)];
	}else{
		[aWindow center];
	}

}
//------------------------------------
// saveWindowRect 
//------------------------------------
- (void)saveWindowRect:(NSWindow*)aWindow key:(NSString*)key
{
	if(aWindow == nil || [key isEqualToString:@""]){
		return;
	}

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *rectStrWindow = NSStringFromRect([aWindow frame]);
	[defaults setObject:rectStrWindow forKey:key];
	[defaults synchronize];

}
//-------------------------
// setSplitViewRect
//-------------------------
- (void)setSplitViewRect:(NSSplitView *)aSplitView key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSArray *array = [defaults objectForKey:key];
	if (array == nil || [array isKindOfClass:[NSArray class]] == NO){
		return;
	}

	NSArray *subviews = [aSplitView subviews];

	int i;
	for (i = 0; i < [subviews count] && i < [array count]; i++){
		NSRect rect = NSRectFromString([array objectAtIndex:i]);
		[[subviews objectAtIndex:i] setFrame:rect];
	}
}

//-------------------------
// saveSplitViewRect
//-------------------------
- (void)saveSplitViewRect:(NSSplitView *)aSplitView key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableArray *array= [[[NSMutableArray alloc] init] autorelease];
	int i;

	// create array
	NSArray *subviews = [aSplitView subviews];
	for (i = 0; i < [subviews count]; i++){
		[array addObject:NSStringFromRect([[subviews objectAtIndex:i] frame])];
	}

	// save array
	if([array count] > 0){
		[defaults setObject:array forKey:key];
	}else{
		if([defaults objectForKey:key]){
			[defaults removeObjectForKey:key];
		}
	}
	[defaults synchronize];
}
//-------------------------
// splitViewRectString
//-------------------------
- (NSString*)splitViewRectString:(NSString*)key index:(int)index
{

	NSString *rectString = @"";

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if([defaults objectForKey:key]){
		NSArray *array = [defaults objectForKey:key];
		if (array != nil && [array isKindOfClass:[NSArray class]] == YES){
			if (index >= 0 && index < [array count]){
				rectString = [array objectAtIndex:index];
			}
		}
	}

	return rectString;
}
//------------------------------------
// setTableColumnState
//------------------------------------
- (void)setTableColumnState:(NSTableView*)aTableView key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSArray *dictArray = [defaults objectForKey:key];
	if (dictArray == nil || [dictArray isKindOfClass:[NSArray class]] == NO){
		return;
	}

	NSTableColumn *aColumn;
	NSString *identifier;
	id record;
	int i;
	int index;
	int currentIndex;

	for (i = 0; i < [dictArray count]; i++){

		record = [dictArray objectAtIndex:i];

		if(![record valueForKey:@"identifier"]){
			continue;
		}

		index = i;
		identifier =[record valueForKey:@"identifier"];

		aColumn = [aTableView tableColumnWithIdentifier:identifier];
		if(aColumn != nil){
			currentIndex = [aTableView columnWithIdentifier:identifier];

			// move column
			[aTableView moveColumn:currentIndex toColumn:index];

			// set column width
			if([record valueForKey:@"width"]){
				[aColumn setWidth:[[record valueForKey:@"width"] intValue]];
			}
		}
	}

}
//-------------------------
// saveTableColumnState
//-------------------------
- (void)saveTableColumnState:(NSTableView*)aTableView key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableArray *arrayColumns = [[[NSMutableArray alloc] init] autorelease];

	NSArray *columnArray = [aTableView tableColumns];
	int i;

	// create array
	for (i = 0; i < [columnArray count]; i++){
		[arrayColumns addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				[[columnArray objectAtIndex:i] identifier], @"identifier",
				[NSNumber numberWithInt:[[columnArray objectAtIndex:i] width]], @"width",
				nil ]
		];
	}

	// save array
	if([arrayColumns count] > 0){
		[defaults setObject:arrayColumns forKey:key];
	}else{
		if([defaults objectForKey:key]){
			[defaults removeObjectForKey:key];
		}
	}
	[defaults synchronize];
}
//------------------------------------
// setArrayControllerSortDescriptor
//------------------------------------
- (void)setArrayControllerSortDescriptor:(NSArrayController*)aController key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *column;
	BOOL isAsc = YES;

	NSDictionary *sortDict = [defaults objectForKey:key];
	if (sortDict == nil || [sortDict isKindOfClass:[NSDictionary class]] == NO){
		return;
	}

	// value not found
	if(![sortDict valueForKey:@"column"]){
		return;
	}

	// colmun not found
	column = [sortDict valueForKey:@"column"];
/*
	if([aTableView tableColumnWithIdentifier:column] == nil){
		return;
	}
*/
	if([sortDict valueForKey:@"isAsc"]){
		isAsc = [[sortDict valueForKey:@"isAsc"] boolValue];
	}

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:column ascending:isAsc selector:@selector(compare:)];
	[sortDescriptor autorelease];
	[aController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

}
//------------------------------------
// saveArrayControllerSortDescriptor
//------------------------------------
- (void)saveArrayControllerSortDescriptor:(NSArrayController*)aController key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if([[aController sortDescriptors] count] > 0){
		NSSortDescriptor *aDescriptor = [[aController sortDescriptors] objectAtIndex:0];

		[defaults setObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
						[aDescriptor key], @"column",
						[NSNumber numberWithBool:[aDescriptor ascending]], @"isAsc",
						nil
			]
		forKey:key];
	}
	[defaults synchronize];
}
//------------------------------------
// setSearchFieldRecentSearches
//------------------------------------
- (void)setSearchFieldRecentSearches:(NSSearchField*)searchField key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSArray *array = [defaults objectForKey:key];
	if (array == nil || [array isKindOfClass:[NSArray class]] == NO){
		return;
	}

	[searchField setRecentSearches:array];

}
//------------------------------------
// saveSearchFieldRecentSearches
//------------------------------------
- (void)saveSearchFieldRecentSearches:(NSSearchField*)searchField key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:[searchField recentSearches] forKey:key];

	[defaults synchronize];
}

//------------------------------------
// saveLastSelectedIndex 
//------------------------------------
- (void)saveLastSelectedIndex:(int)index key:(NSString*)key
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// last uniqueId
	[defaults setObject:[NSNumber numberWithInt:index] forKey:key];
}
//------------------------------------
// getLastSelectedIndex 
//------------------------------------
- (int)getLastSelectedIndex:(NSString*)key
{
	int index = -1;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults objectForKey:key]){
		index = [[defaults objectForKey:key] intValue];
	}

	return index;

}

//------------------------------------
// defaultVideoPlayerType 
//------------------------------------
- (int)defaultVideoPlayerType
{
	return [self defaultIntValue:@"optVideoPlayerType"];
}
//------------------------------------
// defaultPlayFileFormatNo 
//------------------------------------
- (int)defaultPlayFileFormatNo
{

/*
	int formatNo = [self defaultIntValue:@"optPlayFileFormatNo"];

	// change error value from older settings
	if(formatNo != VIDEO_FORMAT_NO_NORMAL && formatNo != VIDEO_FORMAT_NO_HD){
		formatNo = VIDEO_FORMAT_NO_NORMAL;
	}
	return formatNo;
*/
//	return [self defaultIntValue:@"optPlayFileFormatNo"];
	return VIDEO_FORMAT_NO_NONE;
}
//------------------------------------
// defaultPlayHighQuality 
//------------------------------------
- (BOOL)defaultPlayHighQuality
{
	return [self defaultBoolValue:@"optPlayHighQuality"];
}
//----------------------
// defaultAutoPlay
//----------------------
- (BOOL)defaultAutoPlay
{
	return [self defaultBoolValue:@"optAutoPlay"];
}

//----------------------
// defaultPlayVolume
//----------------------
- (float)defaultPlayVolume
{
	return [self defaultFloatValue:@"optPlayVolume"];
}

//------------------------------------
// defaultMaxResults 
//------------------------------------
- (int)defaultMaxResults
{
	return [self defaultIntValue:@"optMaxResults"];
}
//------------------------------------
// defaultSearchMatrixCellSize
//------------------------------------
- (float)defaultSearchMatrixCellSize
{
	float scale = [self defaultFloatValue:@"optSearchMatrixCellScale"];
	return (100 + scale * scale);
}
//----------------------
// defaultPlayRepeat
//----------------------
- (int)defaultPlayRepeat
{
	return [self defaultIntValue:@"optPlayRepeat"];
}
//----------------------
// defaultPlayRepeatInterval
//----------------------
- (float)defaultPlayRepeatInterval
{
	return [self defaultFloatValue:@"optPlayRepeatInterval"];
}
//----------------------
// defaultVideoInfoRequestInterval
//----------------------
- (float)defaultVideoInfoRequestInterval
{
	return [self defaultFloatValue:@"optVideoInfoRequestInterval"];
}
//----------------------
// defaultDownloadRequestInterval
//----------------------
- (float)defaultDownloadRequestInterval
{
	return [self defaultFloatValue:@"optDownloadRequestInterval"];
}

//----------------------
// defaultQueryFeedName
//----------------------
- (NSString*)defaultQueryFeedName
{
	NSString *feedName = [self defaultStringValue:@"optQueryFeedName"];
	if([feedName isEqualToString:@""]){
		feedName = FEED_NAME_MOST_VIEWED;
	}
	return feedName;
}
/*
//------------------------------------
// setDefaultLanguageIsJP 
//------------------------------------
- (void)setDefaultLanguageIsJP
{
	BOOL isLangJP = YES;
	NSString *string = [self defaultLocalizedLanguage];

	[self setDefaultBoolValue:isLangJP key:@"optDefaultLanguageIsJP"];

}
*/
//------------------------------------
// defaultLanguageIsJP 
//------------------------------------
- (BOOL)defaultLanguageIsJP
{
	return [self defaultBoolValue:@"optDefaultLanguageIsJP"];
}
//------------------------------------
// setDefaultStringValue 
//------------------------------------
- (void)setDefaultStringValue:(NSString*)string key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:string forKey:key];

	[defaults synchronize];
}
//------------------------------------
// defaultStringValue 
//------------------------------------
- (NSString*)defaultStringValue:(NSString*)key
{
	NSString *string = @"";

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// string value 
	if([defaults objectForKey:key]){
		string = [defaults objectForKey:key];
	}

	return string;
}
//------------------------------------
// setDefaultIntValue 
//------------------------------------
- (void)setDefaultIntValue:(int)value key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:[NSNumber numberWithInt:value] forKey:key];

	[defaults synchronize];
}
//------------------------------------
// defaultIntValue
//------------------------------------
- (int)defaultIntValue:(NSString*)key
{
	int value = 0;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// int value 
	if([defaults objectForKey:key]){
		value = [[defaults objectForKey:key] intValue];
	}

	return value;
}
//------------------------------------
// setDefaultFloatValue 
//------------------------------------
- (void)setDefaultFloatValue:(float)value key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:[NSNumber numberWithFloat:value] forKey:key];

	[defaults synchronize];
}
//------------------------------------
// defaultFloatValue
//------------------------------------
- (float)defaultFloatValue:(NSString*)key
{
	float value = 0.0;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// float value 
	if([defaults objectForKey:key]){
		value = [[defaults objectForKey:key] floatValue];
	}

	return value;
}
//------------------------------------
// setDefaultBoolValue 
//------------------------------------
- (void)setDefaultBoolValue:(BOOL)value key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:[NSNumber numberWithBool:value] forKey:key];

	[defaults synchronize];
}
//------------------------------------
// defaultBoolValue
//------------------------------------
- (BOOL)defaultBoolValue:(NSString*)key
{
	BOOL value = NO;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// BOOL value 
	if([defaults objectForKey:key]){
		value = [[defaults objectForKey:key] boolValue];
	}

	return value;
}

//-------------------------
// setDefaultArrayValue
//-------------------------
- (void)setDefaultArrayValue:(NSArray*)array key:(NSString*)key
{

	if(array == nil || [key isEqualToString:@""]){
		return;
	}

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:array forKey:key];
	[defaults synchronize];

}
//-------------------------
// defaultArrayValue
//-------------------------
- (NSArray*)defaultArrayValue:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if([defaults objectForKey:key]){
		NSArray *array = [defaults objectForKey:key];
		if (array != nil && [array isKindOfClass:[NSArray class]] == YES){
			return array;
		}
	}

	return nil;
}
//------------------------------------
// defaultAppName
//------------------------------------
- (NSString*)defaultAppName
{
	return (NSString*)[self defaultInfoPlistValue:@"CFBundleName"];
}
//------------------------------------
// defaultAppVersion
//------------------------------------
- (NSString*)defaultAppVersion
{
	return (NSString*)[self defaultInfoPlistValue:@"CFBundleShortVersionString"];
}
//------------------------------------
// defaultLocalizedLanguage
//------------------------------------
- (NSString*)defaultLocalizedLanguage
{
	NSString *lang = @"";
//	id languages = [NSLocale preferredLanguages];
//	NSLog(@"languages=%@", [languages description]);

	return lang;
}
//------------------------------------
// defaultInfoPlistValue
//------------------------------------
- (id)defaultInfoPlistValue:(NSString*)key
{
	id value = nil;

	NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];

	if([dict valueForKey:key]){
		value = [dict valueForKey:key];
	}

	return value;
}
//-------------------------
// defaultOSVersion
//-------------------------
- (NSString*)defaultOSVersion
{
	// ex. Version 10.4.11 (Build 8S165)
	return [[NSProcessInfo processInfo] operatingSystemVersionString];
}
//-------------------------
// defaultOSVersionNo
//-------------------------
- (NSString*)defaultOSVersionNo
{
	// versionString = Version 10.4.11 (Build 8S165)
	NSString *versionString = [self defaultOSVersion];
	NSScanner *scan = [NSScanner scannerWithString:versionString];

	NSString *versionNo = nil;
	[scan scanUpToString:@" " intoString:nil];
	[scan scanUpToString:@" " intoString:&versionNo];

	if(versionNo == nil){
		versionNo = @"";
	}

	return versionNo;
}

@end