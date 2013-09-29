
#import <UIKit/UIKit.h>
#import "SDObjectCellDelegate.h"
#import "SDSameLocationContentRefreshTimerDelegate.h"

@interface SDReadViewController : UITableViewController
    <CLLocationManagerDelegate, SDContentCellDelegate, SDSameLocationContentRefreshTimerDelegate>
@end
