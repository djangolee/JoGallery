//
//  JOAlbumBrowserCell.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/2/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "Masonry.h"
#import "YYWebimage.h"
#import "YYImageCache.h"
#import "JOAlbumBrowserCell.h"
#import "JOPictureSouceModel.h"
#import "JOSudokuPictureView.h"

@interface JOAlbumBrowserCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIControl *maskControl;
@property (nonatomic, strong) UIButton *fullPictureButton;
@property (nonatomic, strong) JOPictureSouceModel *model;

@end

@implementation JOAlbumBrowserCell

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark - Public methods
- (void)showWithModel:(JOPictureSouceModel *)model {
    self.model = model;
    [self.pictureImageView yy_cancelCurrentImageRequest];
    BOOL fullimageDowned = [[YYImageCache sharedCache] containsImageForKey:model.origin];
    self.fullPictureButton.hidden = fullimageDowned;
    if (!fullimageDowned) {
        [self.fullPictureButton setTitle:@"Full Image" forState:(UIControlStateNormal)];
        self.fullPictureButton.enabled = YES;
    }
    NSURL *url = [NSURL URLWithString:fullimageDowned ? model.origin : model.img_300];
    [self setPictureImageWihtURL:url placeholder:[UIImage imageNamed:JOSudokuPicturePlaceholderImageName] progress:nil];
}

- (void)setPictureImageWihtURL:(NSURL *)url placeholder:(UIImage *)placeholderImage progress:(YYWebImageProgressBlock)progress {
    
    [self cancelScrollViewZoom];
    [self.pictureImageView yy_setImageWithURL:url
                                  placeholder:placeholderImage
                                      options:kNilOptions
                                     progress:progress
                                    transform:nil
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                       
        if (!error && image) {
            self.pictureImageView.image = image;
            CGSize imageSize = [[self class] imageSizeToFit:image];
            CGPoint center = self.pictureImageView.center;
            if (progress) {
                [UIView animateWithDuration:0.35 animations:^{
                    self.pictureImageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
                    self.pictureImageView.center = center;
                } completion:^(BOOL finished) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.fullPictureButton.hidden = YES;
                        self.fullPictureButton.enabled = YES;
                    });
                }];
            } else {
                self.pictureImageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
                self.pictureImageView.center = center;
            }
        }
    }];
}

+ (CGSize)imageSizeToFit:(UIImage *)image {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = image.size.width / image.size.height;
    if (image.size.width > screenSize.width || image.size.height > screenSize.height) {
        if (image.size.width > image.size.height) {
            return CGSizeMake(screenSize.width, screenSize.width / scale);
        } else {
            return CGSizeMake(screenSize.height * scale, screenSize.height);
        }
    } else {
        return image.size;
    }
}

#pragma mark - Private methods
- (void)cancelScrollViewZoom {
    self.scrollView.zoomScale = 1;
    self.maskControl.frame = self.bounds;
    self.scrollView.contentSize = self.bounds.size;
    if (CGSizeEqualToSize(self.pictureImageView.frame.size, CGSizeZero)) {
        self.pictureImageView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.maskControl.frame), (CGRectGetWidth(self.maskControl.frame)));
    }
    self.pictureImageView.center = CGPointMake(CGRectGetWidth(self.maskControl.frame) / 2, CGRectGetHeight(self.maskControl.frame) / 2);
}

- (void)scrollViewZoom1 {
    if (self.scrollView.zoomScale == 1) {
        self.scrollView.contentSize = self.bounds.size;
        self.maskControl.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        self.pictureImageView.center = CGPointMake(CGRectGetWidth(self.maskControl.frame) / 2, CGRectGetHeight(self.maskControl.frame) /2);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewGestureEnd];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self scrollViewGestureEnd];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.maskControl;
}

- (void)scrollViewGestureEnd {
    CGRect windowFrame = [UIApplication sharedApplication].keyWindow.frame;
    CGRect imageViewFrame = [self.pictureImageView convertRect:self.pictureImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    CGPoint offset = [self calculationOffset:self.scrollView.contentOffset windowFrame:windowFrame imageViewFrameForWindow:imageViewFrame];
    [self.scrollView setContentOffset:offset animated:YES];

    
}

- (CGPoint)calculationOffset:(CGPoint)offset windowFrame:(CGRect)windowFrame imageViewFrameForWindow:(CGRect)imageViewFrame {
    CGPoint midOffset = [self midOffset];
    CGFloat imageViewMinX = CGRectGetMinX(imageViewFrame);
    CGFloat imageViewMaxX = CGRectGetMaxX(imageViewFrame);
    CGFloat imageViewMinY = CGRectGetMinY(imageViewFrame);
    CGFloat imageViewMaxY = CGRectGetMaxY(imageViewFrame);
    
    if (CGRectGetWidth(imageViewFrame) < CGRectGetWidth(windowFrame)) {
        offset.x = midOffset.x;
    } else {
        if (imageViewMinX < 0 && imageViewMaxX < CGRectGetWidth(windowFrame)) {
            offset.x -= (CGRectGetWidth(windowFrame) - imageViewMaxX);
        } else if (imageViewMinX > 0 && imageViewMaxX > CGRectGetWidth(windowFrame)) {
            offset.x += imageViewMinX;
        }
    }
    
    if (CGRectGetHeight(imageViewFrame) <  CGRectGetHeight(windowFrame)) {
        offset.y = midOffset.y;
    } else {
        if (imageViewMinY < 0 && imageViewMaxY < CGRectGetHeight(windowFrame)) {
            offset.y -= (CGRectGetHeight(windowFrame) - imageViewMaxY);
        } else if (imageViewMinY > 0 && imageViewMaxY > CGRectGetHeight(windowFrame)) {
            offset.y += imageViewMinY;
        }
    }
    return offset;
}


- (CGPoint)midOffset {
    CGFloat midOffsetX = (self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame)) / 2;
    CGFloat midOffsetY = (self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.frame)) / 2;
    return CGPointMake(midOffsetX, midOffsetY);
}

#pragma mark - Event methods
- (void)markViewClick {
    if (self.clickBolck) {
        self.clickBolck();
    }
}

- (void)showFullPicture:(UIButton *)button {
    button.enabled = NO;
    [button setTitle:@"Loading..." forState:(UIControlStateNormal)];
    [self setPictureImageWihtURL:[NSURL URLWithString:self.model.origin] placeholder:self.pictureImageView.image progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        [button setTitle:[NSString stringWithFormat:@"%.2f%%", receivedSize * 100.0 / expectedSize] forState:(UIControlStateNormal)];
        if (receivedSize == expectedSize) {
            [button setTitle:@"Finsh" forState:(UIControlStateNormal)];
        }
    }];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"UIGestureRecognizerStateBegan");
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"UIGestureRecognizerStatePossible");
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"UIGestureRecognizerStateChanged");
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"UIGestureRecognizerStateEnded");
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"UIGestureRecognizerStateCancelled");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"UIGestureRecognizerStateFailed");
            break;
    }
}

- (void)handleDoublePress:(UITapGestureRecognizer *)doublePress {
    CGFloat zoomScale = self.scrollView.zoomScale == 1 ? 2 : 1;
    [self.scrollView setZoomScale:zoomScale animated:YES];
}

- (void)handleOnePress:(UITapGestureRecognizer *)onePress {
    [self markViewClick];
}


#pragma mark - Initialize subviews and make subviews for layout
- (void)setupView {
    [self addSubviews];
    [self makeSubviewsLayout];
}

- (void)addSubviews {
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.maskControl];
    [self.maskControl addSubview:self.pictureImageView];
    [self.contentView addSubview:self.fullPictureButton];
}

- (void)makeSubviewsLayout {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.fullPictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(88, 25));
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-15);
    }];
    [self cancelScrollViewZoom];
}

#pragma mark - Setter and getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIControl *)maskControl {
    if (!_maskControl) {
        _maskControl = [UIControl new];
        [_maskControl addTarget:self action:@selector(markViewClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _maskControl;
}

- (YYAnimatedImageView *)pictureImageView {
    if (!_pictureImageView) {
        _pictureImageView = [YYAnimatedImageView new];
        _pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        _pictureImageView.userInteractionEnabled = YES;
        _pictureImageView.clipsToBounds = YES;
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longRecognizer.minimumPressDuration = 1.5;
        [_pictureImageView addGestureRecognizer:longRecognizer];
        UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoublePress:)];
        doubleRecognizer.numberOfTapsRequired = 2;
        [_pictureImageView addGestureRecognizer:doubleRecognizer];
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnePress:)];
        singleRecognizer.numberOfTapsRequired = 1;
        [_pictureImageView addGestureRecognizer:singleRecognizer];
        [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    }
    return _pictureImageView;
}

- (UIButton *)fullPictureButton {
    if (!_fullPictureButton) {
        _fullPictureButton = [UIButton new];
        _fullPictureButton.layer.cornerRadius = 3;
        _fullPictureButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        _fullPictureButton.layer.borderColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.0].CGColor;
        _fullPictureButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_fullPictureButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_fullPictureButton addTarget:self action:@selector(showFullPicture:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _fullPictureButton;
}

@end
