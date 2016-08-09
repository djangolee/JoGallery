//
//  JOInteractiveTransition.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOAlbumBrowserViewController.h"

/**
 *  交互式转场， 由于UIPercentDrivenInteractiveTransition只支持单一的转场 利用CAMediaTiming协议进行转场进度控制，不好完成我们的需求
 */
@interface JOInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, weak) JOAlbumBrowserViewController *toViewController;
@property (nonatomic, strong) UIView *fromView;
@property (nonatomic) BOOL interacting;

@end
