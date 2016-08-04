//
//  JOInteractiveTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOInteractiveTransition.h"
#import "JOAlbumBrowserViewController.h"

@interface JOInteractiveTransition ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic) BOOL shouldComplete;

@end

@implementation JOInteractiveTransition

#pragma mark - Private methods
- (void)addPanGestureForViewController:(UIViewController *)viewController{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [viewController.view addGestureRecognizer:pan];
}


- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGFloat fraction = translation.y / CGRectGetHeight(gestureRecognizer.view.frame);
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            [self beganHandle];
            break;
        case UIGestureRecognizerStateChanged: {
            self.maskView.alpha = 1 - fabs(fraction) * 0.4;
            CGPoint center = self.snapshotView.center;
            center.y = CGRectGetHeight(self.fromView.frame) / 2 + translation.y;
            self.snapshotView.center = center;
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self endHandle:fabs(fraction) > 0.5];
        }
    }
}

- (void)beganHandle {
    self.fromView.frame = self.toViewController.view.bounds;
    self.maskView.frame = self.fromView.bounds;
    self.maskView.alpha = 1;
    UIView *tempView = ((JOAlbumBrowserViewController *)self.toViewController).currentImageView;
    self.snapshotView = [tempView snapshotViewAfterScreenUpdates:NO];
    self.snapshotView.frame = [tempView convertRect:tempView.bounds toView:[UIApplication sharedApplication].keyWindow];
    [self.fromView addSubview:self.snapshotView];
    [self.toViewController.view addSubview:self.fromView];
}

- (void)endHandle:(BOOL)dismiss {
    if (dismiss) {
        [UIView animateWithDuration:0.25 animations:^{
            self.maskView.alpha = 0;
            CGPoint center = self.snapshotView.center;
            center.y = center.y > (CGRectGetHeight(self.toViewController.view.frame) / 2) ? CGRectGetHeight(self.toViewController.view.frame) * 2 : -CGRectGetHeight(self.toViewController.view.frame);
            self.snapshotView.center = center;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.fromView];
            [self.toViewController dismissViewControllerAnimated:NO completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.fromView removeFromSuperview];
                [self.snapshotView removeFromSuperview];
                self.snapshotView = nil;
            });
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.maskView.alpha = 1;
            CGPoint center = self.snapshotView.center;
            center.y = CGRectGetHeight(self.fromView.frame) / 2;
            self.snapshotView.center = center;
        } completion:^(BOOL finished) {
            [self.fromView removeFromSuperview];
            [self.snapshotView removeFromSuperview];
            self.snapshotView = nil;
        }];
    }
}


#pragma mark - Setter and getter
- (void)setToViewController:(UIViewController *)toViewController {
    _toViewController = toViewController;
    [self addPanGestureForViewController:toViewController];
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [UIView new];
    }
    return _maskView;
}

- (void)setFromView:(UIView *)fromView {
    self.maskView.bounds = fromView.frame;
     self.maskView.backgroundColor = [UIColor blackColor];
    [fromView addSubview:self.maskView];
    _fromView = fromView;
}


@end
