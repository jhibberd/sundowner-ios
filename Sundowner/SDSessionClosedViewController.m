
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
        
        // get product name
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *productName = [info objectForKey:@"CFBundleDisplayName"];
        
        // product label
        UILabel *productLbl = [[UILabel alloc] init];
        productLbl.font = [UIFont productFont];
        productLbl.backgroundColor = [UIColor clearColor];
        productLbl.translatesAutoresizingMaskIntoConstraints = NO;
        productLbl.textColor = [UIColor backgroundTextColor];
        productLbl.text = productName;
        [productLbl sizeToFit];
        [self.view addSubview:productLbl];
        
        // intro label
        UILabel *introLbl = [[UILabel alloc] init];
        introLbl.font = [UIFont introductionFont];
        introLbl.numberOfLines = 0;
        introLbl.backgroundColor = [UIColor clearColor];
        introLbl.translatesAutoresizingMaskIntoConstraints = NO;
        introLbl.textColor = [UIColor backgroundTextColor];
        introLbl.text = NSLocalizedString(@"INTRODUCTION", nil);
        [introLbl sizeToFit];
        CGFloat width = self.view.frame.size.width - (kSDSessionClosedViewControllerHorizontalPadding *2);
        [introLbl autoGrowHeightCompatForWidth:width];
        [self.view addSubview:introLbl];
        
        fbLoginView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:fbLoginView];
     
        // autolayout constraints
        NSDictionary *variableBindings = NSDictionaryOfVariableBindings(self, productLbl, introLbl, fbLoginView);
        float hp = kSDSessionClosedViewControllerHorizontalPadding;
        float tp = kSDSessionClosedViewControllerTopPadding;
        NSString *fmt = nil;
        fmt = [NSString stringWithFormat:@"V:|-%f-[productLbl]-[introLbl]-%f-[fbLoginView]", tp, hp];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fmt
                                                                          options:0
                                                                          metrics:nil
                                                                            views:variableBindings]];
        fmt = [NSString stringWithFormat:@"|-%f-[productLbl]-%f-|", hp, hp];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fmt
                                                                          options:0
                                                                          metrics:nil
                                                                            views:variableBindings]];
        fmt = [NSString stringWithFormat:@"|-%f-[introLbl]-%f-|", hp, hp];
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
