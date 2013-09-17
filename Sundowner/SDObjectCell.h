
#import <UIKit/UIKit.h>
#import "SDObjectCellDelegate.h"

extern CGFloat const GTTitleFontSize;
extern CGFloat const GTNormalFontSize;

extern CGFloat const GTPaddingTopInner;
extern CGFloat const GTPaddingBottomInner;
extern CGFloat const GTPaddingLeftInner;
extern CGFloat const GTPaddingRightInner;
extern CGFloat const GTPaddingTopOuter;
extern CGFloat const GTPaddingBottomOuter;
extern CGFloat const GTPaddingLeftOuter;
extern CGFloat const GTPaddingRightOuter;

@interface SDObjectCell : UITableViewCell
@property (nonatomic, assign) id <SDObjectCellDelegate> delegate;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *author;
+ (CGFloat)estimateHeightForObject:(NSDictionary *)object constrainedByWidth:(CGFloat)width;
- (void)setObject:(NSDictionary *)object;
@end
