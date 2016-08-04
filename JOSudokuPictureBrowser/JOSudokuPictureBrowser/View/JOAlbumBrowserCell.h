//
//  JOAlbumBrowserCell.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/2/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JOPictureSouceModel, YYAnimatedImageView;

@interface JOAlbumBrowserCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView *pictureImageView;
@property (nonatomic, copy) void (^clickBolck)();

- (void)showWithModel:(JOPictureSouceModel *)model;
+ (CGSize)imageSizeToFit:(UIImage *)image;

@end
