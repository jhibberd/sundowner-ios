
#import "SDLocalNativeAccountData.h"

static NSString *const kSDLocalNativeAccountDataUserName = @"kSDLocalNativeAccountDataUserName";
static NSString *const kSDLocalNativeAccountDataUserId = @"kSDLocalNativeAccountDataUserId";

// Native (as opposed to Facebook) account information that has cached locally on the device.
// Currently the storage medium used is NSUserDefaults which probably isn't appropriate for data
// as sensitive as a native user ID.
// TODO implement more secure storage mechanism
@implementation SDLocalNativeAccountData

- (void)save
{
    if (self.userName == NULL || self.userId == NULL) {
        NSLog(@"Attempt to save incomplete local native account data");
        return;
    }
    NSUserDefaults *defaults = [[NSUserDefaults class] standardUserDefaults];
    [defaults setValue:self.userName forKey:kSDLocalNativeAccountDataUserName];
    [defaults setValue:self.userId forKey:kSDLocalNativeAccountDataUserId];
}

+ (SDLocalNativeAccountData *)load
{
    NSUserDefaults *defaults = [[NSUserDefaults class] standardUserDefaults];
    NSString *userName = [defaults stringForKey:kSDLocalNativeAccountDataUserName];
    NSString *userId = [defaults stringForKey:kSDLocalNativeAccountDataUserId];
    if (userName == NULL || userId == NULL) {
        return NULL;
    }
    
    SDLocalNativeAccountData *account = [[SDLocalNativeAccountData alloc] init];
    account.userName = userName;
    account.userId = userId;
    return account;
}

+ (void)clear
{
    NSUserDefaults *defaults = [[NSUserDefaults class] standardUserDefaults];
    [defaults removeObjectForKey:kSDLocalNativeAccountDataUserName];
    [defaults removeObjectForKey:kSDLocalNativeAccountDataUserId];
}

@end
