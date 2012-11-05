#import "BoolReverseTransformer.h"

@implementation BoolReverseTransformer

+ (void)load
{
	[self setValueTransformer:[[BoolReverseTransformer alloc] init] forName:@"BoolReverseTransformer"];

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
	if(object == nil) return [NSNumber numberWithBool:NO];

	if([object boolValue] == YES){
		return [NSNumber numberWithBool:NO];
	}else{
		return [NSNumber numberWithBool:YES];
	}

}
@end