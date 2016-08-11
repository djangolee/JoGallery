//
//  JOAlbumBrowserViewController.m
//  JOSudokuPictureBrowser
//
//  Created by Django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "Masonry.h"
#import "YYWebimage.h"
#import "JOAlbumBrowserCell.h"
#import "JOPictureSouceModel.h"
#import "JOAlbumBrowserViewController.h"

static NSString * const ContentSizeKeyPath = @"contentSize";
static void * contentSizeKey = &contentSizeKey;


@interface JOAlbumBrowserViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JOImageViewTransformDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *substituteView;
@property (nonatomic, strong) UILabel *pageNumLabel;
@property (nonatomic, strong) UIView *maskView;

@end

@implementation JOAlbumBrowserViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self addObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addObservers {
    [self.collectionView addObserver:self forKeyPath:ContentSizeKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:contentSizeKey];
}

- (void)removeObservers {
    [self.collectionView removeObserver:self forKeyPath:ContentSizeKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == contentSizeKey) {
        CGSize oldSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
        if (!CGSizeEqualToSize(oldSize, newSize)) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:NO];
            self.pageNumLabel.text = [NSString stringWithFormat:@"%lu / %ld", self.currentIndex + 1, self.albumSouce.count];
        }
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumSouce.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JOAlbumBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JOAlbumBrowserCell class]) forIndexPath:indexPath];
    [cell showWithModel:self.albumSouce[indexPath.item]];
    [cell setImageViewDelegate:self];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = [self.collectionView indexPathsForVisibleItems].firstObject.item;
    self.pageNumLabel.text = [NSString stringWithFormat:@"%ld / %ld", [self.collectionView indexPathsForVisibleItems].firstObject.item + 1, self.albumSouce.count];
}

#pragma mark - JOImageViewTransformDelegate

- (void)beganTransformOfRecognizer:(UIGestureRecognizer *)recognizer {
    self.currentImageView = (UIImageView *)recognizer.view;
    self.substituteView.frame = [self.imageViewFrames[self.currentIndex] CGRectValue];
}

- (void)changedTransformOfRecognizer:(UIGestureRecognizer *)recognizer {
    CGAffineTransform transform = recognizer.view.transform;
    CGFloat scale = sqrt(transform.a * transform.a + transform.c * transform.c);
    self.maskView.alpha = scale;
    
    self.currentImageView = (UIImageView *)recognizer.view;
    self.currentTransform = recognizer.view.transform;
    self.currentFrame = [recognizer.view convertRect:recognizer.view.bounds toView:self.view];
    
    
}

- (void)endedTransformOfRecognizer:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        CGFloat scale = sqrt(self.currentTransform.a * self.currentTransform.a + self.currentTransform.c * self.currentTransform.c);
        if (scale < 0.9) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            self.currentImageView = nil;
            [UIView animateWithDuration:0.25 animations:^{
                self.maskView.alpha = 1;
            }];
        }
    }
}
- (void)longPressOfRecognizer:(UIGestureRecognizer *)recognizer {
    
}

- (void)singlePressOfRecognizer:(UIGestureRecognizer *)recognizer {
    [self beganTransformOfRecognizer:recognizer];
    self.currentTransform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    self.currentFrame = [recognizer.view convertRect:recognizer.view.bounds toView:self.view];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doublePressOfRecognizer:(UIGestureRecognizer *)recognizer {
    
}


#pragma mark - Initialize subviews and make subviews for layout

- (void)setupView {
    [self addSubviews];
    [self makeSubviewsLayout];
}

- (void)addSubviews {
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageNumLabel];
}

- (void)makeSubviewsLayout {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.pageNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 28));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(15);
    }];
}

#pragma mark - Setter and getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundView = nil;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[JOAlbumBrowserCell class] forCellWithReuseIdentifier:NSStringFromClass([JOAlbumBrowserCell class])];
    }
    return _collectionView;
}

- (UILabel *)pageNumLabel {
    if (!_pageNumLabel) {
        _pageNumLabel =[UILabel new];
        _pageNumLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _pageNumLabel.font = [UIFont systemFontOfSize:14];
        _pageNumLabel.textAlignment = NSTextAlignmentCenter;
        _pageNumLabel.textColor = [UIColor whiteColor];
    }
    return _pageNumLabel;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_backgroundView) {
        [_backgroundView removeFromSuperview];
    }
    backgroundView.frame = self.view.bounds;
    self.maskView.frame = backgroundView.bounds;
    [self.view insertSubview:backgroundView atIndex:0];
    [backgroundView addSubview:self.substituteView];
    [backgroundView addSubview:self.maskView];
    
    _backgroundView = backgroundView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

- (UIView *)substituteView {
    if (!_substituteView) {
        _substituteView = [UIView new];
        _substituteView.backgroundColor = [UIColor whiteColor];
    }
    return _substituteView;
}

- (UIImageView *)currentImageView {
    if (!_currentImageView) {
        _currentImageView = ((JOAlbumBrowserCell *)[self.collectionView visibleCells].firstObject).imageView;
    }
    return _currentImageView;
}

@end
