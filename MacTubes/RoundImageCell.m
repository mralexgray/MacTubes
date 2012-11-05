#import "RoundImageCell.h"
#import "ConvertExtension.h"
#import "CellAttributeExtension.h"

@implementation RoundImageCell
//------------------------------------
// init
//------------------------------------
- (id)init
{
    if (self = [super init])
	{
		[self setIsPlayed:NO];
 		[self setFormatMapNo:VIDEO_FORMAT_MAP_NONE];
   }
    return self;
}
//------------------------------------
// drawInteriorWithFrame
//------------------------------------
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{

    NSPoint	imagePoint;

    imagePoint.x = cellFrame.origin.x;
    imagePoint.y = cellFrame.origin.y;

//	BOOL isPlayed = [self isPlayed];
	int formatMapNo = [self formatMapNo];

    // draw image
    if([self image]){

		NSImage *image = [[self image] copy];

		// set image size
		[image setSize:[self setCellImageSize:[image size]
									frameSize:cellFrame.size
									paddingSize:NSMakeSize(2,2)
						]
		];
		[image setScalesWhenResized:YES];

		// set image rect
		NSRect imageRect = [self setCellImageRect:[image size]
										frameRect:cellFrame
							];

		imagePoint.x += imageRect.origin.x;
		imagePoint.y += imageRect.origin.y;

        if([controlView isFlipped]) {
            imagePoint.y += [image size].height;
        }
		
		// set image round rect
		NSRect imageRoundRect = [self setCellImageRoundRect:[image size]
													frameRect:cellFrame
								];
/*
		// draw shadow rect
		NSRect shadowRect = imageRoundRect;
		shadowRect.origin.x += 5;
		shadowRect.origin.y += 5;
		NSBezierPath *shadowPath = [self setRoundPathForRect:shadowRect radius:5];
		[[NSColor blackColor] set];
		[shadowPath fill];
*/
		// draw image rect
		NSBezierPath *imagePath = [self setRoundPathForRect:imageRoundRect radius:5];
		[NSGraphicsContext saveGraphicsState];

		[imagePath addClip];

		// draw image
		[image compositeToPoint:imagePoint operation:NSCompositeSourceOver];

/*
		// draw iconImage
//		if(isPlayed == YES){
		if( formatMapNo == VIDEO_FORMAT_MAP_HIGH ||
			formatMapNo == VIDEO_FORMAT_MAP_HD ||
			formatMapNo == VIDEO_FORMAT_MAP_HD_720 ||
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
			imageBounds.origin.x = cellFrame.origin.x + imageRect.origin.x;
			imageBounds.origin.y = cellFrame.origin.y + imageRect.origin.y;
//			if([controlView isFlipped]) {
//				imageBounds.origin.y += (imageRect.size.height - imageRect.origin.y);
//			}
			imageBounds.size = imageRect.size;

			// draw label
			NSString *formatTitle = [self convertToFormatMapNoTitle:formatMapNo];
			if(![formatTitle isEqualToString:@""]){
				NSSize stringSize = [formatTitle sizeWithAttributes:nil];
				if( imageBounds.size.width > stringSize.width + 8 &&
					imageBounds.size.height > stringSize.height + 4
				){
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

    }

}
//------------------------------------
// isPlayed
//------------------------------------
- (void)setIsPlayed:(BOOL)isPlayed
{
	isPlayed_ = isPlayed;
}
- (BOOL)isPlayed
{
	return isPlayed_;
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
