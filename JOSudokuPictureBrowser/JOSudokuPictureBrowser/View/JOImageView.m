//
//  JOImageView.m
//  CALayerDemo
//
//  Created by django on 8/10/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOImageView.h"
#import "Masonry.h"

static CGFloat const minimumZoomScale = 1.0;
static CGFloat const maximumZoomScale = 2.0;

@interface JOImageView () <UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat beganZoomScale;
@property (nonatomic) CGFloat maximumZoomScale;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation JOImageView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.image = self.image;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self imageIfLonglong];
    
    CGSize imageSize = [[self class] imageSizeToFit:self.image];
    self.imageView.image = self.image ? : self.placeholderImage;
    self.imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.scrollView.contentSize = self.frame.size;
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width / 2, self.scrollView.contentSize.height / 2);
}


#pragma mark - Private methods

+ (CGSize)imageSizeToFit:(nullable UIImage *)image {
    CGSize selfSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = image.size.width / image.size.height;
    
    if (!image) return CGSizeMake(selfSize.width, selfSize.width);
    
    if (image.size.width / selfSize.width > image.size.height / selfSize.height) {
        return CGSizeMake(selfSize.width, selfSize.width / scale);
    }
    return CGSizeMake(selfSize.height * scale, selfSize.height);
}

- (void)imageIfLonglong {
    CGSize selfSize = self.frame.size;
    CGSize imageFitSize = [[self class] imageSizeToFit:self.image];
    
    CGFloat scale = maximumZoomScale;
    if (imageFitSize.width < selfSize.width) {
        scale = selfSize.width / imageFitSize.width > scale ? selfSize.width / imageFitSize.width : scale;
    }
    if (imageFitSize.height < selfSize.height) {
        scale = selfSize.height / imageFitSize.height > scale ? selfSize.height / imageFitSize.height : scale;
    }
    self.maximumZoomScale = scale;
}

#pragma mark - GestureRecognizer methods

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {

    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            CGFloat scale = sqrt((recognizer.view.transform.a * recognizer.view.transform.a) + (recognizer.view.transform.c + recognizer.view.transform.c));
            self.beganZoomScale = scale;
            CGPoint pointTouch1 = [recognizer locationOfTouch:0 inView:recognizer.view];
            CGPoint pointTouch2 = [recognizer locationOfTouch:1 inView:recognizer.view];
            CGPoint anchorPoint = CGPointMake((pointTouch1.x + pointTouch2.x) / 2 / CGRectGetWidth(recognizer.view.frame) * scale, (pointTouch2.y + pointTouch2.y) / 2 / CGRectGetHeight(recognizer.view.frame) * scale);
            [self setAnchorPoint:anchorPoint forView:recognizer.view];
            [self gestureRecognizerShouldBegan:recognizer];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
            recognizer.scale = 1;
            [self gestureRecognizerShouldChanged:recognizer];
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self gestureRecognizerShouldEnd:recognizer];
            break;
        }
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            [self gestureRecognizerShouldBegan:recognizer];
            CGFloat scale = sqrt((recognizer.view.transform.a * recognizer.view.transform.a) + (recognizer.view.transform.c + recognizer.view.transform.c));
            CGPoint pointTouch1 = [recognizer locationOfTouch:0 inView:recognizer.view];
            CGPoint pointTouch2 = [recognizer locationOfTouch:1 inView:recognizer.view];
            CGPoint anchorPoint = CGPointMake((pointTouch1.x + pointTouch2.x) / 2 / CGRectGetWidth(recognizer.view.frame) * scale, (pointTouch2.y + pointTouch2.y) / 2 / CGRectGetHeight(recognizer.view.frame) * scale);
            [self setAnchorPoint:anchorPoint forView:recognizer.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.beganZoomScale <= minimumZoomScale) {
                self.imageView.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
                recognizer.rotation = 0.0;
                [self gestureRecognizerShouldChanged:recognizer];
                break;
            }
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self gestureRecognizerShouldEnd:recognizer];
            break;
        }
    }
    
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer  {
    static CGPoint point;
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            [self gestureRecognizerShouldBegan:recognizer];
            point = translation;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            point = CGPointMake(translation.x - point.x, translation.y - point.y);
            recognizer.view.center = CGPointMake(recognizer.view.center.x + point.x, recognizer.view.center.y + point.y);
            point = translation;
            [self gestureRecognizerShouldChanged:recognizer];
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self gestureRecognizerShouldEnd:recognizer];
            break;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressOfRecognizer:)]) {
        [self.delegate longPressOfRecognizer:recognizer];
    }
}

- (void)handleDoublePress:(UITapGestureRecognizer *)recognizer {
    CGFloat scale = sqrt((recognizer.view.transform.a * recognizer.view.transform.a) + (recognizer.view.transform.c + recognizer.view.transform.c));
    CGPoint pointTouch = [recognizer locationInView:recognizer.view];
    CGPoint anchorPoint = CGPointMake(pointTouch.x / CGRectGetWidth(recognizer.view.frame) * scale, pointTouch.y / CGRectGetHeight(recognizer.view.frame) * scale);
    [self setAnchorPoint:anchorPoint forView:recognizer.view];
    [UIView animateWithDuration:0.25 animations:^{
        if (scale == 1) {
            recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, self.maximumZoomScale, self.maximumZoomScale);
        } else {
            recognizer.view.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        }
        [self setDefaultAnchorPointforView:recognizer.view];
        self.scrollView.contentSize = [self contentSizeToFitWhitSize:recognizer.view.frame.size];
        [self adjustContentOffsetWithRect:[recognizer.view convertRect:recognizer.view.bounds toView:self] animated:NO];
        recognizer.view.center = CGPointMake(self.scrollView.contentSize.width / 2, self.scrollView.contentSize.height / 2);
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(doublePressOfRecognizer:)]) {
        [self.delegate doublePressOfRecognizer:recognizer];
    }
}

- (void)handleSinglePress:(UITapGestureRecognizer *)recognizer {
    if (recognizer.view != self.imageView) {
        recognizer = self.imageView.gestureRecognizers.firstObject;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(singlePressOfRecognizer:)]) {
        [self.delegate singlePressOfRecognizer:recognizer];
    }
}
- (void)gestureRecognizerShouldBegan:(UIGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(beganTransformOfRecognizer:)]) {
        [self.delegate beganTransformOfRecognizer:recognizer];
    }
}
- (void)gestureRecognizerShouldChanged:(UIGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(changedTransformOfRecognizer:)]) {
        [self.delegate changedTransformOfRecognizer:recognizer];
    }
}
- (void)gestureRecognizerShouldEnd:(UIGestureRecognizer *)recognizer {
    if (self.beganZoomScale <= minimumZoomScale && self.delegate && [self.delegate respondsToSelector:@selector(endedTransformOfRecognizer:)]) {
        [self.delegate endedTransformOfRecognizer:recognizer];
    }
    
    [self setDefaultAnchorPointforView:recognizer.view];
    CGFloat scale = sqrt((recognizer.view.transform.a * recognizer.view.transform.a) + (recognizer.view.transform.c * recognizer.view.transform.c));
    scale = scale < minimumZoomScale ? minimumZoomScale : scale;
    scale = scale > self.maximumZoomScale ? self.maximumZoomScale : scale;
    [UIView animateWithDuration:0.25 animations:^{
        recognizer.view.transform = CGAffineTransformMake(scale, 0, 0, scale, 0, 0);
        self.scrollView.contentSize = [self contentSizeToFitWhitSize:recognizer.view.frame.size];
        [self adjustContentOffsetWithRect:[recognizer.view convertRect:recognizer.view.bounds toView:self] animated:NO];
        recognizer.view.center = CGPointMake(self.scrollView.contentSize.width / 2, self.scrollView.contentSize.height / 2);
    }];
}

- (void)adjustContentOffsetWithRect:(CGRect)rect animated:(BOOL)animated {
    
    // y
    if (rect.size.height < CGRectGetHeight(self.frame)) {
        rect.origin.y = 0;
    } else {
        if (rect.origin.y > 0) {
            rect.origin.y = 0;
        } else {
            if (CGRectGetMaxY(rect) < CGRectGetHeight(self.frame)) {
                rect.origin.y = CGRectGetHeight(rect) - CGRectGetHeight(self.frame);
            } else {
                rect.origin.y = -rect.origin.y;
            }
        }
    }
    // x
    if (rect.size.width < CGRectGetWidth(self.frame)) {
        rect.origin.x = 0;
    } else {
        if (rect.origin.x > 0) {
            rect.origin.x = 0;
        } else {
            if (CGRectGetMaxX(rect) < CGRectGetWidth(self.frame)) {
                rect.origin.x = CGRectGetWidth(rect) - CGRectGetWidth(self.frame);
            } else {
                rect.origin.x = -rect.origin.x;
            }
        }
    }
    [self.scrollView setContentOffset:rect.origin animated:animated];
}

- (CGSize)contentSizeToFitWhitSize:(CGSize)size {
    size.width = size.width > CGRectGetWidth(self.frame) ? size.width : CGRectGetWidth(self.frame);
    size.height = size.height > CGRectGetHeight(self.frame) ? size.height : CGRectGetHeight(self.frame);
    return size;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    
    CGPoint newOrigin = view.frame.origin;
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

- (void)setDefaultAnchorPointforView:(UIView *)view {
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:view];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*) otherGestureRecognizer {
    return [self.imageView.gestureRecognizers containsObject:gestureRecognizer] && [self.imageView.gestureRecognizers containsObject:otherGestureRecognizer];
}


#pragma mark - Setup

- (void)setup {
    [self addSubviews];
    [self bindingSubviewsLayout];
    [self bindingCustomGestureRecognizerWithView:self.imageView];
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePress:)];
    [self.scrollView addGestureRecognizer:singleRecognizer];
}

- (void)addSubviews {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
}

- (void)bindingSubviewsLayout {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerXLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerYLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *widthLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *heightLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self addConstraints:@[centerXLayout, centerYLayout, widthLayout, heightLayout]];
}

- (void)bindingCustomGestureRecognizerWithView:(UIView *)view {
    view.userInteractionEnabled = YES;
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchRecognizer.delegate = self;
    [view addGestureRecognizer:pinchRecognizer];
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationRecognizer.delegate = self;
    [view addGestureRecognizer:rotationRecognizer];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    panRecognizer.maximumNumberOfTouches = 2;
    panRecognizer.minimumNumberOfTouches = 2;
    [view addGestureRecognizer:panRecognizer];
    UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longRecognizer.minimumPressDuration = 1.5;
    [view addGestureRecognizer:longRecognizer];
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoublePress:)];
    doubleRecognizer.numberOfTapsRequired = 2;
    [view addGestureRecognizer:doubleRecognizer];
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePress:)];
    singleRecognizer.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleRecognizer];
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
}

#pragma mark - Getters

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (CGFloat)maximumZoomScale {
    if (_maximumZoomScale < minimumZoomScale) {
        _maximumZoomScale = maximumZoomScale;
    }
    return _maximumZoomScale;
}

@end
