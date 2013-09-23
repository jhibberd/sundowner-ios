
#import <QuartzCore/QuartzCore.h>
#import "SDAppDelegate.h"
#import "SDContentCell.h"
#import "SDEditableCardView.h"
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
    SDEditableCardView *_editableCardView;
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
    
    CGFloat width = self.view.frame.size.width - (GTPaddingLeftOuter + GTPaddingRightOuter);
    CGRect frame = CGRectMake(GTPaddingLeftOuter, GTPaddingTopOuter, width, 0);
    _editableCardView = [[SDEditableCardView alloc] initWithFrame:frame];
    [self.view addSubview:_editableCardView];
    
    // constrain editable card to fixed distance from top of containing view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_editableCardView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:(GTPaddingTopOuter *2)]];
    
    // dismiss the keyboard when the user clicks elsewhere in the view
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(dismissKeyboard)]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // TODO apply character and/or height limit
    //NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

-(void)dismissKeyboard {
    [_editableCardView.contentTextView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_editableCardView.contentTextView becomeFirstResponder];
    
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
    
    NSDictionary *parsedContent = [self parseContentText:_editableCardView.contentTextView.text];
    if (parsedContent == nil) {
        NSLog(@"badly formed content text");
        return;
    }
    
    // ignore the message if the content is blank
    if ([[parsedContent[@"text"] stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {
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
    [app.server setContent:parsedContent[@"text"]
                       url:parsedContent[@"url"]
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

- (NSDictionary *)parseContentText:(NSString *)text
{
    NSObject *url = [NSNull null];
    NSMutableString *mutableText = [[NSMutableString alloc] initWithString:text];
    
    // search the text for URLs
    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matches = [detector matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    if ([matches count] > 1) {
        // more than 1 URL in text!
        return nil;
    }
    
    // if a URL was found extract and remove it from the text
    if ([matches count] > 0) {
        NSTextCheckingResult *match = [matches lastObject];
        url = [[match URL] description];
        [mutableText deleteCharactersInRange:[match range]];
        NSString *trimmedText =
        [mutableText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        mutableText = [[NSMutableString alloc] initWithString:trimmedText];
    }
    
    return @{@"text": mutableText, @"url": url};
}

@end
