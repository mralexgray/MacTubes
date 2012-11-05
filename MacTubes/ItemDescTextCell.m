#import "ItemDescTextCell.h"
#import "UserDefaultsExtension.h"

@implementation ItemDescTextCell
//------------------------------------
// init
//------------------------------------
- (id)init
{
    if (self = [super init])
	{
		[self setItemStatus:VIDEO_ENTRY_INIT];
    }
    return self;
}

//------------------------------------
// drawInteriorWithFrame
//------------------------------------
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{

	NSRect insetRect = NSInsetRect(cellFrame,0,0);

	int itemStatus = [self itemStatus];

	//
	// ParagraphStyle
	//
	NSMutableParagraphStyle *lineStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[lineStyle setLineBreakMode:NSLineBreakByTruncatingTail];
//	[lineStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];

	//
	// color
	//
	NSColor *titleColor = [NSColor grayColor];
	NSColor *descColor = [NSColor grayColor];

	// success
	if(itemStatus == VIDEO_ENTRY_SUCCESS){
		titleColor = [NSColor blackColor];
	}

	//
	// attribute
	//
	// title
	float fontSize = [self defaultFloatValue:@"optFontSizeList"];
	float titleFontSize = fontSize + 1.0;
	NSMutableDictionary *titleAttr = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 titleColor, NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:titleFontSize], NSFontAttributeName,
											 lineStyle, NSParagraphStyleAttributeName,
											 nil
										] autorelease];
											
	// desc1
	float descFontSize = fontSize - 0.5;
	NSMutableDictionary *descAttr = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
												descColor, NSForegroundColorAttributeName,
												[NSFont systemFontOfSize:descFontSize], NSFontAttributeName,
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
	
	NSString *desc1 = @"";
	NSString *desc2 = @"";

	//
	// desc1
	//
	if(itemStatus == VIDEO_ENTRY_SUCCESS){
		if([values count] >= 1){
			desc1 = [values objectAtIndex:1];
		}
		//
		// desc2
		//
		if([values count] >= 2){
			desc2 = [values objectAtIndex:2];
		}
	}
	else if(itemStatus == VIDEO_ENTRY_INIT){
		desc1 = @"Now Searching..";
	}
	else{
		desc1 = @"Not Found";
	}

	NSSize desc1Size = [desc1 sizeWithAttributes:descAttr];
	NSSize desc2Size = [desc2 sizeWithAttributes:descAttr];

	//
	// rect
	//
	float vPadding = 5.0;
	float hPadding = 2.0;
	
//	float totalHeight = titleSize.height + desc1Size.height + vPadding;
	
	NSRect textRect = NSMakeRect(insetRect.origin.x + hPadding,
//								  insetRect.origin.y + (insetRect.size.height - totalHeight) / 2,
								  insetRect.origin.y,
								  insetRect.size.width - hPadding,
//								  totalHeight
								  insetRect.size.height
								);
	
	NSRect titleRect = NSMakeRect(textRect.origin.x, 
//									textRect.origin.y + (textRect.size.height / 2) - titleSize.height - 2,
									textRect.origin.y,
									textRect.size.width,
									titleSize.height
								);

	NSRect desc1Rect = NSMakeRect(textRect.origin.x,
//									textRect.origin.y + (textRect.size.height / 2) + 2,
									textRect.origin.y + titleRect.size.height + vPadding,
									textRect.size.width,
									desc1Size.height
								);
	NSRect desc2Rect = NSMakeRect(textRect.origin.x,
//									textRect.origin.y + (textRect.size.height / 2) + 2,
									desc1Rect.origin.y + desc1Rect.size.height + 2,
									textRect.size.width,
									desc2Size.height
								);
	


	//
	// highlighted
	//
	if([self isHighlighted]){
		[titleAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[descAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}

	//
	// draw text
	//
	float total1Height = titleRect.size.height + desc1Rect.size.height + vPadding;
	float total2Height = titleRect.size.height + desc1Rect.size.height + vPadding + desc2Rect.size.height;

	[title drawInRect:titleRect withAttributes:titleAttr];

	if(total1Height <= textRect.size.height){
		[desc1 drawInRect:desc1Rect withAttributes:descAttr];
	}
	if(total2Height <= textRect.size.height){
		[desc2 drawInRect:desc2Rect withAttributes:descAttr];
	}
}
//------------------------------------
// itemStatus
//------------------------------------
- (void)setItemStatus:(int)itemStatus
{
	itemStatus_ = itemStatus;
}
- (int)itemStatus
{
	return itemStatus_;
}

//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[super dealloc];
}
@end
