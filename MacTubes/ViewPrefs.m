#import "ViewPrefs.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"

static NSString *defaultCountryCode = @"optCountryCode";

@implementation ViewPrefs

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

	//
	// set state from user default
	//
	// window position
	[self setWindowPosition:prefsWindow key:@"rectWindowPrefs"];
	[self setWindowPosition:helpWindow key:@"rectWindowHelp"];

	// alloc searchFilterList
	searchFilterList_ = [[NSMutableArray alloc] init];
	// add converted array from defaults
	[searchFilterList_ addObjectsFromArray:[self convertToSearchFilterItems:[self defaultArrayValue:@"optSearchFilterItems"]]];

	[searchFilterArrayController setContent:searchFilterList_];
	[searchFilterArrayController rearrangeObjects];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:prefsWindow];
	[nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:helpWindow];

	// set observer
//	[searchFilterArrayController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];

	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultCountryCode options:0 context:nil];

}

//=======================================================================
// Event Actions
//=======================================================================
//------------------------------------
// Open Info Window Action
//------------------------------------
- (IBAction)openPrefsWindow:(id)sender
{
	[prefsWindow makeKeyAndOrderFront:self];
}
//------------------------------------
// openPrefsWindowWithIdentifier
//------------------------------------
- (IBAction)openPrefsWindowWithIdentifier:(id)sender
{
	if([sender representedObject]){
		NSString *identifier = [sender representedObject];
		[tabViewPrefs selectTabViewItemWithIdentifier:identifier];
	}
	[prefsWindow makeKeyAndOrderFront:self];

}
//------------------------------------
// Open help Window Action
//------------------------------------
- (IBAction)openHelpWindow:(id)sender
{
	[helpWindow makeKeyAndOrderFront:self];
}

//------------------------------------
// changeWindowTheme
//------------------------------------
- (IBAction)changeWindowTheme:(id)sender
{
	[mainWindow changeWindowTheme:nil];
	[relatedWindow changeWindowTheme:nil];
//	[playerWindow changeWindowTheme:nil];
	[historyWindow changeWindowTheme:nil];
	[downloadWindow changeWindowTheme:nil];
	[fileFormatWindow changeWindowTheme:nil];
	[logWindow changeWindowTheme:nil];
//	[infoWindow changeWindowTheme:nil];

}
//------------------------------------
// selectDownloadFolderPath
//------------------------------------
- (IBAction)selectDownloadFolderPath:(id)sender
{

	NSArray *selectedPaths;
	NSString *defaultPath = [self defaultStringValue:@"optDownloadFolderPath"];

	// get path
	selectedPaths = [self selectFilePathWithOpenPanel:NO
												isDir:YES
												isMultiSel:NO
												isPackage:NO
												isAlias:YES
												canCreateDir:YES
												defaultPath:defaultPath
					];

	// set path
	if([selectedPaths count] > 0){
		[self setDefaultStringValue:[selectedPaths objectAtIndex:0] key:@"optDownloadFolderPath"];
	}
}
//------------------------------------
// addSearchFilterList
//------------------------------------
- (IBAction)addSearchFilterList:(id)sender
{

	// add object
	[searchFilterList_ addObject:
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:0], @"index" ,
			@"Author or Keyword", @"keyword" ,
			[NSNumber numberWithBool:YES], @"enabled" ,
			nil
		]
	];

	// re-number
	int i, row;
	id record;

	for(i = 0; i < [searchFilterList_ count]; i++){
		record = [searchFilterList_ objectAtIndex:i];
		[record setObject:[NSNumber numberWithInt:i] forKey:@"index"];
		row = i;
	}

	// reload
	[searchFilterArrayController rearrangeObjects];

	// save
	[self saveSearchFilterList:nil];

	// select and editable
	int col = [tbvSearchFilter columnWithIdentifier:@"keyword"];
	[tbvSearchFilter selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	[tbvSearchFilter editColumn:col row:row withEvent:nil select:YES];

}

/*
//------------------------------------
// editSearchFilterList
//------------------------------------
- (IBAction)editSearchFilterList:(id)sender
{

	[self saveSearchFilterList:nil];

}
*/
//------------------------------------
// removeSearchFilterList
//------------------------------------
- (IBAction)removeSearchFilterList:(id)sender
{
	// no select
	if([tbvSearchFilter numberOfSelectedRows] <= 0){
		return;
	}

	// remove object
	[searchFilterList_ removeObjectsAtIndexes:[tbvSearchFilter selectedRowIndexes]];

	// re-number
	int i;
	id record;
	
	for(i = 0; i < [searchFilterList_ count]; i++){
		record = [searchFilterList_ objectAtIndex:i];
		[record setValue:[NSNumber numberWithInt:i] forKey:@"index"];
	}


	// reload
	[searchFilterArrayController rearrangeObjects];

	// save
	[self saveSearchFilterList:nil];

}

//------------------------------------
// saveSearchFilterList
//------------------------------------
- (IBAction)saveSearchFilterList:(id)sender
{
//	NSLog(@"saveSearchFilterList");

	[self setDefaultArrayValue:[self searchFilterList] key:@"optSearchFilterItems"];
}
//------------------------------------
// convertToSearchFilterItems
//------------------------------------
- (NSMutableArray*)convertToSearchFilterItems:(NSArray*)array
{

	NSMutableArray *muArray = [NSMutableArray array];
	if(array != nil){
		int i;
		id record;
		for(i = 0; i < [array count]; i++){
			record = [array objectAtIndex:i];
			// add object
			[muArray addObject:
				[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[record valueForKey:@"index"], @"index" ,
					[record valueForKey:@"keyword"], @"keyword" ,
					[record valueForKey:@"enabled"], @"enabled" ,
					nil
				]
			];
		}
	}

	return muArray;
}
//------------------------------------
// searchFilterList
//------------------------------------
- (NSMutableArray*)searchFilterList
{
	return searchFilterList_;
}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:defaultCountryCode]){
		// set language Japanese
		if([[self defaultStringValue:defaultCountryCode] isEqualToString:@"JP"]){
			[self setDefaultBoolValue:YES key:@"optDefaultLanguageIsJP"];
		}
	}
/*
	// save 
	if([keyPath isEqualToString:@"arrangedObjects"]){
		[self saveSearchFilterList:nil];
	}
*/
}
//------------------------------------
// windowWillClose
//------------------------------------
-(void)windowWillClose:(NSNotification *)notification
{
	// save window rect
	if([notification object] == prefsWindow){
		[self saveWindowRect:prefsWindow key:@"rectWindowPrefs"];
	}
	else if([notification object] == helpWindow){
		[self saveWindowRect:helpWindow key:@"rectWindowHelp"];
	}

}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:defaultCountryCode];
//	[searchFilterArrayController removeObserver:self forKeyPath:@"arrangedObjects"];
	[searchFilterList_ release];
    [super dealloc];
}

@end
