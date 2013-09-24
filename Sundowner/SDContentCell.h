
#import <UIKit/UIKit.h>
#import "SDObjectCellDelegate.h"

extern CGFloat const GTPaddingTopInner;
extern CGFloat const GTPaddingBottomInner;
extern CGFloat const GTPaddingLeftInner;
extern CGFloat const GTPaddingRightInner;
extern CGFloat const GTPaddingTopOuter;
extern CGFloat const GTPaddingBottomOuter;
extern CGFloat const GTPaddingLeftOuter;
extern CGFloat const GTPaddingRightOuter;

@interface SDContentCell : UITableViewCell
@property (nonatomic, assign) id <SDContentCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *content;
+ (CGFloat)estimateHeightForObject:(NSDictionary *)object constrainedByWidth:(CGFloat)width;
@end
