
#import <QuartzCore/QuartzCore.h>
#import "SDComposeIconView.h"

@implementation SDComposeIconView

- (void)buildIconPath:(CGMutablePathRef)path forSize:(CGSize)size
{
    CGPathMoveToPoint(path, NULL, 0, size.height / 2.0);
    CGPathAddLineToPoint(path, NULL, size.width, size.height / 2.0);
    CGPathMoveToPoint(path, NULL, size.width / 2.0, 0);
    CGPathAddLineToPoint(path, NULL, size.width / 2.0, size.height);
}

@end
