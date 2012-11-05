#import "ViewPlaylist.h"
#import "ViewMainSearch.h"
#import "TBArrayController.h"
#import "ImpExpManager.h"
#import "HelperExtension.h"
#import "ConvertExtension.h"
#import "GDataYouTubeExtension.h"
#import "UserDefaultsExtension.h"
#import "DialogExtension.h"

@implementation ViewPlaylist

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{
	// set display setting
	[self setControlButtonEnable];

	// set notification
	NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(frameDidResize:) name:NSViewFrameDidChangeNotification object:[olvPlaylist enclosingScrollView]];


}
//=======================================================================
// action methods
//=======================================================================
//------------------------------------
// addPlaylist
//------------------------------------
- (IBAction)addPlaylist:(id)sender
{
	int itemType = ITEM_PLAYLIST;
	int itemSubType = ITEM_SEARCH_KEYWORD;
	NSString *title = @"New Playlist";

	[self addItem:itemType
				itemSubType:itemSubType
				title:title
				keyword:@""
				isFolder:NO
				isSelect:YES
				isEdit:YES
	];

}
//------------------------------------
// addSearchlist
//------------------------------------
- (IBAction)addSearchlist:(id)sender
{

	int itemType = ITEM_SEARCH;
	int itemSubType = ITEM_SEARCH_KEYWORD;
	NSString *title = @"";

	if([sender tag] == 0){
		itemSubType = ITEM_SEARCH_KEYWORD;
		title = @"Keyword";
	}
	else if([sender tag] == 1){
		itemSubType = ITEM_SEARCH_AUTHOR;
		title = @"Author";
	}

	[self addItem:itemType
				itemSubType:itemSubType
				title:title
				keyword:@""
				isFolder:NO
				isSelect:YES
				isEdit:YES
	];

}
//------------------------------------
// addFeedlist
//------------------------------------
- (IBAction)addFeedlist:(id)sender
{
	int itemType = ITEM_FEED;
	int itemSubType = [sender tag];

	NSString *title = [self getFeedTitle:itemSubType];

	[self addItem:itemType
				itemSubType:itemSubType
				title:title
				keyword:@""
				isFolder:NO
				isSelect:YES
				isEdit:YES
	];

}
//------------------------------------
// addCategorylist
//------------------------------------
- (IBAction)addCategorylist:(id)sender
{
	int itemType = ITEM_CATEGORY;
	NSString *categoryName = [sender representedObject];

	NSString *title = @"";

	if([self defaultLanguageIsJP] == YES){
		title = [self getCategoryTitleJP:categoryName];
	}else{
		title = [self getCategoryTitle:categoryName];
	}

	[self addItem:itemType
				itemSubType:0
				title:title
				keyword:categoryName
				isFolder:NO
				isSelect:YES
				isEdit:YES
	];

}
//------------------------------------
// addFolder
//------------------------------------	  
- (IBAction)addFolder:(id)sender
{

	// add folder item
	[self addItem:ITEM_FOLDER
			itemSubType:0
			title:@"New Folder"
			keyword:@""
			isFolder:YES
			isSelect:YES
			isEdit:YES
	];

}

//------------------------------------
// searchItem
//------------------------------------
- (IBAction)searchItem:(id)sender
{

	// get selected item
	NSManagedObject *selectedItem = [olvPlaylist selectedObservedObject];
	// no select
	if(!selectedItem){
		return;
	}

	NSString *plistId = [selectedItem valueForKey:@"plistId"];
	NSString *searchString = [selectedItem valueForKey:@"title"];
	NSString *keyword = [selectedItem valueForKey:@"keyword"];
	int itemType = [[selectedItem valueForKey:@"itemType"] intValue];
	int itemSubType = [[selectedItem valueForKey:@"itemSubType"] intValue];

	if(!keyword){keyword = @"";}

//	NSLog(@"searchString=%@", searchString);
	// action
	// search with keyword
	if(itemType == ITEM_SEARCH){
		// keyword search
		if(itemSubType == ITEM_SEARCH_KEYWORD){
			[viewMainSearch searchWithString:searchString startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_STRING];
		}
		// author search
		if(itemSubType == ITEM_SEARCH_AUTHOR){
			NSString *url = [self convertToAuthorsUploadURL:searchString];    
			[viewMainSearch searchWithURL:url startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_URL];
		}
	}
	// search with playlist
	else if(itemType == ITEM_PLAYLIST){
		[viewMainSearch searchWithPlaylist:plistId startIndex:1];
	}
	// search with feed
	else if(itemType == ITEM_FEED){
		[self displayMessage:@"alert"
						messageText:@"Sorry, standard feeds are disabled."
						infoText:@"Please add category list."
						btnList:@"Cancel"
		];
		return;
//		[viewMainSearch searchWithFeedName:[self getFeedName:itemSubType] startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_FEED];
	}
	// search with category
	else if(itemType == ITEM_CATEGORY){
		if([self isEnabledCategory:keyword] == NO){
			[self displayMessage:@"alert"
							messageText:@"This category is enabled in Worldwide only."
							infoText:@"Please change country code."
							btnList:@"Cancel"
			];
			return;
		}
		[viewMainSearch searchWithCategoryName:keyword startIndex:1 maxResults:[self defaultMaxResults] searchType:SEARCH_WITH_CATEGORY];
	}
}
//------------------------------------
// removeItem
//------------------------------------	  
- (IBAction)removeItem:(id)sender
{

	// get selected item
	NSManagedObject *selectedItem = [olvPlaylist selectedObservedObject];
	// no select
	if(!selectedItem){
		return;
	}

	BOOL isFolder = [[selectedItem valueForKey:@"isFolder"] boolValue];
	int itemType = [[selectedItem valueForKey:@"itemType"] intValue];
	int itemSubType = [[selectedItem valueForKey:@"itemSubType"] intValue];
	int result;

	// Alert before remove
	// folder
	if(isFolder == YES){
		result = [self displayMessageWithIcon:@"icon_alert_folder"
											messageText:@"Delete Folder?"
											infoText:@"All items in folder are deleted"
											btnList:@"Delete,Cancel"
											];
	}
	else{
		// playlist
		if(itemType == ITEM_PLAYLIST){
			result = [self displayMessageWithIcon:@"icon_alert_playlist"
												messageText:@"Delete Playlist?"
												infoText:@""
												btnList:@"Delete,Cancel"
												];
		}
		// search
		else if(itemType == ITEM_SEARCH){
			// keyword
			if(itemSubType == ITEM_SEARCH_KEYWORD){
				result = [self displayMessageWithIcon:@"icon_alert_search"
													messageText:@"Delete keyword list?"
													infoText:@""
													btnList:@"Delete,Cancel"
													];
			}
			// author
			else if(itemSubType == ITEM_SEARCH_AUTHOR){
				result = [self displayMessageWithIcon:@"icon_alert_author"
													messageText:@"Delete author list?"
													infoText:@""
													btnList:@"Delete,Cancel"
													];
			}
			else{
				return;
			}
		}
		// feed
		else if(itemType == ITEM_FEED){
			result = [self displayMessageWithIcon:@"icon_alert_feed"
												messageText:@"Delete feed list?"
												infoText:@""
												btnList:@"Delete,Cancel"
												];
		}
		// category
		else if(itemType == ITEM_CATEGORY){
			result = [self displayMessageWithIcon:@"icon_alert_category"
												messageText:@"Delete category list?"
												infoText:@""
												btnList:@"Delete,Cancel"
												];
		}
		else{
			return;
		}
	}

	if(result != NSAlertFirstButtonReturn){
		return;
	}

	// remove tree of selectedItem
	[tbArrayController removeTreeItems:selectedItem];

	// reload
	[playlistTreeController rearrangeObjects];

}
//------------------------------------
// exportItem
//------------------------------------
- (IBAction)exportItem:(id)sender
{
	// get selected item
	NSManagedObject *selectedItem = [olvPlaylist selectedObservedObject];

	// no select
	if(!selectedItem){
		return;
	}

	NSString *title = [selectedItem valueForKey:@"title"];

	[impExpManager exportPlaylistWithItem:selectedItem title:title rootFolder:NO];

}
//------------------------------------
// openAuthorsProfileWithBrowser
//------------------------------------
- (IBAction)openAuthorsProfileWithBrowser:(id)sender
{
	// get selected item
	NSManagedObject *selectedItem = [olvPlaylist selectedObservedObject];

	// no select
	if(!selectedItem){
		return;
	}

	NSString *author = [selectedItem valueForKey:@"title"];

	// open item
	[self openAuthorsProfileURL:author];
}
//------------------------------------
// editItem
//------------------------------------
- (IBAction)editItem:(id)sender
{

	[olvPlaylist editSelectedItem];

}
//------------------------------------
// deselectItem
//------------------------------------
- (IBAction)deselectItem:(id)sender
{
	[olvPlaylist deselectItem];
}
//------------------------------------
// nullAction
//------------------------------------
- (IBAction)nullAction:(id)sender
{
	// null action
}
//=======================================================================
// methods
//=======================================================================
//------------------------------------
// addItem
//------------------------------------
- (void)addItem:(int)itemType
			itemSubType:(int)itemSubType
			title:(NSString*)title
			keyword:(NSString*)keyword
			isFolder:(BOOL)isFolder
			isSelect:(BOOL)isSelect
			isEdit:(BOOL)isEdit
{


	// get selected item
	id selectedRowItem = [olvPlaylist selectedRowObject];
	NSManagedObject *selectedItem = nil;
	if(selectedRowItem){
		selectedItem = [olvPlaylist selectedObservedObject];
	}

	// create item
	id item = [tbArrayController insertPlaylist:itemType
									itemSubType:itemSubType
									index:0
									title:title
									keyword:keyword
									parentItem:nil
									isFolder:isFolder
				];

	// add item to patent of selected item
	[tbArrayController addItemToParent:selectedItem item:item maxNum:YES];			

	// reload
	[playlistTreeController rearrangeObjects];

	// expand selectedRowItem
	if(selectedItem){
		if([[selectedItem valueForKey:@"isFolder"] boolValue] ==YES){
			[olvPlaylist expandItem:selectedRowItem expandChildren:YES];
		}
	}

	// select add item
	if(isSelect == YES){
		[olvPlaylist selectItem:item];
	}

	// edit selected row
	if(isEdit == YES){
		[olvPlaylist editSelectedItem];
	}

}

//------------------------------------
// setControlButton
//------------------------------------
- (void)setControlButtonEnable
{
	BOOL canAdd = [playlistTreeController canAdd];
	int selectedRow = [olvPlaylist selectedRow];
	BOOL isDisplay = [olvPlaylist isDisplay];

	if(canAdd == YES && isDisplay == YES){
		[btnAdd setEnabled:YES];
	}else{
		[btnAdd setEnabled:NO];
	}

	if(selectedRow >= 0 && isDisplay == YES){
		[btnRemove setEnabled:YES];
	}else{
		[btnRemove setEnabled:NO];
	}

}
//------------------------------------
// frameDidResize
//------------------------------------
-(void)frameDidResize:(NSNotification *)notification
{
	[self setControlButtonEnable];
}
//--------------------------------------
// isSelectItem
//--------------------------------------
- (BOOL)isSelectItem
{
	BOOL ret = NO;

	// get selected item
	NSManagedObject *item = [olvPlaylist selectedObservedObject];
	if(item){
		if([[item valueForKey:@"isFolder"] boolValue] == NO){
			ret = YES;
		}
	}

	return ret;
}
//--------------------------------------
// isSelectFolder
//--------------------------------------
- (BOOL)isSelectFolder
{
	BOOL ret = NO;

	// get selected item
	NSManagedObject *item = [olvPlaylist selectedObservedObject];
	if(item){
		if([[item valueForKey:@"isFolder"] boolValue] == YES){
			ret = YES;
		}
	}

	return ret;
}
//--------------------------------------
// isSelectPlaylist
//--------------------------------------
- (BOOL)isSelectPlaylist
{
	BOOL ret = NO;

	// get selected item
	NSManagedObject *item = [olvPlaylist selectedObservedObject];
	if(item){
		if( [[item valueForKey:@"isFolder"] boolValue] == NO &&
			[[item valueForKey:@"itemType"] intValue] == ITEM_PLAYLIST
			){
			ret = YES;
		}
	}

	return ret;
}
//--------------------------------------
// isSelectSearchKeyword
//--------------------------------------
- (BOOL)isSelectSearchKeyword
{
	BOOL ret = NO;

	// get selected item
	NSManagedObject *item = [olvPlaylist selectedObservedObject];
	if(item){
		if( [[item valueForKey:@"isFolder"] boolValue] == NO &&
			[[item valueForKey:@"itemType"] intValue] == ITEM_SEARCH &&
			[[item valueForKey:@"itemSubType"] intValue] == ITEM_SEARCH_KEYWORD
			){
			ret = YES;
		}
	}

	return ret;
}
//--------------------------------------
// isSelectSearchAuthor
//--------------------------------------
- (BOOL)isSelectSearchAuthor
{
	BOOL ret = NO;

	// get selected item
	NSManagedObject *item = [olvPlaylist selectedObservedObject];
	if(item){
		if( [[item valueForKey:@"isFolder"] boolValue] == NO &&
			[[item valueForKey:@"itemType"] intValue] == ITEM_SEARCH &&
			[[item valueForKey:@"itemSubType"] intValue] == ITEM_SEARCH_AUTHOR
			){
			ret = YES;
		}
	}

	return ret;
}
//------------------------------------
// isKeyMainWindow
//------------------------------------
- (BOOL)isKeyMainWindow
{
	return [mainWindow isKeyWindow];
}
//------------------------------------
// canAddPlaylist
//------------------------------------
- (BOOL)canAddPlaylist
{
	if( [self isKeyMainWindow] == YES &&
		[self isDisplayPlaylist] == YES){
		return YES;
	}else{
		return NO;
	}
}
//------------------------------------
// isDisplayPlaylist
//------------------------------------
- (BOOL)isDisplayPlaylist
{
	return [olvPlaylist isDisplay];
}

//----------------------
// dealloc
//----------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}
@end
