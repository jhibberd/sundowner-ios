
#import <QuartzCore/QuartzCore.h>
#import "SDAppDelegate.h"
#import "SDContentCell.h"
#import "SDWriteViewController.h"
#import "SDURLField.h"
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "UIColor+SDColor.h"

static CGFloat GTTextViewInherentPadding = 8;

@interface SDWriteViewController ()
@end

@implementation SDWriteViewController {
    UIBarButtonItem *_acceptButton;
    UIBarButtonItem *_backButton;
    UITextView *_contentTextView;
    UIView *_card;
    UILabel *_author;
    NSString *_authorText;
    SDURLField *_urlField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor backgroundColor]];
    
    // add buttons to the navigation bar
    _acceptButton = [UIBarButtonItem itemAcceptForTarget:self action:@selector(acceptButtonWasClicked)];
    [self.navigationItem setRightBarButtonItem:_acceptButton];
    _backButton = [UIBarButtonItem itemBackForTarget:self action:@selector(backButtonWasClicked)];
    [self.navigationItem setLeftBarButtonItem:_backButton];
    
    // card view
    _card = [[UIView alloc] init];
    [_card setBackgroundColor:[UIColor whiteColor]];
    [_card.layer setCornerRadius:3.0f];
    [self.view addSubview:_card];
    
    // Measure the size of a single line of content text, to be used as the starting height of the content
    // control. The constraint width doesn't really matter as the text " " will never consume more than a
    // single line.
    CGFloat width = self.view.frame.size.width -
        (GTPaddingLeftOuter + GTPaddingLeftInner + GTPaddingRightInner + GTPaddingRightOuter);
    CGFloat contentHeight = [self estimateHeightForTitle:@" " constrainedByWidth:width];
    
    // content text
    _contentTextView = [[UITextView alloc] init];
    CGRect contentFrame = CGRectMake(GTPaddingLeftInner, GTPaddingTopInner, width, contentHeight);
    contentFrame = [self adjustContentViewFrameToActualPosition:contentFrame];
    [_contentTextView setFrame:contentFrame];
    [_contentTextView setFont:[UIFont systemFontOfSize:GTTitleFontSize]];;
    [_contentTextView setDelegate:self];
    _contentTextView.backgroundColor = [UIColor clearColor];
    [_card addSubview:_contentTextView];
    
    // without this, when the content view is resizing to fit new content, the content is scrolled upwards before
    // the control has a chance to grow
    [_contentTextView setScrollEnabled:NO];
    
    // create author label
    NSString *username = [[[NSUserDefaults class] standardUserDefaults] stringForKey:@"username"];
    _authorText = [NSString stringWithFormat:@"by %@", username];
    _author = [[UILabel alloc] init];
    [_author setFont:[UIFont systemFontOfSize:GTNormalFontSize]];
    _author.textColor = [UIColor lightGrayColor];
    [_author setText:_authorText];
    [_card addSubview:_author];
    
    // create URL field
    _urlField = [[SDURLField alloc] initWithWidth:width delegate:self];
    [_card addSubview:_urlField];
    
    // dismiss the keyboard when the user clicks elsewhere in the view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

// The UITextView class has inherent padding. If this padding is modified it interferes with the logic for
// growing the size of the control relative to the content size. An easier approach is to offset the position
// of the control on the screen to effectively negate the padding.
- (CGRect)adjustContentViewFrameToActualPosition:(CGRect)frame
{
   return CGRectMake(frame.origin.x - GTTextViewInherentPadding,
                     frame.origin.y - GTTextViewInherentPadding,
                     frame.size.width + (GTTextViewInherentPadding * 2),
                     frame.size.height + (GTTextViewInherentPadding * 2));
}

- (CGRect)adjustContentViewFrameToLogicalPosition:(CGRect)frame
{
    return CGRectMake(frame.origin.x + GTTextViewInherentPadding,
                      frame.origin.y + GTTextViewInherentPadding,
                      frame.size.width - (GTTextViewInherentPadding * 2),
                      frame.size.height - (GTTextViewInherentPadding * 2));
}

- (void)urlFieldDidResize
{
    [self updateLayout];
}

- (void)updateLayout
{
    CGFloat width = self.view.frame.size.width -
        (GTPaddingLeftOuter + GTPaddingLeftInner + GTPaddingRightInner + GTPaddingRightOuter);
    
    // get position and height of content view control as a starting point (taking the inherent padding
    // into consideration
    CGRect contentFrame =[self adjustContentViewFrameToLogicalPosition:_contentTextView.frame];
    CGFloat yAxisCursor = GTPaddingTopInner + contentFrame.size.height;
    
    // update author label
    CGFloat authorHeight = [self estimateHeightForAuthor:_authorText constrainedByWidth:width];
    [_author setFrame:CGRectMake(GTPaddingLeftInner, yAxisCursor, width, authorHeight)];
    yAxisCursor += authorHeight;
    
    // update URL field
    CGFloat urlFieldHeight = _urlField.frame.size.height;
    [_urlField setFrame:CGRectMake(GTPaddingLeftInner, yAxisCursor, width, urlFieldHeight)];
    
    // update card view
    CGFloat cardHeight = GTPaddingTopOuter + contentFrame.size.height + authorHeight +
                         urlFieldHeight + GTPaddingTopOuter; // TODO confusing!
    _card.frame = CGRectMake(GTPaddingLeftOuter,
                             GTPaddingTopOuter,
                             self.view.frame.size.width - (GTPaddingLeftOuter + GTPaddingRightOuter),
                             cardHeight);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // TODO apply character and/or height limit
    //NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    // each time the content text changes ensure that the text view is big enough to show all the text without
    // needing to scroll
    CGRect frame = _contentTextView.frame;
    if (frame.size.height != _contentTextView.contentSize.height) {
        frame.size.height = _contentTextView.contentSize.height;
        _contentTextView.frame = frame;
        [self updateLayout];
    }
}

- (CGFloat)estimateHeightForTitle:(NSString *)titleText constrainedByWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, INT_MAX); // effectively unbounded height
    CGSize size = [titleText sizeWithFont:[UIFont systemFontOfSize:GTTitleFontSize]
                        constrainedToSize:constraint
                            lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}

- (CGFloat)estimateHeightForAuthor:(NSString *)authorText constrainedByWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, INT_MAX);
    CGSize size = [authorText sizeWithFont:[UIFont systemFontOfSize:GTNormalFontSize] constrainedToSize:constraint];
    return size.height;
}

-(void)dismissKeyboard {
    [_contentTextView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_contentTextView becomeFirstResponder];
    
    // during the time that the user is composing the content attempt to get an accurate location on
    // the device
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.location2 startUpdatingLocation:self];
    
    // request to be notified when the application enters the foreground so that the URL field can
    // refresh itself
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [_urlField refreshStateUsingPasteboard];
    
    // size the views according to content and view frame
    [self updateLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // stop getting location updates if the view disappears (if the user cancels the composition view
    // for example
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.location2 stopUpdatingLocationAndReturnBest];
    
    // no longer listen for UIApplicationWillEnterForegroundNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [_urlField refreshStateUsingPasteboard];
}

- (void)backButtonWasClicked {
    [self closeView];
}

- (void)acceptButtonWasClicked {
    
    NSString *content = _contentTextView.text;
    NSString *url = _urlField.url;
    
    // ignore the message if the content is blank
    if ([[content stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {
        return;
    }
    
    // Disable the post and cancel buttons. The post button is disabled to prevent the user from
    // repeatedly clicking it while a post is depending, which would result in multiple copies of
    // the same message being posted.
    [_acceptButton setEnabled:NO];
    [_backButton setEnabled:NO];
    
    NSString *username = [[[NSUserDefaults class] standardUserDefaults] stringForKey:@"username"];
    
    // first obtain the device's current location then post the object to the server
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    CLLocation *bestLocation = [app.location2 stopUpdatingLocationAndReturnBest];
    [app.server setContent:content
                   withURL:url
                atLocation:bestLocation
                    byUser:username
                  callback:^(NSDictionary *response) {
                     
                     // TODO check response
                     [self closeView];
                 }];
}

- (void)closeView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)failedToGetBestLocation
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:@"Unable to find your current location"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    [self closeView];
}

@end
