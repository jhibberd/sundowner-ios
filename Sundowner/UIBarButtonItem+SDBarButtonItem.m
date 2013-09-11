
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "SDAcceptIconView.h"
#import "SDBackIconView.h"
#import "SDComposeIconView.h"

@implementation UIBarButtonItem (SDBarButtonItem)

// as per the iOS Human Interface Guidelines
// https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/IconsImages/IconsImages.html
static CGFloat const kGTIconSize = 20;
static CGFloat const kGTIconButtonHorizontalPadding = 10;
static CGFloat const kGTIconButtonVerticalPadding = 5;

# pragma mark - Public

+ (UIBarButtonItem *)itemComposeForTarget:(id)target action:(SEL)action
{
    return [self makeBarButtonItem:[SDComposeIconView class] target:target action:action];
}

+ (UIBarButtonItem *)itemAcceptForTarget:(id)target action:(SEL)action
{
    return [self makeBarButtonItem:[SDAcceptIconView class] target:target action:action];
}

+ (UIBarButtonItem *)itemBackForTarget:(id)target action:(SEL)action
{
    return [self makeBarButtonItem:[SDBackIconView class] target:target action:action];
}

# pragma mark - Private

+ (UIBarButtonItem *)makeBarButtonItem:(Class)iconViewClass target:(id)target action:(SEL)action
{
    NSAssert([iconViewClass isSubclassOfClass:[SDIconView class]], @"Invalid icon view class");
    CGRect viewFrame = CGRectMake(0, 0, kGTIconSize, kGTIconSize);
    UIView *view = [[iconViewClass alloc] initWithFrame:viewFrame];
    UIButton *button = [self makeButton:view];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

// to make it easier for the user to press an icon button the clickable area of the button should
// include the padding
+ (UIButton *)makeButton:(UIView *)view
{
    // without this the view part of the button isn't clickable
    [view setUserInteractionEnabled:NO];
    
    // reposition the view within the button to account for the padding
    view.frame = CGRectMake(kGTIconButtonHorizontalPadding,
                            kGTIconButtonVerticalPadding,
                            view.frame.size.width,
                            view.frame.size.height);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,
                              0,
                              view.frame.size.width + (kGTIconButtonHorizontalPadding *2),
                              view.frame.size.height + (kGTIconButtonVerticalPadding *2));
    [button addSubview:view];
    return button;
}

@end
