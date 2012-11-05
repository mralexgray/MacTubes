#import "ControlSlider.h"
#import "ControlSliderCell.h"

static NSString *defaultKeyName = @"optPlayVolume";

@implementation ControlSlider

//=======================================================================
// awakeFromNib
//=======================================================================
- (void)awakeFromNib
{
	// add observer
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults addObserver:self forKeyPath:defaultKeyName options:0 context:nil];
}
//=======================================================================
// method
//=======================================================================
//------------------------------------
// cellClass
//------------------------------------
+ (Class)cellClass
{
	return [ControlSliderCell class];
}

//------------------------------------
// initWithCoder
//------------------------------------
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
//------------------------------------
// mouseDown
//------------------------------------
- (void)mouseDown:(NSEvent *)event
{
	// for transparent window mouseDown
	if([self isEnabled] == YES){
		[super mouseDown:event];
	}else{
		[[self window] mouseDown:event];
	}
}
//------------------------------------
// mouseDragged
//------------------------------------
- (void)mouseDragged:(NSEvent *)event
{
	// for transparent window mouseDragged
	if([self isEnabled] == YES){
		[super mouseDragged:event];
	}else{
		[[self window] mouseDragged:event];
	}
}
//------------------------------------
// observeValueForKeyPath
//------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:defaultKeyName]){
		if([self tag] == 1){
			[self setNeedsDisplay:YES];
		}
	}
}
//------------------------------------
// dealloc
//------------------------------------
- (void)dealloc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObserver:self forKeyPath:defaultKeyName];
	[super dealloc];
}
@end
