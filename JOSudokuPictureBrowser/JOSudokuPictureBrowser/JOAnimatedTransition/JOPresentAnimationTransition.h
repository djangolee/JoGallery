//
//  JOPresentAnimationTransition.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JOPresentAnimationTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) UIImageView *transitionView;

- (instancetype)initWithDuration:(NSTimeInterval)duration;

@end
