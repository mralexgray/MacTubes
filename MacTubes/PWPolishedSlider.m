#import "PWPolishedSlider.h"
#import "PWPolishedSliderCell.h"

@implementation PWPolishedSlider

+ (Class)cellClass
{
	return [PWPolishedSliderCell class];
}

- initWithCoder: (NSCoder *)origCoder
{
	if(![origCoder isKindOfClass: [NSKeyedUnarchiver class]]){
		self = [super initWithCoder: origCoder]; 
	} else {
		NSKeyedUnarchiver *coder = (id)origCoder;
		
		NSString *oldClassName = [[[self superclass] cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
		if(!oldClass)
			oldClass = [[super superclass] cellClass];
		[coder setClass: [[self class] cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
	}

	// delete focus ring
	[self setFocusRingType:NSFocusRingTypeNone];
	
	return self;
}
//------------------------------------
// keyDown
//------------------------------------
- (void)keyDown:(NSEvent *)theEvent
{    

	BOOL isAction = NO;
	NSString *keys = [theEvent charactersIgnoringModifiers];

	if (keys && [keys length] > 0){
		unichar c = [keys characterAtIndex:0];
		if(c == NSUpArrowFunctionKey){
			isAction = YES;
		}
		else if(c == NSDownArrowFunctionKey){
			isAction = YES;
		}
		else if(c == NSLeftArrowFunctionKey){
			isAction = YES;
		}
		else if(c == NSRightArrowFunctionKey){
			isAction = YES;
		}

	}

	if(isAction == NO){
		[super keyDown:theEvent];
	}

}
@end
