
#import "UILabel+SDLabel.h"

@implementation UILabel (SDLabel)

- (void)autoGrowHeightCompatForWidth:(CGFloat)width
{
    // ensure height of UILabel grows to fit the text with autolayout (required for iOS 6.1)
    // http://stackoverflow.com/questions/16009405/uilabel-sizetofit-doesnt-work-with-autolayout-ios6
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.preferredMaxLayoutWidth = width;
    [self setContentHuggingPriority:UILayoutPriorityRequired
                            forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisVertical];
}

@end
