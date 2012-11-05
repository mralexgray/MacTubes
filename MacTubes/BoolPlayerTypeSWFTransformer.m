#import "BoolPlayerTypeSWFTransformer.h"

@implementation BoolPlayerTypeSWFTransformer

+ (void)load
{
	[self setValueTransformer:[[BoolPlayerTypeSWFTransformer alloc] init] forName:@"BoolPlayerTypeSWFTransformer"];

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

	int playerType = [object intValue];
	BOOL enabled = NO;

	if(playerType == VIDEO_PLAYER_TYPE_SWF){
		enabled = YES;
	}
	return [NSNumber numberWithBool:enabled];

}
@end