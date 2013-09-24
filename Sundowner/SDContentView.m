
#import "SDContentView.h"
#import "SystemVersion.h"
#import "UIColor+SDColor.h"
#import "UIFont+SDFont.h"

@implementation SDContentView {
    UILabel *_text;
    UILabel *_author;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.0;
        
        // disable older layout mechanism otherwise auto layout doesn't work
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _text = [[UILabel alloc] init];
        _text.font = [UIFont titleFont];
        _text.translatesAutoresizingMaskIntoConstraints = NO;
        _text.numberOfLines = 0;
        [self addSubview:_text];
        
        _author = [[UILabel alloc] init];
        _author.textColor = [UIColor lightGrayColor];
        _author.font = [UIFont normalFont];
        _author.translatesAutoresizingMaskIntoConstraints = NO;
        _author.numberOfLines = 0;
        [self addSubview:_author];
        
        // define layout constraints
        NSDictionary *variableBindings = NSDictionaryOfVariableBindings(self, _text, _author);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_text]-0-[_author]-10-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:variableBindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_text]-10-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:variableBindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_author]-10-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:variableBindings]];
        NSString *format = [NSString stringWithFormat:@"[self(%f)]", self.frame.size.width];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                     options:0
                                                                     metrics:nil
                                                                       views:variableBindings]];
        
        // fix to dynamically grow height of UILabel with autolayout in iOS 6
        // http://stackoverflow.com/questions/16009405/uilabel-sizetofit-doesnt-work-with-autolayout-ios6
        if (SYSTEM_VERSION_LESS_THAN(@"7")) {
            _text.lineBreakMode = NSLineBreakByWordWrapping;
            _text.preferredMaxLayoutWidth = self.frame.size.width - 20;
            [_text setContentHuggingPriority:UILayoutPriorityRequired
                                     forAxis:UILayoutConstraintAxisVertical];
            [_text setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                   forAxis:UILayoutConstraintAxisVertical];
        }
        
    }
    return self;
}
 
- (void)setContent:(NSDictionary *)content
{
    _text.text = content[@"title"];
    _text.textColor = content[@"url"] == nil ? [UIColor textColor] : [UIColor linkColor];
    _author.text = [NSString stringWithFormat:@"by %@", content[@"username"]];
}

@end
