/* UserDefaultsExtension */

#import <Cocoa/Cocoa.h>
#import "PlaylistItemTypes.h"
#import "VideoFormatTypes.h"

@interface NSObject(userDefaultsExtension_)

- (void)setWindowRect:(NSWindow*)aWindow key:(NSString*)key;
- (void)setWindowPosition:(NSWindow*)aWindow key:(NSString*)key;
- (void)saveWindowRect:(NSWindow*)aWindow key:(NSString*)key;

- (void)setSplitViewRect:(NSSplitView *)aSplitView key:(NSString*)key;
- (void)saveSplitViewRect:(NSSplitView *)aSplitView key:(NSString*)key;
- (NSString*)splitViewRectString:(NSString*)key index:(int)index;

- (void)setTableColumnState:(NSTableView*)aTableView key:(NSString*)key;
- (void)saveTableColumnState:(NSTableView*)aTableView key:(NSString*)key;

- (void)setArrayControllerSortDescriptor:(NSArrayController*)aController key:(NSString*)key;
- (void)saveArrayControllerSortDescriptor:(NSArrayController*)aController key:(NSString*)key;

- (void)setSearchFieldRecentSearches:(NSSearchField*)searchField key:(NSString*)key;
- (void)saveSearchFieldRecentSearches:(NSSearchField*)searchField key:(NSString*)key;

- (void)saveLastSelectedIndex:(int)index key:(NSString*)key;
- (int)getLastSelectedIndex:(NSString*)key;

- (int)defaultVideoPlayerType;
- (int)defaultPlayFileFormatNo;
- (BOOL)defaultPlayHighQuality;
- (BOOL)defaultAutoPlay;
- (float)defaultPlayVolume;
- (int)defaultMaxResults;

- (float)defaultSearchMatrixCellSize;

- (int)defaultPlayRepeat;
- (float)defaultPlayRepeatInterval;
- (float)defaultVideoInfoRequestInterval;
- (float)defaultDownloadRequestInterval;

- (NSString*)defaultQueryFeedName;

//- (void)setDefaultLanguageIsJP;
- (BOOL)defaultLanguageIsJP;

- (void)setDefaultStringValue:(NSString*)string key:(NSString*)key;
- (NSString*)defaultStringValue:(NSString*)key;

- (void)setDefaultIntValue:(int)value key:(NSString*)key;
- (int)defaultIntValue:(NSString*)key;

- (void)setDefaultFloatValue:(float)value key:(NSString*)key;
- (float)defaultFloatValue:(NSString*)key;

- (void)setDefaultBoolValue:(BOOL)value key:(NSString*)key;
- (BOOL)defaultBoolValue:(NSString*)key;

- (void)setDefaultArrayValue:(NSArray*)array key:(NSString*)key;
- (NSArray*)defaultArrayValue:(NSString*)key;

- (NSString*)defaultOSVersion;
- (NSString*)defaultOSVersionNo;
- (NSString*)defaultAppName;
- (NSString*)defaultAppVersion;
- (NSString*)defaultLocalizedLanguage;
- (id)defaultInfoPlistValue:(NSString*)key;

@end
