
#import "SDAppDelegate.h"
#import "SDContentCell.h"
#import "SDReadViewController.h"
#import "OpenInChromeController.h"
#import "UIBarButtonItem+SDBarButtonItem.h"
#import "UIColor+SDColor.h"

@interface SDReadViewController ()
@end

@implementation SDReadViewController {
    NSMutableArray *_content;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor backgroundColor]];
    
    // compose button in navigation bar        
    UIBarButtonItem *composeItem = [UIBarButtonItem itemComposeForTarget:self action:@selector(composeButtonWasClicked)];
    [self.navigationItem setRightBarButtonItem:composeItem];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(GTPaddingTopOuter, 0, GTPaddingBottomOuter, 0)];
    
    _content = [[NSMutableArray alloc] init];
    [self.tableView registerClass:[SDContentCell class] forCellReuseIdentifier:@"Object"];
    
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
                            callback:^(NSDictionary *response) {
                                     
            _content = response[@"data"];
            [self.tableView reloadData];
            
            // stop refresh animation if one is in progress
            if (self.refreshControl.refreshing)
                [self.refreshControl endRefreshing];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_content count];
}

- (void)contentURLRequested:(NSDictionary *)content
{
    //NSDictionary *object = [_objects objectAtIndex:indexPath.item];
    NSURL *url = [[NSURL alloc] initWithString:content[@"url"]];
    
    // Ideally open the content URL is Google Chrome which provides a back button that returns the user
    // to this app. If Google Chrome isn't installed use the default browser.
    // https://developers.google.com/chrome/mobile/docs/ios-links
    BOOL success;
    OpenInChromeController *chromeController = [OpenInChromeController sharedInstance];
    if ([chromeController isChromeInstalled]) {
        static NSString *const chromeCallbackURLString = @"sundowner://";
        NSURL *callbackURL = [[NSURL alloc] initWithString:chromeCallbackURLString];
        success = [[OpenInChromeController sharedInstance] openInChrome:url
                                                        withCallbackURL:callbackURL
                                                           createNewTab:YES];
    } else {
        success = [[UIApplication sharedApplication] openURL:url];
    }
    if (!success) {
        NSLog(@"Failed to open URL in browser");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [_content objectAtIndex:indexPath.item];
    return [SDContentCell estimateHeightForObject:object constrainedByWidth:tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Object";
    SDContentCell *cell = (SDContentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                           forIndexPath:indexPath];
    NSDictionary *object = [_content objectAtIndex:indexPath.item];
    cell.delegate = self;
    [cell setContent:object];
    return cell;
}

- (void)contentVotedUp:(NSDictionary *)content
{
    /*
     // notify the server
     NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
     NSString *userId = [defaults stringForKey:@"userId"];
     SDAppDelegate *app = [UIApplication sharedApplication].delegate;
     [app.server vote:SDVoteUp content:content[@"id"] user:userId callback:^(NSDictionary *response) {
     // TODO check response code and alert user if failure.
     }];
     */
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
    
    /*
    // notify the server
    NSUserDefaults* defaults = [[NSUserDefaults class] standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"userId"];
    SDAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.server vote:SDVoteDown content:content[@"id"] user:userId callback:^(NSDictionary *response) {
        // TODO check response code and alert user if failure.
    }];
     */
}

@end
