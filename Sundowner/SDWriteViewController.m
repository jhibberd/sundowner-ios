
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
    UIScrollView *_scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor backgroundColor]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // add buttons to the navigation bar
    _acceptButton = [UIBarButtonItem itemAcceptForTarget:self action:@selector(acceptButtonWasClicked)];
    _backButton = [UIBarButtonItem itemBackForTarget:self action:@selector(backButtonWasClicked)];
    [self.navigationItem setRightBarButtonItem:_acceptButton];
    [self.navigationItem setLeftBarButtonItem:_backButton];
    
    // add scroll view
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];
    
    // add compose content view
    CGFloat width = self.view.frame.size.width - (kSDContentCellHorizontalPadding *2);
    CGRect frame = CGRectMake(kSDContentCellHorizontalPadding, 0, width, 0);
    _composeContentView = [[SDComposeContentView alloc] initWithFrame:frame];
    [_scrollView addSubview:_composeContentView];
    
    // auto layout constraints
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_scrollView, _composeContentView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:viewsDictionary]];
    NSString *hFormat = [NSString stringWithFormat:@"H:|-%f-[_composeContentView]-%f-|",
                         kSDContentCellHorizontalPadding, kSDContentCellHorizontalPadding];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hFormat
                                                                        options:0
                                                                        metrics:0
                                                                          views:viewsDictionary]];
    NSString *vFormat = [NSString stringWithFormat:@"V:|-%f-[_composeContentView]-%f-|",
                         kSDContentCellVerticalPadding *2, kSDContentCellVerticalPadding *2];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vFormat
                                                                        options:0
                                                                        metrics:0
                                                                          views:viewsDictionary]];
    
    [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(dismissKeyboard)]];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    // adjust the scroll view's frame so that no part of it is obscured by the keyboard
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // adjust the scroll view's frame so that it fills its superview
    _scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)dismissKeyboard {
    [_composeContentView resignFirstResponder];
}

- (void)locationsServicesDidBecomeUnavailable:(NSNotification *)notification
{
    NSLog(@"Location services did become unavailable");
    [self closeView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set keyboard focus to content UITextView control
    [_composeContentView becomeFirstResponder];
    
    // get notified when the keyboard appears/disappears so that the scroll view's frame can be adjusted
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardDidShow:)
                               name:UIKeyboardDidShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(locationsServicesDidBecomeUnavailable:)
                               name:kSDLocationUnavailableNotification
                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // stop receiving keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    // get the current location
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = [app.location getCurrentLocation];
    if (!currentLocation) {
        [SDToast toast:@"CANNOT_GET_LOCATION"];
        [_acceptButton setEnabled:YES];
        [_backButton setEnabled:YES];
        return;
    }
    
    // first obtain the device's current location then post the object to the server
    [app.server setContent:text
                       url:url
                  location:currentLocation
                 onSuccess:^(NSDictionary *response) {
                     // notify the user of the successful post and return to the read view
                     [SDToast toast:NSLocalizedString(@"CONTENT_POSTED", nil)];
                     [self closeView];
                 }
                 onFailure:^(NSDictionary *response) {
                     // enable the nav buttons to allow the user to return to the read view or
                     // retry the submission
                     [_acceptButton setEnabled:YES];
                     [_backButton setEnabled:YES];
                 }];
}

- (void)closeView
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
