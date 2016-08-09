//
//  JOAnimatedTransition.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOAnimatedTransition.h"
#import "JOInteractiveTransition.h"
#import "JODismissAnimationTransition.h"
#import "JOPresentAnimationTransition.h"

static CGFloat const duration = 0.5;

@interface JOAnimatedTransition ()

@property (nonatomic, strong) JOPresentAnimationTransition *presentAnimationTransition;
@property (nonatomic, strong) JODismissAnimationTransition *dismissAnimationTransition;
@property (nonatomic, strong) JOInteractiveTransition *interactiveTransition;

@end

@implementation JOAnimatedTransition

#pragma mark - Present

- (void)setPresentFromWithView:(UIImageView *)view {
    self.presentAnimationTransition.transitionView = view;
}

#pragma mark - Dismiss

- (void)setPictureImageViewsFrame:(NSArray *)frames {
    self.dismissAnimationTransition.pictureFrames = frames;
}

#pragma mark - Interactive

- (void)setViewController:(JOAlbumBrowserViewController *)toViewController fromWindow:(UIView *)fromView {
    self.interactiveTransition.toViewController = toViewController;
    self.interactiveTransition.fromView = fromView;
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.presentAnimationTransition;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.dismissAnimationTransition;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

#pragma mark - Setter and getter

- (JOPresentAnimationTransition *)presentAnimationTransition {
    if (!_presentAnimationTransition) {
        _presentAnimationTransition = [[JOPresentAnimationTransition alloc] initWithDuration:duration];
    }
    return _presentAnimationTransition;
}

- (JODismissAnimationTransition *)dismissAnimationTransition {
    if (!_dismissAnimationTransition) {
        _dismissAnimationTransition = [[JODismissAnimationTransition alloc] initWithDuration:duration];
    }
    return _dismissAnimationTransition;
}

- (JOInteractiveTransition *)interactiveTransition {
    if (!_interactiveTransition) {
        _interactiveTransition = [JOInteractiveTransition new];
    }
    return _interactiveTransition;
}

@end
