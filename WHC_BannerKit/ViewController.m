//
//  ViewController.m
//  WHC_BannerKit
//
//  Created by 吴海超 on 16/4/14.
//  Copyright © 2016年 吴海超. All rights reserved.
//

/*************************************************************
 *                                                           *
 *  qq:712641411                                             *
 *  开发作者: 吴海超(WHC)                                      *
 *  iOS技术交流群:302157745                                    *
 *  gitHub:https://github.com/netyouli/WHC_AutoLayoutKit     *
 *                                                           *
 *************************************************************/

#import "ViewController.h"
#import "WHC_Banner.h"

@interface ViewController ()<WHC_BannerDelegate> {
    WHC_Banner * _banner1, * _banner2, * _banner3, * _banner4;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"WHC";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat bannerHeight = (CGRectGetHeight([UIScreen mainScreen].bounds) - 64) / 4;
    
    _banner1 = [[WHC_Banner alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), bannerHeight)];
    _banner1.imageWidth = CGRectGetWidth([UIScreen mainScreen].bounds) / 2;
    _banner1.images = @[@"banner-2.jpg",@"banner-1.jpg",@"banner-0.jpg"];
    _banner1.pageIndicatorTintColor = [UIColor redColor];
    _banner1.currentPageIndicatorTintColor = [UIColor greenColor];
    [self.view addSubview:_banner1];
    [_banner1 startBanner];
    
    _banner2 = [[WHC_Banner alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_banner1.frame) + 2, CGRectGetWidth([UIScreen mainScreen].bounds), bannerHeight)];
    _banner2.images = @[@"banner-1.jpg",@"banner-0.jpg",@"banner-2.jpg"];
    _banner2.imageTitles = @[@"WHC优秀开源项目",@"WHC_iOS",@"WHC_android"];
    [self.view addSubview:_banner2];
    [_banner2 startBanner];
    
    
    _banner3 = [[WHC_Banner alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_banner2.frame) + 2, CGRectGetWidth([UIScreen mainScreen].bounds), bannerHeight)];
    _banner3.images = @[@"banner-2.jpg",@"banner-0.jpg",@"banner-1.jpg"];
    _banner3.imageTitles = @[@"WHC优秀开源项目",@"WHC_iOS",@"WHC_android"];
    _banner3.pageViewPosition = Left;
    [self.view addSubview:_banner3];
    [_banner3 startBanner];
    
    _banner4 = [[WHC_Banner alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_banner3.frame) + 2, CGRectGetWidth([UIScreen mainScreen].bounds), bannerHeight)];
    [self.view addSubview:_banner4];
    _banner4.images = @[@"banner-0.jpg",@"banner-1.jpg",@"banner-2.jpg"];
    _banner4.pageViewBackgroundColor = [UIColor clearColor];
    [_banner4 startBanner];
    
    /// 加载网络图片
    // _banner4.imageUrls = @[@"http://....image.png",@"http://....image.png",@"http://....image.png",@"http://....image.png"];
    /*
         _banner4.delegate = self;
     */
    
    // 或者下面方式
    
    /*
        [_banner4 setNetworkLoadingImageBlock:^(UIImageView *imageView, NSString *url, NSInteger index) {
            // 这里加载网络图片操作 以YYWebImage为例
            //[imageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"default.png"]];
        }];
     */
    
    // [_banner4 startBanner];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WHC_BannerDelegate -

- (void)WHC_Banner:(WHC_Banner *)banner networkLoadingWithImageView:(UIImageView *)imageView
          imageUrl:(NSString *)url
             index:(NSInteger)index {
    // 这里加载网络图片操作 以YYWebImage为例
    //[imageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"default.png"]];
}

@end
