//
//  JOImageView.h
//  CALayerDemo
//
//  Created by django on 8/10/16.
//  Copyright © 2016 django. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JOImageViewTransformDelegate <NSObject>

@optional

- (void)beganTransformOfRecognizer:(UIGestureRecognizer *)recognizer;
- (void)changedTransformOfRecognizer:(UIGestureRecognizer *)recognizer;
- (void)endedTransformOfRecognizer:(UIGestureRecognizer *)recognizer;
- (void)longPressOfRecognizer:(UIGestureRecognizer *)recognizer;
- (void)singlePressOfRecognizer:(UIGestureRecognizer *)recognizer;
- (void)doublePressOfRecognizer:(UIGestureRecognizer *)recognizer;

@end

@interface JOImageView : UIView

@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *placeholderImage;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, weak, nullable) id <JOImageViewTransformDelegate> delegate;

+ (CGSize)imageSizeToFit:(nullable UIImage *)image;

@end

NS_ASSUME_NONNULL_END
