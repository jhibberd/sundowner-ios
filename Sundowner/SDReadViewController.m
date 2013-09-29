
#import "SDAppDelegate.h"
#import "SDContentCell.h"
#import "SDReadViewController.h"
#import "SDSameLocationContentRefreshTimer.h"
#import "SDLocation.h"
#import "SDToast.h"
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "UIColor+SDColor.h"

@interface SDReadViewController ()
@end

@implementation SDReadViewController {
    NSMutableArray *_content;
    UILabel *_noContentLabel;
    SDSameLocationContentRefreshTimer *_sameLocationContentRefreshTimer;
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
    
    _sameLocationContentRefreshTimer = [[SDSameLocationContentRefreshTimer alloc] init];
    _sameLocationContentRefreshTimer.delegate = self;
}

- (void)composeButtonWasClicked
{
    static NSString *identifier = @"Compose";
    [self performSegueWithIdentifier:identifier sender:nil];
}

# pragma mark Refreshing Content

- (void)viewWillAppear:(BOOL)animated
{
    [_sameLocationContentRefreshTimer start];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidChange:)
                                                 name:kSDLocationDidChangeNotification
                                               object:nil];
    
    // the view has just been shown so refresh content for the current location
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.location flushLocationIfAvailable];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // no longer listen for location updates
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_sameLocationContentRefreshTimer stop];
}

- (void)locationDidChange:(NSNotification *)notification
{
    NSLog(@"Received notification that location changed");
    // the location changed which will result in a request for new content to reset the countdown that
    // guards against stale content
    [_sameLocationContentRefreshTimer locationDidChange];
    [self refreshContentForLocation:notification.userInfo[@"location"]];
}

- (void)shouldRefreshContentAsLocationIsStillSame
{
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.location flushLocationIfAvailable];
}
 
- (void)refreshContentForLocation:(CLLocation *)location
{
    NSLog(@"Requesting content for lng=%f lat=%f accuracy=%f",
          location.coordinate.longitude, location.coordinate.latitude, location.horizontalAccuracy);
    
    NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userId"];
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    
    [app.server getContentNearby:location.coordinate
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
