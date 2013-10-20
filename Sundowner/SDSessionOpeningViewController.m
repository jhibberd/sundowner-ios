
#import "SDSessionOpeningViewController.h"
#import "UIColor+SDColor.h"

@interface SDSessionOpeningViewController ()
@end

@implementation SDSessionOpeningViewController

- (id)init
{
    self = [super self];
    if (self) {
        self.view.backgroundColor = [UIColor backgroundColor];
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] init];
        aiv.center = self.view.center;
        aiv.color = [UIColor backgroundTextColor];
        [aiv startAnimating];
        [self.view addSubview:aiv];
    }
    return self;
}

@end
