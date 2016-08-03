//
//  JOAnimatedTransition.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JOAnimatedTransition : NSObject <UIViewControllerTransitioningDelegate>

#pragma mark - Present
- (void)setPresentFromWithView:(UIView *)view;

#pragma mark - Dismiss
- (void)setPictureImageViewsFrame:(NSArray *)frames;

#pragma mark - Interactive
- (void)setViewController:(UIViewController *)toViewController fromWindow:(UIView *)fromView;

@end
