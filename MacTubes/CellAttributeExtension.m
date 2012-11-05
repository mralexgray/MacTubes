#import "CellAttributeExtension.h"

@implementation NSObject(cellAttributeExtension_)

//------------------------------------
// setCellImageSize
//------------------------------------
- (NSSize)setCellImageSize:(NSSize)imageSize
					frameSize:(NSSize)frameSize
					paddingSize:(NSSize)paddingSize
{

	float imageWidth = imageSize.width;
	float imageHeight = imageSize.height;

	if(imageWidth < 1){imageWidth = 1;}
	if(imageHeight < 1){imageHeight = 1;}

	float frameWidth = frameSize.width - (paddingSize.width * 2);
	float frameHeight = frameSize.height - (paddingSize.height * 2);
	if(frameWidth < 1){frameWidth = 1;}
	if(frameHeight < 1){frameHeight = 1;}

	float scale = 1.0;

	// image size is smaller than frame size
	if(imageWidth < frameWidth && imageHeight < frameHeight){
		// calc scale horizontal and vertical
		float scaleH = frameWidth / imageWidth;
		float scaleV = frameHeight / imageHeight;
		// set smaller scale
		if(scaleH < scaleV){
			scale = scaleH;
		}else{
			scale = scaleV;
		}
		imageWidth = imageWidth * scale;
		imageHeight = imageHeight * scale;
	}
	else{
		// set image size by horizontal scale
		if(imageWidth > frameWidth){
			scale = frameWidth / imageWidth;
			imageWidth = imageWidth * scale;
			imageHeight = imageHeight * scale;
		}
		// still height is over,  set image size by vertical scale
		if(imageHeight > frameHeight){
			scale = frameHeight / imageHeight;
			imageWidth = imageWidth * scale;
			imageHeight = imageHeight * scale;
		}
	}

	if(imageWidth < 1){imageWidth = 1;}
	if(imageHeight < 1){imageHeight = 1;}

	return NSMakeSize(imageWidth,imageHeight);
}
//------------------------------------
// setCellImageRect
//------------------------------------
- (NSRect)setCellImageRect:(NSSize)size
				frameRect:(NSRect)frameRect
{
	return NSMakeRect(
						floor((frameRect.size.width - size.width) / 2),
						floor((frameRect.size.height - size.height) / 2),
						floor(size.width),
						floor(size.height)
					);
}
//------------------------------------
// setCellImageRoundRect
//------------------------------------
- (NSRect)setCellImageRoundRect:(NSSize)size
						frameRect:(NSRect)frameRect
{
	return NSMakeRect(
						frameRect.origin.x + floor((frameRect.size.width - size.width) / 2),
						frameRect.origin.y + floor((frameRect.size.height - size.height) / 2),
						floor(size.width),
						floor(size.height)
					);
}

//------------------------------------
// drawLabelAndString
//------------------------------------
- (void)drawLabelAndString:(NSRect)rect
				withString:(NSString*)str
				fontSize:(int)fontSize
				fontColor:(NSColor*)fontColor
				labelColor:(NSColor*)labelColor
				align:(int)align
				valign:(int)valign
				hPadding:(int)hPadding
				vPadding:(int)vPadding
				radius:(float)radius
{
	NSMutableDictionary *attr_;
	NSPoint stringOrigin;
	NSSize stringSize;

	attr_ = [[NSMutableDictionary alloc] init];

	[attr_ setObject:[NSFont boldSystemFontOfSize:fontSize] forKey:NSFontAttributeName];
	[attr_ setObject:fontColor forKey:NSForegroundColorAttributeName];

	stringSize = [str sizeWithAttributes:attr_];

	// horizontal align
	if(align == CELL_ALIGN_CENTER){
		stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width) / 2;
	}
	else if(align == CELL_ALIGN_LEFT){
		stringOrigin.x = rect.origin.x + hPadding;
	}
	else if(align == CELL_ALIGN_RIGHT){
		stringOrigin.x = (rect.origin.x + rect.size.width) - stringSize.width - hPadding;
	}
	else{
		stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width) / 2;
	}

	// vertical align
	if(valign == CELL_VALIGN_MIDDLE){
		stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height) / 2;
	}
	else if(valign == CELL_VALIGN_TOP){
		stringOrigin.y = (rect.origin.y + rect.size.height) - stringSize.height - vPadding;
	}
	else if(valign == CELL_VALIGN_BOTTOM){
		stringOrigin.y = rect.origin.y + vPadding;
	}
	else{
		stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height) / 2;
	}

	// draw label
	int bezierWidth = 5;
	NSRect labelRect = NSMakeRect(stringOrigin.x - bezierWidth,
									stringOrigin.y,
									stringSize.width + (bezierWidth * 2),
									stringSize.height
								);

	[labelColor set];
	NSBezierPath *labelBoxPath = [self setRoundPathForRect:labelRect radius:radius];
	[labelBoxPath fill];

	[str drawAtPoint:stringOrigin withAttributes:attr_];
	[attr_ release];
}
//------------------------------------
// setRoundPathForRect
//------------------------------------
- (NSBezierPath *)setRoundPathForRect:(NSRect)rect radius:(float)radius
{
    NSRect inset = NSInsetRect(rect,0,0);
//    float radius = 10;
    
    float minX = NSMinX(inset);
    float midX = NSMidX(inset);
    float maxX = NSMaxX(inset);
    float minY = NSMinY(inset);
    float midY = NSMidY(inset);
    float maxY = NSMaxY(inset);
    
    NSBezierPath *path = [[NSBezierPath alloc] init];
    [path moveToPoint:NSMakePoint(midX, minY)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX,minY) toPoint:NSMakePoint(maxX,midY) radius:radius];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX,maxY) toPoint:NSMakePoint(midX,maxY) radius:radius];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX,maxY) toPoint:NSMakePoint(minX,midY) radius:radius];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX,minY) toPoint:NSMakePoint(midX,minY) radius:radius];
    
    return [path autorelease];
    
}

@end