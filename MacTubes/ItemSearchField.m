#import "ItemSearchField.h"

@implementation ItemSearchField

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	[super setDelegate:self];

	// create search text menu
	[self createSearchTextMenu];
	[self setSearchFormat:@""];
}
//=======================================================================
// Action
//=======================================================================
//------------------------------------
// searchWithField
//------------------------------------
- (IBAction)searchWithField:(id)sender
{

	NSString *searchFormat = @"";
	NSMutableString *searchString = @"";
	NSMutableString *searchColumn = @"";
	NSString *predString = @"";
	NSString *matchString = @"";
	int cnt;
	NSMutableString *itemFormat;
	NSArray *searchArray;

	searchFormat = [self getSearchFormat];

	// escape charactoer
	searchString = [NSMutableString stringWithString:[self stringValue]];
	[searchString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0,[searchString length])];
	[searchString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0,[searchString length])];
	[searchString replaceOccurrencesOfString:@"'" withString:@"\\'" options:0 range:NSMakeRange(0,[searchString length])];

	if(![searchString isEqualToString:@""]){

		// AND search by word
		searchArray = [searchString componentsSeparatedByString:@" "];
		for (cnt = 0; cnt < [searchArray count]; cnt++){
			searchColumn = [NSMutableString stringWithString:[searchArray objectAtIndex:cnt]];
			if([searchColumn isEqualToString:@""]){
				continue;
			}
			matchString = @"";
			// ALL
			if([searchFormat isEqualToString:@""]){
				itemFormat = [NSMutableString stringWithString:[self getSearchFormatAll]];
			}
			// selected column
			else{
				itemFormat = [NSMutableString stringWithString:searchFormat];
			}
			// replace $value
			[itemFormat replaceOccurrencesOfString:@"$value" withString:searchColumn options:0 range:NSMakeRange(0,[itemFormat length])];
			matchString = itemFormat;

			// create predicate string
			if([predString isEqualToString:@""]){
				predString = [predString stringByAppendingString:[NSString stringWithFormat:@"(%@)", matchString]];
			}else{
				predString = [predString stringByAppendingString:[NSString stringWithFormat:@"AND (%@)", matchString]];
			}
		}
	}

//	NSLog(@"predString=%@", predString);
 	NSPredicate *pred = nil;
	if(![predString isEqualToString:@""]){
		pred = [NSPredicate predicateWithFormat:predString];
	}

	// set filterPredicate
	[targetArrayController setFilterPredicate:pred];

}
//------------------------------------
// changeSearchFormat
//------------------------------------
- (IBAction)changeSearchFormat:(id)sender
{

	NSString *record = [sender representedObject];
	NSArray *myColmun = [record componentsSeparatedByString:@","];

	NSString *itemFormat = [myColmun objectAtIndex:1];
	int itemIndex = [[myColmun objectAtIndex:0] intValue];
	int i;

	for(i = 0; i < [[searchTextMenu_ itemArray] count]; i++){
		if(i == itemIndex){
			[[searchTextMenu_ itemAtIndex:i] setState:1];
		}else{
			[[searchTextMenu_ itemAtIndex:i] setState:0];
		}
	}

	id searchCell = [self cell];
	[searchCell setSearchMenuTemplate:searchTextMenu_];

	[self setSearchFormat:itemFormat];

	if(![[self stringValue] isEqualToString:@""]){
		[self searchWithField:nil];
	}

}
//------------------------------------
// createSearchTextMenu
//------------------------------------
- (void)createSearchTextMenu
{
	NSArray *myColmun;
	NSString *itemName;
	NSString *itemFormat;
	NSString *itemRecord;
    id searchCell = [self cell];
	int i;

	// create menu array
	NSArray *searchTextArray = [self createSearchTextArray];

    searchTextMenu_ = [[[NSMenu alloc] initWithTitle:@"searchTextMenu_"] autorelease];

	for(i = 0; i < [searchTextArray count]; i++){

		myColmun = [[searchTextArray objectAtIndex:i] componentsSeparatedByString:@","];
		itemName = [myColmun objectAtIndex:0];
		itemFormat = [myColmun objectAtIndex:1];
		itemRecord = [NSString stringWithFormat:@"%d,%@",i, itemFormat];

 		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:itemName action:@selector(changeSearchFormat:) keyEquivalent:@""];

		[menuItem setTarget:self];
		[menuItem setRepresentedObject:itemRecord];

        [searchTextMenu_ addItem:menuItem];
		[menuItem release];
    }
    
	[[searchTextMenu_ itemAtIndex:0] setState:1];
	[searchCell setSearchMenuTemplate:searchTextMenu_];

	// set setSearchFormatAll
	[self setSearchFormatAll:[self createSearchFormatAll:searchTextArray]];

	[searchTextArray release];
}
//------------------------------------
// createSearchFormatAll
//------------------------------------
- (NSString*)createSearchFormatAll:(NSArray*)searchTextArray
{

	NSString *formatString = @"";
	NSArray *myColmun;
	int i;

	for(i = 0; i < [searchTextArray count]; i++){
		myColmun = [[searchTextArray objectAtIndex:i] componentsSeparatedByString:@","];
		if(![[myColmun objectAtIndex:1] isEqualToString:@""]){
			if([formatString isEqualToString:@""]){
				formatString = [formatString stringByAppendingString:[NSString stringWithFormat:@"(%@)", [myColmun objectAtIndex:1]]];
			}else{
				formatString = [formatString stringByAppendingString:[NSString stringWithFormat:@"OR (%@)", [myColmun objectAtIndex:1]]];
			}
		}
	}

	return formatString;

}

//------------------------------------
// clear Search Text
//------------------------------------
- (void)clearSearchText
{
	[self setStringValue:@""];
}

//------------------------------------
// get Search Format
//------------------------------------
- (NSString *)getSearchFormat
{
    return searchFormat_;
}
//------------------------------------
// get Search Format All
//------------------------------------
- (NSString *)getSearchFormatAll
{
    return searchFormatAll_;
}
//------------------------------------
// set Search Format
//------------------------------------
- (void)setSearchFormat:(NSString *)newFormat
{
	[newFormat retain];
    [searchFormat_ release];
    searchFormat_ = newFormat;

}
//------------------------------------
// set Search Format
//------------------------------------
- (void)setSearchFormatAll:(NSString *)newFormat
{
	[newFormat retain];
    [searchFormatAll_ release];
    searchFormatAll_ = newFormat;

}
//------------------------------------
// createSearchTextArray
//------------------------------------
- (NSArray*)createSearchTextArray
{
	return [[NSArray alloc] initWithObjects: 
		@"All,",
		@"Title,title contains[c] '$value'",
		@"Author,author contains[c] '$value'",
		nil];
}
//------------------------------------
// textDidChange
//------------------------------------
- (BOOL)textDidChange:(NSNotification *)aNotification
{
	[self searchWithField:nil];
	return YES;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[searchFormat_ release];
	[searchFormatAll_ release];
	
    [super dealloc];
}

@end
