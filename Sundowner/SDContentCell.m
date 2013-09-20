
#import <QuartzCore/QuartzCore.h>
#import "SDContentCell.h"
#import "SDLikeView.h"
#import "UIColor+SDColor.h"

CGFloat const GTTitleFontSize =         22;
CGFloat const GTNormalFontSize =        14;

CGFloat const GTPaddingTopInner =       10;
CGFloat const GTPaddingBottomInner =    10;
CGFloat const GTPaddingLeftInner =      10;
CGFloat const GTPaddingRightInner =     10;
CGFloat const GTPaddingTopOuter =       5;
CGFloat const GTPaddingBottomOuter =    5;
CGFloat const GTPaddingLeftOuter =      10;
CGFloat const GTPaddingRightOuter =     10;

// this aspect ratio must be maintained for correct shape proportion (original 110x95)
static NSUInteger const kSDLikeViewWidth =      77;
static NSUInteger const kSDLikeViewHeight =     66.5;

@implementation SDContentCell {
    NSDictionary *_content;
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
        self.backgroundColor = [UIColor backgroundColor];
        
        _card = [[UIView alloc] init];
        [_card setBackgroundColor:[UIColor whiteColor]];
        _card.layer.cornerRadius = 3.0;
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
        
        UIGestureRecognizer *panGestureRecognizer =
            [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPanGesture:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *singleTapGestureRecogniser =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSingleTapGesture:)];
        singleTapGestureRecogniser.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGestureRecogniser];
        
        UITapGestureRecognizer *doubleTapGestureRecogniser =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToDoubleTapGesture:)];
        doubleTapGestureRecogniser.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecogniser];
        
        // single and double tap gestures are mutually exclusive; the cost of this is a slight delay in
        // responding to single taps
        [singleTapGestureRecogniser requireGestureRecognizerToFail:doubleTapGestureRecogniser];
    }
    return self;
}

- (void)respondToDoubleTapGesture:(UIGestureRecognizer *)recognizer
{    
    // notify the delegate that content has been vote up (so that it can notify the server)
    [self.delegate contentVotedUp:_content];
    
    // add the like view to the content view
    SDLikeView *likeView = [[SDLikeView alloc] initWithFrame:CGRectMake(0, 0, kSDLikeViewWidth, kSDLikeViewHeight)];
    likeView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    likeView.alpha = 0;
    likeView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [self addSubview:likeView];

    // animate it
    [UIView animateWithDuration:.15 animations:^{
        likeView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        likeView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            likeView.alpha = 0;
        } completion:^(BOOL finished) {
            [likeView removeFromSuperview];
        }];
    }];
}

- (void)respondToSingleTapGesture:(UIGestureRecognizer *)recognizer
{
    [self.delegate contentURLRequested:_content];
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
                [self.delegate contentVotedDown:_content];
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    // prevent vertical scrolling otherwise table scrolling won't work only allow
    // content to be scrolled to the right
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)recognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y) && translation.x > 0;
        
    } else {
        return YES;
    }
}

- (void)setContent:(NSDictionary *)content
{
    _content = content;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    NSString *titleText = _content[@"title"];
    BOOL hasURL = _content[@"url"] != nil;
    NSString *authorText = [[self class] constructAuthorString:_content];
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
