//
//  JOAlbumBrowserViewController.h
//  JOSudokuPictureBrowser
//
//  Created by Django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JOPictureSouceModel;

extern NSString * const JOAlbumBrowserNoitifaction;

@interface JOAlbumBrowserViewController : UIViewController

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSArray<JOPictureSouceModel *> *albumSouce;
@property (nonatomic, strong) NSArray *imageViewFrames;
@property (nonatomic, weak) UIImageView *currentImageView;
@property (nonatomic) CGAffineTransform currentTransform;
@property (nonatomic) CGRect currentFrame;
@property (nonatomic) NSUInteger currentIndex;

@end
