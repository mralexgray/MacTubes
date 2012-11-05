//
//  MacTubes_AppDelegate.h
//  MacTubes
//
//  Created by MacTubes on 08/07/27.
//  Copyright MacTubes 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlaylistOutlineView.h"

@interface MacTubes_AppDelegate : NSObject 
{
    IBOutlet NSWindow *mainWindow;
    IBOutlet id launchServicesManager;
    IBOutlet id downloadManager;
	IBOutlet PlaylistOutlineView *olvPlaylist;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

+ (void)setupDefaults;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
