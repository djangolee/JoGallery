//
//  JOPresentAnimationTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOPresentAnimationTransition.h"
#import "JOAlbumBrowserCell.h"
#import "JOImageView.h"

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
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.hidden = YES;
    [containerView addSubview:toViewController.view];
    
    UIView *substituteView = [UIView new];
    substituteView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:substituteView];
    
    UIView *backgoundView = [[UIView alloc] initWithFrame:containerView.bounds];
    backgoundView.backgroundColor = [UIColor blackColor];
    backgoundView.alpha = 0;
    [containerView addSubview:backgoundView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.transitionView.image];
    imageView.frame = [self.transitionView convertRect:self.transitionView.bounds toView:containerView];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [containerView addSubview:imageView];
    
    substituteView.frame = imageView.frame;
    
    [UIView animateWithDuration:self.duration animations:^{
        backgoundView.alpha = 1;
    } completion:^(BOOL finished) {
        [backgoundView removeFromSuperview];
    }];
    
    [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGSize size = [JOImageView imageSizeToFit:imageView.image];
        imageView.bounds = CGRectMake(0, 0, size.width, size.height);
        imageView.center = CGPointMake(CGRectGetWidth(containerView.frame) / 2, CGRectGetHeight(containerView.frame) / 2);
    } completion:^(BOOL finished) {
        toViewController.view.hidden = NO;
        [imageView removeFromSuperview];
        [substituteView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
    
}

@end
