
#import <QuartzCore/QuartzCore.h>
#import "SDContentCell.h"
#import "SDLikeView.h"
#import "UIColor+SDColor.h"
#import "UIFont+SDFont.h"
#import "SDContentView.h"

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
    
    SDContentView *_contentView;
    
    // for managing the horizontal scrolling (voting down) of content
    CGPoint _originalCenter;
    BOOL _voteDownOnDragRelease;
}

+ (CGFloat)estimateHeightForObject:(NSDictionary *)object constrainedByWidth:(CGFloat)width
{
    //return 100;
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
    CGSize size = [titleText sizeWithFont:[UIFont titleFont] constrainedToSize:constraint];
    return size.height;
}

+ (CGFloat)estimateHeightForAuthor:(NSString *)authorText constrainedByWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, INT_MAX);
    CGSize size = [authorText sizeWithFont:[UIFont normalFont] constrainedToSize:constraint];
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
        
        // TODO it would be nice not to have to define the width first and rely on autolayout entirely
        // but it's not easy and so far a solution hasn't been found
        CGFloat width = self.frame.size.width - (GTPaddingLeftOuter + GTPaddingRightOuter);
        _contentView = [[SDContentView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_contentView];
        
        NSDictionary *variableBindings = NSDictionaryOfVariableBindings(_contentView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_contentView]-5-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:variableBindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_contentView]-10-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:variableBindings]];
        
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

- (void)setContent:(NSDictionary *)content
{
    _contentView.content = content;
}

# pragma mark Handling Gestures

- (void)respondToDoubleTapGesture:(UIGestureRecognizer *)recognizer
{    
    // notify the delegate that content has been vote up (so that it can notify the server)
    [self.delegate contentVotedUp:_content];
    
    // add the like view to the content view
    CGRect frame = CGRectMake(0, 0, kSDLikeViewWidth, kSDLikeViewHeight);
    SDLikeView *likeView = [[SDLikeView alloc] initWithFrame:frame];
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
    if (_content[@"url"] != nil) {
        [self.delegate contentURLRequested:_content];
    }
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
                // if the content has been dragged at least half the cell width then proceed to
                // vote down the content when the user releases their finger
                _voteDownOnDragRelease = translation.x > (self.frame.size.width / 2);
            } else {
                self.center = _originalCenter;
                _voteDownOnDragRelease = NO;
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            if (_voteDownOnDragRelease) {
                // inform the containing table that the content has been voted down so that it can
                // be removed
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

@end
