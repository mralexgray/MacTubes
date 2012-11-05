#import "TBArrayController.h"
#import "ConvertExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"

@implementation TBArrayController
//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

}
//=======================================================================
// methods
//=======================================================================
//--------------------------------------
// getMaxIntValueFromEntityWithColumn
//--------------------------------------
- (int)getMaxIntValueFromEntityWithColumn:(NSString*)entityName column:(NSString*)column
{
	NSArray *array = [self getAllObjects:entityName];
	return [self getMaxIntValueFromArrayWithColumn:array column:column];
}
//--------------------------------------
// getMaxIntValueFromArrayWithColumn
//--------------------------------------
- (int)getMaxIntValueFromArrayWithColumn:(NSArray*)array column:(NSString*)column
{

	int value = 0;

	if([array count] > 0){
		NSString *keyPath = [NSString stringWithFormat: @"@max.%@", column];
		value = [[array valueForKeyPath:keyPath] intValue];
	}

	return value;
}
//------------------------------------
// getMaxIndexFromChildItems
//------------------------------------	  
- (int)getMaxIndexFromChildItems:(NSManagedObject*)item
{

	NSArray *childItems = [self getChildObjects:item];
	return [self getMaxIntValueFromArrayWithColumn:childItems column:@"index"];

}
//------------------------------------
// getSelectedObject
//------------------------------------
- (NSManagedObject*)getSelectedObject:(NSString*)entityName
{

 	NSArray *fetchArray = [[[NSArray alloc] init] autorelease];
	NSManagedObject *object = nil;

	if([entityName isEqualToString:@"itemlist"]){
		fetchArray = [itemlistArrayController selectedObjects];
	}
	if([entityName isEqualToString:@"playlist"]){
		fetchArray = [playlistTreeController selectedObjects];
	}

	if([fetchArray count] > 0){
		object = [fetchArray objectAtIndex:0];
	}

	return object;
}
//------------------------------------
// getAllObjects
//------------------------------------
- (NSArray*)getAllObjects:(NSString*)entityName
{

 	NSArray *fetchedObjects = [[[NSArray alloc] init] autorelease];
	NSFetchRequest *request;

	// set entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
				inManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]];

	// set fetch request
	request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];

	// execute fetch
	fetchedObjects = [[MacTubes_AppDelegate managedObjectContext] 
					executeFetchRequest:request error:nil];

	return fetchedObjects;
}
//------------------------------------
// getArrangedObjects
//------------------------------------
- (NSArray*)getArrangedObjects:(NSString*)entityName
{

 	NSArray *fetchArray = [[[NSArray alloc] init] autorelease];
	if([entityName isEqualToString:@"itemlist"]){
		fetchArray = [itemlistArrayController arrangedObjects];
	}
	if([entityName isEqualToString:@"playlist"]){
		fetchArray = [playlistTreeController arrangedObjects];
	}

	return fetchArray;
}
//------------------------------------
// getSelectedObjects
//------------------------------------
- (NSArray*)getSelectedObjects:(NSString*)entityName
{

 	NSArray *fetchArray = [[[NSArray alloc] init] autorelease];
	if([entityName isEqualToString:@"itemlist"]){
		fetchArray = [itemlistArrayController selectedObjects];
	}
	if([entityName isEqualToString:@"playlist"]){
		fetchArray = [playlistTreeController selectedObjects];
	}

	return fetchArray;
}
//------------------------------------
// getChildObjects
//------------------------------------
- (NSArray*)getChildObjects:(NSManagedObject*)parent
{

	NSPredicate* pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"parent==%@", parent];

	return [self getObjectsWithPred:@"playlist" pred:pred];

}
//------------------------------------
// getObjectsWithPred
//------------------------------------
- (NSArray*)getObjectsWithPred:(NSString*)entityName pred:(NSPredicate*)pred
{

 	NSArray *fetchedObjects = [[[NSArray alloc] init] autorelease];
	NSFetchRequest *request;

	// set entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
				inManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]];

	// set fetch request
	request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	if(pred){
		[request setPredicate:pred];
	}

	// execute fetch
	fetchedObjects = [[MacTubes_AppDelegate managedObjectContext] 
					executeFetchRequest:request error:nil];

	return fetchedObjects;
}
//------------------------------------
// removeAllObjects
//------------------------------------
- (void)removeAllObjects:(NSString*)entityName
{

	// get objects
	NSArray *fetchedArray = [self getAllObjects:entityName];

	// remove objects
	[self removeObjectsWithArray:fetchedArray];

}
//------------------------------------
// removeObjectsWithArray
//------------------------------------
- (void)removeObjectsWithArray:(NSArray*)array
{

	NSEnumerator *enumArray = [array objectEnumerator];
	id record;

	while (record = [enumArray nextObject]) {
		[self removeObject:record];
	}

}
//------------------------------------
// removeObject
//------------------------------------
- (void)removeObject:(id)record
{

	[[MacTubes_AppDelegate managedObjectContext] deleteObject:record];

}
//------------------------------------
// getManagedObjectContext
//------------------------------------
- (NSManagedObjectContext*)getManagedObjectContext:(NSString*)entityName
{

	NSManagedObjectContext *context;

	if([entityName isEqualToString:@"itemlist"]){
		context = [itemlistArrayController managedObjectContext];
	}
	if([entityName isEqualToString:@"playlist"]){
		context = [playlistTreeController managedObjectContext];
	}
	return context;
}

//------------------------------------
// setItemlistFilterPredicate
//------------------------------------
- (void)setItemlistFilterPredicate:(NSPredicate*)searchPred
{

//	NSLog([searchPred description]);

	// setFilterPredicate
	[itemlistArrayController setFilterPredicate:searchPred];

}

//------------------------------------
// createItemlist
//------------------------------------
- (void)createItemlist:(NSString*)plistId items:(NSArray*)items
{
	// error
	if(!plistId || [plistId isEqualToString:@""]){
		[self displayMessage:@"alert"
									messageText:@"Can not add item."
									infoText:@""
									btnList:@"Cancel"
									];
		return;
	}

	// get already exists records
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"plistId == %@", plistId];
	NSArray *fetchedArray = [self getObjectsWithPred:@"itemlist" pred:pred];
	NSArray *itemIDs = [fetchedArray valueForKey:@"itemId"];

	int index = [self getMaxIntValueFromArrayWithColumn:fetchedArray column:@"index"];

	int i;
	id object;
	NSString *itemId;

	// if itemId is not contains in fetchedArray
	// insert itemId
	for (i = 0; i < [items count]; i++){
		object = [items objectAtIndex:i];
		itemId = [object valueForKey:@"itemId"];
		if(!itemId){
			continue;
		}
		// not contains
		if(![itemIDs containsObject:itemId]){
			// insert
			index++;
			[self insertItemlist:plistId object:object index:index];
		}
	}

}

//------------------------------------
// insertItemlist
//------------------------------------
- (void)insertItemlist:(NSString*)plistId object:(id)object index:(int)index
{

//	NSLog(@"index = %d", index);

	NSString *itemId = [object valueForKey:@"itemId"];
	NSString *title = [object valueForKey:@"title"];
	NSString *author = [object valueForKey:@"author"];

	//---------------------------
	//	insert record 
	//---------------------------
	NSEntityDescription *entItem = [NSEntityDescription 
									entityForName:@"itemlist"
									inManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]];

	NSManagedObject *mo = [[[NSManagedObject alloc]
							initWithEntity:entItem
							insertIntoManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]]
							autorelease];

	[mo setValue:plistId forKey:@"plistId"];
	[mo setValue:itemId forKey:@"itemId"];
	[mo setValue:title forKey:@"title"];
	[mo setValue:author forKey:@"author"];
	[mo setValue:[NSNumber numberWithInt:index] forKey:@"index"];

}
//------------------------------------
// removeItemlistWithPlaylist
//------------------------------------
- (void)removeItemlistWithPlaylist:(NSString*)plistId
{
	// key error
	if(!plistId || [plistId isEqualToString:@""]){
/*
		[self displayMessage:@"alert"
									messageText:@"Can not remove item."
									infoText:@""
									btnList:@"Cancel"
									];
*/
		return;
	}

	// get objects
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"plistId == %@", plistId];

	NSArray *fetchedArray = [self getObjectsWithPred:@"itemlist" pred:pred];

	// remove objects
	[self removeObjectsWithArray:fetchedArray];

}
//------------------------------------
// removeItemlistFromPlaylist
//------------------------------------
- (void)removeItemlistFromPlaylist:(NSString*)plistId items:(NSArray*)items
{
	// error
	if(!plistId || [plistId isEqualToString:@""]){
		[self displayMessage:@"alert"
									messageText:@"Can not remove item."
									infoText:@""
									btnList:@"Cancel"
									];
		return;
	}

	// get objects
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"plistId == %@ AND itemId IN %@", plistId, items];

//	NSLog(@"pred = %@", [pred description]);

	NSArray *fetchedArray = [self getObjectsWithPred:@"itemlist" pred:pred];

	// remove objects
	[self removeObjectsWithArray:fetchedArray];

}
//------------------------------------
// insertPlaylist
//------------------------------------	  
- (NSManagedObject *)insertPlaylist:(int)itemType
					itemSubType:(int)itemSubType
					index:(int)index
					title:(NSString*)title
					keyword:(NSString*)keyword
					parentItem:(id)parentItem
					isFolder:(BOOL)isFolder
{

	// get plistNo
	int plistNo = [self defaultIntValue:@"optPlistNoForPlist"];

	// get max plistNo
	if(plistNo <= 0){
		plistNo = [self getMaxIntValueFromEntityWithColumn:@"playlist" column:@"plistId"];
	}

	plistNo++;

	//---------------------------
	//	insert record 
	//---------------------------
	NSEntityDescription *entItem = [NSEntityDescription 
									entityForName:@"playlist"
									inManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]];

	NSManagedObject *mo = [[[NSManagedObject alloc]
							initWithEntity:entItem
							insertIntoManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]]
							autorelease];

	[mo setValue:[NSNumber numberWithBool:isFolder] forKey:@"isFolder"];
	[mo setValue:[NSNumber numberWithBool:NO] forKey:@"isExpand"];
	[mo setValue:[NSNumber numberWithInt:itemType] forKey:@"itemType"];
	[mo setValue:[NSNumber numberWithInt:itemSubType] forKey:@"itemSubType"];
	[mo setValue:title forKey:@"title"];
	[mo setValue:keyword forKey:@"keyword"];
//	[mo setValue:parentItem forKey:@"parent"];
	[mo setValue:[self convertToZeroFormat:plistNo] forKey:@"plistId"];
	[mo setValue:[NSNumber numberWithInt:0] forKey:@"groupNo"];
	[mo setValue:[NSNumber numberWithInt:index] forKey:@"index"];
	[mo setValue:[NSNumber numberWithInt:0] forKey:@"labelColorNo"];

	// set default
	[self setDefaultIntValue:plistNo key:@"optPlistNoForPlist"];

	return mo;

}
//------------------------------------
// addItemToParent
//------------------------------------	  
- (void)addItemToParent:(NSManagedObject *)targetItem item:(NSManagedObject *)item maxNum:(BOOL)maxNum
{

	// get parent item
	NSManagedObject *parentItem = [self getUpdateTargetItem:targetItem];

	// update relation
//	if(parentItem){
//		[[parentItem mutableSetValueForKey:@"children"] addObject:item];
		[item setValue:parentItem forKey:@"parent"];
//	}

	// set max index
	if(maxNum == YES){
		int index = [self getMaxIndexFromChildItems:parentItem];
		index++;
		[item setValue:[NSNumber numberWithInt:index] forKey:@"index"]; 
	}

}
//------------------------------------
// getUpdateTargetItem
//------------------------------------	  
- (NSManagedObject*)getUpdateTargetItem:(NSManagedObject*)item
{

	NSManagedObject *targetItem = nil;

	if(item){
		// folder
		if([[item valueForKey:@"isFolder"] boolValue] == YES){
			targetItem = item;
		}
		// file -> parentItem
		else{
			NSManagedObject *parentItem = [item valueForKey:@"parent"];
			// folder
			if(parentItem && [[parentItem valueForKey:@"isFolder"] boolValue] == YES){
				targetItem = parentItem;
			}
		}
	}

	return targetItem;

}
//------------------------------------
// getTreeItems
//------------------------------------	  
- (NSMutableArray*)getTreeItems:(NSManagedObject*)item
{

	NSMutableArray *outArray = [[[NSMutableArray alloc] init] autorelease];

	// parent is folder -> get child
	if([[item valueForKey:@"isFolder"] boolValue] == YES){

		NSEnumerator *enumerator = [[item mutableSetValueForKey:@"children"] objectEnumerator];
		NSManagedObject *childItem;
		while(childItem = [enumerator nextObject]) {

			// add object from children
			if([[childItem valueForKey:@"isFolder"] boolValue] == YES){
				[outArray addObjectsFromArray:[self getTreeItems:childItem]];
			}else{
				[outArray addObject:childItem];
			}

		}
	}
	// parent is not folder
	else{
		[outArray addObject:item];
	}

	return outArray;

}
//------------------------------------
// removeTreeItems
//------------------------------------	  
- (void)removeTreeItems:(NSManagedObject*)item
{

//	NSString *plistId;

	// parent is folder -> remove child
	if([[item valueForKey:@"isFolder"] boolValue] == YES){

		NSEnumerator *enumerator = [[item mutableSetValueForKey:@"children"] objectEnumerator];
		NSManagedObject *childItem;
		while(childItem = [enumerator nextObject]) {

			if([[childItem valueForKey:@"isFolder"] boolValue] == YES){
				// remove child
				[self removeTreeItems:childItem];
			}else{
				// remove item of playlist
				if([[childItem valueForKey:@"itemType"] intValue] == ITEM_PLAYLIST){
					[self removeItemlistWithPlaylist:[childItem valueForKey:@"plistId"]];
				}
			}
			// remove childItem
			[self removeObject:childItem];
		}
	}
	// parent is playlist -> remove member of playlist
	else{
		// remove item of playlist
		if([[item valueForKey:@"itemType"] intValue] == ITEM_PLAYLIST){
			[self removeItemlistWithPlaylist:[item valueForKey:@"plistId"]];
		}
	}

	//remove item
	[self removeObject:item];
}
//-------------------------------------------
// resetItemIndex
//-------------------------------------------
- (void)resetItemIndex:(NSManagedObject*)insItem
			parentItem:(NSManagedObject*)parentItem
			targetItem:(NSManagedObject*)targetItem
			insIndex:(int)insIndex
{

	int index = -1;

//	NSLog(@"insIndex=%d", insIndex);
//	NSLog(@"orgIndex=%d", [[insItem valueForKey:@"index"] intValue]);

	// same parent & drop down
	if(parentItem == targetItem){
//		NSLog(@"same parent!!");
		if(insIndex > [[insItem valueForKey:@"index"] intValue]){
			insIndex--;
		}
	}

	id insParent = [insItem valueForKey:@"parent"];
	NSArray *array = [self getChildObjects:insParent];
 
	NSSortDescriptor *descriptor=[[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES] autorelease];
	array = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];

	NSEnumerator *enumObject = [array objectEnumerator];
	id item;
	while (item = [enumObject nextObject]){

		if(item == insItem){
			[item setValue:[NSNumber numberWithInt:insIndex] forKey:@"index"]; 
			continue;
		}
		index++;
		// skip count index
		if(index == insIndex){
			index++;	
		}
		[item setValue:[NSNumber numberWithInt:index] forKey:@"index"]; 
	}

}
//------------------------------------
// createPlayHistory
//------------------------------------
- (void)createPlayHistory:(NSString*)itemId title:(NSString*)title author:(NSString*)author
{
	// error
	if(!itemId || [itemId isEqualToString:@""]){
		[self displayMessage:@"alert"
									messageText:@"Can not add item."
									infoText:@""
									btnList:@"Cancel"
									];
		return;
	}

	// update
	if([self updatePlayHistory:itemId title:title author:author] == YES){
		[playhistoryArrayController rearrangeObjects];
		return;
	}

	// get max index
	int index = [self getMaxIntValueFromEntityWithColumn:@"playhistory" column:@"index"];

	// insert
	index++;
	[self insertPlayHistory:itemId title:title author:author index:index];

	//
	// over max count
	//
	// get item
	NSArray *allObjects = [self getAllObjects:@"playhistory"];
	int maxCount = [self defaultIntValue:@"optMaxCountPlayHistory"];
	if(maxCount <= 0){
		maxCount = 100;
	}

	// over max count
	if([allObjects count] > maxCount){
		// Set sort descriptors
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO];
		allObjects = [allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];

		// create remove items
		NSMutableArray *overFlowItems = [[NSMutableArray alloc] init];
		int i;
		for(i = maxCount; i < [allObjects count]; i++){
			[overFlowItems addObject:[[allObjects objectAtIndex:i] valueForKey:@"itemId"]];
		}

		// remove items
		[self removePlayHistory:overFlowItems];
		[overFlowItems release];

	}

	[playhistoryArrayController rearrangeObjects];

}

//------------------------------------
// insertPlayHistory
//------------------------------------
- (void)insertPlayHistory:(NSString*)itemId title:(NSString*)title author:(NSString*)author index:(int)index
{

//	NSLog(@"index = %d", index);

	//---------------------------
	//	insert record 
	//---------------------------
	NSEntityDescription *entItem = [NSEntityDescription 
									entityForName:@"playhistory"
									inManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]];

	NSManagedObject *mo = [[[NSManagedObject alloc]
							initWithEntity:entItem
							insertIntoManagedObjectContext:[MacTubes_AppDelegate managedObjectContext]]
							autorelease];

	[mo setValue:itemId forKey:@"itemId"];
	[mo setValue:title forKey:@"title"];
	[mo setValue:author forKey:@"author"];
	[mo setValue:[NSNumber numberWithInt:index] forKey:@"index"];
	[mo setValue:[NSDate date] forKey:@"playDate"];

}
//------------------------------------
// updatePlayHistory
//------------------------------------
- (BOOL)updatePlayHistory:(NSString*)itemId title:(NSString*)title author:(NSString*)author
{

	BOOL ret = NO;

	// get objects
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];
	NSArray *fetchedArray = [self getObjectsWithPred:@"playhistory" pred:pred];

	// update objects
	NSEnumerator *enumArray = [fetchedArray objectEnumerator];
	id record;
	// update objects
	while (record = [enumArray nextObject]) {
		[record setValue:title forKey:@"title"];
		[record setValue:author forKey:@"author"];
		[record setValue:[NSDate date] forKey:@"playDate"];
		ret = YES;
	}

	return ret;

}
//------------------------------------
// removePlayHistory
//------------------------------------
- (void)removePlayHistory:(NSArray*)items
{

	// get objects
	NSPredicate *pred = [[[NSPredicate alloc] init] autorelease];
	pred = [NSPredicate predicateWithFormat:@"itemId IN %@", items];

//	NSLog(@"pred = %@", [pred description]);

	NSArray *fetchedArray = [self getObjectsWithPred:@"playhistory" pred:pred];

	// remove objects
	[self removeObjectsWithArray:fetchedArray];

}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
    [super dealloc];
}

@end
