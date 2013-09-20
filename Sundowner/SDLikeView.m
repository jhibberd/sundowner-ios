
#import <QuartzCore/QuartzCore.h>
#import "SDLikeView.h"
#import "UIColor+SDColor.h"

@implementation SDLikeView {
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
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        // https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Canvas_tutorial/Drawing_shapes
        CGPathMoveToPoint(_path, NULL, 0.5*w, 0.158*h);
        CGPathAddCurveToPoint(_path, NULL, 0.5*w, 0.126*h, 0.455*w, 0, 0.273*w, 0);
        CGPathAddCurveToPoint(_path, NULL, 0, 0, 0, 0.395*h, 0, 0.395*h);
        CGPathAddCurveToPoint(_path, NULL, 0, 0.579*h, 0.182*w, 0.811*h, 0.5*w, 1*h);
        CGPathAddCurveToPoint(_path, NULL, 0.818*w, 0.811*h, 1*w, 0.579*h, 1*w, 0.395*h);
        CGPathAddCurveToPoint(_path, NULL, 1*w, 0.395*h, 1*w, 0, 0.727*w, 0);
        CGPathAddCurveToPoint(_path, NULL, 0.591*w, 0, 0.5*w, 0.126*h, 0.5*w, 0.158*h);
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect(c, rect);
    CGContextSaveGState(c);
    CGContextSetFillColorWithColor(c, [UIColor likeColor].CGColor);
    CGContextAddPath(c, _path);
    CGContextFillPath(c);
    CGContextRestoreGState(c);
}

@end
