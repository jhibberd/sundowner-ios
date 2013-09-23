
#import <UIKit/UIKit.h>
#import "SDGrowingTextViewDelegate.h"

@interface SDGrowingTextView : UITextView <UITextViewDelegate>
- (id)initWithWidth:(CGFloat)width origin:(CGPoint)origin delegate:(id<SDGrowingTextViewDelegate>)delegate;
- (void)sizeHeightToContent;
@end
