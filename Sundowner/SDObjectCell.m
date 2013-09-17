
#import <QuartzCore/QuartzCore.h>
#import "SDObjectCell.h"
#import "UIColor+SDColor.h"

CGFloat const GTTitleFontSize =         22;
CGFloat const GTNormalFontSize =        14;

CGFloat const GTPaddingTopInner =       10;
CGFloat const GTPaddingBottomInner =    10;
CGFloat const GTPaddingLeftInner =      10;
CGFloat const GTPaddingRightInner =     10;
CGFloat const GTPaddingTopOuter =       10;
CGFloat const GTPaddingBottomOuter =    0;
CGFloat const GTPaddingLeftOuter =      10;
CGFloat const GTPaddingRightOuter =     10;

@implementation SDObjectCell {
    NSDictionary *_object;
    UIView *_card;
    
    // for managing the horizontal scrolling (voting down) of content
    CGPoint _originalCenter;
    BOOL _voteDownOnDragRelease;
}

+ (CGFloat)estimateHeightForObject:(NSDictionary *)object constrainedByWidth:(CGFloat)width
{
    // padding is defined internally within this class so should be applied here
    width -= (GTPaddingLeftInner + GTPaddingRightInner + GTPaddingLeftOuter + GTPaddingRightOuter);
    NSString *titleText = object[@"title"];
    NSString *authorText = [self constructAuthorString:object];
    CGFloat titleHeight = [self estimateHeightForTitle:titleText constrainedByWidth:width];
    CGFloat authorHeight = [self estimateHeightForAuthor:authorText constrainedByWidth:width];
    return GTPaddingTopOuter + GTPaddingTopInner + titleHeight + authorHeight + GTPaddingBottomInner + GTPaddingBottomOuter;
}

+ (CGFloat)estimateHeightForTitle:(NSString *)titleText constrainedByWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, INT_MAX); // effectively unbounded height
    CGSize size = [titleText sizeWithFont:[UIFont systemFontOfSize:GTTitleFontSize] constrainedToSize:constraint];
    return size.height;
}

+ (CGFloat)estimateHeightForAuthor:(NSString *)authorText constrainedByWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, INT_MAX);
    CGSize size = [authorText sizeWithFont:[UIFont systemFontOfSize:GTNormalFontSize] constrainedToSize:constraint];
    return size.height;
}

+ (NSString *)constructAuthorString:(NSDictionary *)object
{
    return [NSString stringWithFormat:@"by %@", object[@"username"]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _card = [[UIView alloc] init];
        [_card setBackgroundColor:[UIColor whiteColor]];
        [_card.layer setCornerRadius:3.0f];
        [self addSubview:_card];
        
        self.title = [[UILabel alloc] init];
        self.title.font = [UIFont systemFontOfSize:GTTitleFontSize];
        self.title.numberOfLines = 0; // infinite
        [self.title setBackgroundColor:[UIColor clearColor]];
        [_card addSubview:self.title];
        
        self.author = [[UILabel alloc] init];
        self.author.font = [UIFont systemFontOfSize:GTNormalFontSize];
        self.author.textColor = [UIColor lightGrayColor];
        self.author.numberOfLines = 0;
        [self.author setBackgroundColor:[UIColor clearColor]];
        [_card addSubview:self.author];
        
        UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPanGesture:)];
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer
{
    // prevent vertical scrolling otherwise table scrolling won't work
    // only allow content to be scrolled to the right
    CGPoint translation = [recognizer translationInView:self];
    return fabs(translation.x) > fabs(translation.y) && translation.x > 0;
}

- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            _originalCenter = self.center;
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self];
            if (translation.x > 0) {
                self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
                // if the content has been dragged at least half the cell width then proceed to vote down
                // the content when the user releases their finger
                _voteDownOnDragRelease = translation.x > (self.frame.size.width / 2);
            } else {
                self.center = _originalCenter;
                _voteDownOnDragRelease = NO;
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            if (_voteDownOnDragRelease) {
                // inform the containing table that the content has been voted down so that it can be removed
                [self.delegate contentVotedDown:_object];
            } else {
                // return the content to its original position
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = _originalCenter;
                }];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)setObject:(NSDictionary *)object
{
    _object = object;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    NSString *titleText = _object[@"title"];
    BOOL hasURL = _object[@"url"] != nil;
    NSString *authorText = [[self class] constructAuthorString:_object];
    CGFloat widthConstraint = self.frame.size.width -
    (GTPaddingLeftInner + GTPaddingRightInner + GTPaddingLeftOuter + GTPaddingRightOuter);
    
    CGFloat titleHeight = [[self class] estimateHeightForTitle:titleText constrainedByWidth:widthConstraint];
    CGFloat authorHeight = [[self class] estimateHeightForAuthor:authorText constrainedByWidth:widthConstraint];
    
    // cell can't be interacted with if it doesn't have a URL
    [self setUserInteractionEnabled:hasURL];
    
    [_card setFrame:CGRectMake(GTPaddingLeftOuter,
                               GTPaddingTopOuter,
                               widthConstraint + GTPaddingLeftInner + GTPaddingRightInner,
                               titleHeight + authorHeight + GTPaddingTopInner + GTPaddingBottomInner)];
    
    CGFloat yAxisCursor = GTPaddingTopInner;
    
    self.title.text = titleText;
    [self.title setTextColor:(hasURL ? [UIColor linkColor] : [UIColor textColor])];
    [self.title setFrame:CGRectMake(GTPaddingLeftInner, yAxisCursor, widthConstraint, titleHeight)];
    yAxisCursor += titleHeight;
    
    self.author.text = authorText;
    [self.author setFrame:CGRectMake(GTPaddingLeftInner, yAxisCursor, widthConstraint, authorHeight)];
}

@end
