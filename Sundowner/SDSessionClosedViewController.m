
#import "SDSessionClosedViewController.h"
#import "SystemVersion.h"
#import "UIColor+SDColor.h"
#import "UIFont+SDFont.h"
#import "UILabel+SDLabel.h"

static float const kSDSessionClosedViewControllerHorizontalPadding = 15.0;
static float const kSDSessionClosedViewControllerTopPadding = 35.0;

@interface SDSessionClosedViewController ()
@end

@implementation SDSessionClosedViewController

- (id)initWithFBLoginView:(FBLoginView *)fbLoginView
{
    self = [super self];
    if (self) {
        
        self.view.backgroundColor = [UIColor backgroundColor];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont introductionFont];
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textColor = [UIColor backgroundTextColor];
        label.text = NSLocalizedString(@"INTRODUCTION", nil);
        [label sizeToFit];
        CGFloat width = self.view.frame.size.width - (kSDSessionClosedViewControllerHorizontalPadding *2);
        [label autoGrowHeightCompatForWidth:width];
        [self.view addSubview:label];
        
        fbLoginView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:fbLoginView];
     
        // autolayout constraints
        NSDictionary *variableBindings = NSDictionaryOfVariableBindings(self, label, fbLoginView);
        float hp = kSDSessionClosedViewControllerHorizontalPadding;
        float tp = kSDSessionClosedViewControllerTopPadding;
        NSString *fmt = nil;
        fmt = [NSString stringWithFormat:@"V:|-%f-[label]-%f-[fbLoginView]", tp, hp];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fmt
                                                                          options:0
                                                                          metrics:nil
                                                                            views:variableBindings]];
        fmt = [NSString stringWithFormat:@"|-%f-[label]-%f-|", hp, hp];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fmt
                                                                          options:0
                                                                          metrics:nil
                                                                            views:variableBindings]];
        fmt = [NSString stringWithFormat:@"|-%f-[fbLoginView]", hp];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fmt
                                                                          options:0
                                                                          metrics:nil
                                                                            views:variableBindings]];
    }
    return self;
}

@end
