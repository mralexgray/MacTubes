/* ViewPrefs */

#import <Cocoa/Cocoa.h>
#import "PolishedWindow.h"
#import "FullScreenWindow.h"
#import "SearchFilterTableView.h"

@interface ViewPrefs : NSObject
{

	IBOutlet PolishedWindow *mainWindow;
	IBOutlet PolishedWindow *relatedWindow;
//	IBOutlet FullScreenWindow *playerWindow;
	IBOutlet PolishedWindow *historyWindow;
	IBOutlet PolishedWindow *fileFormatWindow;
	IBOutlet PolishedWindow *downloadWindow;
	IBOutlet PolishedWindow *logWindow;
	IBOutlet NSWindow *infoWindow;
	IBOutlet NSWindow *prefsWindow;
	IBOutlet NSWindow *helpWindow;
	IBOutlet NSTabView *tabViewPrefs;

	IBOutlet NSTextField *txtDownloadFolderPath;

	IBOutlet NSArrayController *searchFilterArrayController;
	IBOutlet SearchFilterTableView *tbvSearchFilter;

	NSMutableArray *searchFilterList_;

}

- (IBAction)openPrefsWindow:(id)sender;
- (IBAction)openPrefsWindowWithIdentifier:(id)sender;
- (IBAction)openHelpWindow:(id)sender;
- (IBAction)changeWindowTheme:(id)sender;
- (IBAction)selectDownloadFolderPath:(id)sender;

- (IBAction)addSearchFilterList:(id)sender;
//- (IBAction)editSearchFilterList:(id)sender;
- (IBAction)removeSearchFilterList:(id)sender;
- (IBAction)saveSearchFilterList:(id)sender;

- (NSMutableArray*)searchFilterList;
- (NSMutableArray*)convertToSearchFilterItems:(NSArray*)array;

@end
