//
//  JOAlbumBrowserCell.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/2/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOImageView.h"

@class JOPictureSouceModel;

@interface JOAlbumBrowserCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

- (void)setImageViewDelegate:(id <JOImageViewTransformDelegate>)delegate;
- (void)showWithModel:(JOPictureSouceModel *)model;

@end
