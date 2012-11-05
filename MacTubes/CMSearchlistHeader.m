#import "CMSearchlistHeader.h"
#import "SearchlistTableView.h"

@implementation CMSearchlistHeader

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	//set delegate parent menu
	[super setDelegate:self];

}
//------------------------------------
// set Menu Item
//------------------------------------
-(void)setMenuItem
{

	NSArray *cols;
	NSString *title;
	NSString *identifier;
	NSString *senderString;
	NSMenuItem *menuItem;
	int state;
	id record;

	// remove all items
    NSEnumerator *enumItemArray = [[self itemArray] objectEnumerator];
    while (record = [enumItemArray nextObject]) {
		[self removeItem:record];
	}

	// add item 
    NSEnumerator *enumMenuItems = [[self menuItems] objectEnumerator];
    while (record = [enumMenuItems nextObject]) {

		cols = [record componentsSeparatedByString:@","];
		title = [cols objectAtIndex:0];
		identifier = [cols objectAtIndex:1];

		if([tbvSearchlist isShowColumn:identifier] == YES){
			state = 1;
		}else{
			state = 0;
		}

		senderString = [NSString stringWithFormat: @"%@,%d",identifier,state];

		menuItem = [[[NSMenuItem alloc] initWithTitle:title action:@selector(changeColumnState:) keyEquivalent:@""] autorelease];
		[menuItem setTarget:tbvSearchlist];
		[menuItem setRepresentedObject:senderString];
		[menuItem setState:state];
         
        [self addItem:menuItem];
    }

}
//------------------------------------
// menuItems
//------------------------------------
-(NSArray*)menuItems
{
	// must show at least 1 binded column
	return 	[[NSArray alloc] initWithObjects: 
				@"No,rowNumber",
				@"Image,image",
//				@"Description,description",
				@"Author,author",
				@"Time,playTime",
				@"Views,viewCount",
				@"Rating,rating",
				@"Date,publishedDate",
//				@"ID,itemId",
				nil
			];
}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self setMenuItem];
}

@end
