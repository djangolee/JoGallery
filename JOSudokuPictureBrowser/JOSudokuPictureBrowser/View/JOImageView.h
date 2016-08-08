//
//  JOImageView.h
//  GestureRecognizerDemo
//
//  Created by django on 8/5/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JOImageView;

@protocol JOImageViewTransformDelegate <NSObject>

@optional

- (void)beganTransformImageView:(UIImageView *)imageView;
- (void)imageView:(UIImageView *)imageview changeTransform:(CGAffineTransform) transform;
- (void)imageView:(UIImageView *)imageview endTransform:(CGAffineTransform) transform frame:(CGRect)frame;
- (void)longPressImageView:(UIImageView *)imageview;
- (void)singlePressimageView:(UIImageView *)imageview;
- (void)doublePressimageView:(UIImageView *)imageview;

@end

@interface JOImageView : UIView

@property (nonatomic) CGFloat minimumZoomScale;
@property (nonatomic) CGFloat maximumZoomScale;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nullable, nonatomic, strong) UIImage *image;
@property (nullable, nonatomic, strong) UIImage *placeholderImage;
@property (nullable, nonatomic, weak) id <JOImageViewTransformDelegate> delegate;

+ (CGSize)imageSizeToFit:(nullable UIImage *)image;

@end

NS_ASSUME_NONNULL_END
