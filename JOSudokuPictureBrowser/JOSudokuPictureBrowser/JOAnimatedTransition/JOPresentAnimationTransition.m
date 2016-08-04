//
//  JOPresentAnimationTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOPresentAnimationTransition.h"
#import "JOAlbumBrowserCell.h"

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
    
    UIImageView *transitionImageView = [UIImageView new];
    transitionImageView.clipsToBounds = YES;
    transitionImageView.image = self.transitionView.image;
    transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    CGRect fromRect = [self.transitionView convertRect:self.transitionView.bounds toView:[UIApplication sharedApplication].keyWindow];
    CGSize transitionSize = [JOAlbumBrowserCell imageSizeToFit:transitionImageView.image];
    CGRect transitionBounds = CGRectMake(0, 0, transitionSize.width, transitionSize.height);
    CGPoint transtionCenter = CGPointMake(CGRectGetWidth(containerView.frame) / 2, CGRectGetHeight(containerView.frame) / 2);
    transitionImageView.frame = fromRect;
    substituteView.frame = CGRectMake(0, 0, CGRectGetWidth(fromRect) + 1, CGRectGetHeight(fromRect) + 1);
    substituteView.center = transitionImageView.center;
    [containerView addSubview:transitionImageView];
    
    [UIView animateWithDuration:self.duration animations:^{
        markView.alpha = 1;
        transitionImageView.bounds = transitionBounds;
        transitionImageView.center = transtionCenter;
    } completion:^(BOOL finished) {
        [markView removeFromSuperview];
        [transitionImageView removeFromSuperview];
        [substituteView removeFromSuperview];
        [containerView addSubview:toViewController.view];
        [transitionContext completeTransition:YES];
        
    } ];
}

@end
