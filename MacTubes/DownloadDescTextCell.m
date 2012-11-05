#import "DownloadDescTextCell.h"
#import "ConvertExtension.h"

@implementation DownloadDescTextCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{

	NSRect insetRect = NSInsetRect(cellFrame,5,0);

	//
	// get value
	//
	int status = [self downloadStatus];

	//
	// ParagraphStyle
	//
	NSMutableParagraphStyle *lineStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[lineStyle setLineBreakMode:NSLineBreakByTruncatingTail];

	//
	// color
	//
	NSColor *titleColor = [NSColor blackColor];
	NSColor *descColor = [NSColor grayColor];

	if( status == DOWNLOAD_INIT ||
		status == DOWNLOAD_STARTED){
		// none
	}
	else if(status == DOWNLOAD_COMPLETED ||
			status == DOWNLOAD_CANCELED ||
			status == DOWNLOAD_FAILED){
		titleColor = [NSColor grayColor];
		descColor = [NSColor grayColor];
	}

	//
	// attribute
	//
	// title
	NSMutableDictionary *titleAttr = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 titleColor, NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:12.0], NSFontAttributeName,
											 lineStyle, NSParagraphStyleAttributeName,
											 nil
										] autorelease];
											
	// description
	NSMutableDictionary *descAttr = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
												descColor, NSForegroundColorAttributeName,
												[NSFont systemFontOfSize:10.0], NSFontAttributeName,
												lineStyle, NSParagraphStyleAttributeName,
												nil
										] autorelease];
											

	//
	// stringValue
	//
	NSArray *values = [[self stringValue] componentsSeparatedByString:@"\t"];

	//
	// title
	//
	NSString *title = @"";
	if([values count] >= 1){
		title = [values objectAtIndex:0];
	}
	NSSize titleSize = [title sizeWithAttributes:titleAttr];
	
	//
	// description
	//
	NSString *description = @"";
	if([values count] >= 2){
		description = [values objectAtIndex:1];
	}
	NSSize descSize = [description sizeWithAttributes:descAttr];

	//
	// rect
	//
	float vPadding = 5.0;
	float hPadding = 0.0;
	
	float totalHeight = titleSize.height + descSize.height + vPadding;
	
	NSRect textRect = NSMakeRect(insetRect.origin.x + hPadding,
								  insetRect.origin.y + (insetRect.size.height - totalHeight) / 2,
								  insetRect.size.width - hPadding,
								  totalHeight);
	
	NSRect titleRect = NSMakeRect(textRect.origin.x, 
									textRect.origin.y + (textRect.size.height / 2) - titleSize.height - 2,
									textRect.size.width,
									titleSize.height
								);

	NSRect descRect = NSMakeRect(textRect.origin.x,
									textRect.origin.y + (textRect.size.height / 2) + 2,
									textRect.size.width,
									descSize.height
								);
	


	//
	// highlighted
	//
	if([self isHighlighted]){
		[titleAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[descAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}
	else{
		[titleAttr setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		[descAttr setValue:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
	}


	//
	// draw text
	//
	[title drawInRect:titleRect withAttributes:titleAttr];
	[description drawInRect:descRect withAttributes:descAttr];

}
//------------------------------------
// setDownloadStatus
//------------------------------------
- (void)setDownloadStatus:(int)downloadStatus
{
	downloadStatus_ = downloadStatus;
}
- (int)downloadStatus
{
	return downloadStatus_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[super dealloc];
}
@end
