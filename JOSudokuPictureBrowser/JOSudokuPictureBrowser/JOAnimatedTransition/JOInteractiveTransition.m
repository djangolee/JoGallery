//
//  JOInteractiveTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOInteractiveTransition.h"

@interface JOInteractiveTransition ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *substituteView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) CGPoint imageViewCenter;

@end

@implementation JOInteractiveTransition

#pragma mark - Private methods

- (void)addPanGestureForViewController:(UIViewController *)viewController{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [viewController.view addGestureRecognizer:pan];
}


- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGFloat scale = 1 - fabs(translation.y / (CGRectGetHeight(self.toViewController.view.frame)));
    scale = scale < 0 ? 0 : scale;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            [self beganHandle];
            break;
        case UIGestureRecognizerStateChanged: {
            self.imageView.center = CGPointMake(self.imageViewCenter.x + translation.x * scale, self.imageViewCenter.y + translation.y);
            self.maskView.alpha = scale;
            self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self endHandle:scale < 0.9];
        }
    }
}

- (void)beganHandle {
    self.fromView.frame = self.toViewController.view.bounds;
    self.maskView.frame = self.fromView.bounds;
    self.substituteView.frame = [self.toViewController.imageViewFrames[self.toViewController.currentIndex] CGRectValue];
    self.imageView.frame = [self.toViewController.currentImageView convertRect:self.toViewController.currentImageView.bounds toView:self.toViewController.view];
    self.imageViewCenter = self.imageView.center;
    self.imageView.image = self.toViewController.currentImageView.image;
    
    [self.toViewController.view addSubview:self.fromView];
}

- (void)endHandle:(BOOL)dismiss {
    if (dismiss) {
        [UIView animateWithDuration:0.25 animations:^{
            self.maskView.alpha = 0;
            self.imageView.frame = self.substituteView.frame;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.fromView];
            [self.toViewController dismissViewControllerAnimated:NO completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.fromView removeFromSuperview];
                self.fromView = nil;
            });
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.maskView.alpha = 1;
            self.imageView.center = self.imageViewCenter;
            self.imageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        } completion:^(BOOL finished) {
            self.toViewController.currentImageView = nil;
            [self.fromView removeFromSuperview];
        }];
    }
}

#pragma mark - Setter and getter

- (void)setToViewController:(JOAlbumBrowserViewController *)toViewController {
    _toViewController = toViewController;
    [self addPanGestureForViewController:toViewController];
}

- (void)setFromView:(UIView *)fromView {
    _fromView = [fromView snapshotViewAfterScreenUpdates:NO];
    [_fromView addSubview:self.substituteView];
    [_fromView addSubview:self.maskView];
    [_fromView addSubview:self.imageView];
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

- (UIView *)substituteView {
    if (!_substituteView) {
        _substituteView = [UIView new];
        _substituteView.backgroundColor = [UIColor whiteColor];
    }
    return _substituteView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

@end
