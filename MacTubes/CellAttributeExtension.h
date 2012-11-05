/* CellAttributeExtension */

#import <Cocoa/Cocoa.h>
#import "CellAttributes.h"
#import "LabelAttributes.h"

@interface NSObject(cellAttributeExtension_)
	
- (NSSize)setCellImageSize:(NSSize)imageSize
					frameSize:(NSSize)frameSize
					paddingSize:(NSSize)paddingSize;

- (NSRect)setCellImageRect:(NSSize)size
				frameRect:(NSRect)frameRect;

- (NSRect)setCellImageRoundRect:(NSSize)size
						frameRect:(NSRect)frameRect;

- (void)drawLabelAndString:(NSRect)rect
				withString:(NSString*)str
				fontSize:(int)fontSize
				fontColor:(NSColor*)fontColor
				labelColor:(NSColor*)labelColor
				align:(int)align
				valign:(int)valign
				hPadding:(int)hPadding
				vPadding:(int)vPadding
				radius:(float)radius;

- (NSBezierPath *)setRoundPathForRect:(NSRect)rect radius:(float)radius;

@end
