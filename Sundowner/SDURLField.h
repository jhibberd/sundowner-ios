
#import <UIKit/UIKit.h>
#import "SDURLFieldDelegate.h"

@interface SDURLField : UIButton
@property (nonatomic, strong) NSString *url;
- (id)initWithWidth:(CGFloat)width delegate:(id <SDURLFieldDelegate>)delegate;
- (void)refreshStateUsingPasteboard;
@end
