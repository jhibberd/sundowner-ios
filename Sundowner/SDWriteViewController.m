
#import <QuartzCore/QuartzCore.h>
#import "NSString+SDContentText.h"
#import "SDAppDelegate.h"
#import "SDContentCell.h"
#import "SDComposeContentView.h"
#import "SDToast.h"
#import "SDWriteViewController.h"
#import "SystemVersion.h"
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "UIColor+SDColor.h"

@interface SDWriteViewController ()
@end

@implementation SDWriteViewController {
    UIBarButtonItem *_acceptButton;
    UIBarButtonItem *_backButton;
    SDComposeContentView *_composeContentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"WRITE_TITLE", nil);
    [self.view setBackgroundColor:[UIColor backgroundColor]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // add buttons to the navigation bar
    _acceptButton = [UIBarButtonItem itemAcceptForTarget:self action:@selector(acceptButtonWasClicked)];
    _backButton = [UIBarButtonItem itemBackForTarget:self action:@selector(backButtonWasClicked)];
    [self.navigationItem setRightBarButtonItem:_acceptButton];
    [self.navigationItem setLeftBarButtonItem:_backButton];
    
    CGFloat width = self.view.frame.size.width - (kSDContentCellHorizontalPadding *2);
    CGRect frame = CGRectMake(kSDContentCellHorizontalPadding, 0, width, 0);
    _composeContentView = [[SDComposeContentView alloc] initWithFrame:frame];
    [self.view addSubview:_composeContentView];
    
    // constrain editable card to fixed distance from top of containing view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_composeContentView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:(kSDContentCellVerticalPadding *2)]];
    
    // dismiss the keyboard when the user clicks elsewhere in the view
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(dismissKeyboard)]];
}

-(void)dismissKeyboard {
    [_composeContentView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_composeContentView becomeFirstResponder];
    
    // during the time that the user is composing the content attempt to get an accurate location on
    // the device
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.location2 startUpdatingLocation:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // stop getting location updates if the view disappears (if the user cancels the composition view
    // for example
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.location2 stopUpdatingLocationAndReturnBest];
}

- (void)backButtonWasClicked {
    [self closeView];
}

- (void)acceptButtonWasClicked {
    
    NSDictionary *parsedText = [[_composeContentView getContentText] parseAsContentText];
    NSString *text = parsedText[@"text"];
    NSString *url = parsedText[@"url"];
    
    // ignore the message if the content is blank
    if ([text length] == 0) {
        return;
    }
    
    // Disable the post and cancel buttons. The post button is disabled to prevent the user from
    // repeatedly clicking it while a post is depending, which would result in multiple copies of
    // the same message being posted.
    [_acceptButton setEnabled:NO];
    [_backButton setEnabled:NO];
    
    // first obtain the device's current location then post the object to the server
    NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userId"];
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    CLLocation *bestLocation = [app.location2 stopUpdatingLocationAndReturnBest];
    [app.server setContent:text
                       url:url
                  location:bestLocation
                      user:userId
                  callback:^(NSDictionary *response) {
                     
                      // TODO check response
                      // TODO if fail alert user, reanable buttons and stay on view
                      [self closeView];
                  }];
}

- (void)closeView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)failedToGetBestLocation
{
    [SDToast toast:@"CANNOT_GET_LOCATION"];
    [self closeView];
}

@end
