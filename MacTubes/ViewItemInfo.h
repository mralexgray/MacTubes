/* ViewItemInfo */

#import <Cocoa/Cocoa.h>
#import "ContentItem.h"
#import "ControlTypes.h"

@interface ViewItemInfo : NSObject
{

	IBOutlet id viewPlayer;
	IBOutlet id viewItemComment;

	IBOutlet NSArrayController *searchlistArrayController;
	IBOutlet NSArrayController *relatedlistArrayController;

	IBOutlet NSWindow *infoWindow;
	IBOutlet NSImageView *imagePreview;
	IBOutlet NSTabView *tabViewComment;

	IBOutlet NSTextField *txtTitle;
	IBOutlet NSTextField *txtWatchURL;
	IBOutlet NSTextField *txtAuthor;
	IBOutlet NSTextField *txtUserCommentResults;
	IBOutlet NSTextView *txtItemInfo;
	IBOutlet NSTextView *txtDescription;

	IBOutlet NSButton *btnOpenVideoURL;
	IBOutlet NSButton *btnOpenAuthorPage;
	IBOutlet NSButton *btnCopy;

	NSDictionary *params_;
	int arrayNo_;

}
- (IBAction)openInfoWindow:(id)sender;

- (IBAction)playItem:(id)sender;
- (IBAction)openWatchWithBrowser:(id)sender;
- (IBAction)openAuthorsProfileWithBrowser:(id)sender;
- (IBAction)copyInfoToPasteboard:(id)sender;

- (void)createItemInfoFromArray;
- (BOOL)createItemInfo:(int)arrayNo record:(id)record;
- (void)changePlayItem:(int)tag isLoop:(BOOL)isLoop;
- (BOOL)selectPlayItem:(int)tag isLoop:(BOOL)isLoop;
- (void)setButtonnCopyEnabled;
- (void)postControlBindArrayChangedNotification:(int)arrayNo;

- (void)setArrayNo:(int)arrayNo;
- (int)arrayNo;
- (NSArrayController*)arrayController:(int)arrayNo;

- (void)setParams:(NSDictionary*)params;
- (NSDictionary*)params;

@end
