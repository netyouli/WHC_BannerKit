//
//  WHC_Banner.m
//  WHC_BannerKit
//
//  Created by 吴海超 on 15/12/23.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*************************************************************
 *                                                           *
 *  qq:712641411                                             *
 *  开发作者: 吴海超(WHC)                                      *
 *  iOS技术交流群:302157745                                    *
 *  gitHub:https://github.com/netyouli/WHC_AutoLayoutKit     *
 *                                                           *
 *************************************************************/

#import "WHC_Banner.h"

typedef NS_OPTIONS(NSUInteger, WHCBannerOrientation) {
    None = 1 << 0,
    ScrollLeft = 1 << 1,
    ScrollRight = 1 << 2,
};

const CGFloat kPageViewHeight = 30;
const CGFloat kImageNamePading = 10;
const NSTimeInterval kDefaultInterval = 5;

@interface WHC_Banner ()<UIScrollViewDelegate>{
    UIScrollView            * _bannerView;
    UIView                  * _bottomView;
    UILabel                 * _imageNameLabel;
    UIPageControl           * _pageCtl;
    NSMutableArray          * _imageArray;
    NSMutableArray          * _imageTitleArray;
    CGFloat                   _imageWidth;
    CGFloat                   _initOffset;
    NSTimer                 * _autoTimer;
    NSInteger                 _imageCount;
    NSInteger                 _actualImageCount;
    NSInteger                 _visibleImageCount;
    NSInteger                 _currentImageIndex;
    NSInteger                 _actualImageIndex;
    NSInteger                 _initImageIndex;
    NSInteger                 _networkImageCount;
    BOOL                      _isClickAnimation;
    WHCBannerOrientation      _doingScrollOrientation;
    WillLoadingNetworkImageBlock   _netWorkCallBack;
    ClickImageViewBlock            _clickImageViewCallBack;
}

@end

@implementation WHC_Banner

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self layoutUI];
        _imageWidth = CGRectGetWidth(frame);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame imageWidth:(CGFloat)width {
    self = [self initWithFrame:frame];
    if (self) {
        _imageWidth = width;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initData];
    [self layoutUI];
    _imageWidth = CGRectGetWidth(self.bounds);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bannerView.contentInset = UIEdgeInsetsZero;
}

- (void)setImageWidth:(CGFloat)imageWidth {
    _imageWidth = MIN(CGRectGetWidth(self.bounds), imageWidth);
}

- (void)initData {
    _visibleImageCount = 1;
    _interval = kDefaultInterval;
    _pageViewPosition = Centre;
    _initOffset = 0;
    _initImageIndex = 0;
    _currentImageIndex = 0;
    _doingScrollOrientation = None;
    _imageArray = [NSMutableArray array];
    _imageTitleArray = [NSMutableArray array];
}

- (void)layoutUI {
    _bannerView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _bannerView.showsHorizontalScrollIndicator = NO;
    _bannerView.showsVerticalScrollIndicator = NO;
    _bannerView.delegate = self;
    _bannerView.bounces = YES;
    [self addSubview:_bannerView];
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                           CGRectGetHeight(self.frame) - kPageViewHeight,
                                                           CGRectGetWidth(self.frame),
                                                           kPageViewHeight)];
    _bottomView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self addSubview:_bottomView];
    _pageCtl = [[UIPageControl alloc]initWithFrame:_bottomView.bounds];
    _pageCtl.backgroundColor = [UIColor clearColor];
    [_bottomView addSubview:_pageCtl];
}

- (void)setNetworkLoadingImageBlock:(WillLoadingNetworkImageBlock)callBack {
    _netWorkCallBack = callBack;
}

- (void)setClickImageViewBlock:(ClickImageViewBlock)callBack {
    _clickImageViewCallBack = callBack;
}

- (void)setPageViewBackgroundColor:(UIColor *)pageViewBackgroundColor {
    _pageViewBackgroundColor = pageViewBackgroundColor;
    if (_bottomView && pageViewBackgroundColor) {
        _bottomView.backgroundColor = pageViewBackgroundColor;
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    if (_pageCtl && _pageIndicatorTintColor) {
        _pageCtl.pageIndicatorTintColor = _pageIndicatorTintColor;
    }
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    if (_pageCtl && _currentPageIndicatorTintColor) {
        _pageCtl.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
    }
}

- (void)autoBanner:(BOOL)isAuto {
    if (_autoTimer) {
        [_autoTimer invalidate];
        [_autoTimer fire];
        _autoTimer = nil;
    }
    if (isAuto) {
        _autoTimer = [NSTimer timerWithTimeInterval:_interval
                                             target:self
                                           selector:@selector(handleBannerTimer:)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_autoTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)handleBannerTimer:(NSTimer *)timer {
    if (_isClickAnimation && _visibleImageCount > 1) return;
    [self automaticCorrectionPosition];
}

- (void)automaticCorrectionPosition {
    _doingScrollOrientation = ScrollLeft;
    _currentImageIndex += 1;
    if (_currentImageIndex > _actualImageCount) {
        _currentImageIndex = _initImageIndex;
    }
    /// automatic correction
    CGFloat currentOffsetX = _bannerView.contentOffset.x - (NSInteger)(_bannerView.contentOffset.x / _imageWidth) * _imageWidth;
    if (currentOffsetX != _initOffset) {
        currentOffsetX = _initOffset - currentOffsetX;
    }else {
        currentOffsetX = 0;
    }
    [_bannerView setContentOffset:CGPointMake(_bannerView.contentOffset.x + _imageWidth + currentOffsetX, 0) animated:YES];
}

- (void)startBanner {
    if (_imageWidth == 0) {
        _imageWidth = CGRectGetWidth(self.bounds);
    }
    if (_images) {
        [self checkImageTitleDataWithImageCount:_images.count];
        id firstObject = _images.firstObject;
        if (firstObject != nil && [firstObject isKindOfClass:[UIImage class]]) {
            [self makeBannerLayout:_images networkImageNumber:0];
        }else if (firstObject != nil && [firstObject isKindOfClass:[NSString class]]) {
            NSMutableArray * images = [NSMutableArray array];
            for (NSString * imageName in _images) {
                UIImage * image = [UIImage imageNamed:imageName];
                [images addObject:image];
            }
            [self makeBannerLayout:images networkImageNumber:0];
        }
    }else if (_imageUrls) {
        [self checkImageTitleDataWithImageCount:_imageUrls.count];
        [self makeBannerLayout:nil networkImageNumber:_imageUrls.count];
    }
    
}

- (void)checkImageTitleDataWithImageCount:(NSUInteger)count {
    if (_imageTitles) {
        @autoreleasepool {
            NSInteger diffCount = count - _imageTitles.count;
            NSMutableArray * imageTitles = [NSMutableArray arrayWithArray:_imageTitles];
            for (NSInteger i = 0; i < diffCount; i++) {
                [imageTitles addObject:@""];
            }
            [_imageTitleArray removeAllObjects];
            [imageTitles insertObject:_imageTitles.lastObject atIndex:0];
            [imageTitles addObject:_imageTitles.firstObject];
            [_imageTitleArray addObjectsFromArray:imageTitles];
        }
    }
}

- (void)makeBannerLayout:(NSArray *)images networkImageNumber:(NSUInteger)number {
    [self autoBanner:false];
    for (UIView * subView in _bannerView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    if (images && images.count > 0) {
        [_imageArray removeAllObjects];
        [_imageArray addObject:images.lastObject];
        [_imageArray addObjectsFromArray:images];
        [_imageArray addObject:images.firstObject];
    }else if (number <= 0){
        return;
    }
    CGFloat bannerWidth = CGRectGetWidth(_bannerView.bounds);
    _networkImageCount = number;
    _actualImageCount = number > 0 ? number : images.count;
    _imageCount = number > 0 ? number + 2 : _imageArray.count;
    for (NSInteger i = 0; i < _imageCount; i++) {
        CGRect frame = CGRectMake(i * _imageWidth, 0.0, _imageWidth, CGRectGetHeight(self.bounds));
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tapGesture];
        [_bannerView addSubview:imageView];
        imageView.tag = i;
        if (_networkImageCount > 0) {
            NSInteger index = i;
            if (i == 0) {
                index = _networkImageCount - 1;
            }else if (i == _imageCount - 1) {
                index = 0;
            }else {
                index = i - 1;
            }
            if (_netWorkCallBack) {
                _netWorkCallBack(imageView,_imageUrls[index],index);
            }
            if (_delegate && [_delegate respondsToSelector:@selector(WHC_Banner:networkLoadingWithImageView:imageUrl:index:)]) {
                [_delegate WHC_Banner:self networkLoadingWithImageView:imageView imageUrl:_imageUrls[index] index:index];
            }
        }else {
            imageView.image = _imageArray[i];
        }
    }
    CGFloat startOffset = _imageWidth;
    if (_imageWidth < bannerWidth) {
        _bannerView.pagingEnabled = NO;
        _initOffset = _imageWidth - (bannerWidth - _imageWidth) / 2;
        startOffset = _initOffset;
        _initImageIndex = 1;
        _currentImageIndex = 1;
        _visibleImageCount = (NSInteger)(bannerWidth / _imageWidth);
        if (_visibleImageCount * _imageWidth < bannerWidth) {
            _visibleImageCount += 1;
        }
    }else {
        _bannerView.pagingEnabled = YES;
    }
    CGFloat pageViewWidth = CGRectGetWidth(_bottomView.frame) / 4;
    CGFloat imageNameWidth = CGRectGetWidth(_bottomView.frame) - pageViewWidth;
    if (_pageViewPosition == Centre && _imageTitles) {
        _pageViewPosition = Right;
    }
    switch (_pageViewPosition) {
        case Left: {
            _pageCtl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, pageViewWidth, CGRectGetHeight(_bottomView.frame))];
            if (_imageTitleArray) {
                _imageNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_pageCtl.frame), 0, imageNameWidth - kImageNamePading, CGRectGetHeight(_bottomView.frame))];
                _imageNameLabel.textAlignment = NSTextAlignmentRight;
            }
        }
            break;
        case Centre: {
            _pageCtl = [[UIPageControl alloc]initWithFrame:CGRectMake((CGRectGetWidth(_bottomView.frame) - pageViewWidth) / 2, 0, pageViewWidth, CGRectGetHeight(_bottomView.frame))];
        }
            break;
        case Right: {
            _pageCtl = [[UIPageControl alloc]initWithFrame:CGRectMake(CGRectGetWidth(_bottomView.frame) - pageViewWidth, 0, pageViewWidth, CGRectGetHeight(_bottomView.frame))];
            if (_imageTitleArray) {
               _imageNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kImageNamePading, 0, imageNameWidth - kImageNamePading, CGRectGetHeight(_bottomView.frame))];
                _imageNameLabel.textAlignment = NSTextAlignmentLeft;
            }
        }
            break;
        default:
            break;
    }
    _pageCtl.backgroundColor = [UIColor clearColor];
    _pageCtl.pageIndicatorTintColor = _pageIndicatorTintColor;
    _pageCtl.currentPageIndicatorTintColor = _currentPageIndicatorTintColor;
    [_bottomView addSubview:_pageCtl];
    if (_imageNameLabel) {
        _imageNameLabel.textColor = [UIColor whiteColor];
        _imageNameLabel.text = _imageTitles.firstObject;
        [_bottomView addSubview:_imageNameLabel];
    }
    
    _pageCtl.numberOfPages = _actualImageCount;
    _bannerView.contentSize = CGSizeMake(_imageCount * _imageWidth, 0);
    _bannerView.contentOffset = CGPointMake(startOffset, 0);
    [self autoBanner:YES];
}

- (void)handleTapImageView:(UITapGestureRecognizer *)tapGesture {
    
    UIImageView * imageView = (UIImageView *)tapGesture.view;
    NSInteger tag = imageView.tag;
    NSInteger index = 0;
    if (tag == 0) {
        index = _actualImageCount - 1;
    }else if (tag == _imageCount - 1) {
        index = 0;
    }else {
        index = tag - 1;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(WHC_Banner:clickImageView:index:)]) {
        [_delegate WHC_Banner:self clickImageView:imageView index:index];
    }
    if (_clickImageViewCallBack) {
        _clickImageViewCallBack(imageView,index);
    }
    if (_visibleImageCount == 1 || _isClickAnimation) return;
    _isClickAnimation = YES;
    if (tag < _actualImageIndex) {
        _doingScrollOrientation = ScrollRight;
        _currentImageIndex -= 1;
        if (_currentImageIndex < 0) {
            _currentImageIndex = _actualImageCount;
        }
        CGFloat currentOffsetX = _bannerView.contentOffset.x - (NSInteger)(_bannerView.contentOffset.x / _imageWidth) * _imageWidth;
        if (currentOffsetX == _initOffset) {
            currentOffsetX = 0;
        }else {
            currentOffsetX -= _initOffset;
        }
        [_bannerView setContentOffset:CGPointMake(_bannerView.contentOffset.x - _imageWidth - currentOffsetX, 0) animated:YES];
    }else if (tag > _actualImageIndex) {
        [self automaticCorrectionPosition];
    }else {
        _doingScrollOrientation = None;
        _isClickAnimation = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat oriX = [scrollView.panGestureRecognizer
                    velocityInView:scrollView.panGestureRecognizer.view].x;
    if (oriX > 0) {
        _doingScrollOrientation = ScrollRight;
    }else if (oriX < 0) {
        _doingScrollOrientation = ScrollLeft;
    }
    CGFloat  offsetX = scrollView.contentOffset.x;
    _currentImageIndex = (NSInteger)floor((scrollView.contentOffset.x - _imageWidth / 2.0) / _imageWidth) + 1;
    _actualImageIndex = _currentImageIndex;
    if (_currentImageIndex > 0) {
        _currentImageIndex -= 1;
    }
    if (_currentImageIndex < 0) {
        _currentImageIndex = _actualImageCount - 1;
    }
    _pageCtl.currentPage = _currentImageIndex;
    if (_imageNameLabel) {
        _imageNameLabel.text = _imageTitles[MIN(_currentImageIndex, _imageTitles.count - 1)];
    }
    
    if (offsetX <= 0) {
        /// scroll right
        if (_doingScrollOrientation == ScrollLeft) {
            return;
        }
        _bannerView.contentOffset = CGPointMake((_actualImageCount) * _imageWidth, 0);
    }else if (offsetX >= _imageWidth * (_imageCount - _visibleImageCount)) {
        /// scroll left
        if (_doingScrollOrientation == ScrollRight) {
            return;
        }
        if (_visibleImageCount > 1) {
            _bannerView.contentOffset = CGPointMake(0.5, 0);
        }else {
            _bannerView.contentOffset = CGPointMake(_visibleImageCount * _imageWidth, 0);
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_visibleImageCount > 1) {
        _isClickAnimation = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _doingScrollOrientation = None;
}

@end
