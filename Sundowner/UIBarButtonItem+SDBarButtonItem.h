
#import <UIKit/UIKit.h>

@interface UIBarButtonItem (SDBarButtonItem)
+ (UIBarButtonItem *)itemComposeForTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)itemAcceptForTarget:(id)target action:(SEL)action;
+ (UIBarButtonItem *)itemBackForTarget:(id)target action:(SEL)action;
@end
