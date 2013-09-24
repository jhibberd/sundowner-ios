
#import <UIKit/UIKit.h>
#import "SDGrowingTextViewDelegate.h"

@interface SDComposeContentView : UIView <SDGrowingTextViewDelegate>
- (NSString *)getContentText;
- (void)resignFirstResponder;
- (void)becomeFirstResponder;
@end
