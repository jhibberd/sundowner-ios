
#import <UIKit/UIKit.h>
#import "SDBestLocationDelegate.h"
#import "SDURLFieldDelegate.h"

@interface SDWriteViewController : UIViewController
    <SDBestLocationDelegate, SDURLFieldDelegate, UITextViewDelegate>
@end
