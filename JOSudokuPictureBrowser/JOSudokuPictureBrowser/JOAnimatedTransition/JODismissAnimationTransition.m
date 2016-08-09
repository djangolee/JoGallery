//
//  JODismissAnimationTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOImageView.h"
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
    
    UIView *maskView = [[UIView alloc] initWithFrame:containerView.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    [containerView addSubview:maskView];
    
    JOAlbumBrowserViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect toFrame = [self.pictureFrames[fromViewController.currentIndex] CGRectValue];
    CGRect fromFrame = fromViewController.currentFrame;
    CGAffineTransform transform = fromViewController.currentTransform;
    
    substituteView.frame = toFrame;
    maskView.alpha = sqrt(transform.a * transform.a + transform.c * transform.c);
    
    UIView *imageView = [[UIImageView alloc] initWithImage:fromViewController.currentImageView.image];
    imageView.clipsToBounds = YES;
    imageView.frame = fromFrame;
    imageView.transform = transform;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [containerView addSubview:imageView];
    
    [UIView animateWithDuration:self.duration / 2 animations:^{
        imageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        maskView.alpha = 0;
        imageView.frame = toFrame;
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
        [substituteView removeFromSuperview];
        [imageView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}


@end
