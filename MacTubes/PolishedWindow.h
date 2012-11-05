//
//	PolishedWindow.h
//	TunesWindow
//
//	Created by Matt Gemmell on 12/02/2006.
//	Copyright 2006 Magic Aubergine. All rights reserved.
//  Customized MacTubes 2008
//

#import <Cocoa/Cocoa.h>

@interface PolishedWindow : NSWindow {

	NSImage *bgImage_;
	NSColor *bgColor_;
	NSColor *bgPatternColor_;
	BOOL _flat;
	BOOL forceDisplay;
}

- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(unsigned int)styleMask 
				  backing:(NSBackingStoreType)bufferingType 
					defer:(BOOL)flag 
					 flat:(BOOL)flat;

- (IBAction)changeWindowTheme:(id)sender;

- (NSColor *)sizedPolishedBackground;
- (void)setWindowBGImage;
- (void)setWindowBGColor;
- (void)setWindowBGPatternColor;

- (void)setBGImage:(NSImage *)bgImage;
- (NSImage *)bgImage;
- (void)setBGColor:(NSColor *)bgColor;
- (NSColor *)bgColor;
- (void)setBGPatternColor:(NSColor *)bgPatternColor;
- (NSColor *)bgPatternColor;

- (BOOL)flat;
- (void)setFlat:(BOOL)newFlat;

@end
