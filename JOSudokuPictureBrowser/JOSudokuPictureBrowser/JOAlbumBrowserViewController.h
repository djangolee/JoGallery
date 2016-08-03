//
//  JOAlbumBrowserViewController.h
//  JOSudokuPictureBrowser
//
//  Created by Django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JOPictureSouceModel;

@interface JOAlbumBrowserViewController : UIViewController

@property (nonatomic, strong) NSArray<JOPictureSouceModel *> *albumSouce;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic) NSUInteger currentIndex;

@end
