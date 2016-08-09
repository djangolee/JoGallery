//
//  JOImageView.m
//  GestureRecognizerDemo
//
//  Created by django on 8/5/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOImageView.h"

static CGFloat const minimumZoomScale = 1.0;
static CGFloat const maximumZoomScale = 2.0;

@interface JOImageView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic) CGFloat beganZoomScale;
@property (atomic) BOOL transforming;

@end

@implementation JOImageView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) { [self setup]; }
    return self;
}

#pragma mark - Over ride

- (void)layoutSubviews {
    [super layoutSubviews];
    self.image = self.image;
}

#pragma mark - Public methods

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image ? : self.placeholderImage;
    if (CGRectEqualToRect(self.frame, CGRectZero)) return;
    
    self.scrollView.contentSize = self.frame.size;
    CGSize imageSize = [[self class] imageSizeToFit:self.imageView.image];
    self.imageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    self.imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.imageView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    self.imageView.contentMode = contentMode;
}

#pragma mark - Private methods

+ (CGSize)imageSizeToFit:(nullable UIImage *)image {
    if (!image) return CGSizeZero;
    
    CGSize selfSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = image.size.width / image.size.height;
    if (image.size.width / selfSize.width > image.size.height / selfSize.height) {
        return CGSizeMake(selfSize.width, selfSize.width / scale);
    }
    return CGSizeMake(selfSize.height * scale, selfSize.height);
}

#pragma mark - Touch modth

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    CGFloat scale = sqrt(recognizer.view.transform.a * recognizer.view.transform.a + recognizer.view.transform.c * recognizer.view.transform.c);
    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            self.beganZoomScale = scale == self.minimumZoomScale ? recognizer.scale : scale;
            if (self.beganZoomScale <= self.minimumZoomScale && self.delegate && [self.delegate respondsToSelector:@selector(beganTransformImageView:)]) {
                [self.delegate beganTransformImageView:self.imageView];
            }
            [self gestureRecognizerShouldBegan:recognizer];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (self.beganZoomScale <= self.minimumZoomScale && self.delegate && [self.delegate respondsToSelector:@selector(imageView:changeTransform:)]) {
                [self.delegate imageView:self.imageView changeTransform:self.imageView.transform];
            }
            CGFloat scale = recognizer.scale;
            recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, scale, scale);
            recognizer.scale = 1.0;
            [self gestureRecognizerShouldChange:recognizer];
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self gestureRecognizerShouldEnd:recognizer];
            break;
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            [self gestureRecognizerShouldBegan:recognizer];
            break;
        case UIGestureRecognizerStateChanged: {
            if (self.beganZoomScale < self.minimumZoomScale) {
                recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
                recognizer.rotation = 0.0;
            }
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self gestureRecognizerShouldEnd:recognizer];
            break;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            [self gestureRecognizerShouldBegan:recognizer];
            break;
        case UIGestureRecognizerStateChanged: {
            self.imageView.center = CGPointMake(self.scrollView.contentSize.width / 2 + translation.x, self.scrollView.contentSize.height / 2 + translation.y);
            [self gestureRecognizerShouldChange:recognizer];
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self gestureRecognizerShouldEnd:recognizer];
            break;
    }
}

- (void)handleSinglePress:(UITapGestureRecognizer *)singlePress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(singlePressimageView:)]) {
        [self.delegate singlePressimageView:self.imageView];
    }
}

- (void)handleDoublePress:(UITapGestureRecognizer *)doublePress {
    CGFloat scale = sqrt(doublePress.view.transform.a * doublePress.view.transform.a + doublePress.view.transform.c * doublePress.view.transform.c);
    scale = scale != self.maximumZoomScale ? self.maximumZoomScale : self.minimumZoomScale;
    [self contentSizeTofFitWithScale:scale gestureRecognizer:doublePress];
    if (self.delegate && [self.delegate respondsToSelector:@selector(doublePressimageView:)]) {
        [self.delegate doublePressimageView:self.imageView];
    }
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressImageView:)]) {
        [self.delegate longPressImageView:self.imageView];
    }
}

#pragma mark - Private methods

- (void)gestureRecognizerShouldBegan:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.transforming) {
        self.transforming = YES;
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * 3, CGRectGetHeight(self.frame) * 3);
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.imageView.center = CGPointMake(self.scrollView.contentSize.width / 2, self.scrollView.contentSize.height / 2);
    }
}

- (void)gestureRecognizerShouldChange:(UIGestureRecognizer *)gestureRecognizer {

}

- (void)gestureRecognizerShouldEnd:(UIGestureRecognizer *)gestureRecognizer {
    if (self.transforming) {
        self.transforming = NO;
        CGFloat scale = sqrt(gestureRecognizer.view.transform.a * gestureRecognizer.view.transform.a + gestureRecognizer.view.transform.c * gestureRecognizer.view.transform.c);
        if (self.beganZoomScale <= self.minimumZoomScale && scale < self.minimumZoomScale && self.delegate && [self.delegate respondsToSelector:@selector(imageView:endTransform:frame:)]) {
            CGRect toFrame = [self.imageView convertRect:self.imageView.bounds toView:[UIApplication sharedApplication].keyWindow];
            [self.delegate imageView:self.imageView endTransform:self.imageView.transform frame:toFrame];
        }
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * 3, CGRectGetHeight(self.frame) * 3);
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.center = CGPointMake(self.scrollView.contentSize.width / 2, self.scrollView.contentSize.height / 2);
        }];
        if (scale > self.maximumZoomScale) {
            scale = self.maximumZoomScale;
        } else if (scale < self.minimumZoomScale) {
            scale = self.minimumZoomScale;
        }
        [self contentSizeTofFitWithScale:scale gestureRecognizer:gestureRecognizer];
    }
}

- (void)contentSizeTofFitWithScale:(CGFloat)scale  gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.25 animations:^{
        gestureRecognizer.view.transform = CGAffineTransformMake(scale, 0, 0, scale, 0, 0);
    }];
    
    CGRect frame = [gestureRecognizer.view convertRect:gestureRecognizer.view.bounds toView:self];
    CGSize size = frame.size;
    CGSize contentSize = self.frame.size;
    CGPoint midOffset = CGPointZero;
    if (CGRectGetWidth(frame) > CGRectGetWidth(self.frame)) {
        contentSize.width = CGRectGetWidth(frame);
        midOffset.x = (contentSize.width - CGRectGetWidth(self.frame)) / 2;
    }
    if (CGRectGetHeight(frame) > CGRectGetHeight(self.frame)) {
        contentSize.height = CGRectGetHeight(frame);
        midOffset.y = (contentSize.height - CGRectGetHeight(self.frame)) / 2;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentSize = contentSize;
        self.imageView.frame = CGRectMake((contentSize.width - size.width) / 2, (contentSize.height - size.height) / 2, size.width, size.height);
        self.scrollView.contentOffset = midOffset;
    }];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*) otherGestureRecognizer {
    return [self.imageView.gestureRecognizers containsObject:gestureRecognizer] && [self.imageView.gestureRecognizers containsObject:otherGestureRecognizer];
}


- (void)bingCustomGestureRecognizerWithView:(UIView *)view {
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

#pragma mark - Initialize subviews and make subviews for layout

- (void)setup {
    [self addSubviews];
    [self makeSubviewsLayout];
    [self bingCustomGestureRecognizerWithView:self.imageView];
    self.minimumZoomScale = minimumZoomScale;
    self.maximumZoomScale = maximumZoomScale;
}

- (void)addSubviews {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
}

- (void)makeSubviewsLayout {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerXLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerYLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *widthLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *heightLayout = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self addConstraints:@[centerXLayout, centerYLayout, widthLayout, heightLayout]];
}

#pragma mark - Setter and getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale {
    if (minimumZoomScale < 0) {
        minimumZoomScale = 1;
    }
    _minimumZoomScale = minimumZoomScale;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale {
    if (maximumZoomScale < 0) {
        maximumZoomScale = 1;
    }
    _maximumZoomScale = maximumZoomScale;
}

@end
