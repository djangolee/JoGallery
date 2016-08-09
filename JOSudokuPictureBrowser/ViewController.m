//
//  ViewController.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/1/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "ViewController.h"
#import "JOSudokuPictureView.h"
#import "JOPictureSouceModel.h"

#import "YYImageCache.h"
#import "YYWebImageManager.h"
#import "YYCache.h"
#import "Masonry.h"

@interface ViewController ()

@property (nonatomic, strong) JOSudokuPictureView *sudokuPictureView;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.sudokuPictureView mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat height = [JOSudokuPictureView heightWithModels:self.array width:CGRectGetWidth(self.view.frame)];
        make.height.mas_equalTo(height);
    }];
}

#pragma mark - Initialize subviews and make subviews for layout

- (void)setupView {
    [self addSubviews];
    [self makeSubviewsLayout];
}

- (void)addSubviews {
    [self.view addSubview:self.sudokuPictureView];
}

- (void)makeSubviewsLayout {
    [self.sudokuPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(64, 0, 0, 0));
        CGFloat height = [JOSudokuPictureView heightWithModels:self.array width:CGRectGetWidth(self.view.frame)];
        make.height.mas_equalTo(height);
    }];
}

#pragma mark - Setter and getter

- (JOSudokuPictureView *)sudokuPictureView {
    if (!_sudokuPictureView) {
        _sudokuPictureView = [JOSudokuPictureView new];
        [_sudokuPictureView showAlbumWithPictures:self.array];
    }
    return _sudokuPictureView;
}

- (NSMutableArray *)array {
    if (!_array) {
        YYImageCache *cache = [YYWebImageManager sharedManager].cache;
        [cache.memoryCache removeAllObjects];
        [cache.diskCache removeAllObjects];
        
        _array = [NSMutableArray new];
        NSUInteger number = arc4random() % 9 + 1;
        for (NSUInteger index = 0; index < number; index++) {
            JOPictureSouceModel *model = [JOPictureSouceModel new];
            model.img_300 = @"https://avatars2.githubusercontent.com/u/17513630?v=3&s=40";
            model.origin = @"https://avatars0.githubusercontent.com/u/17513630?v=3&s=460";
            [_array addObject:model];
        }
    }
    return _array;
}

@end
