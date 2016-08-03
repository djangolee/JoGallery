//
//  JODismissAnimationTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JODismissAnimationTransition.h"
#import "JOAlbumBrowserViewController.h"

@interface JODismissAnimationTransition ()

@property (nonatomic) NSTimeInterval duration;

@end

@implementation JODismissAnimationTransition

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
    [containerView addSubview:toViewController.view];
    
    UIView *substituteView = [UIView new];
    substituteView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:substituteView];
    
    UIView *markView = [[UIView alloc] initWithFrame:containerView.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 1;
    [containerView addSubview:markView];
    
    JOAlbumBrowserViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect pictureFrame = [self.pictureFrames[fromViewController.currentIndex] CGRectValue];
    substituteView.frame = pictureFrame;
    UIImageView *imageView = fromViewController.currentImageView;
    
    UIImageView *snapshotView = [UIImageView new];
    snapshotView.clipsToBounds = YES;
    snapshotView.contentMode = UIViewContentModeScaleAspectFill;
    snapshotView.image = imageView.image;
    snapshotView.frame = [imageView convertRect:imageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    [containerView addSubview:snapshotView];
    
    [UIView animateWithDuration:self.duration animations:^{
        snapshotView.frame = pictureFrame;
        markView.alpha = 0;
    } completion:^(BOOL finished) {
        [markView removeFromSuperview];
        [snapshotView removeFromSuperview];
        [substituteView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}


@end
