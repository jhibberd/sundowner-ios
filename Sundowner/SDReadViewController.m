
#import "SDAppDelegate.h"
#import "SDContentCell.h"
#import "SDFacebookSessionManager.h"
#import "SDReadViewController.h"
#import "SDSameLocationContentRefreshTimer.h"
#import "SDLocalNativeAccountData.h"
#import "SDLocation.h"
#import "SDToast.h"
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "UIColor+SDColor.h"

@interface SDReadViewController ()
@end

// TODO functions for transitioning between different states
typedef enum {
    SDReadViewUnknown = 0,
    SDReadViewStateNormal,
    SDReadViewStateNoContent,
    SDReadViewStateLocationServicesUnavailable
} SDReadViewState;

@implementation SDReadViewController {
    NSMutableArray *_content;
    UILabel *_noContentLabel;
    UILabel *_locationServicesUnavailableView;
    SDSameLocationContentRefreshTimer *_sameLocationContentRefreshTimer;
    UIBarButtonItem *_composeItem;
    SDReadViewState _state;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor backgroundColor]];
    
    // construct the label to show when there is no content available nearby
    _noContentLabel = [[UILabel alloc] init];
    _noContentLabel.text = NSLocalizedString(@"NO_CONTENT", nil);
    _noContentLabel.textAlignment = NSTextAlignmentCenter;
    _noContentLabel.textColor = [UIColor backgroundTextColor];
    
    // construct the label to show when location services are unavailable
    _locationServicesUnavailableView = [[UILabel alloc] init];
    _locationServicesUnavailableView.text = NSLocalizedString(@"LOCATION_SERIVCES_UNAVAILABLE", nil);
    _locationServicesUnavailableView.textAlignment = NSTextAlignmentCenter;
    _locationServicesUnavailableView.textColor = [UIColor backgroundTextColor];
    
    // add buttons to the navigation bar
    UIBarButtonItem *backBarButtonItem = [UIBarButtonItem itemBackForTarget:self action:@selector(backButtonWasClicked)];
    _composeItem = [UIBarButtonItem itemComposeForTarget:self action:@selector(composeButtonWasClicked)];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    [self.navigationItem setRightBarButtonItem:_composeItem];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(kSDContentCellVerticalPadding, 0, kSDContentCellVerticalPadding, 0)];
    
    _content = [[NSMutableArray alloc] init];
    [self.tableView registerClass:[SDContentCell class] forCellReuseIdentifier:@"Content"];
    
    _sameLocationContentRefreshTimer = [[SDSameLocationContentRefreshTimer alloc] init];
    _sameLocationContentRefreshTimer.delegate = self;
}

- (void)backButtonWasClicked
{
    [SDFacebookSessionManager closeSession];
}

- (void)composeButtonWasClicked
{
    static NSString *identifier = @"Compose";
    [self performSegueWithIdentifier:identifier sender:nil];
}

# pragma mark Refreshing Content

- (void)locationsServicesDidBecomeAvailable:(NSNotification *)notification
{
    NSLog(@"Location services did become available");
    self.tableView.backgroundView = nil;
    [self.navigationItem setRightBarButtonItem:_composeItem];
    [_sameLocationContentRefreshTimer start];
}

- (void)locationsServicesDidBecomeUnavailable:(NSNotification *)notification
{
    NSLog(@"Location services did become unavailable");
    self.tableView.backgroundView = _locationServicesUnavailableView;
    [self.navigationItem setRightBarButtonItem:nil];
    [_content removeAllObjects];
    [self.tableView reloadData];
    [_sameLocationContentRefreshTimer stop];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(locationsServicesDidBecomeAvailable:)
                               name:kSDLocationAvailableNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(locationsServicesDidBecomeUnavailable:)
                               name:kSDLocationUnavailableNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(locationDidChange:)
                               name:kSDLocationDidChangeNotification
                             object:nil];
    
    // the view has just been shown so refresh content for the current location
    [_sameLocationContentRefreshTimer start];
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    [app.location flushLocationIfAvailable];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // stop services that are no longer required now that the view has disappeared
    [super viewWillDisappear:animated];
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
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    [app.location flushLocationIfAvailable];
}
 
- (void)refreshContentForLocation:(CLLocation *)location
{
    NSLog(@"Requesting content for lng=%f lat=%f accuracy=%f",
          location.coordinate.longitude, location.coordinate.latitude, location.horizontalAccuracy);
    
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *userId = [SDLocalNativeAccountData load].userId;
    
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
    NSString *userId = [SDLocalNativeAccountData load].userId;
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
    [app.server vote:SDVoteUp content:content[@"id"] user:userId];
}

- (void)contentVotedDown:(NSDictionary *)content
{    
    // notify the server
    NSString *userId = [SDLocalNativeAccountData load].userId;
    SDAppDelegate *app = (SDAppDelegate *)[UIApplication sharedApplication].delegate;
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
