//
//  JOSudokuPictureView.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "JOAlbumBrowserViewController.h"
#import "JOAnimatedTransition.h"
#import "JOSudokuPictureView.h"
#import "JOPictureSouceModel.h"
#import "YYWebImage.h"

static CGFloat const itemSpacing = 5;
NSString * const JOSudokuPicturePlaceholderImageName = @"default";

@interface JOSudokuPictureView ()

@property (nonatomic, strong) NSMutableArray<YYAnimatedImageView *> *pictureImageViews;
@property (nonatomic, strong) JOAnimatedTransition *animatedTransition;

@end

@implementation JOSudokuPictureView

#pragma mark - Over ride
- (void)layoutSubviews {
    [super layoutSubviews];
    [self jo_sizeToFit];
    [self makePicturesLayout];
}

#pragma mark - Public methods
- (void)showAlbumWithPictures:(NSArray<JOPictureSouceModel *> *)models {
    self.albumSouce = models;
    for (JOPictureSouceModel *model in self.albumSouce) {
        NSUInteger index = [self.albumSouce indexOfObject:model];
        [self.pictureImageViews[index] yy_setImageWithURL:[NSURL URLWithString:model.img_300] placeholder:[UIImage imageNamed:JOSudokuPicturePlaceholderImageName]];
    }
}

+ (CGFloat)heightWithModels:(NSArray<JOPictureSouceModel *> *)models width:(CGFloat)width {
    if (models.count == 0 || width <= 0) {
        return 0;
    }
    CGFloat height = 0;
    CGFloat itemHeight = [[self class] itemHeightWithModels:models width:width];
    switch (models.count) {
        case 1:
        case 2:
        case 3:
            height = itemHeight;
            break;
        case 4:
        case 5:
        case 6:
            height = itemHeight * 2 + itemSpacing;
            break;
        default:
            height = itemHeight * 3 + itemSpacing * 2;
            break;
    }
    return height;
}

+ (CGFloat)itemHeightWithModels:(NSArray<JOPictureSouceModel *> *)models width:(CGFloat)width {
    if (models.count == 0 || width <= 0) {
        return 0;
    }
    CGFloat itemHeight = 0;
    switch (models.count) {
        case 1:
            itemHeight = width / 2;
            break;
        case 2:
        case 4:
            itemHeight = (width - itemSpacing) / 2;
            break;
        default:
            itemHeight = (width - 2 * itemSpacing) / 3;
            break;
    }
    return itemHeight;
}

#pragma mark - Private methods
- (void)refuelPictureImageView {
    if (self.pictureImageViews.count >= self.albumSouce.count) {
        return;
    }
    NSUInteger refuelNumber = self.albumSouce.count - self.pictureImageViews.count;
    for (NSUInteger index = 0; index < refuelNumber; index ++) {
        YYAnimatedImageView *pictureImageView = [YYAnimatedImageView new];
        pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        pictureImageView.userInteractionEnabled = YES;
        pictureImageView.clipsToBounds = YES;
        pictureImageView.hidden = YES;
        [pictureImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureClick:)]];
        [self addSubview:pictureImageView];
        [self.pictureImageViews addObject:pictureImageView];
    }
}

- (void)makePicturesLayout {
    CGFloat itemHeight = [[self class] itemHeightWithModels:self.albumSouce width:CGRectGetWidth(self.frame)];
    
    for (YYAnimatedImageView *pictureImageView in self.pictureImageViews) {
        NSUInteger index = [self.pictureImageViews indexOfObject:pictureImageView];
        pictureImageView.hidden = !(index < self.albumSouce.count);
        if (index < self.albumSouce.count) {
            pictureImageView.bounds = CGRectMake(0, 0, itemHeight, itemHeight);
            pictureImageView.center = [self pictureCenterWithIndex:index];
        }
    }
}

- (CGPoint)pictureCenterWithIndex:(NSUInteger)index {
    CGFloat itemHeight = [[self class] itemHeightWithModels:self.albumSouce width:CGRectGetWidth(self.frame)];
    CGPoint center = CGPointZero;
    switch (self.albumSouce.count) {
        case 1:
            center = CGPointMake(CGRectGetWidth(self.frame) / 2, itemHeight / 2);
            break;
        case 2:
        case 3:
            center = CGPointMake(itemHeight / 2 + (itemSpacing + itemHeight) * index, itemHeight / 2);
            break;
        case 4:
            center = CGPointMake(itemHeight / 2 + (itemSpacing + itemHeight) * (index % 2), itemHeight / 2 + (itemSpacing + itemHeight) * (index / 2));
            break;
        case 5:
        case 6:
            center = CGPointMake(itemHeight / 2 + (itemSpacing + itemHeight) * (index % 3), itemHeight / 2 + (itemSpacing + itemHeight) * (index / 3));
            break;
        case 7:
        case 8:
        case 9:
            center = CGPointMake(itemHeight / 2 + (itemSpacing + itemHeight) * (index % 3), itemHeight / 2 + (itemSpacing + itemHeight) * (index / 3));
            break;
    }
    return center;
}

- (void)jo_sizeToFit {
    CGFloat height = [[self class] heightWithModels:self.albumSouce width:CGRectGetWidth(self.frame)];
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (NSArray<NSValue *> *)pictureFrames {
    NSMutableArray *frames = [NSMutableArray new];
    for (YYAnimatedImageView *pictureImageView in self.pictureImageViews) {
        CGRect frame = [pictureImageView convertRect:pictureImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    return frames;
}

#pragma mark - Touch methods
- (void)pictureClick:(UITapGestureRecognizer *)recognizer {
    self.animatedTransition = nil;
    JOAlbumBrowserViewController *viewController = [JOAlbumBrowserViewController new];
    viewController.albumSouce = self.albumSouce.copy;
    viewController.currentIndex = [self.pictureImageViews indexOfObject:(YYAnimatedImageView *)recognizer.view];
    viewController.transitioningDelegate = self.animatedTransition;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
    [self.animatedTransition setPictureImageViewsFrame:[self pictureFrames]];
    [self.animatedTransition setPresentFromWithView:recognizer.view];
    [self.animatedTransition setViewController:viewController fromWindow:[[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:NO]];
}

#pragma mark - Setter and getter
- (NSMutableArray<YYAnimatedImageView *> *)pictureImageViews {
    if (!_pictureImageViews) {
        _pictureImageViews = [[NSMutableArray alloc] initWithCapacity:9];
    }
    return _pictureImageViews;
}

- (void)setAlbumSouce:(NSArray<JOPictureSouceModel *> *)albumSouce {
    _albumSouce = albumSouce;
    [self refuelPictureImageView];
    [self makePicturesLayout];
}

- (JOAnimatedTransition *)animatedTransition {
    if (!_animatedTransition) {
        _animatedTransition = [JOAnimatedTransition new];
    }
    return _animatedTransition;
}

@end
