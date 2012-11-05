#import "BoolPlayerTypeVideoTransformer.h"

@implementation BoolPlayerTypeVideoTransformer

+ (void)load
{
	[self setValueTransformer:[[BoolPlayerTypeVideoTransformer alloc] init] forName:@"BoolPlayerTypeVideoTransformer"];

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

	if(playerType == VIDEO_PLAYER_TYPE_VIDEO || playerType == VIDEO_PLAYER_TYPE_QUICKTIME){
		enabled = YES;
	}
	return [NSNumber numberWithBool:enabled];

}
@end