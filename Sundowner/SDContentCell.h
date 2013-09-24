
#import <UIKit/UIKit.h>
#import "SDObjectCellDelegate.h"

extern CGFloat const kSDContentCellHorizontalPadding;
extern CGFloat const kSDContentCellVerticalPadding;

@interface SDContentCell : UITableViewCell
@property (nonatomic, assign) id <SDContentCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *content;
+ (CGFloat)calculateContentHeight:(NSDictionary *)content constrainedByWidth:(CGFloat)width;
@end
