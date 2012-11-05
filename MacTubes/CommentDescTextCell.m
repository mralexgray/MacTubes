#import "CommentDescTextCell.h"
#import "UserDefaultsExtension.h"

@implementation CommentDescTextCell
//------------------------------------
// init
//------------------------------------
- (id)init
{
    if (self = [super init])
	{
//		[self setTextAreaSize:[self cellSize]];
    }
    return self;
}

//------------------------------------
// drawInteriorWithFrame
//------------------------------------
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{

	NSRect insetRect = NSInsetRect(cellFrame,0,0);

	//
	// ParagraphStyle
	//
	NSMutableParagraphStyle *lineStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[lineStyle setLineBreakMode:NSLineBreakByWordWrapping];
//	[lineStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];

	//
	// color
	//
	NSColor *nameColor = [NSColor grayColor];
	NSColor *dateColor = [NSColor grayColor];
	NSColor *descColor = [NSColor blackColor];

	//
	// attribute
	//
	// name
	float fontSize = [self defaultFloatValue:@"optFontSizeList"];
	float nameFontSize = fontSize - 0.5;
	NSMutableDictionary *nameAttr = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 nameColor, NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:nameFontSize], NSFontAttributeName,
											 lineStyle, NSParagraphStyleAttributeName,
											 nil
										] autorelease];
											
	// date
	float dateFontSize = fontSize - 0.5;
	NSMutableDictionary *dateAttr = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 dateColor, NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:dateFontSize], NSFontAttributeName,
											 lineStyle, NSParagraphStyleAttributeName,
											 nil
										] autorelease];
											
	// desc1
	float descFontSize = fontSize;
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
	NSString *name = @"";
	NSString *date = @"";
	NSString *desc1 = @"";
	if([values count] >= 1){
		name = [values objectAtIndex:0];
		date = [values objectAtIndex:1];
		desc1 = [values objectAtIndex:2];
	}
	NSSize nameSize = [name sizeWithAttributes:nameAttr];
	NSSize dateSize = [date sizeWithAttributes:dateAttr];
//	NSSize desc1Size = [desc1 sizeWithAttributes:descAttr];
//	NSLog(@"desc1Size=%.2f, %.2f", desc1Size.width, desc1Size.height);
	//
	// rect
	//
	float vPadding = 5.0;
	float hPadding = 2.0;
	float tPadding = 10.0;
	
//	float totalHeight = nameSize.height + desc1Size.height + vPadding;
	
	NSRect textRect = NSMakeRect(insetRect.origin.x + hPadding,
								  insetRect.origin.y,
								  insetRect.size.width - hPadding,
								  insetRect.size.height
								);
	
	NSRect nameRect = NSMakeRect(textRect.origin.x, 
									textRect.origin.y,
									nameSize.width,
									nameSize.height
								);
	NSRect dateRect = NSMakeRect(textRect.origin.x + nameRect.size.width + tPadding, 
									textRect.origin.y,
									dateSize.width,
									dateSize.height
								);

	NSRect desc1Rect = NSMakeRect(textRect.origin.x,
									textRect.origin.y + nameRect.size.height + vPadding,
									textRect.size.width,
									textRect.size.height - (nameRect.size.height + vPadding)
//									desc1Size.height
								);
	


	//
	// highlighted
	//
	if([self isHighlighted]){
		[nameAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[dateAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[descAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}

	//
	// draw text
	//
	float total1Width = nameRect.size.width + dateRect.size.width + tPadding + hPadding;
	float total1Height = nameRect.size.height + desc1Rect.size.height + vPadding;
//	[self setTextAreaSize:NSMakeSize(total1Width, total1Height)];

	[name drawInRect:nameRect withAttributes:nameAttr];

	if(total1Width <= textRect.size.width){
		[date drawInRect:dateRect withAttributes:dateAttr];
	}
	if(total1Height <= textRect.size.height){
		[desc1 drawInRect:desc1Rect withAttributes:descAttr];
	}
}
/*
//------------------------------------
// textAreaSize
//------------------------------------
- (void)setTextAreaSize:(NSSize)textAreaSize
{
	textAreaSize_ = textAreaSize;
}
- (NSSize)textAreaSize
{
	return textAreaSize_;
}
*/
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[super dealloc];
}
@end
