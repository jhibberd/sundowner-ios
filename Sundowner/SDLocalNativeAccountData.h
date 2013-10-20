
#import <Foundation/Foundation.h>

@interface SDLocalNativeAccountData : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
- (void)save;
+ (SDLocalNativeAccountData *)load;
+ (void)clear;
@end
