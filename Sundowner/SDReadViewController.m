
#import "SDAppDelegate.h"
#import "SDContentCell.h"
#import "SDReadViewController.h"
#import "SDToast.h"
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "UIColor+SDColor.h"

@interface SDReadViewController ()
@end

@implementation SDReadViewController {
    NSMutableArray *_content;
    UILabel *_noContentLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"READ_TITLE", nil);
    [self.tableView setBackgroundColor:[UIColor backgroundColor]];
    
    // construct the label to show when there is no content available nearby
    _noContentLabel = [[UILabel alloc] init];
    _noContentLabel.text = NSLocalizedString(@"NO_CONTENT", nil);
    _noContentLabel.textAlignment = NSTextAlignmentCenter;
    _noContentLabel.textColor = [UIColor backgroundTextColor];
    
    // compose button in navigation bar        
    UIBarButtonItem *composeItem = [UIBarButtonItem itemComposeForTarget:self action:@selector(composeButtonWasClicked)];
    [self.navigationItem setRightBarButtonItem:composeItem];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(kSDContentCellVerticalPadding, 0, kSDContentCellVerticalPadding, 0)];
    
    _content = [[NSMutableArray alloc] init];
    [self.tableView registerClass:[SDContentCell class] forCellReuseIdentifier:@"Content"];
    
    // add handler for refreshing gesture
    [self.refreshControl addTarget:self
                            action:@selector(refreshContent)
                  forControlEvents:UIControlEventValueChanged];
    
    [self refreshContent];
}

- (void)composeButtonWasClicked
{
    static NSString *identifier = @"Compose";
    [self performSegueWithIdentifier:identifier sender:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // request to be notified when the application enters the foreground so that the content can be
    // refreshed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // no longer listen for UIApplicationWillEnterForegroundNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self refreshContent];
}

- (void)refreshContent
{    
    NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userId"];
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    
    [app.location getCurrentLocationThen:^(CLLocation *currentLocation) {
        [app.server getContentNearby:currentLocation.coordinate
                                user:userId
                           onSuccess:^(NSDictionary *response) {
                                
                                // TODO what if there is a server error? Caught by the request class?
                                _content = response[@"data"];
                                [self.tableView reloadData];
                                
                                // display no content label if necessary
                                UIView *expectedBackgroundView = [_content count] > 0 ? nil : _noContentLabel;
                                if (self.tableView.backgroundView != expectedBackgroundView) {
                                    self.tableView.backgroundView = expectedBackgroundView;
                                }
                                
                                // stop refresh animation if one is in progress
                                if (self.refreshControl.refreshing)
                                    [self.refreshControl endRefreshing];
                                
                            }];
    }];
}

# pragma mark Content Interaction

- (void)contentURLRequested:(NSDictionary *)content
{
    NSURL *url = [[NSURL alloc] initWithString:content[@"url"]];
    if (![[UIApplication sharedApplication] openURL:url]) {
        [SDToast toast:@"CANNOT_OPEN_URL"];
    }
}

- (void)contentVotedUp:(NSDictionary *)content
{
     // notify the server
     NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
     NSString *userId = [defaults stringForKey:@"userId"];
     SDAppDelegate *app = [UIApplication sharedApplication].delegate;
     [app.server vote:SDVoteUp content:content[@"id"] user:userId];
}

- (void)contentVotedDown:(NSDictionary *)content
{
    // animate the removal of the content from the table and remove it from the content array
    NSUInteger index = [_content indexOfObject:content];
    [self.tableView beginUpdates];
    [_content removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    
    // notify the server
    NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userId"];
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.server vote:SDVoteDown content:content[@"id"] user:userId];
}

# pragma mark Table Management

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_content count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *content = [_content objectAtIndex:indexPath.item];
    return [SDContentCell calculateContentHeight:content constrainedByWidth:tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Content";
    SDContentCell *cell = (SDContentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                           forIndexPath:indexPath];
    cell.delegate = self;
    cell.content = [_content objectAtIndex:indexPath.item];
    return cell;
}

@end
