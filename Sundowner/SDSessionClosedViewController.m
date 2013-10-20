
#import "SDSessionClosedViewController.h"
#import "UIColor+SDColor.h"

@interface SDSessionClosedViewController ()
@end

@implementation SDSessionClosedViewController

- (id)initWithFBLoginView:(FBLoginView *)fbLoginView
{
    self = [super self];
    if (self) {
        self.view.backgroundColor = [UIColor backgroundColor];
        fbLoginView.center = self.view.center;
        [self.view addSubview:fbLoginView];
        
    }
    return self;
}

@end
