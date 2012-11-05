//
//  ImageAndTextCell.h
//
//  Copyright (c) 2001-2002, Apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImageAndTextCell : NSTextFieldCell {
@private
    NSImage	*image;
	int labelColorNo_;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;
- (void)setLabelColorNo:(int)labelColorNo;
- (int)labelColorNo;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end