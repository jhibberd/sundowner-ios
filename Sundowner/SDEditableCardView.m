
#import "SDContentView.h"
#import "SDEditableCardView.h"
#import "SDGrowingTextView.h"
#import "SystemVersion.h"
#import "UIFont+SDFont.h"

@implementation SDEditableCardView {
    UIEdgeInsets _contentTextViewEdgeInsets;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.0;
        
        // disable older layout mechanism otherwise auto layout doesn't work
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        // in order for components to initially size themselves correctly they need a width
        CGFloat componentWidth = self.frame.size.width - (kSDContentViewPadding *2);
        
        // UITextView comes with inherent content inset which can't be cleanly removed. To overcome this
        // (and have better alignment of text within the UITextView and other components) the control's
        // origin and size are altered to negate the content inset. Also iOS 6.1 and iOS 7 have different
        // inherent content inset values that need to be negated.
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            _contentTextViewEdgeInsets = UIEdgeInsetsMake(-10, -5, -5, -5);
        } else {
            _contentTextViewEdgeInsets = UIEdgeInsetsMake(-8, -8, -5, -8);
        }
        
        CGPoint origin = CGPointMake(kSDContentViewPadding + _contentTextViewEdgeInsets.left,
                                     kSDContentViewPadding + _contentTextViewEdgeInsets.top);
        CGFloat contentWidth = componentWidth -
                               (_contentTextViewEdgeInsets.left + _contentTextViewEdgeInsets.right);
        _contentTextView = [[SDGrowingTextView alloc] initWithWidth:contentWidth origin:origin delegate:self];
        _contentTextView.font = [UIFont titleFont];
        [_contentTextView sizeHeightToContent];
        [self addSubview:_contentTextView];
        
        // construct the author string
        NSString *username = [[[NSUserDefaults class] standardUserDefaults] stringForKey:@"username"];
        NSString *authorText = [NSString stringWithFormat:@"by %@", username];
        
        _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, componentWidth, 0)];
        _authorLabel.text = authorText;
        _authorLabel.textColor = [UIColor lightGrayColor];
        _authorLabel.font = [UIFont normalFont];
        _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_authorLabel sizeToFit];
        [self addSubview:_authorLabel];
         
        // define vertical layout constraints
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_contentTextView, _authorLabel);
        NSString *format = [NSString stringWithFormat:@"V:[_contentTextView]-(%f)-[_authorLabel]",
                            _contentTextViewEdgeInsets.bottom];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDictionary]];
        
        // align left points of all components
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_authorLabel
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_contentTextView
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:-_contentTextViewEdgeInsets.left]];
    }
    return self;
}

- (void)growingTextViewDidChangeHeight
{
    // if the textview grows in height then this view also must grow (see intrinsicContentSize)
    [self invalidateIntrinsicContentSize];
}

- (void)urlLinkDidChangeHeight
{
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    CGFloat height = (kSDContentViewPadding *2) +
                     _contentTextView.frame.size.height +
                     (_contentTextViewEdgeInsets.top + _contentTextViewEdgeInsets.bottom) +
                     _authorLabel.frame.size.height;
    return CGSizeMake(self.frame.size.width, height);
}

@end
