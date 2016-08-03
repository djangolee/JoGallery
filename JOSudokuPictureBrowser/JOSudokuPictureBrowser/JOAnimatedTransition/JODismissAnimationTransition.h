//
//  JODismissAnimationTransition.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JODismissAnimationTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) NSArray *pictureFrames;

- (instancetype)initWithDuration:(NSTimeInterval)duration;

@end
