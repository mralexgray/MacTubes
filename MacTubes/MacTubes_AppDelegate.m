//
//  MacTubes_AppDelegate.m
//  MacTubes
//
//  Created by MacTubes on 08/07/27.
//  Copyright MacTubes 2008 . All rights reserved.
//

#import "MacTubes_AppDelegate.h"
#import "LaunchServicesManager.h"
#import "DownloadManager.h"
#import "YouTubeHelperExtension.h"
#import "DialogExtension.h"
#import "UserDefaultsExtension.h"

@implementation MacTubes_AppDelegate


//------------------------------------
// initialize
//------------------------------------
+ (void)initialize {

    [self setupDefaults];

/*
	// register types for service menu
	[NSApp registerServicesMenuSendTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
								returnTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
	];
*/

}
//------------------------------------
// setupDefaults
//------------------------------------
+ (void)setupDefaults {

	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
								@"http://www.youtube.com", @"optBaseURL",	// url for base
								@"http://youtube.com", @"optBaseComURL",	// url for base com
								[NSNumber numberWithInt:0], @"optPlayFileFormatNo",	// 0:flv 1:hq 2:high 3:hd 4:fmt34 5:fmt35 6:hd_1080
								[NSNumber numberWithInt:0], @"optVideoPlayerType",	// 0:swf 1:video 2:quicktime
								[NSNumber numberWithInt:30], @"optMaxResults",
								[NSNumber numberWithInt:0], @"optQuerySort",		// 0:none(relevance) 1:published 2:viewCount 3:rating
								[NSNumber numberWithInt:0], @"optQuerySortRelated",
								[NSNumber numberWithInt:0], @"optQueryTimePeriod",	// 0:today 1:this_week 2:this_month 9:all_time
								@"at_d", @"optPlaylistSortString",
								@"most_viewed", @"optQueryFeedName",
								[NSNumber numberWithInt:0], @"optTabViewSearchIndex",
								@"", @"optCountryCode",
								[NSNumber numberWithBool:YES], @"optAutoPlay",
								[NSNumber numberWithInt:0], @"optPlayRepeat",		// 0:none 1:repeat all 2:repeat one
								[NSNumber numberWithBool:YES], @"optPlayerShowRelatedVideos",
								[NSNumber numberWithBool:YES], @"optPlayerShowSearch",
								[NSNumber numberWithBool:YES], @"optPlayerShowInfo",
								[NSNumber numberWithBool:NO], @"optPlayerHideAnnotation",
								[NSNumber numberWithBool:YES], @"optPlayerLiveResize",
								[NSNumber numberWithFloat:3.0], @"optPlayRepeatInterval",
								[NSNumber numberWithFloat:0.2], @"optPlayVolume",
								[NSNumber numberWithFloat:0.2], @"optVideoInfoRequestInterval",
								[NSNumber numberWithFloat:0.5], @"optDownloadRequestInterval",
								[NSNumber numberWithInt:100], @"optMaxCountPlayHistory",
								[NSNumber numberWithBool:NO], @"optSearchVideoInfo",
								[NSNumber numberWithBool:NO], @"optPlayHighQuality",
								[NSNumber numberWithBool:YES], @"optShowPopupComment",
								[NSNumber numberWithBool:YES], @"optShowMenuIcon",
								[NSNumber numberWithFloat:12.0], @"optFontSizeList",
								[NSNumber numberWithFloat:64.0], @"optSearchRowHeight",
								[NSNumber numberWithFloat:48.0], @"optRelatedRowHeight",
								[NSNumber numberWithFloat:48.0], @"optCommentRowHeight",
								[NSNumber numberWithFloat:5.0], @"optSearchMatrixCellScale",
//								[NSNumber numberWithBool:NO], @"optAllowRacy",
								[NSNumber numberWithInt:0], @"optSafeSearchNo",
								[NSNumber numberWithBool:NO], @"optSearchFilterEnable",
								[@"~/Desktop" stringByExpandingTildeInPath], @"optDownloadFolderPath",
								[NSNumber numberWithInt:0], @"optWindowThemeNo",		
								[NSNumber numberWithBool:NO], @"optDefaultLanguageIsJP",
								[NSNumber numberWithBool:NO], @"optCanSelectFLVFormat",
								nil
							];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

//------------------------------------
// applicationWillFinishLaunching
//------------------------------------
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	// for apple event
	NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
//	[appleEventManager setEventHandler:launchServicesManager andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	[appleEventManager setEventHandler:launchServicesManager andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:'GURL' andEventID:'GURL'];
}
//------------------------------------
// applicationDidFinishLaunching
//------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//	[NSApp setServicesProvider:self];
	// set default language is JP
//	[self setDefaultLanguageIsJP];
}
/*

//------------------------------------
// validRequestorForSendType
//------------------------------------
- (id)validRequestorForSendType:(NSString *)sendType
					returnType:(NSString *)returnType
{
	// for other apps service
	if(sendType && [sendType isEqualToString:NSStringPboardType]){
		return self;
	}

	// no other apps service
	return nil;
}
//------------------------------------
// writeSelectionToPasteboard
//------------------------------------
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types
{
 
    if ([types containsObject:NSStringPboardType] == NO) {
        return NO;
    }
	return YES;
}
//------------------------------------
// readSelectionFromPasteboard
//------------------------------------
- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard
{
	return YES;
}
*/

/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "MacTubes" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"MacTubes"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle and all of the 
    framework bundles.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    NSMutableSet *allBundles = [[NSMutableSet alloc] init];
    [allBundles addObject: [NSBundle mainBundle]];
    [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"MacTubes.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;

	// confirm cancel download
	if([downloadManager anyItemIsDownloading] == YES){
		int result = [self displayMessage:@"alert"
						messageText:@"Downloading is not compeleted."
						infoText:@"Quit application?"
						btnList:@"Cancel, Quit"
				];

		// cancel quit
		if(result == NSAlertFirstButtonReturn){
			return NSTerminateCancel;
		}
		// cancel download
		else{
			[downloadManager cancelAllDownloadItem:nil];
		}

	}

	// store last state
	[olvPlaylist storeLastState];

    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}


@end
