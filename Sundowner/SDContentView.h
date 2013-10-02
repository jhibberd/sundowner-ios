
#import <UIKit/UIKit.h>

extern CGFloat const kSDContentViewPadding;

@interface SDContentView : UIView
+ (CGFloat)calculateContentHeight:(NSDictionary *)content constrainedByWidth:(CGFloat)width;
@property (nonatomic, strong) NSDictionary *content;
- (void)beginVoteDownAnimation;
@end
