#import "BoolSingleSelectionTransformer.h"

@implementation BoolSingleSelectionTransformer

+ (void)load
{
	[self setValueTransformer:[[BoolSingleSelectionTransformer alloc] init] forName:@"BoolSingleSelectionTransformer"];

}

+ (Class)transformedValueClass
{
    return [NSString self];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)object
{
	if(object == nil) return NO;

	if([object count] == 1){
		return [NSNumber numberWithBool:YES];
	}else{
		return [NSNumber numberWithBool:NO];
	}

}
@end