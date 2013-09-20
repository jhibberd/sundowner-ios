
#import "SDToast.h"

@implementation SDToast

// display a short notification message to the user
// http://developer.android.com/guide/topics/ui/notifiers/toasts.html
+ (void)toast:(NSString *)stringKey
{
    NSString *app = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    [[[UIAlertView alloc] initWithTitle:app
                                message:NSLocalizedString(stringKey, nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}

@end
