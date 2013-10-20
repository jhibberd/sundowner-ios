
#import "UIColor+SDColor.h"

@implementation UIColor (SDColor)

// Google Android Design Guide provides a nice palette
// http://developer.android.com/design/style/color.html

+ (UIColor *)textColor {
    return [UIColor colorWithWhite:0.2 alpha:1];
}

+ (UIColor *)likeColor {
    return [UIColor colorWithRed:235/255.0 green:91/255.0 blue:84/255.0 alpha:1];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:51/255.0 green:181/255.0 blue:229/255.0 alpha:1];
}

+ (UIColor *)backgroundTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *)navIconColor {
    return [UIColor whiteColor];
}

+ (UIColor *)subtextColor {
    return [UIColor colorWithRed:0/255.0 green:153/255.0 blue:204/255.0 alpha:1];
}

@end
