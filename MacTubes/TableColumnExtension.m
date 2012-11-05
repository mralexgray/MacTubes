#import "TableColumnExtension.h"

@implementation NSObject(tableColumnExtension_)

//------------------------------------
// setColumnState
//------------------------------------
- (void)setColumnState:(TableColumnController*)tcc sender:(id)sender
{
	NSString *identifier;
	int state;

	NSString *record = [sender representedObject];
	NSArray *cols = [record componentsSeparatedByString:@","];

	identifier = [cols objectAtIndex:0];
	state = [[cols objectAtIndex:1] intValue];

	// change table column
	if(state == 0){
		[tcc showColumn:identifier];
	}else{
		[tcc hideColumn:identifier];
	}
}
//------------------------------------
// showTableColumns
//------------------------------------
- (void)showTableColumns:(TableColumnController*)tcc
				aTableView:(NSTableView*)aTableView
				defaultHideCols:(NSArray*)defaultHideCols
				key:(NSString*)key
{

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *identifier;
	int i;
	BOOL isKey = NO;
	id record;

	// dict is available
	NSArray *arrayColumns = [defaults objectForKey:key];
/*
	if (arrayColumns == nil || [arrayColumns isKindOfClass:[NSArray class]] == NO){
		return;
	}
*/

	// set dict 
	NSMutableDictionary *dictColumns = [[NSMutableDictionary alloc] init];
	for (i = 0; i < [arrayColumns count]; i++){
		record = [arrayColumns objectAtIndex:i];
		if(![record valueForKey:@"identifier"]){
			continue;
		}
		identifier = [record valueForKey:@"identifier"];
		[dictColumns setObject:identifier forKey:identifier];
	}

	if([dictColumns count] > 0){
		isKey = YES;
	}

//	NSLog([dictColumns description]);

	// using copy because columns will decrease
	NSArray *columnArray = [[aTableView tableColumns] copy];

	for (i = 0; i < [columnArray count]; i++){

		identifier =[[columnArray objectAtIndex:i] identifier];

		// switch show / hide
		if(isKey == YES){
			if([dictColumns objectForKey:identifier]){
				[tcc showColumn:identifier];
			}else{
				[tcc hideColumn:identifier];
			}
		}
		// show all
		else{
			// default hide
			if([defaultHideCols indexOfObject:identifier] != NSNotFound){
				[tcc hideColumn:identifier];
			}else{
				[tcc showColumn:identifier];
			}
		}
	}

	[columnArray release];
	[dictColumns release];

}
//------------------------------------
// isShowColumnState
//------------------------------------
- (BOOL)isShowColumnState:(TableColumnController*)tcc identifier:(NSString*)identifier
{
	return [tcc isShowColumn:identifier];
}

@end
