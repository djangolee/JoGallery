//
//  JOSudokuPictureView.h
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const JOSudokuPicturePlaceholderImageName;

@class JOPictureSouceModel;

@interface JOSudokuPictureView : UIView

@property (nonatomic, strong) NSArray<JOPictureSouceModel *> *albumSouce;

- (void)showAlbumWithPictures:(NSArray<JOPictureSouceModel *> *)models;
+ (CGFloat)heightWithModels:(NSArray<JOPictureSouceModel *> *)models width:(CGFloat)width;
+ (CGFloat)itemHeightWithModels:(NSArray<JOPictureSouceModel *> *)models width:(CGFloat)width;

@end
