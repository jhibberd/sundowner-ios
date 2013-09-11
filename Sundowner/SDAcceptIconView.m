
#import <QuartzCore/QuartzCore.h>
#import "SDAcceptIconView.h"

static CGFloat const GTLineWidth = 3.0;

@implementation SDAcceptIconView

- (void)buildIconPath:(CGMutablePathRef)path forSize:(CGSize)size
{
    // intent points that fall on the edge by half a line width to ensure none of the stroke
    // falls outside the frame
    CGFloat halfLineWidth = kGTIconButtonLineWidth / 2.0;
    CGPathMoveToPoint(path, NULL, 0+halfLineWidth, size.height / 2.0);
    CGPathAddLineToPoint(path, NULL, size.width / 3.0, size.height - halfLineWidth);
    CGPathAddLineToPoint(path, NULL, size.width - halfLineWidth, halfLineWidth);
}

@end
