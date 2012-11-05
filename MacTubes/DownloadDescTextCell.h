#import <Cocoa/Cocoa.h>
#import "DownloadStatus.h"

@interface DownloadDescTextCell : NSCell 
{
	int downloadStatus_;
}
- (void)setDownloadStatus:(int)downloadStatus;
- (int)downloadStatus;
@end
