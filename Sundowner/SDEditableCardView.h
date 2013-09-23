
#import <UIKit/UIKit.h>
#import "SDGrowingTextView.h"
#import "SDGrowingTextViewDelegate.h"

@interface SDEditableCardView : UIView <SDGrowingTextViewDelegate>
@property (nonatomic, strong) SDGrowingTextView *contentTextView;
@property (nonatomic, strong) UILabel *authorLabel;
@end
