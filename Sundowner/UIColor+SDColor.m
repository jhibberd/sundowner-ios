
#import "UIColor+SDColor.h"

@implementation UIColor (SDColor)

/* Google Android Design Guide provides a nice palette
 * http://developer.android.com/design/style/color.html
 */

+ (UIColor *)textColor {
    return [UIColor colorWithWhite:0.2 alpha:1];
}

+ (UIColor *)linkColor {
    return [UIColor colorWithRed:62/255.0 green:154/255.0 blue:201/255.0 alpha:1];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
}

+ (UIColor *)navigationBarShadowColor {
    return [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
}

@end
