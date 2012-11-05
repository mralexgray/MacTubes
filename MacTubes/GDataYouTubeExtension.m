#import "GDataYouTubeExtension.h"
#import "UserDefaultsExtension.h"
#import "ConvertExtension.h"
#import "YouTubeHelperExtension.h"

@implementation NSObject(GDataYouTubeExtension_)
//------------------------------------
// youTubeService
//------------------------------------
- (GDataServiceGoogleYouTube *)youTubeService
{
	static GDataServiceGoogleYouTube *service = nil;
	
	if (!service)
	{
		service = [[GDataServiceGoogleYouTube alloc] init];
		[service setUserAgent:@"MacTubes"];
		[service setShouldCacheDatedData:YES];
		
		/* this is where we'd set the username/password if we accepted one */
		[service setUserCredentialsWithUsername:nil password:nil];
	}
	
	return service;
}
//------------------------------------
// getCategoryTitle
//------------------------------------
- (NSString*)getCategoryTitle:(NSString*)name
{
	NSString *title = @"";

	if([name isEqualToString:ITEM_CATEGORY_NAME_ALL]){
		title = ITEM_CATEGORY_TITLE_ALL;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_ANIMALS]){
		title = ITEM_CATEGORY_TITLE_ANIMALS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_AUTOS]){
		title = ITEM_CATEGORY_TITLE_AUTOS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_COMEDY]){
		title = ITEM_CATEGORY_TITLE_COMEDY;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_EDUCATION]){
		title = ITEM_CATEGORY_TITLE_EDUCATION;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_ENTERTAINMENT]){
		title = ITEM_CATEGORY_TITLE_ENTERTAINMENT;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_FILM]){
		title = ITEM_CATEGORY_TITLE_FILM;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_GAMES]){
		title = ITEM_CATEGORY_TITLE_GAMES;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_HOWTO]){
		title = ITEM_CATEGORY_TITLE_HOWTO;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_NONPROFIT]){
		title = ITEM_CATEGORY_TITLE_NONPROFIT;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_MUSIC]){
		title = ITEM_CATEGORY_TITLE_MUSIC;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_NEWS]){
		title = ITEM_CATEGORY_TITLE_NEWS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_PEOPLE]){
		title = ITEM_CATEGORY_TITLE_PEOPLE;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_SPORTS]){
		title = ITEM_CATEGORY_TITLE_SPORTS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_TECH]){
		title = ITEM_CATEGORY_TITLE_TECH;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_TRAVEL]){
		title = ITEM_CATEGORY_TITLE_TRAVEL;
	}

	return title;

}
//------------------------------------
// getCategoryTitleJP
//------------------------------------
- (NSString*)getCategoryTitleJP:(NSString*)name
{
	char *value = "";

	if([name isEqualToString:ITEM_CATEGORY_NAME_ALL]){
		value = ITEM_CATEGORY_TITLE_JP_ALL;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_ANIMALS]){
		value = ITEM_CATEGORY_TITLE_JP_ANIMALS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_AUTOS]){
		value = ITEM_CATEGORY_TITLE_JP_AUTOS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_COMEDY]){
		value = ITEM_CATEGORY_TITLE_JP_COMEDY;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_EDUCATION]){
		value = ITEM_CATEGORY_TITLE_JP_EDUCATION;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_ENTERTAINMENT]){
		value = ITEM_CATEGORY_TITLE_JP_ENTERTAINMENT;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_FILM]){
		value = ITEM_CATEGORY_TITLE_JP_FILM;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_GAMES]){
		value = ITEM_CATEGORY_TITLE_JP_GAMES;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_HOWTO]){
		value = ITEM_CATEGORY_TITLE_JP_HOWTO;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_NONPROFIT]){
		value = ITEM_CATEGORY_TITLE_JP_NONPROFIT;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_MUSIC]){
		value = ITEM_CATEGORY_TITLE_JP_MUSIC;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_NEWS]){
		value = ITEM_CATEGORY_TITLE_JP_NEWS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_PEOPLE]){
		value = ITEM_CATEGORY_TITLE_JP_PEOPLE;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_SPORTS]){
		value = ITEM_CATEGORY_TITLE_JP_SPORTS;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_TECH]){
		value = ITEM_CATEGORY_TITLE_JP_TECH;
	}
	else if([name isEqualToString:ITEM_CATEGORY_NAME_TRAVEL]){
		value = ITEM_CATEGORY_TITLE_JP_TRAVEL;
	}

	return [self convertToShiftJISString:value];

}
//------------------------------------
// getFeedName
//------------------------------------
- (NSString*)getFeedName:(int)itemSubType
{
	NSString *name = @"";

	switch (itemSubType){
		case ITEM_FEED_TOP_RATED:
			name = FEED_NAME_TOP_RATED;
			break;
		case ITEM_FEED_TOP_FAVORITES:
			name = FEED_NAME_TOP_FAVORITES;
			break;
		case ITEM_FEED_MOST_RECENT:
			name = FEED_NAME_MOST_RECENT;
			break;
		case ITEM_FEED_MOST_DISCUSSED:
			name = FEED_NAME_MOST_DISCUSSED;
			break;
		case ITEM_FEED_MOST_VIEWED:
			name = FEED_NAME_MOST_VIEWED;
			break;
		case ITEM_FEED_MOST_LINKED:
			name = FEED_NAME_MOST_LINKED;
			break;
		case ITEM_FEED_MOST_RESPONDED:
			name = FEED_NAME_MOST_RESPONDED;
			break;
		case ITEM_FEED_MOST_POPULAR:
			name = FEED_NAME_MOST_POPULAR;
			break;
		case ITEM_FEED_RECENTLY_FEATURED:
			name = FEED_NAME_RECENTLY_FEATURED;
			break;
		case ITEM_FEED_WATCH_ON_MOBILE:
			name = FEED_NAME_WATCH_ON_MOBILE;
			break;
	}

	return name;

}
//------------------------------------
// getFeedTitle
//------------------------------------
- (NSString*)getFeedTitle:(int)itemSubType
{
	NSString *title = @"";

	switch (itemSubType){
		case ITEM_FEED_TOP_RATED:
			title = FEED_TITLE_TOP_RATED;
			break;
		case ITEM_FEED_TOP_FAVORITES:
			title = FEED_TITLE_TOP_FAVORITES;
			break;
		case ITEM_FEED_MOST_RECENT:
			title = FEED_TITLE_MOST_RECENT;
			break;
		case ITEM_FEED_MOST_DISCUSSED:
			title = FEED_TITLE_MOST_DISCUSSED;
			break;
		case ITEM_FEED_MOST_VIEWED:
			title = FEED_TITLE_MOST_VIEWED;
			break;
		case ITEM_FEED_MOST_LINKED:
			title = FEED_TITLE_MOST_LINKED;
			break;
		case ITEM_FEED_MOST_RESPONDED:
			title = FEED_TITLE_MOST_RESPONDED;
			break;
		case ITEM_FEED_MOST_POPULAR:
			title = FEED_TITLE_MOST_POPULAR;
			break;
		case ITEM_FEED_RECENTLY_FEATURED:
			title = FEED_TITLE_RECENTLY_FEATURED;
			break;
		case ITEM_FEED_WATCH_ON_MOBILE:
			title = FEED_TITLE_WATCH_ON_MOBILE;
			break;
	}

	return title;

}
//------------------------------------
// getQueryFeedTitle
//------------------------------------
- (NSString*)getQueryFeedTitle:(NSString*)name
{
	NSString *title = @"";

	if([name isEqualToString:QUERY_FEED_NAME_TOP_RATED]){
		title = QUERY_FEED_TITLE_TOP_RATED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_TOP_FAVORITES]){
		title = QUERY_FEED_TITLE_TOP_FAVORITES;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_RECENT]){
		title = QUERY_FEED_TITLE_MOST_RECENT;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_DISCUSSED]){
		title = QUERY_FEED_TITLE_MOST_DISCUSSED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_VIEWED]){
		title = QUERY_FEED_TITLE_MOST_VIEWED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_LINKED]){
		title = QUERY_FEED_TITLE_MOST_LINKED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_RESPONDED]){
		title = QUERY_FEED_TITLE_MOST_RESPONDED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_POPULAR]){
		title = QUERY_FEED_TITLE_MOST_POPULAR;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_RECENTLY_FEATURED]){
		title = QUERY_FEED_TITLE_RECENTLY_FEATURED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_WATCH_ON_MOBILE]){
		title = QUERY_FEED_TITLE_WATCH_ON_MOBILE;
	}

	return title;

}
//------------------------------------
// getQueryFeedTitleJP
//------------------------------------
- (NSString*)getQueryFeedTitleJP:(NSString*)name
{
	char *value = "";

	if([name isEqualToString:QUERY_FEED_NAME_TOP_RATED]){
		value = QUERY_FEED_TITLE_JP_TOP_RATED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_TOP_FAVORITES]){
		value = QUERY_FEED_TITLE_JP_TOP_FAVORITES;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_RECENT]){
		value = QUERY_FEED_TITLE_JP_MOST_RECENT;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_DISCUSSED]){
		value = QUERY_FEED_TITLE_JP_MOST_DISCUSSED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_VIEWED]){
		value = QUERY_FEED_TITLE_JP_MOST_VIEWED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_LINKED]){
		value = QUERY_FEED_TITLE_JP_MOST_LINKED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_RESPONDED]){
		value = QUERY_FEED_TITLE_JP_MOST_RESPONDED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_MOST_POPULAR]){
		value = QUERY_FEED_TITLE_JP_MOST_POPULAR;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_RECENTLY_FEATURED]){
		value = QUERY_FEED_TITLE_JP_RECENTLY_FEATURED;
	}
	else if([name isEqualToString:QUERY_FEED_NAME_WATCH_ON_MOBILE]){
		value = QUERY_FEED_TITLE_JP_WATCH_ON_MOBILE;
	}

	return [self convertToShiftJISString:value];

}
//------------------------------------
// getFeedType
//------------------------------------
- (int)getFeedType:(NSString*)name
{
	int value = 0;

	if([name isEqualToString:FEED_NAME_TOP_RATED]){
		value = ITEM_FEED_TOP_RATED;
	}
	else if([name isEqualToString:FEED_NAME_TOP_FAVORITES]){
		value = ITEM_FEED_TOP_FAVORITES;
	}
	else if([name isEqualToString:FEED_NAME_MOST_RECENT]){
		value = ITEM_FEED_MOST_RECENT;
	}
	else if([name isEqualToString:FEED_NAME_MOST_DISCUSSED]){
		value = ITEM_FEED_MOST_DISCUSSED;
	}
	else if([name isEqualToString:FEED_NAME_MOST_VIEWED]){
		value = ITEM_FEED_MOST_VIEWED;
	}
	else if([name isEqualToString:FEED_NAME_MOST_LINKED]){
		value = ITEM_FEED_MOST_LINKED;
	}
	else if([name isEqualToString:FEED_NAME_MOST_RESPONDED]){
		value = ITEM_FEED_MOST_RESPONDED;
	}
	else if([name isEqualToString:FEED_NAME_MOST_POPULAR]){
		value = ITEM_FEED_MOST_POPULAR;
	}
	else if([name isEqualToString:FEED_NAME_RECENTLY_FEATURED]){
		value = ITEM_FEED_RECENTLY_FEATURED;
	}
	else if([name isEqualToString:FEED_NAME_WATCH_ON_MOBILE]){
		value = ITEM_FEED_WATCH_ON_MOBILE;
	}

	return value;

}

//------------------------------------
// isEnabledFeedTime
//------------------------------------
- (BOOL)isEnabledFeedTime:(NSString*)feedName
{
	BOOL enabled = NO;

	if([feedName isEqualToString:FEED_NAME_TOP_RATED]){
		enabled = YES;
	}
	else if([feedName isEqualToString:FEED_NAME_TOP_FAVORITES]){
		enabled = YES;
	}
	else if([feedName isEqualToString:FEED_NAME_MOST_RECENT]){
		enabled = NO;
	}
	else if([feedName isEqualToString:FEED_NAME_MOST_DISCUSSED]){
		enabled = YES;
	}
	else if([feedName isEqualToString:FEED_NAME_MOST_VIEWED]){
		enabled = YES;
	}
	else if([feedName isEqualToString:FEED_NAME_MOST_LINKED]){
		enabled = YES;
	}
	else if([feedName isEqualToString:FEED_NAME_MOST_RESPONDED]){
		enabled = YES;
	}
	else if([feedName isEqualToString:FEED_NAME_MOST_POPULAR]){
		enabled = YES;
	}
	else if([feedName isEqualToString:FEED_NAME_RECENTLY_FEATURED]){
		enabled = NO;
	}
	else if([feedName isEqualToString:FEED_NAME_WATCH_ON_MOBILE]){
		enabled = NO;
	}

	return enabled;

}
//------------------------------------
// isEnabledCategory
//------------------------------------
- (BOOL)isEnabledCategory:(NSString*)categoryName
{
	BOOL enabled = YES;
	NSString *countryCode = [self defaultStringValue:@"optCountryCode"];

	if([categoryName isEqualToString:ITEM_CATEGORY_NAME_NONPROFIT]){
		if(![countryCode isEqualToString:@""]){
			enabled = NO;
		}
	}
	return enabled;
}
//------------------------------------
// getCountryIconImage
//------------------------------------
- (NSImage*)getCountryIconImage:(NSString*)countryCode
{
	NSString *imageName = @"icon_cc_WW";

	if(![countryCode isEqualToString:@""]){
		imageName = [NSString stringWithFormat:@"icon_cc_%@", countryCode];
	}

	return [NSImage imageNamed:imageName];
}

//------------------------------------
// setYouTubeQueryOrder
//------------------------------------
- (GDataQueryYouTube*)setYouTubeQueryOrder:(GDataQueryYouTube*)query queryOrder:(int)queryOrder
{

//	NSLog(@"queryOrder=%d", queryOrder);

	// get sort string
	NSString *orderString = [self getYouTubeQueryOrderString:queryOrder];

	if(![orderString isEqualToString:@""]){
		[query setOrderBy:orderString];
	}

	return query;

}
//------------------------------------
// setYouTubeQueryTimePeriod
//------------------------------------
- (GDataQueryYouTube*)setYouTubeQueryTimePeriod:(GDataQueryYouTube*)query queryTimePeriod:(int)queryTimePeriod
{
	NSString *timePeriodString = [self getTimePeriodString:queryTimePeriod];
	if(![timePeriodString isEqualToString:@""]){
		[query setTimePeriod:timePeriodString];
	}

	return query;
}
//------------------------------------
// setYouTubeQueryAllowRacy
//------------------------------------
- (GDataQueryYouTube*)setYouTubeQueryAllowRacy:(GDataQueryYouTube*)query allowRacy:(BOOL)allowRacy
{

	// racy
	[query setAllowRacy:allowRacy];

	return query;

}
//------------------------------------
// setYouTubeQuerySafeSearch
//------------------------------------
- (GDataQueryYouTube*)setYouTubeQuerySafeSearch:(GDataQueryYouTube*)query safeSearchNo:(int)safeSearchNo
{

	// get safeSearchString
	NSString *safeSearchString = [self getYouTubeSafeSearchString:safeSearchNo];

	// safeSearch
	if(![safeSearchString isEqualToString:@""]){
		[query setSafeSearch:safeSearchString];
	}

	return query;

}
//------------------------------------
// appendYouTubeQueryOrderString
//------------------------------------
- (NSString*)appendYouTubeQueryOrderString:(NSString*)string queryOrder:(int)queryOrder addPara:(BOOL*)addPara
{

	// get sort string
	NSString *orderString = [self getYouTubeQueryOrderString:queryOrder];

	if(![orderString isEqualToString:@""]){
		if(*addPara == NO){
			string = [NSString stringWithFormat:@"%@?orderby=%@", string, orderString];
		}else{
			string = [NSString stringWithFormat:@"%@&orderby=%@", string, orderString];
		}
		*addPara = YES;
	}

	return string;

}

//------------------------------------
// appendYouTubeQueryTimePeriodString
//------------------------------------
- (NSString*)appendYouTubeQueryTimePeriodString:(NSString*)string queryTimePeriod:(int)queryTimePeriod addPara:(BOOL*)addPara
{

	NSString *timePeriodString = [self getTimePeriodString:queryTimePeriod];
	if(![timePeriodString isEqualToString:@""]){
		if(*addPara == NO){
			string = [NSString stringWithFormat:@"%@?time=%@", string, timePeriodString];
		}else{
			string = [NSString stringWithFormat:@"%@&time=%@", string, timePeriodString];
		}
		*addPara = YES;
	}

	return string;

}
//------------------------------------
// getYouTubeQueryOrderString
//------------------------------------
- (NSString*)getYouTubeQueryOrderString:(int)queryOrder
{

	NSString *orderString = @"";

	// relevance
	if(queryOrder == QUERY_ORDER_RELEVANCE){
		// none
//		orderString = kGDataYouTubeOrderByRelevance;
	}
	// date added
	else if(queryOrder == QUERY_ORDER_PUBLISHED){
		orderString = kGDataYouTubeOrderByUpdated;
	}
	// viewCount
	else if(queryOrder == QUERY_ORDER_VIEWS){
		orderString = kGDataYouTubeOrderByViewCount;
	}
	// rating
	else if(queryOrder == QUERY_ORDER_RATING){
		orderString = kGDataYouTubeOrderByRating;
	}

	return orderString;

}
//------------------------------------
// getYouTubeSafeSearchString
//------------------------------------
- (NSString*)getYouTubeSafeSearchString:(int)safeSearchNo
{

	NSString *safeSearchString = @"";

	// none
	if(safeSearchNo == SAFE_SEARCH_NONE){
		safeSearchString = kGDataYouTubeSafeSearchNone;
	}
	// strict
	else if(safeSearchNo == SAFE_SEARCH_STRICT){
		safeSearchString = kGDataYouTubeSafeSearchStrict;
	}
	// moderate
	else if(safeSearchNo == SAFE_SEARCH_MODERATE){
		safeSearchString = kGDataYouTubeSafeSearchModerate;
	}

	return safeSearchString;
}

//------------------------------------
// getTimePeriodString
//------------------------------------
- (NSString*)getTimePeriodString:(int)timePeriod
{
	NSString *timePeriodString = @"";

	switch (timePeriod){
		case TIME_PERIOD_TODAY:
			timePeriodString = kGDataYouTubePeriodToday;
			break;
		case TIME_PERIOD_THIS_WEEK:
			timePeriodString = kGDataYouTubePeriodThisWeek;
			break;
		case TIME_PERIOD_THIS_MONTH:
			timePeriodString = kGDataYouTubePeriodThisMonth;
			break;
		case TIME_PERIOD_ALL_TIME:
			timePeriodString = kGDataYouTubePeriodAllTime;
			break;
	}

	return timePeriodString;

}
//------------------------------------
// getYouTubeVideoValues
//------------------------------------
- (NSDictionary*)getYouTubeVideoValues:(GDataEntryYouTubeVideo *)video
{

//	NSString *playerURL = [[[[video mediaGroup] mediaPlayers] objectAtIndex:0] URLString];    
//	NSString *itemId = [self getItemIdFromURL:playerURL];
	NSString *itemId = [[video mediaGroup] videoID];

	NSString *title = [[video title] stringValue];
	NSString *author = [[[[video authors] objectAtIndex:0] URI] lastPathComponent];
	NSString *description = [[[video mediaGroup] mediaDescription] stringValue];
	NSNumber *playTime = [[video mediaGroup] duration];
	NSNumber *viewCount = [[video statistics] viewCount];
	NSNumber *rating = [[video rating] average];
	NSDate *publishedDate = [[video publishedDate] date];

	// null check
	if(!itemId){itemId = @"";}
	if(!title){title = @"";}
	if(!author){author = @"";}
	if(!description){description = @"";}
	if(!playTime){playTime = [NSNumber numberWithInt:0];}
	if(!viewCount){viewCount = [NSNumber numberWithInt:0];}
	if(!rating){rating = [NSNumber numberWithInt:0];}
	if(!publishedDate){
		publishedDate = [NSDate dateWithString:@"1970-01-01 00:00:00 +0900"];
	}

	// trancate tag
	description = [self replaceCharacter:description str1:@"<b>" str2:@""];
	description = [self replaceCharacter:description str1:@"</b>" str2:@""];

	return [NSDictionary dictionaryWithObjectsAndKeys:
					itemId, @"itemId" ,
					title, @"title" ,
					author, @"author" ,
					description, @"description" ,
					playTime, @"playTime" ,
					viewCount, @"viewCount" ,
					rating, @"rating" ,
					publishedDate, @"publishedDate" ,
					nil
			];
}
//------------------------------------
// getYouTubeEntryValues
//------------------------------------
- (NSDictionary*)getYouTubeEntryValues:(GDataEntryBase *)entry
{

//	NSString *identifier = [entry identifier];
	NSString *title = [[entry title] stringValue];
	NSString *content = [[entry content] stringValue];
	NSArray *authors = [entry authors];
	NSString *author = @"";
	if(authors && [authors count] > 0){
		author = [[authors objectAtIndex:0] name];
	}
	NSString *authorLink = [[entry linkWithRelAttributeValue:@"self"] href];
	NSDate *publishedDate = [[entry publishedDate] date];

/*
//	NSLog(@"identifier=%@", identifier);
	NSLog(@"title=%@", title);
	NSLog(@"content=%@", content);
	NSLog(@"author=%@", author);
	NSLog(@"authorLink=%@", authorLink);
	NSLog(@"publishedDate=%@", [publishedDate description]);
*/

	// null check
	if(!title){title = @"";}
	if(!content){content = @"";}
	if(!author){author = @"";}
	if(!authorLink){authorLink = @"";}
	if(!publishedDate){
		publishedDate = [NSDate dateWithString:@"1970-01-01 00:00:00 +0900"];
	}

	return [NSDictionary dictionaryWithObjectsAndKeys:
					title, @"title" ,
					content, @"content" ,
					author, @"author" ,
					authorLink, @"authorLink" ,
					publishedDate, @"publishedDate" ,
					nil
			];
}
//------------------------------------
// categoryNameMenuItems
//------------------------------------
- (NSArray*)categoryNameMenuItems
{
	// categoryName
	return [[NSArray alloc] initWithObjects: 
		@",",
		@"-,",
		@"Autos,",
		@"Comedy,",
		@"Education,",
		@"Entertainment,",
		@"Film,",
		@"Games,",
		@"Howto,",
		@"Music,",
		@"News,",
		@"Nonprofit,",
		@"People,",
		@"Animals,",
		@"Tech,",
		@"Sports,",
		@"Travel,",
		nil
	];
}
//------------------------------------
// queryFeedNameMenuItems
//------------------------------------
- (NSArray*)queryFeedNameMenuItems
{
	// feedName
	return [[NSArray alloc] initWithObjects: 
		@"most_popular",
		@"most_viewed",
		@"recently_featured",
		@"most_recent",
		@"most_discussed",
		@"most_responded",
		@"top_favorites",
		@"top_rated",
//		@"most_linked",
//		@"watch_on_mobile",
		nil
	];
}
//------------------------------------
// countryCodeMenuItems
//------------------------------------
- (NSArray*)countryCodeMenuItems
{
	// value, title,
	return [[NSArray alloc] initWithObjects: 
		@",Worldwide (All)",
		@"AU,Australia",
		@"CA,Canada",
		@"IN,India",
		@"IE,Ireland",
		@"NZ,New Zealand",
		@"GB,UK",
		@"BR,Brazil",
		@"CZ,Czech Republic",
		@"DE,Germany",
		@"ES,Spain",
		@"FR,France",
		@"HK,Hong Kong",
		@"IL,Israel",
		@"IT,Italy",
		@"JP,Japan",
		@"KR,South Korea",
		@"MX,Mexico",
		@"NL,Netherlands",
		@"PL,Poland",
		@"RU,Russia",
		@"SE,Sweden",
		@"TW,Taiwan",
		nil
	];
}

@end