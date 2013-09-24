
#import "SDContentView.h"
#import "UIColor+SDColor.h"
#import "UIFont+SDFont.h"

CGFloat const kSDContentViewPadding = 10;

@implementation SDContentView {
    UILabel *_text;
    UILabel *_author;
}

// A UITableViewController needs to know in advance (of autolayout) the heights of all visible cells.
// This method (tied somewhat to the autolayout constraints algorithm) will calculate the height consumed
// by each piece of content once it has been layed out using the autolayout algorithm.
+ (CGFloat)calculateContentHeight:(NSDictionary *)content constrainedByWidth:(CGFloat)width
{
    NSString *titleText = content[@"title"];
    NSString *authorText = [NSString stringWithFormat:@"by %@", content[@"username"]];
    CGSize constraint = CGSizeMake(width - (kSDContentViewPadding *2), MAXFLOAT);
    CGSize titleSize = [titleText sizeWithFont:[UIFont titleFont] constrainedToSize:constraint];
    CGSize authorSize = [authorText sizeWithFont:[UIFont normalFont] constrainedToSize:constraint];
    return titleSize.height + authorSize.height + (kSDContentViewPadding *2);
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
        NSArray *constaintFormats = @[
            [NSString stringWithFormat:@"V:|-%f-[_text]-0-[_author]-%f-|", kSDContentViewPadding, kSDContentViewPadding],
            [NSString stringWithFormat:@"|-%f-[_text]-%f-|", kSDContentViewPadding, kSDContentViewPadding],
            [NSString stringWithFormat:@"|-%f-[_author]-%f-|", kSDContentViewPadding, kSDContentViewPadding],
            [NSString stringWithFormat:@"[self(%f)]", self.frame.size.width]
            ];
        for (NSString *constaintFormat in constaintFormats) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constaintFormat
                                                                         options:0
                                                                         metrics:nil
                                                                           views:variableBindings]];
        }
        
        // ensure height of UILabel grows to fit the text with autolayout
        // http://stackoverflow.com/questions/16009405/uilabel-sizetofit-doesnt-work-with-autolayout-ios6
        _text.lineBreakMode = NSLineBreakByWordWrapping;
        _text.preferredMaxLayoutWidth = self.frame.size.width - (kSDContentViewPadding *2);
        [_text setContentHuggingPriority:UILayoutPriorityRequired
                                 forAxis:UILayoutConstraintAxisVertical];
        [_text setContentCompressionResistancePriority:UILayoutPriorityRequired
                                               forAxis:UILayoutConstraintAxisVertical];
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
