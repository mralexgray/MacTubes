//
//  TableColumnController.h
//
//  Original code
//  Created by Hiroshi Hashiguchi on 05/03/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TableColumnController : NSObject {

	NSTableView *table_;
	NSMutableDictionary *columnHolders_;

}

-(id)initWithTable:(NSTableView*)aTableView;
-(void)sortTableColumns:(NSTableView*)aTableView;
-(void)showColumn:(NSString*)identifier;
-(void)hideColumn:(NSString*)identifier;
-(BOOL)isShowColumn:(NSString*)identifier;
@end
