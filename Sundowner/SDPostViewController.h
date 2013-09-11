
#import <UIKit/UIKit.h>
#import "SDBestLocationDelegate.h"
#import "SDURLFieldDelegate.h"

@interface SDPostViewController : UIViewController
    <SDBestLocationDelegate, SDURLFieldDelegate, UITextViewDelegate>
@end
