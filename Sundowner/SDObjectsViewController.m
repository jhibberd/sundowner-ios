
#import "SDAppDelegate.h"
#import "SDObjectCell.h"
#import "SDObjectsViewController.h"
#import "OpenInChromeController.h"
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "UIColor+SDColor.h"

static NSString *const GTChromeCallback = @"geotag://";

@interface SDObjectsViewController ()
@end

@implementation SDObjectsViewController {
    NSArray *_objects;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor backgroundColor]];
    
    // compose button in navigation bar        
    UIBarButtonItem *composeItem = [UIBarButtonItem itemComposeForTarget:self action:@selector(composeButtonWasClicked)];
    [self.navigationItem setRightBarButtonItem:composeItem];
    
    // bottom padding as all table view cells have top padding but not bottom padding
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, GTPaddingTopOuter, 0)];
    
    _objects = @[];
    [self.tableView registerClass:[SDObjectCell class] forCellReuseIdentifier:@"Object"];
    
    // add handler for refreshing gesture
    [self.refreshControl addTarget:self
                            action:@selector(refreshObjects)
                  forControlEvents:UIControlEventValueChanged];
    
    [self refreshObjects];
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
    [self refreshObjects];
}

- (void)refreshObjects
{
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.location getCurrentLocationThen:^(CLLocation *currentLocation) {
        [app.server getObjectsForLocation:currentLocation.coordinate
                                 callback:^(NSDictionary *response) {
                                     
            _objects = response[@"data"];
            [self.tableView reloadData];
            
            // stop refresh animation if one is in progress
            if (self.refreshControl.refreshing)
                [self.refreshControl endRefreshing];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // open the object URL in Google Chrome browser in a mode that displays a back button in the browser
    // that, when clicked, brings the user back to this app.
    NSDictionary *object = [_objects objectAtIndex:indexPath.item];
    NSURL *url = [[NSURL alloc] initWithString:object[@"url"]];
    NSURL *callback = [[NSURL alloc] initWithString:GTChromeCallback];
    [[OpenInChromeController sharedInstance] openInChrome:url withCallbackURL:callback createNewTab:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [_objects objectAtIndex:indexPath.item];
    return [SDObjectCell estimateHeightForObject:object constrainedByWidth:tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Object";
    SDObjectCell *cell = (SDObjectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                         forIndexPath:indexPath];
    NSDictionary *object = [_objects objectAtIndex:indexPath.item];
    [cell setObject:object];
    return cell;
}

@end
