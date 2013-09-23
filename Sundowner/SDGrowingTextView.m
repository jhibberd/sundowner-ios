
#import "SDGrowingTextView.h"
#import "SDGrowingTextViewDelegate.h"

@implementation SDGrowingTextView {
    id<SDGrowingTextViewDelegate> _externalDelegate;
}

- (id)initWithWidth:(CGFloat)width
             origin:(CGPoint)origin
           delegate:(id<SDGrowingTextViewDelegate>)delegate
{
    _externalDelegate = delegate; // different to inherited internal delegate
    
    // height will be determined dynamically based on the content
    return [self initWithFrame:CGRectMake(origin.x, origin.y, width, 0)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scrollEnabled = NO; // required in iOS 6.1 to prevent jerky growth
    }
    return self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self sizeHeightToContent];
}

- (void)sizeHeightToContent
{
    CGFloat fixedWidth = self.frame.size.width;
    CGSize newSize = [self sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    if (newSize.height == self.frame.size.height) {
        return;
    }
    
    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    self.frame = newFrame;
    
    [_externalDelegate growingTextViewDidChangeHeight];
}

@end
