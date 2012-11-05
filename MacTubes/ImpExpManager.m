#import "ImpExpManager.h"
#import "TBArrayController.h"
#import "LogStatusController.h"
#import "HelperExtension.h"
#import "UserDefaultsExtension.h"
#import "GDataYouTubeExtension.h"
#import "DialogExtension.h"

@implementation ImpExpManager

//------------------------------------
// awake
//------------------------------------
- (void)awakeFromNib
{
	[self setLogString:@""];

}
//------------------------------------
// importPlaylist
//------------------------------------
- (IBAction)importPlaylist:(id)sender;
{

	int result;

	// select file
	NSArray *filePaths = [self selectFilePathWithOpenPanel:YES
											isDir:NO
											isMultiSel:NO
											isPackage:NO
											isAlias:NO
											canCreateDir:NO
											defaultPath:@""
						];

	// no select
	if([filePaths count] <= 0){
		return;
	}

	// proc start
	[self handleProcStatusChanged:PROC_IND_STATUS_START];

	NSString *filePath = [filePaths objectAtIndex:0];

	// create data
	NSError *error = nil;
	NSData *xmlData = [[[NSData alloc] initWithContentsOfFile:filePath options:nil error:&error] autorelease];

	// error
	if(xmlData == nil || error != nil){
		// proc stop
		[self handleProcStatusChanged:PROC_IND_STATUS_STOP];

		result = [self displayMessage:@"alert"
						messageText:@"Can not read data from file."
						infoText:@"Please check error log."
						btnList:@"Cancel,Log"
				];

		// show log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Import Log"];
			[logStatusController setLogString:[error description]];
			[logStatusController openLogWindow:nil];
		}else{
			[self setLogString:@""];
		}
		return;
	}


	// create string
	NSString *xmlString = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease];
//	NSLog(@"xmlString=%@", xmlString);

	//
	// import playlist
	//
	if([self importPlaylistWithString:xmlString] == NO){
		// proc stop
		[self handleProcStatusChanged:PROC_IND_STATUS_STOP];

		result = [self displayMessage:@"alert"
						messageText:@"Can not import playlist."
						infoText:@"Please check error log."
						btnList:@"Cancel,Log"
				];

		// show log
		if(result == NSAlertSecondButtonReturn){
			[logStatusController setTitle:@"Import Log"];
			[logStatusController setLogString:[self logString]];
			[logStatusController openLogWindow:nil];
		}else{
			[self setLogString:@""];
		}
		return;
	}

	// proc stop
	[self handleProcStatusChanged:PROC_IND_STATUS_STOP];

	// success
	result = [self displayMessage:@"info"
					messageText:@"Imported playlist."
					infoText:@"Please check import log."
					btnList:@"OK,Log"
			];

	// show log
	if(result == NSAlertSecondButtonReturn){
		[logStatusController setTitle:@"Import Log"];
		[logStatusController setLogString:[self logString]];
		[logStatusController openLogWindow:nil];
	}else{
		[self setLogString:@""];
	}

}

//------------------------------------
// exportPlaylist
//------------------------------------
- (IBAction)exportPlaylist:(id)sender
{
	int result = [self displayMessage:@"alert"
						messageText:@"Export all playlists?"
						infoText:@""
						btnList:@"Export,Cancel"
				];
	// cancel
	if(result == NSAlertSecondButtonReturn){
		return;
	}

//	NSArray *items = [tbArrayController getAllObjects:@"playlist"];

	[self exportPlaylistWithItem:nil title:@"All_Playlist" rootFolder:YES];

}
//------------------------------------
// importPlaylistWithString
//------------------------------------
- (BOOL)importPlaylistWithString:(NSString*)xmlString
{

	// clear log
	[self setLogString:@""];

	// create xml document
	NSError *error = nil;
	NSXMLDocument *xmlDoc = [[[NSXMLDocument alloc] initWithXMLString:xmlString options:nil error:&error] autorelease];
	if(error != nil){
		[self appendLogString:[NSString stringWithFormat:@"error=[%@]\n", error]];
		[self appendLogString:[NSString stringWithFormat: @"xmlString=[%@]\n", xmlString]];
		return NO;
	}

	// parse xml document
	//
	// <root>
	//
	NSXMLNode *rootNode = [xmlDoc rootElement];
//	NSLog(@"rootNode=%@", [rootNode name]);

	// null or not match
	if(rootNode == nil || ![[rootNode name] isEqualToString:@"root"]){
		[self appendLogString:@"error=[<root> is null]\n"];
		return NO;
	}

	//
	// <datainfo>
	//
	NSXMLNode *dataInfoNode = [self getChildNode:rootNode name:@"datainfo"];
	// null
	if(dataInfoNode == nil){
		[self appendLogString:@"error=[<datainfo> is null]\n"];
		return NO;
	}

	NSString *appname = [[self getChildNode:dataInfoNode name:@"appname"] stringValue];
	NSString *datatype = [[self getChildNode:dataInfoNode name:@"datatype"] stringValue];
	NSString *title = [[self getChildNode:dataInfoNode name:@"title"] stringValue];
	BOOL rootFolder = [[[self getChildNode:dataInfoNode name:@"rootfolder"] stringValue] intValue];
//	NSString *appversion = [[self getChildNode:dataInfoNode name:@"appversion"] stringValue];
//	NSString *date = [[self getChildNode:dataInfoNode name:@"date"] stringValue];

	// null or not match
	if(appname == nil || ![appname isEqualToString:[self defaultAppName]]){
		[self appendLogString:@"error=[<appname> is invalid value]\n"];
		return NO;
	}
	// null or not match
	if(datatype == nil || ![datatype isEqualToString:@"playlist"]){
		[self appendLogString:@"error=[<datatype> is invalid value]\n"];
		return NO;
	}

	//
	// <entries>
	//
	NSXMLNode *entriesNode = [self getChildNode:rootNode name:@"entries"];
	// null
	if(entriesNode == nil){
		[self appendLogString:@"error=[<entries> is null]\n"];
		return NO;
	}


	id parentItem = nil;
	id childItem = nil;

	//
	// create folder
	//
	if(rootFolder == YES){

		parentItem = [tbArrayController insertPlaylist:ITEM_FOLDER
												itemSubType:0
												index:0
												title:title
												keyword:@""
												parentItem:nil
												isFolder:YES
						];
		// add item to parent item
		[tbArrayController addItemToParent:nil item:parentItem maxNum:YES];			

	}

	//
	// create playlist & itemlist
	//
	if([self createPlaylistWithNode:entriesNode
								parentItem:parentItem
								childItem:&childItem
								indLevel:0
								index:0
		] == NO
	){
		return NO;
	}


	[playlistTreeController rearrangeObjects];	

	// select folder
	if(rootFolder == YES){
		[olvPlaylist selectItem:parentItem];
//		[olvPlaylist editSelectedItem:nil];
	}
	// select item
	else{
		if(childItem != nil){
			[olvPlaylist selectItem:childItem];
		}
	}

	return YES;

}
//------------------------------------
// createPlaylistWithNode
//------------------------------------
- (BOOL)createPlaylistWithNode:(NSXMLNode*)node
					parentItem:(id)parentItem
					childItem:(id*)childItem
					indLevel:(int)indLevel
					index:(int)index
{

	BOOL isSuccess = NO;

	NSString *title;
	NSString *keyword;
	NSString *entryType;
	NSString *entrySubType;
	NSString *plistId;
	id plistItem = nil;

	int itemType;
	int itemSubType;
	BOOL isFolder;

	NSString *description;

	// create indent
	NSString *indentString = [self createIndentString:indLevel];
	NSString *treeString;

	NSXMLNode *entryNode;
	NSEnumerator *enumNodes = [[node children] objectEnumerator];
	while (entryNode = [enumNodes nextObject]){

		//
		// <entry>
		//
		if ([[entryNode name] isEqualToString:@"entry"]){

			entryType = [[(NSXMLElement*)entryNode attributeForName:@"type"] stringValue];
			entrySubType = [[(NSXMLElement*)entryNode attributeForName:@"subtype"] stringValue];

			title = [[self getChildNode:entryNode name:@"title"] stringValue];
			keyword = [[self getChildNode:entryNode name:@"keyword"] stringValue];
			// null check
			if(!keyword){keyword = @"";}

			description = @"";
			treeString = @"-";

			itemType = 0;
			itemSubType = 0;
			isFolder = NO;

			// folder
			if([entryType isEqualToString:@"folder"]){
				itemType = ITEM_FOLDER;
				isFolder = YES;
				description = entryType;
				treeString = @"+";
			}
			// playlist
			else if([entryType isEqualToString:@"playlist"]){
				itemType = ITEM_PLAYLIST;
				description = entryType;
				treeString = @"+";
			}
			// search
			else if([entryType isEqualToString:@"search"]){
				itemType = ITEM_SEARCH;
				itemSubType = ITEM_SEARCH_KEYWORD;

				// keyword
				if([entrySubType isEqualToString:@"keyword"]){
					itemSubType = ITEM_SEARCH_KEYWORD;
				}
				// author
				else if([entrySubType isEqualToString:@"author"]){
					itemSubType = ITEM_SEARCH_AUTHOR;
				}
				// unknown
				else{
					continue;
				}
				description = [NSString stringWithFormat:@"%@ : %@", entryType, entrySubType];
			}
			// feed
			else if([entryType isEqualToString:@"feed"]){
				itemType = ITEM_FEED;
				itemSubType = [self getFeedType:entrySubType];
				description = [NSString stringWithFormat:@"%@ : %@", entryType, entrySubType];

			}
			// category
			else if([entryType isEqualToString:@"category"]){
				itemType = ITEM_CATEGORY;
				description = [NSString stringWithFormat:@"%@ : %@", entryType, entrySubType];

			}
			// unknown
			else{
				continue;
			}

			// insert playlist
//			index++;
			plistItem = [tbArrayController insertPlaylist:itemType
													itemSubType:itemSubType
													index:0
													title:title
													keyword:keyword
													parentItem:nil
													isFolder:isFolder
							];

			// add item to parent item
			[tbArrayController addItemToParent:parentItem item:plistItem maxNum:YES];			

			plistId = [plistItem valueForKey:@"plistId"];

			// append log
			[self appendLogString:[self createPlistLogString:indentString
												treeString:treeString
												title:title
												description:description
									]
			];

			isSuccess = YES;

			//
			// create child
			//
			if([entryType isEqualToString:@"folder"]){

				//
				// <entries>
				//
				NSXMLNode *entriesNode = [self getChildNode:entryNode name:@"entries"];

				if(entriesNode != nil){
					isSuccess = [self createPlaylistWithNode:entriesNode
													parentItem:plistItem
													childItem:childItem
													indLevel:(indLevel+1)
													index:0
								];
				}

			}

			//
			// create itemlist
			//
			if([entryType isEqualToString:@"playlist"]){

				//
				// <items>
				//
				NSXMLNode *itemsNode = [self getChildNode:entryNode name:@"items"];

				if(itemsNode != nil){
					[self createItemlistWithNode:itemsNode plistId:plistId indLevel:(indLevel + 1)];
				}

			}

		}

	}

	// last child item of root
	if(indLevel == 0){
		*childItem = plistItem;
	}

	return isSuccess;

}
//------------------------------------
// createItemlistWithNode
//------------------------------------
- (void)createItemlistWithNode:(NSXMLNode*)node plistId:(NSString*)plistId indLevel:(int)indLevel
{

	int index;
	NSString *itemId;
	NSString *title;
	NSString *author;

	NSXMLNode *itemNode;

	NSString *indentString = [self createIndentString:indLevel];
	NSString *treeString = @"-";

	NSEnumerator *enumNodes = [[node children] objectEnumerator];
	while (itemNode = [enumNodes nextObject]){

		//
		// <item>
		//
		if ([[itemNode name] isEqualToString:@"item"]){


			index = [[[self getChildNode:itemNode name:@"index"] stringValue] intValue];
			itemId = [[self getChildNode:itemNode name:@"itemid"] stringValue];
			title = [[self getChildNode:itemNode name:@"title"] stringValue];
			author = [[self getChildNode:itemNode name:@"author"] stringValue];

			// insert itemlist
			if(itemId != nil && ![itemId isEqualToString:@""]){
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
											title, @"title",
											itemId, @"itemId",
											author, @"author",
											nil
										];
				[tbArrayController insertItemlist:plistId object:params index:index];

				// append log
				[self appendLogString:[self createItemLogString:indentString
													treeString:treeString
													itemId:itemId
													title:title
										]
				];

			}
		}
	}

}
//------------------------------------
// exportPlaylistWithItem
//------------------------------------
- (BOOL)exportPlaylistWithItem:(NSManagedObject*)item title:(NSString*)title rootFolder:(BOOL)rootFolder
{

	NSMutableArray *childItems = [[[NSMutableArray alloc] init] autorelease];

	// add self item
	if(item != nil){
		[childItems addObject:item];
	}
	// add child items
	else{
		[childItems addObjectsFromArray:[tbArrayController getChildObjects:item]];
	}

	// export playlist
	return [self exportPlaylistWithItems:childItems title:title rootFolder:rootFolder];

}

//------------------------------------
// exportPlaylistWithItems
//------------------------------------
- (BOOL)exportPlaylistWithItems:(NSArray*)items title:(NSString*)title rootFolder:(BOOL)rootFolder
{

	int result;

	// proc start
	[self handleProcStatusChanged:PROC_IND_STATUS_START];

	//
	// create xml
	//
	BOOL isError = NO;
	NSXMLDocument *document = [self createXMLDocumentWithItems:items
														title:title
														rootFolder:rootFolder
														isError:&isError
							];

	// proc stop
	[self handleProcStatusChanged:PROC_IND_STATUS_STOP];

	// error
	if(isError == YES){

		[self displayMessage:@"alert"
						messageText:@"Can not export playlist."
						infoText:@"No playlist for exporting."
						btnList:@"Cancel"
		];
		return NO;
	}

/*
	// create fileName
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] 
									initWithDateFormat:@"%Y%m%d_%H%M%S" 
									allowNaturalLanguage:FALSE
								] autorelease];
	NSString *dateStr = [formatter stringFromDate:[NSDate date]];
*/
	// confirm save
	NSString *fileName = [NSString stringWithFormat:@"%@_%@.xml", [self defaultAppName], title];

	NSString *filePath = [self selectFilePathWithSavePanel:fileName
												canCreateDir:YES
												defaultPath:@""
						];

	if([filePath isEqualToString:@""]){
		return NO;
	}

	NSString *xmlString= [document XMLStringWithOptions:NSXMLNodePrettyPrint];
//	NSString* xmlString= [document XMLStringWithOptions:NSXMLNodeCompactEmptyElement];
//	NSLog(@"xmlString=%@", xmlString);

	// write data
//	NSData *xmlData = [[[NSData alloc] init] autorelease]; 
//	xmlData = [NSData dataWithBytes:[xmlString cString] length:[xmlString cStringLength]];
//	const NSStringEncoding *encoding = [NSString availableStringEncodings];
	NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 

	// writeToFile
	if([xmlData writeToFile:[filePath stringByExpandingTildeInPath] atomically:YES] == NO){
		[self displayMessage:@"alert"
						messageText:@"Can not export playlist."
						infoText:@"Failed write to file."
						btnList:@"Cancel"
		];
		return NO;
	}

	// success
	result = [self displayMessage:@"info"
					messageText:@"Exported playlist."
					infoText:@"Please check export log."
					btnList:@"OK,Log"
			];

	// show log
	if(result == NSAlertSecondButtonReturn){
		[logStatusController setTitle:@"Export Log"];
		[logStatusController setLogString:[self logString]];
		[logStatusController openLogWindow:nil];
	}else{
		[self setLogString:@""];
	}

	return YES;

}
//------------------------------------
// createXMLDocumentWithItems
//------------------------------------
- (NSXMLDocument*)createXMLDocumentWithItems:(NSArray*)items
										title:(NSString*)title
										rootFolder:(BOOL)rootFolder
										isError:(BOOL*)isError
{

	NSXMLDocument *document = [NSXMLNode document];
	[document setVersion:@"1.0"];

//	NSXMLDTD *dtd= [[[NSXMLDTD alloc] init] autorelease];
//	[dtd setPublicID:@"__URL__"];
//	[document setDTD:dtd];
	[document setCharacterEncoding:@"UTF-8"];
//	[document addChild:[NSXMLNode commentWithStringValue:@"__Comment_String__"]];

	// <root>
	NSXMLElement *root = [NSXMLNode elementWithName:@"root"];
	[document setRootElement:root];

	// <datainfo>
	NSXMLElement *elemDataInfo = [self createDataInfoElement:title
													rootFolder:rootFolder
													dataType:@"playlist"
								];
	[root addChild:elemDataInfo];

	// clear log
	[self setLogString:@""];

	// <entry>
	NSXMLElement *elemEntry = [self createEntryElementWithItems:items indLevel:0 isError:isError];
	[root addChild:elemEntry];

	return document;

}
//------------------------------------
// createDataInfoElement
//------------------------------------
- (NSXMLElement*)createDataInfoElement:(NSString*)title
								rootFolder:(BOOL)rootFolder
								dataType:(NSString*)dataType
{

	// <datainfo>
	NSXMLElement *element = [NSXMLNode elementWithName:@"datainfo"];

	// <appname>
	NSXMLElement *elemAppname = [NSXMLNode elementWithName:@"appname"];
	[elemAppname setObjectValue:[self defaultAppName]];
	[element addChild:elemAppname];

	// <appver>
	NSXMLElement *elemAppver = [NSXMLNode elementWithName:@"appversion"];
	[elemAppver setObjectValue:[self defaultAppVersion]];
	[element addChild:elemAppver];

	// <title>
	NSXMLElement *elemTitle = [NSXMLNode elementWithName:@"title"];
	[elemTitle setObjectValue:title];
	[element addChild:elemTitle];

	// <rootfolder>
	NSXMLElement *elemRootFolder = [NSXMLNode elementWithName:@"rootfolder"];
	[elemRootFolder setObjectValue:[NSNumber numberWithBool:rootFolder]];
	[element addChild:elemRootFolder];

	// <datatype>
	NSXMLElement *elemDataType = [NSXMLNode elementWithName:@"datatype"];
	[elemDataType setObjectValue:dataType];
	[element addChild:elemDataType];

	// <date>
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] 
									initWithDateFormat:@"%Y/%m/%d %H:%M:%S" 
									allowNaturalLanguage:FALSE
								] autorelease];
	NSString *dateStr = [formatter stringFromDate:[NSDate date]];

	NSXMLElement *elemDate = [NSXMLNode elementWithName:@"date"];
	[elemDate setObjectValue:dateStr];
	[element addChild:elemDate];

	return element;

}
//------------------------------------
// createEntryElementWithItems
//------------------------------------
- (NSXMLElement*)createEntryElementWithItems:(NSArray*)items indLevel:(int)indLevel isError:(BOOL*)isError
{

	// <entries>
	NSXMLElement *element = [NSXMLNode elementWithName:@"entries"];

	BOOL isSuccess = NO;
	BOOL isFolder;
	int itemType;
	int itemSubType;
	NSString *plistId;
	NSString *title;
	NSString *keyword;
	NSString *entryType;
	NSString *entrySubType;
	NSString *description;

	// create indent
	NSString *indentString = [self createIndentString:indLevel];
	NSString *treeString;

	// sort by index
	NSSortDescriptor *sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	NSArray *sortedItems = [items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc1]];
	[sortDesc1 release];

	id record;

	NSEnumerator *enumItems = [sortedItems objectEnumerator];
	while (record = [enumItems nextObject]) {

		plistId = [record valueForKey:@"plistId"];
		title = [record valueForKey:@"title"];
		keyword = [record valueForKey:@"keyword"];

		isFolder = [[record valueForKey:@"isFolder"] boolValue];
		itemType = [[record valueForKey:@"itemType"] intValue];
		itemSubType = [[record valueForKey:@"itemSubType"] intValue];

		// null check
		if(!keyword){keyword = @"";}

		entryType = @"";
		entrySubType = @"";
		description = @"";
		treeString = @"-";

		// folder
		if(itemType == ITEM_FOLDER){
			entryType = @"folder";
			entrySubType = @"";
			description = [NSString stringWithFormat:@"%@", entryType];
			treeString = @"+";
		}
		// playlist
		else if(itemType == ITEM_PLAYLIST){
			entryType = @"playlist";
			entrySubType = @"";
			description = [NSString stringWithFormat:@"%@", entryType];
			treeString = @"+";
		}
		// searchlist
		else if(itemType == ITEM_SEARCH){
			entryType = @"search";
			// keyword
			if(itemSubType == ITEM_SEARCH_KEYWORD){
				entrySubType = @"keyword";
			}
			// author
			else if(itemSubType == ITEM_SEARCH_AUTHOR){
				entrySubType = @"author";
			}
			// unknown
			else{
				continue;
			}
			description = [NSString stringWithFormat:@"%@ : %@", entryType, entrySubType];

		}
		// feed
		else if(itemType == ITEM_FEED){
			entryType = @"feed";
			entrySubType = [self getFeedName:itemSubType];
			description = [NSString stringWithFormat:@"%@ : %@", entryType, entrySubType];

		}
		// category
		else if(itemType == ITEM_CATEGORY){
			entryType = @"category";
			entrySubType = keyword;
			description = [NSString stringWithFormat:@"%@ : %@", entryType, entrySubType];
		}
		// unknown
		else{
			continue;
		}

		// <entry>
		NSXMLElement *elemEntry= [NSXMLNode elementWithName:@"entry"];
		[elemEntry addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:entryType]];
		[elemEntry addAttribute:[NSXMLNode attributeWithName:@"subtype" stringValue:entrySubType]];
		[element addChild:elemEntry];

		// <title>
		NSXMLElement *elemTitle= [NSXMLNode elementWithName:@"title"];
		[elemTitle setObjectValue:title];
		[elemEntry addChild:elemTitle];

		// <keyword>
		NSXMLElement *keywordTitle= [NSXMLNode elementWithName:@"keyword"];
		[keywordTitle setObjectValue:keyword];
		[elemEntry addChild:keywordTitle];

		// append log
		[self appendLogString:[self createPlistLogString:indentString
											treeString:treeString
											title:title
											description:description
								]
		];

		// add child entries
		if(itemType == ITEM_FOLDER && [record valueForKey:@"children"] != nil){
			NSArray *childItems = [[record valueForKey:@"children"] allObjects];
			NSXMLElement *elemChildEntries = [self createEntryElementWithItems:childItems indLevel:(indLevel + 1) isError:isError];
			[elemEntry addChild:elemChildEntries];
		}

		// add itemlist
		if(itemType == ITEM_PLAYLIST){
			NSXMLElement *elemItems = [self createItemElementWithPlistId:plistId indLevel:(indLevel + 1)];
			[elemEntry addChild:elemItems];
		}

		// data is found
		isSuccess = YES;
	}

	*isError = !isSuccess;

	return element;

}

//------------------------------------
// createItemElementWithPlistId
//------------------------------------
- (NSXMLElement*)createItemElementWithPlistId:(NSString*)plistId indLevel:(int)indLevel
{

	// get itemlist
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"plistId == %@", plistId];
	NSArray *items = [tbArrayController getObjectsWithPred:@"itemlist" pred:pred];

	// sort by index
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
	NSArray *sortedItems = [items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];

	// add item element
	return [self createItemElementWithItems:sortedItems indLevel:indLevel];

}
//------------------------------------
// createItemElementWithItems
//------------------------------------
- (NSXMLElement*)createItemElementWithItems:(NSArray*)items indLevel:(int)indLevel
{

	// <items>
	NSXMLElement *element = [NSXMLNode elementWithName:@"items"];

	int index;
	NSString *itemId;
	NSString *title;
	NSString *author;
	id record;

	// create indent
	NSString *indentString = [self createIndentString:indLevel];
	NSString *treeString = @"-";

	NSEnumerator *enumItems = [items objectEnumerator];
	while (record = [enumItems nextObject]) {

		index = [[record valueForKey:@"index"] intValue];
		itemId = [record valueForKey:@"itemId"];
		title = [record valueForKey:@"title"];
		author = [record valueForKey:@"author"];

		// <item>
		NSXMLElement *elemItem = [NSXMLNode elementWithName:@"item"];
//		[elemItem addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"video"]];
		[element addChild:elemItem];

		// <index>
		NSXMLElement *elemIndex = [NSXMLNode elementWithName:@"index"];
		[elemIndex setObjectValue:[NSString stringWithFormat:@"%d", index]];
		[elemItem addChild:elemIndex];

		// <itemid>
		NSXMLElement *elemItemId = [NSXMLNode elementWithName:@"itemid"];
		[elemItemId setObjectValue:itemId];
		[elemItem addChild:elemItemId];

		// <title>
		NSXMLElement *elemTitle = [NSXMLNode elementWithName:@"title"];
		[elemTitle setObjectValue:title];
		[elemItem addChild:elemTitle];

		// <author>
		NSXMLElement *elemAuthor = [NSXMLNode elementWithName:@"author"];
		[elemAuthor setObjectValue:author];
		[elemItem addChild:elemAuthor];

		// append log
		[self appendLogString:[self createItemLogString:indentString
											treeString:treeString
											itemId:itemId
											title:title
								]
		];

	}

	return element;
}
//------------------------------------
// createIndentString
//------------------------------------
- (NSString*)createIndentString:(int)indLevel
{
	NSString *indentString = @"";
	int i;
	for(i = 0; i < indLevel; i++){
		indentString = [indentString stringByAppendingString:@"\t"];
	}
	return indentString;
}
//------------------------------------
// createPlistLogString
//------------------------------------
- (NSString*)createPlistLogString:(NSString*)indentString
							treeString:(NSString*)treeString
							title:(NSString*)title
							description:(NSString*)description
{
	return [NSString stringWithFormat:@"%@%@ %@ [ %@ ]\n"
													, indentString
													, treeString
													, title
													, description
			];
}
//------------------------------------
// createItemLogString
//------------------------------------
- (NSString*)createItemLogString:(NSString*)indentString
							treeString:(NSString*)treeString
							itemId:(NSString*)itemId
							title:(NSString*)title
{
	return [NSString stringWithFormat:@"%@[%@]\t%@\n"
												, indentString
												, itemId
												, title
			];
}
//------------------------------------
// handleProcStatusChanged
//------------------------------------
- (void)handleProcStatusChanged:(int)status
{
	if(status == PROC_IND_STATUS_START){
		[indProc startAnimation:nil];
	}
	else{
		[indProc stopAnimation:nil];
	}
}
//------------------------------------
// logString
//------------------------------------
- (void)setLogString:(NSString*)logString
{
	[logString retain];
	[logString_ release];
	logString_ = logString;
}
- (NSString*)logString
{
	return logString_;
}
//------------------------------------
// appendLogString
//------------------------------------
- (void)appendLogString:(NSString *)logString
{
	[self setLogString:[[self logString] stringByAppendingString:logString]];
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[logString_ release];

    [super dealloc];
}

@end
