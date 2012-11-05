/* TBArrayController */

#import <Cocoa/Cocoa.h>
#import "PlaylistItemTypes.h"

@interface TBArrayController : NSObject
{
	IBOutlet NSArrayController *itemlistArrayController;
	IBOutlet NSArrayController *playhistoryArrayController;
	IBOutlet NSTreeController *playlistTreeController;
	IBOutlet id MacTubes_AppDelegate;

}

- (int)getMaxIntValueFromEntityWithColumn:(NSString*)entityName column:(NSString*)column;
- (int)getMaxIntValueFromArrayWithColumn:(NSArray*)array column:(NSString*)column;
- (int)getMaxIndexFromChildItems:(NSManagedObject*)item;

- (NSManagedObject*)getSelectedObject:(NSString*)entityName;
- (NSArray*)getAllObjects:(NSString*)entityName;
- (NSArray*)getArrangedObjects:(NSString*)entityName;
- (NSArray*)getSelectedObjects:(NSString*)entityName;
- (NSArray*)getChildObjects:(NSManagedObject*)parent;
- (NSArray*)getObjectsWithPred:(NSString*)entityName pred:(NSPredicate*)pred;

- (void)removeAllObjects:(NSString*)entityName;
- (void)removeObjectsWithArray:(NSArray*)array;
- (void)removeObject:(id)record;

- (NSManagedObjectContext*)getManagedObjectContext:(NSString*)entityName;

- (void)setItemlistFilterPredicate:(NSPredicate*)searchPred;
- (void)createItemlist:(NSString*)plistId items:(NSArray*)items;
- (void)insertItemlist:(NSString*)plistId object:(id)object index:(int)index;
- (void)removeItemlistWithPlaylist:(NSString*)plistId;
- (void)removeItemlistFromPlaylist:(NSString*)plistId items:(NSArray*)items;

- (NSManagedObject *)insertPlaylist:(int)itemType
					itemSubType:(int)itemSubType
					index:(int)index
					title:(NSString*)title
					keyword:(NSString*)keyword
					parentItem:(id)parentItem
					isFolder:(BOOL)isFolder;

- (void)addItemToParent:(NSManagedObject *)selectedItem item:(NSManagedObject *)item maxNum:(BOOL)maxNum;
- (NSManagedObject*)getUpdateTargetItem:(NSManagedObject*)item;
- (NSMutableArray*)getTreeItems:(NSManagedObject*)item;
- (void)removeTreeItems:(NSManagedObject*)item;
- (void)resetItemIndex:(NSManagedObject*)insItem
			parentItem:(NSManagedObject*)parentItem
			targetItem:(NSManagedObject*)targetItem
			insIndex:(int)insIndex;

- (void)createPlayHistory:(NSString*)itemId title:(NSString*)title author:(NSString*)author;
- (void)insertPlayHistory:(NSString*)itemId title:(NSString*)title author:(NSString*)author index:(int)index;
- (BOOL)updatePlayHistory:(NSString*)itemId title:(NSString*)title author:(NSString*)author;
- (void)removePlayHistory:(NSArray*)items;

@end
