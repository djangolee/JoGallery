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

@interface ViewController ()

@property (nonatomic, strong) JOSudokuPictureView *sudokuPictureView;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
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
    self.sudokuPictureView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 300);
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
            model.img_300 = @"http://img22.mtime.cn/up/2010/06/08/113030.87522850_500.jpg";
            model.origin = @"http://www.cx8888.cn/tk/tksheying/tksheying3/tksheying3_2/tksheying3_2016.jpg";
            [_array addObject:model];
        }
    }
    return _array;
}

@end
