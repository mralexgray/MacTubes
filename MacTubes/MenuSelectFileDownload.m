#import "MenuSelectFileDownload.h"
#import "ViewPlayer.h"
#import "ConvertExtension.h"
#import "UserDefaultsExtension.h"
#import "YouTubeHelperExtension.h"

static NSString *DEFAULT_ACTION = @"downloadItem:";
static NSString *defaultKeyName = @"optCanSelectFLVFormat";

@implementation MenuSelectFileDownload

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	[super setDelegate:self];
	[self createMenuItem];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKeyName options:0 context:nil];

}
//------------------------------------
// downloadItem
//------------------------------------
- (IBAction)downloadItem:(id)sender
{

	[viewPlayer downloadItem:sender];

}
//------------------------------------
// openVideoFormatItem
//------------------------------------
- (IBAction)openVideoFormatItem:(id)sender
{

	[viewPlayer openVideoFormatItem:sender];

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

	NSArray *cols;
	NSString *itemName;
	int fileFormatNo;
	int fileFormatType;
	int i;
	id record;

	BOOL isSelectFLV = [self defaultBoolValue:defaultKeyName];

	// remove menuItem
	while (record = [[[self itemArray] objectEnumerator] nextObject]) {
		[self removeItem:record];
	}

	NSArray *menuItems = [self menuItems];
	NSMenuItem *menuItem;

	for(i = 0; i < [menuItems count]; i++){

		cols = [[menuItems objectAtIndex:i] componentsSeparatedByString:@","];

		// add item separator
        if([[cols objectAtIndex:0] isEqualToString:@"-"]){
			[self addItem:[NSMenuItem separatorItem]];
			continue;
		}

		itemName = [cols objectAtIndex:0];
		fileFormatNo = [[cols objectAtIndex:1] intValue];
		fileFormatType = [[cols objectAtIndex:2] intValue];

		// skip flv/webm
		if(isSelectFLV == NO &&
			(
				fileFormatType == VIDEO_FORMAT_FILE_TYPE_FLV ||
				fileFormatType == VIDEO_FORMAT_FILE_TYPE_WEBM
			)
		){
			continue;
		}

		// set action
 		SEL sel = NSSelectorFromString(DEFAULT_ACTION);

		menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:sel keyEquivalent:@""] autorelease];
		[menuItem setTarget:self];
//		[menuItem setRepresentedObject:[NSNumber numberWithInt:fileFormatNo]]];
		[menuItem setTag:fileFormatNo];

		[self addItem:menuItem];

	}

	// separator
	[self addItem:[NSMenuItem separatorItem]];

	// add show files
	menuItem = [[[NSMenuItem alloc] initWithTitle:@"Show Files" action:@selector(openVideoFormatItem:) keyEquivalent:@""] autorelease];
 	[menuItem setTarget:self];
	[menuItem setRepresentedObject:nil];
	[menuItem setTag:99];
 	[self addItem:menuItem];

	[menuItems release];

}
//------------------------------------
// updateMenuItem
//------------------------------------
- (void)updateMenuItem
{

	id menuItem;
	int fileFormatNo;
	NSString *fileFormatStr;
//	NSString *downloadURL;

	NSDictionary *fileFormatNoMaps = [viewPlayer fileFormatNoMaps];

	NSEnumerator *enumArray = [[self itemArray] objectEnumerator];
	while (menuItem = [enumArray nextObject]) {

		fileFormatNo = [menuItem tag];

		// skip show files
		if(fileFormatNo == 99){
			continue;
		}

		fileFormatStr = [self convertIntToString:fileFormatNo];

		// set action
 		SEL sel = NSSelectorFromString(DEFAULT_ACTION);
 
 		// not found in format maps
		if(![fileFormatNoMaps valueForKey:fileFormatStr]){
			sel = nil;
//			downloadURL = @"";
		}else{
//			downloadURL = [fileFormatNoMaps valueForKey:fileFormatStr];
		}

		[menuItem setAction:sel];
//		[menuItem setRepresentedObject:downloadURL];

	}

}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	
	if([keyPath isEqualToString:defaultKeyName]){
		[self createMenuItem];
	}
	
}
//------------------------------------
// menuNeedsUpdate
//------------------------------------
-( void )menuNeedsUpdate:(NSMenu *)menu
{
	[self updateMenuItem];
}
//------------------------------------
// menuItems
//------------------------------------
- (NSArray*)menuItems
{
	return [[NSArray alloc] initWithObjects:
				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_NORMAL, VIDEO_FORMAT_NO_NORMAL, VIDEO_FORMAT_TYPE_NORMAL], 
//				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_HQ, VIDEO_FORMAT_NO_HQ, VIDEO_FORMAT_TYPE_HQ], 
				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_HIGH, VIDEO_FORMAT_NO_HIGH, VIDEO_FORMAT_TYPE_HIGH], 
				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_FMT_34, VIDEO_FORMAT_NO_FMT_34, VIDEO_FORMAT_TYPE_FMT_34], 
				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_FMT_35, VIDEO_FORMAT_NO_FMT_35, VIDEO_FORMAT_TYPE_FMT_35], 
				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_HD, VIDEO_FORMAT_NO_HD, VIDEO_FORMAT_TYPE_HD], 
				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_HD_1080, VIDEO_FORMAT_NO_HD_1080, VIDEO_FORMAT_TYPE_HD_1080], 
//				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_WEBM_43, VIDEO_FORMAT_NO_WEBM_43, VIDEO_FORMAT_TYPE_WEBM_43], 
//				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_WEBM_44, VIDEO_FORMAT_NO_WEBM_44, VIDEO_FORMAT_TYPE_WEBM_44], 
//				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_WEBM_45, VIDEO_FORMAT_NO_WEBM_45, VIDEO_FORMAT_TYPE_WEBM_45], 
//				[NSString stringWithFormat:@"%@,%d,%d", VIDEO_FORMAT_NAME_ORIGINAL, VIDEO_FORMAT_NO_ORIGINAL, VIDEO_FORMAT_TYPE_ORIGINAL], 
				nil
			];
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKeyName];
	[super dealloc];
}


@end
