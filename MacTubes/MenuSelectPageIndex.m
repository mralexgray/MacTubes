#import "MenuSelectPageIndex.h"
#import "ViewMainSearch.h"
#import "UserDefaultsExtension.h"

@implementation MenuSelectPageIndex

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[super setDelegate:self];

}
//------------------------------------
// changePageIndex
//------------------------------------
- (IBAction)changePageIndex:(id)sender
{

	// move
	[viewTargetSearch moveSearchPage:sender];

}
//------------------------------------
// nullAction
//------------------------------------
- (IBAction)nullAction:(id)sender
{
	// nullAction
}
//------------------------------------
// createMenuItem
//------------------------------------
- (void)createMenuItem
{

	int i;
	id record;
	NSString *title;

	// remove menuItem
	 while (record = [[[self itemArray] objectEnumerator] nextObject]) {
		[self removeItem:record];
	}

	// set action
	SEL sel = NSSelectorFromString(@"changePageIndex:");

	int startIndex = (int)[viewTargetSearch startIndex];
	int totalResults = (int)[viewTargetSearch totalResults];
	int maxResults = [self defaultMaxResults];

	int pageIndex = ((startIndex - 1) / maxResults) + 1;
	int pageStartIndex = pageIndex - 4;
	int pageEndIndex = pageIndex + 5;
	int pageLastIndex = 0;
	int pagelimitIndex = (1000 / maxResults) - 1;

	// start index
	if(pageStartIndex < 1){
		pageEndIndex += (1 - pageStartIndex); 
		pageStartIndex = 1;
	}

	// last index
	if(totalResults > 0){
		pageLastIndex = totalResults / maxResults;
		if(totalResults % maxResults > 0){
			pageLastIndex++;
		}
	}
	if(pageLastIndex > pagelimitIndex){
		pageLastIndex = pagelimitIndex; 
	}

	// end index
	if(pageEndIndex > pageLastIndex){
		pageStartIndex -= (pageEndIndex - pageLastIndex); 
		if(pageStartIndex < 1){
			pageStartIndex = 1;
		}
		pageEndIndex = pageLastIndex; 
	}

	// start index
	if(pageStartIndex > 1){
		title = [NSString stringWithFormat:@"Page %d", 1];
		NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:[NSNumber numberWithInt:1]];
		[self addItem:menuItem];
		// add separator
//		if(pageStartIndex > 2){
			[self addItem:[NSMenuItem separatorItem]];
//		}
	}

	// page index
	for(i = pageStartIndex; i <= pageEndIndex; i++){

		title = [NSString stringWithFormat:@"Page %d", i];

		NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:[NSNumber numberWithInt:i]];

		// set state
		if(pageIndex == i){
			[menuItem setState:1];
		}else{
			[menuItem setState:0];
		}

		[self addItem:menuItem];
	}

	// last index
	if(pageLastIndex > pageEndIndex){

		// add separator
//		if(pageLastIndex > pageEndIndex + 1){
			[self addItem:[NSMenuItem separatorItem]];
//		}

		title = [NSString stringWithFormat:@"Page %d", pageLastIndex];
		NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:[NSNumber numberWithInt:pageLastIndex]];
		[self addItem:menuItem];
	}

}

//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self createMenuItem];
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[super dealloc];
}


@end
