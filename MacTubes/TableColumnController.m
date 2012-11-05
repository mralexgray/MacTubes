//
//  TableColumnController.m
//
//  Original code
//  Created by Hiroshi Hashiguchi on 05/03/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
//  customized by MacTubes 2008
//

#import "TableColumnController.h"

////////////////////////////////////////
// private class
////////////////////////////////////////
@interface _ColumnHolder : NSObject
{
	int order_;
	id column_;
	BOOL isShow_;
}
- (id)initWithOrder:(int)order column:(id)column;
- (void)setOrder:(int)order;
- (void)setIsShow:(BOOL)isShow;
- (id)column;
- (int)order;
- (BOOL)isShow;
@end

@implementation _ColumnHolder

//------------------------------------
// initWithOrder
//------------------------------------
- (id)initWithOrder:(int)order column:(id)column
{
	if (self = [super init]) {
		order_ = order;
		column_ = [column retain];
		isShow_ = YES;
	}
	return self;
}
//------------------------------------
// setter
//------------------------------------
- (void)setOrder:(int)order
{
	order_ = order;
}
- (void)setIsShow:(BOOL)isShow
{
	isShow_ = isShow;
}
//------------------------------------
// getter
//------------------------------------
- (int)order
{
	return order_;
}
- (id)column
{
	return column_;
}
- (BOOL)isShow
{
	return isShow_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[column_ release];
    [super dealloc];
}
@end


////////////////////////////////////////
// manager implementation
////////////////////////////////////////
@implementation TableColumnController

//------------------------------------
// initWithTable
//------------------------------------
-(id)initWithTable:(NSTableView*)aTableView
{
	if (self = [super init]) {

		table_ = [aTableView retain];
		columnHolders_ = [[NSMutableDictionary alloc] init];
		
		id columnArray = [table_ tableColumns];
		int i;
		
		for (i = 0; i < [columnArray count]; i++) {
			id column = [columnArray objectAtIndex:i];
			id columnHolder = [[_ColumnHolder alloc] initWithOrder:i column:column];
			id identifier = [column identifier];
			if ([columnHolders_ objectForKey:identifier]) {
				NSLog(@"Warning: identifier '%@' already exists.", identifier);
			}
			[columnHolders_ setObject:columnHolder forKey:identifier];
		}
	}
	return self;
}
//------------------------------------
// sortTableColumns
//------------------------------------
-(void)sortTableColumns:(NSTableView*)aTableView
{
	id columnArray = [aTableView tableColumns];
	int i;
		
	for (i = 0; i < [columnArray count]; i++) {
		id newColumnHolder = [columnHolders_ objectForKey:[[columnArray objectAtIndex:i] identifier]];
		if(newColumnHolder != nil){
			[newColumnHolder setOrder:i];
		}
	}
}
//------------------------------------
// showColumn
//------------------------------------
-(void)showColumn:(NSString*)identifier
{
	if ([table_ tableColumnWithIdentifier:identifier] == nil) {
		
		id newColumnHolder = [columnHolders_ objectForKey:identifier];
		if (newColumnHolder != nil) {

			[table_ addTableColumn:[newColumnHolder column]];

			int lastIndex = [[table_ tableColumns] count] - 1;
			if([newColumnHolder order] < lastIndex){
				[table_ moveColumn:lastIndex toColumn:[newColumnHolder order]];
			}
//			[table_ sizeToFit];

			[newColumnHolder setIsShow:YES];
		}
	}
}
//------------------------------------
// hideColumn
//------------------------------------
-(void)hideColumn:(NSString*)identifier
{
	id column = [table_ tableColumnWithIdentifier:identifier];
	if (column != nil) {
		[table_ removeTableColumn:column];
//		[table_ sizeToFit];

		[[columnHolders_ objectForKey:identifier] setIsShow:NO];
	}
}
//------------------------------------
// isShowColumn
//------------------------------------
-(BOOL)isShowColumn:(NSString*)identifier
{
	return [[columnHolders_ objectForKey:identifier] isShow];
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[table_ release];
	[columnHolders_ release];
    [super dealloc];
}

@end
