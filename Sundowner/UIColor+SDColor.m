
#import "UIColor+SDColor.h"

@implementation UIColor (SDColor)

// Google Android Design Guide provides a nice palette
// http://developer.android.com/design/style/color.html

+ (UIColor *)textColor {
    return [UIColor colorWithWhite:0.2 alpha:1];
}

+ (UIColor *)linkColor {
    return [UIColor colorWithRed:117/255.0 green:146/255.0 blue:13/255.0 alpha:1];
}

+ (UIColor *)likeColor {
    return [UIColor colorWithRed:235/255.0 green:91/255.0 blue:84/255.0 alpha:1];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
}

+ (UIColor *)backgroundTextColor {
    return [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
}

@end
