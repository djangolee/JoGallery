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

@interface JOAlbumBrowserViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *pageNumLabel;

@end

@implementation JOAlbumBrowserViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:NO];
    self.pageNumLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.currentIndex + 1, self.albumSouce.count];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumSouce.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JOAlbumBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JOAlbumBrowserCell class]) forIndexPath:indexPath];
    __weak __typeof (self) weakSelf = self;
    [cell showWithModel:self.albumSouce[indexPath.item]];
    cell.clickBolck = ^ {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
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

- (UIImageView *)currentImageView {
    JOAlbumBrowserCell *cell = [self.collectionView visibleCells].firstObject;
    return cell.pictureImageView;
}



@end
