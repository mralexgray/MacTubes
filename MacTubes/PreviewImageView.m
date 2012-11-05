#import "PreviewImageView.h"
#import "ViewMainSearch.h"
#import "ConvertExtension.h"
#import "CellAttributeExtension.h"

@implementation PreviewImageView

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
// drawRect
//------------------------------------
- (void)drawRect:(NSRect)rect
{

	// draw background
	[[NSColor blackColor] set];
	NSRectFill([self bounds]);

    NSPoint	imagePoint;
    imagePoint.x = [self bounds].origin.x;
    imagePoint.y = [self bounds].origin.y;

//	BOOL isPlayed = [self isPlayed];
	int formatMapNo = [self formatMapNo];

    // draw image
    if([self image]){

		NSImage *image = [[self image] copy];
 
		// set image size
		[image setSize:[self setCellImageSize:[image size]
									frameSize:[self bounds].size
									paddingSize:NSMakeSize(2,2)
						]
		];
		[image setScalesWhenResized:YES];

		// set image rect
		NSRect imageRect = [self setCellImageRect:[image size]
										frameRect:[self bounds]
							];

		imagePoint.x += imageRect.origin.x;
		imagePoint.y += imageRect.origin.y;

		// set image round rect

		NSRect imageRoundRect = [self setCellImageRoundRect:[image size]
													frameRect:[self bounds]
								];

		// draw shadow rect
/*
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
		if(isPlayed == YES){
			NSPoint iconPoint;
			NSImage *iconImage = [[NSImage imageNamed:@"icon_video"] copy];
			[iconImage setSize:NSMakeSize(28,28)];
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
			imageBounds.origin.x = rect.origin.x + imageRect.origin.x;
			imageBounds.origin.y = rect.origin.y + imageRect.origin.y;
//			if([controlView isFlipped]) {
//				imageBounds.origin.y += (imageRect.size.height - imageRect.origin.y);
//			}
			imageBounds.size = imageRect.size;

			// draw label
			NSString *formatTitle = [self convertToFormatMapNoTitle:formatMapNo];
			if(![formatTitle isEqualToString:@""]){
				NSSize stringSize = [formatTitle sizeWithAttributes:nil];
				if( imageBounds.size.width > stringSize.width + 6 &&
					imageBounds.size.height > stringSize.height + 4
				){
					[self drawLabelAndString:imageBounds
									withString:formatTitle
									fontSize:LABEL_FORMAT_FSIZE
									fontColor:[NSColor whiteColor]
									labelColor:[self convertToFormatMapNoLabelColor:formatMapNo]
									align:CELL_ALIGN_RIGHT
									valign:CELL_VALIGN_BOTTOM
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
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)event
{
	// double clicked
	if([event type] == NSLeftMouseDown){
		if([event clickCount] == 2){
			[viewMainSearch playItem:nil];
		}
	}
}
//------------------------------------
// scrollWheel
//------------------------------------
- (void)scrollWheel:(NSEvent *)theEvent
{
	int wheelDelta;

	wheelDelta = [theEvent deltaY];

	if(wheelDelta <= 0){
		[searchlistArrayController selectNext:nil];
	}else{
		[searchlistArrayController selectPrevious:nil];
	}
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
    [super dealloc];
}

@end
