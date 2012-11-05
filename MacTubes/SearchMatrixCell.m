#import "SearchMatrixCell.h"
#import "ConvertExtension.h"
#import "UserDefaultsExtension.h"
#import "CellAttributeExtension.h"

static float CELL_PADDING_WIDTH = 6.0;
static float IMAGE_PADDING_HEIGHT = 15;
static float IMAGE_SHADOW_OFFSET = 5;
static float IMAGE_POINT_Y_OFFSET = -13;
static float TEXT_BLANK_HEIGHT = 0.0;
static float TEXT_POINT_Y_OFFSET = -5;

@implementation SearchMatrixCell

//------------------------------------
// init
//------------------------------------
- (id)initWithItemObject:(id)itemObject
				itemIndex:(int)itemIndex
				isEnabled:(BOOL)isEnabled
				formatMapNo:(int)formatMapNo
{
    if (self = [super init])
	{
		[self setItemObject:itemObject];
		[self setItemIndex:itemIndex];
		[self setIsEnabled:isEnabled];
		[self setIsSelected:NO];
 		[self setFormatMapNo:formatMapNo];
   }
    return self;
}

//------------------------------------
// drawInteriorWithFrame
//------------------------------------
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{

	if([self isEnabled] == NO || ![self itemObject]){
		return;
	}

	// innerRect
	float innerSize = [self defaultSearchMatrixCellSize];
	NSRect innerRect;
	innerRect.origin.x = cellFrame.origin.x + ((cellFrame.size.width - innerSize) / 2);
	innerRect.origin.y = cellFrame.origin.y + ((cellFrame.size.height - innerSize) / 2);
	innerRect.size.width = innerSize;
	innerRect.size.height = innerSize;

	id record = [self itemObject];
	int formatMapNo = [self formatMapNo];

    NSString *title = [record valueForKey:@"title"];
    NSString *desc = @"";
	int itemStatus = [[record valueForKey:@"itemStatus"] intValue];

    NSString *playTimeStr = @"";
	if([record valueForKey: @"playTime"]){
		int playTime = [[record valueForKey: @"playTime"] intValue];
		if(playTime > 0){
			playTimeStr = [self convertTimeToString:playTime];
		}
	}
	desc = playTimeStr;

	NSImage *image = nil;
	BOOL hasImage;
	ContentItem *contentItem = [record objectForKey:@"itemObject"]; 
	if(contentItem){
		image = [[contentItem image] copy];
		hasImage = YES;
	}else{
		image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"image_null" ofType:@"png"]];
		hasImage = NO;
	}
/*
	NSImage *image = [self image];
	BOOL hasImage = YES;
	if(!image){
		ContentItem *contentItem = [record objectForKey:@"itemObject"]; 
		if(contentItem){
			image = [[contentItem image] copy];
			hasImage = YES;
		}else{
			image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"image_null" ofType:@"png"]];
			hasImage = NO;
		}
		[self setImage:image];
	}
*/

    NSPoint	imagePoint;
    imagePoint.x = innerRect.origin.x;
    imagePoint.y = innerRect.origin.y;

/*
	//
	// draw highlight
	//
	if([self isSelected] == YES){
		[[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0] set];
		NSBezierPath *selectedBoxPath = [self setRoundPathForRect:innerRect radius:10];
		[selectedBoxPath fill];
	}
*/

	//
	// draw image
	//
    if(image){

		// set image size from original size
		[image setSize:[self setCellImageSize:[image size]
									frameSize:innerRect.size
									paddingSize:NSMakeSize(CELL_PADDING_WIDTH,IMAGE_PADDING_HEIGHT)
						]
		];

		// set image rect
		NSRect imageRect = [self setCellImageRect:[image size]
										frameRect:innerRect
							];

		// shift image rect
		imageRect.origin.y += IMAGE_POINT_Y_OFFSET;

		[image setScalesWhenResized:YES];

		imagePoint.x += imageRect.origin.x;
		imagePoint.y += imageRect.origin.y;

        if([controlView isFlipped]) {
            imagePoint.y += [image size].height;
        }

		// set image round rect
		NSRect imageRoundRect = [self setCellImageRoundRect:[image size]
													frameRect:innerRect
								];

		// shift image round rect
		imageRoundRect.origin.y += IMAGE_POINT_Y_OFFSET;

		if([self isSelected] == YES){
			//
			// draw highlight
			//
			NSRect highlightRect = imageRoundRect;
			highlightRect.origin.x -= IMAGE_SHADOW_OFFSET;
			highlightRect.origin.y -= IMAGE_SHADOW_OFFSET;
			highlightRect.size.width += (IMAGE_SHADOW_OFFSET * 2);
			highlightRect.size.height += (IMAGE_SHADOW_OFFSET * 2);

//			[[NSColor colorWithCalibratedRed:0.1 green:0.1 blue:1.0 alpha:1.0] set];
			[[NSColor blueColor] set];
			NSBezierPath *selectedBoxPath = [self setRoundPathForRect:highlightRect radius:10];
			[selectedBoxPath fill];
		}else{
			//
			// draw shadow rect
			//
			if(hasImage == YES){
				NSRect shadowRect = imageRoundRect;
				shadowRect.origin.x += IMAGE_SHADOW_OFFSET;
				shadowRect.origin.y += IMAGE_SHADOW_OFFSET;
				NSBezierPath *shadowPath = [self setRoundPathForRect:shadowRect radius:5];
				[[NSColor blackColor] set];
				[shadowPath fill];
			}
		}

		// draw image rect
		NSBezierPath *imagePath = [self setRoundPathForRect:imageRoundRect radius:5];
		[NSGraphicsContext saveGraphicsState];

		[imagePath addClip];

		// draw image
		[image compositeToPoint:imagePoint operation:NSCompositeSourceOver];

/*
		//
		// draw iconImage
		//
		if( formatMapNo == VIDEO_FORMAT_MAP_HIGH ||
			formatMapNo == VIDEO_FORMAT_MAP_HD ||
			formatMapNo == VIDEO_FORMAT_MAP_HD_1080
		){
			NSPoint iconPoint;
			NSImage *iconImage = [[NSImage imageNamed:@"icon_video"] copy];
			[iconImage setScalesWhenResized:YES];
			iconPoint.x = imagePoint.x + imageRect.size.width - [iconImage size].width - 3;
			iconPoint.y = imagePoint.y - 2;
			[iconImage compositeToPoint:iconPoint operation:NSCompositeSourceOver];
			[iconImage release];
		}
*/
		[NSGraphicsContext restoreGraphicsState];


		//
		// draw label
		//
		if( formatMapNo == VIDEO_FORMAT_MAP_HD ||
			formatMapNo == VIDEO_FORMAT_MAP_HD_1080
		){
			// now origin.y is buggy
			NSRect imageBounds;
			imageBounds.origin.x = innerRect.origin.x + imageRect.origin.x;
			imageBounds.origin.y = innerRect.origin.y + imageRect.origin.y;
//			if([controlView isFlipped]) {
//				imageBounds.origin.y += (imageRect.size.height - imageRect.origin.y);
//			}
			imageBounds.size = imageRect.size;

			// draw label
			NSString *formatTitle = [self convertToFormatMapNoTitle:formatMapNo];
			if(![formatTitle isEqualToString:@""]){
				[self drawLabelAndString:imageBounds
								withString:formatTitle
								fontSize:LABEL_FORMAT_FSIZE
								fontColor:[NSColor whiteColor]
								labelColor:[self convertToFormatMapNoLabelColor:formatMapNo]
								align:CELL_ALIGN_RIGHT
								valign:CELL_VALIGN_TOP
								hPadding:LABEL_FORMAT_HPADDING
								vPadding:LABEL_FORMAT_VPADDING
								radius:LABEL_FORMAT_RADIUS
				];
			}
		}

	}

	[image release];

	//
	// draw text
	//
//	if(title){

		NSMutableParagraphStyle *lineStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[lineStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
		[lineStyle setAlignment:NSCenterTextAlignment];

		// color
		NSColor *titleColor = [NSColor whiteColor];
		NSColor *descColor = [NSColor colorWithCalibratedWhite:0.7 alpha:1.0];
		// not success
		if(itemStatus != VIDEO_ENTRY_SUCCESS){
			titleColor = [NSColor grayColor];
		}

		// attributes
		NSDictionary *titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont systemFontOfSize:11.5], NSFontAttributeName,
										titleColor, NSForegroundColorAttributeName,
										lineStyle, NSParagraphStyleAttributeName,
										nil
									];

		NSDictionary *descAttr = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont systemFontOfSize:10.5], NSFontAttributeName,
										descColor, NSForegroundColorAttributeName,
										lineStyle, NSParagraphStyleAttributeName,
										nil
									];

		// size
		NSSize titleSize = [title sizeWithAttributes:titleAttr];
		NSSize descSize = [desc sizeWithAttributes:descAttr];

		// text rect
		float textHeight;
		NSPoint textPoint;
		textPoint.x = innerRect.origin.x + CELL_PADDING_WIDTH;
		if(image){
			textHeight = innerRect.origin.y + innerRect.size.height - imagePoint.y + TEXT_POINT_Y_OFFSET;
			textPoint.y = imagePoint.y - TEXT_POINT_Y_OFFSET;
		}else{
			textHeight = titleSize.height + TEXT_BLANK_HEIGHT + descSize.height;
			textPoint.y = innerRect.origin.y + innerRect.size.height - textHeight;
		}

		// rect
		NSRect textRect = NSMakeRect(textPoint.x,
										textPoint.y,
//										innerRect.origin.y + (innerRect.size.height - textHeight) - TEXT_POINT_Y_OFFSET,
//										innerRect.origin.y + (innerRect.size.height - textHeight),
										innerRect.size.width - (CELL_PADDING_WIDTH * 2),
										textHeight
									);

		NSRect titleRect = NSMakeRect(textRect.origin.x, 
										textRect.origin.y,
										textRect.size.width,
										titleSize.height
									);

		NSRect descRect = NSMakeRect(textRect.origin.x,
										textRect.origin.y + titleRect.size.height + TEXT_BLANK_HEIGHT,
										textRect.size.width,
										descSize.height
									);

		float total1Height = titleRect.size.height;
		float total2Height = titleRect.size.height + (descRect.size.height / 2) + TEXT_BLANK_HEIGHT;

		if(total1Height <= textRect.size.height){
			[title drawInRect:titleRect withAttributes:titleAttr];
		}
		if(total2Height <= textRect.size.height){
			[desc drawInRect:descRect withAttributes:descAttr];
		}

//	}


}
//------------------------------------
// itemObject
//------------------------------------
- (void)setItemObject:(id)itemObject
{
    itemObject_ = itemObject;
}
- (id)itemObject
{
    return itemObject_;
}
//------------------------------------
// itemIndex
//------------------------------------
- (void)setItemIndex:(int)itemIndex
{
    itemIndex_ = itemIndex;
}
- (int)itemIndex
{
    return itemIndex_;
}
//------------------------------------
// isEnabled
//------------------------------------
- (void)setImageSize:(NSSize)imageSize
{
    imageSize_ = imageSize;
}
- (NSSize)imageSize
{
    return imageSize_;
}
//------------------------------------
// isEnabled
//------------------------------------
- (void)setIsEnabled:(BOOL)isEnabled
{
	isEnabled_ = isEnabled;
}
- (BOOL)isEnabled
{
	return isEnabled_;
}
//------------------------------------
// isSelected
//------------------------------------
- (void)setIsSelected:(BOOL)isSelected
{
	isSelected_ = isSelected;
}
- (BOOL)isSelected
{
	return isSelected_;
}
//------------------------------------
// formatMapNo
//------------------------------------
- (void)setFormatMapNo:(int)formatMapNo
{
	formatMapNo_ = formatMapNo;
}
- (int)formatMapNo
{
	return formatMapNo_;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{	
    [super dealloc];
}

@end
