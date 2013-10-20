
#import <QuartzCore/QuartzCore.h>
#import "SDIconView.h"
#import "UIColor+SDColor.h"

CGFloat const kGTIconButtonLineWidth = 3.0;

@implementation SDIconView {
    CGMutablePathRef _path;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _path = nil;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{    
    if (_path == nil) {
        _path = CGPathCreateMutable();
        [self buildIconPath:_path forSize:self.frame.size];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect(c, rect);
    CGContextSaveGState(c);
    CGContextSetLineWidth(c, kGTIconButtonLineWidth);
    CGContextSetStrokeColorWithColor(c, [UIColor navIconColor].CGColor);
    CGContextAddPath(c, _path);
    CGContextStrokePath(c);
    CGContextRestoreGState(c);
}

- (void)buildIconPath:(CGMutablePathRef)path forSize:(CGSize)size
{
    NSAssert(NO, @"Abstract method requires implementation");
}

@end
