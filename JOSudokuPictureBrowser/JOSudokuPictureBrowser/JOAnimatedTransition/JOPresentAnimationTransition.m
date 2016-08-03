//
//  JOPresentAnimationTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOPresentAnimationTransition.h"

@interface JOPresentAnimationTransition ()

@property (nonatomic) NSTimeInterval duration;

@end

@implementation JOPresentAnimationTransition

#pragma mark - Lief cycle
- (instancetype)initWithDuration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        _duration = duration;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [containerView addSubview:fromViewController.view];
    
    UIView *substituteView = [UIView new];
    substituteView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:substituteView];
    
    UIView *markView = [[UIView alloc] initWithFrame:containerView.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 0;
    [containerView addSubview:markView];
    
    UIView *snapshotView = [self.transitionView snapshotViewAfterScreenUpdates:NO];
    CGRect fromRect = [self.transitionView convertRect:self.transitionView.bounds toView:[UIApplication sharedApplication].keyWindow];
    CGRect transitionBounds = CGRectMake(0, 0, CGRectGetWidth(containerView.frame), CGRectGetWidth(containerView.frame));
    CGPoint transtionCenter = CGPointMake(CGRectGetWidth(containerView.frame) / 2, CGRectGetHeight(containerView.frame) / 2);
    snapshotView.frame = fromRect;
    substituteView.frame = fromRect;
    [containerView addSubview:snapshotView];
    
    [UIView animateWithDuration:self.duration animations:^{
        markView.alpha = 1;
    }];
    [UIView animateWithDuration:self.duration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        snapshotView.bounds = transitionBounds;
        snapshotView.center = transtionCenter;
    } completion:^(BOOL finished) {
        [markView removeFromSuperview];
        [snapshotView removeFromSuperview];
        [substituteView removeFromSuperview];
        [containerView addSubview:toViewController.view];
        [transitionContext completeTransition:YES];
    }];
}

@end
