#import <Cocoa/Cocoa.h>
#import "VideoQueryStatus.h"

@interface ItemDescTextCell : NSCell 
{
	int itemStatus_;
}
- (void)setItemStatus:(int)itemStatus;
- (int)itemStatus;

@end
