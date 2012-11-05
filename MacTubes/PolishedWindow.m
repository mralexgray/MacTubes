//
//	PolishedWindow.m
//	TunesWindow
//
//	Created by Matt Gemmell on 12/02/2006.
//	Copyright 2006 Magic Aubergine. All rights reserved.
//  Customized MacTubes 2008
//

#import "PolishedWindow.h"
#import "UserDefaultsExtension.h"

@implementation PolishedWindow

//=======================================================================
// awake App
//=======================================================================
- (void)awakeFromNib
{

}

- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(unsigned int)styleMask 
				  backing:(NSBackingStoreType)bufferingType 
					defer:(BOOL)flag
{
	return [self initWithContentRect:contentRect 
						   styleMask:styleMask 
							 backing:bufferingType 
							   defer:flag 
								flat:NO];
}

- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(unsigned int)styleMask 
				  backing:(NSBackingStoreType)bufferingType 
					defer:(BOOL)flag 
					 flat:(BOOL)flat 
{
	// Conditionally add textured window flag to stylemask
	unsigned int newStyle;
	if (styleMask & NSTexturedBackgroundWindowMask){
		newStyle = styleMask;
	} else {
		newStyle = (NSTexturedBackgroundWindowMask | styleMask);
	}
	
	if (self = [super initWithContentRect:contentRect 
								styleMask:newStyle 
								  backing:bufferingType 
									defer:flag]) {
		
		_flat = NO;
		forceDisplay = NO;
		
		[self setWindowBGImage];
		[self setWindowBGColor];
		[self setWindowBGPatternColor];

		[self setBackgroundColor:[self sizedPolishedBackground]];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(windowDidResize:) 
													 name:NSWindowDidResizeNotification 
												   object:self];
		
		return self;
	}
	
	return nil;
}
//------------------------------------
// changeWindowTheme
//------------------------------------
- (IBAction)changeWindowTheme:(id)sender
{
	[self setWindowBGImage];
	[self setWindowBGColor];
	[self setWindowBGPatternColor];

	[self setBackgroundColor:[self sizedPolishedBackground]];
	[self display];
}

/*
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
- (void)setToolbar:(NSToolbar *)toolbar
{
	// Only actually call this if we respond to it on this machine
	if ([toolbar respondsToSelector:@selector(setShowsBaselineSeparator:)]) {
		[toolbar setShowsBaselineSeparator:NO];
	}
	
	[super setToolbar:toolbar];
}
#endif
*/
//------------------------------------
// windowDidResize
//------------------------------------
- (void)windowDidResize:(NSNotification *)aNotification
{

	[self setBackgroundColor:[self sizedPolishedBackground]];
	if (forceDisplay) {
		[self display];
	}

}
//------------------------------------
// setMinSize
//------------------------------------
- (void)setMinSize:(NSSize)aSize
{
	[super setMinSize:NSMakeSize(MAX(aSize.width, 150.0), MAX(aSize.height, 150.0))];
}
//------------------------------------
// setFrame
//------------------------------------
- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag
{
	forceDisplay = YES;
	[super setFrame:frameRect display:displayFlag animate:animationFlag];
	forceDisplay = NO;
}

//------------------------------------
// sizedPolishedBackground
//------------------------------------
- (NSColor *)sizedPolishedBackground
{

	NSImage *bgImage = [self bgImage];

	// no image
	if(bgImage == nil){
		return nil;
	}

	NSImage *bgFrameImage = [[NSImage alloc] initWithSize:[self frame].size];
//	NSColor *bgPatternColor = [NSColor colorWithPatternImage:bgImage];

	// Set min width of temporary pattern image to prevent flickering at small widths
	float minWidth = 300.0;
	
	// Create temporary image
	NSImage *bgPatternImage = [[NSImage alloc] initWithSize:NSMakeSize(MAX(minWidth, [self frame].size.width), [bgImage size].height)];
//	NSImage *bgPatternImage = [[NSImage alloc] initWithSize:NSMakeSize([self frame].size.width, [bgImage size].height)];

	[bgPatternImage lockFocus];
	[[self bgPatternColor] set];
	NSRectFill(NSMakeRect(0, 0, [bgPatternImage size].width, [bgPatternImage size].height));
	[bgPatternImage unlockFocus];

	// Begin drawing into our main image
	[bgFrameImage lockFocus];
	
	// Composite current background color into bgFrameImage
	[[self bgColor] set];
	NSRectFill(NSMakeRect(0, 0, [bgFrameImage size].width, [bgFrameImage size].height));

	[bgPatternImage drawInRect:NSMakeRect(0, [bgFrameImage size].height - [bgImage size].height, 
										[bgFrameImage size].width, 
										[bgImage size].height) 
					fromRect:NSMakeRect(0, 0, 
										[bgFrameImage size].width, 
										[bgImage size].height) 
					operation:NSCompositeSourceOver 
					fraction:1.0];

	[bgPatternImage release];
	
	[bgFrameImage unlockFocus];
	
	return [NSColor colorWithPatternImage:[bgFrameImage autorelease]];
}
//------------------------------------
// setWindowBGImage
//------------------------------------
- (void)setWindowBGImage
{

	int windowThemeNo = [self defaultIntValue:@"optWindowThemeNo"];
	NSImage *bgImage = nil;

	if(windowThemeNo == 1){
		bgImage = [NSImage imageNamed:@"gray_top"];
	}
	else if(windowThemeNo == 2){
		bgImage = [NSImage imageNamed:@"black_top"];
	}
	else if(windowThemeNo == 3){
		bgImage = [NSImage imageNamed:@"white_top"];
	}

	[self setBGImage:bgImage];

}
//------------------------------------
// setWindowBGColor
//------------------------------------
- (void)setWindowBGColor
{

	NSImage *bgImage = [self bgImage];

	NSColor *bgColor = nil;

	if(bgImage != nil){
		[bgImage lockFocus];
		bgColor = NSReadPixel(NSMakePoint(0, 0));
		[bgImage unlockFocus];
	}

	[self setBGColor:bgColor];

}
//------------------------------------
// setWindowBGPatternColor
//------------------------------------
- (void)setWindowBGPatternColor
{

	NSImage *bgImage = [self bgImage];

	NSColor *bgPatternColor = nil;

	if(bgImage != nil){
		bgPatternColor = [NSColor colorWithPatternImage:bgImage];
	}

	[self setBGPatternColor:bgPatternColor];

}
//------------------------------------
// bgImage
//------------------------------------
- (void)setBGImage:(NSImage *)bgImage
{
	[bgImage retain];
	[bgImage_ release];
	bgImage_ = bgImage;
}

- (NSImage *)bgImage
{
    return bgImage_;
}
//------------------------------------
// bgColor
//------------------------------------
- (void)setBGColor:(NSColor *)bgColor
{
	[bgColor retain];
	[bgColor_ release];
	bgColor_ = bgColor;
}

- (NSColor *)bgColor
{
    return bgColor_;
}
//------------------------------------
// bgPatternColor
//------------------------------------
- (void)setBGPatternColor:(NSColor *)bgPatternColor
{
	[bgPatternColor retain];
	[bgPatternColor_ release];
	bgPatternColor_ = bgPatternColor;
}

- (NSColor *)bgPatternColor
{
    return bgPatternColor_;
}
//------------------------------------
// flat
//------------------------------------
- (BOOL)flat
{
	return _flat;
}

- (void)setFlat:(BOOL)newFlat
{
	_flat = newFlat;
	forceDisplay = YES;
	[self windowDidResize:nil];
	forceDisplay = NO;
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self];
	[bgImage_ release];
	[bgColor_ release];
	[bgPatternColor_ release];
	[super dealloc];
}

@end
