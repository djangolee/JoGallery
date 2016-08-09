//
//  JOAnimatedTransition.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JOAlbumBrowserViewController;

@interface JOAnimatedTransition : NSObject <UIViewControllerTransitioningDelegate>

#pragma mark - Present

- (void)setPresentFromWithView:(UIImageView *)view;

#pragma mark - Dismiss

- (void)setPictureImageViewsFrame:(NSArray *)frames;

#pragma mark - Interactive

- (void)setViewController:(JOAlbumBrowserViewController *)toViewController fromWindow:(UIView *)fromView;

@end
