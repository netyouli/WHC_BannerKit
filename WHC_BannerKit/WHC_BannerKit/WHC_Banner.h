//
//  WHC_Banner.h
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

#import <UIKit/UIKit.h>

/**
 * 说明:页指示器位置
 */
typedef NS_OPTIONS(NSUInteger, WHCBannerPageViewPosition) {
    Left = 1 << 0,
    Centre = 1 << 1,
    Right = 1 << 2,
};

/**
 * 说明: 加载网络图片回调块
 */

typedef void (^WillLoadingNetworkImageBlock)(UIImageView * imageView, NSString * url ,NSInteger index);

/**
 * 说明: 点击图片回调
 */

typedef void (^ClickImageViewBlock)(UIImageView * imageView, NSInteger index);

@class WHC_Banner;

/**
 * 说明:加载网络图片代理
 */

@protocol WHC_BannerDelegate <NSObject>

@optional
/**
 * 说明:将要加载网络图片
 * @param banner 当前轮播视图
 * @param imageView 当前图片视图
 * @param url 当前图片视图要加载的图片Url
 * @param index 当前图片的下标
 */

- (void)WHC_Banner:(WHC_Banner *)banner networkLoadingWithImageView:(UIImageView *)imageView
          imageUrl:(NSString *)url
             index:(NSInteger)index;



/**
 * 说明:点击图片回调
 * @param banner 当前轮播视图
 * @param imageView 当前图片视图
 * @param index 当前图片的下标
 */
- (void)WHC_Banner:(WHC_Banner *)banner
    clickImageView:(UIImageView *)imageView
             index:(NSInteger)index;
@end

/**
 * 说明:轮播视图类
 */
@interface WHC_Banner : UIView

/// 轮播网络加载代理
@property (nonatomic ,weak)id<WHC_BannerDelegate> delegate;

/// 页指示器位置(默认Center)
@property (nonatomic ,assign)WHCBannerPageViewPosition pageViewPosition;

/// 轮播周期(默认 5s)
@property (nonatomic ,assign)NSTimeInterval interval;

/// 自定义图片显示宽度(此参数在iPad上比较常 注:iPad比较宽图片拉宽容易变形所以一般用同时显示3张图片进行轮播)
@property (nonatomic ,assign)CGFloat imageWidth;

/// 本地图片数组(注:该数组可以是图片名称数组也可以是UIImage对象数组)
@property (nonatomic ,copy)NSArray * images;

/// 本地图片标题数组(注:可以为nil)
@property (nonatomic ,copy)NSArray * imageTitles;

/// 网络图片数组(注:数组元素为图片url字符串)
@property (nonatomic ,copy)NSArray * imageUrls;

/// 设置页指示器背景颜色
@property (nonatomic ,strong)UIColor * pageViewBackgroundColor;

/// 页指示器未选中圆点颜色
@property(nonatomic,strong) UIColor *pageIndicatorTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

/// 页指示器选中圆点颜色
@property(nonatomic,strong) UIColor *currentPageIndicatorTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;

/**
 * 说明: 初始化轮播视图
 * @param frame 轮播视图位置和大小
 * @param width 自定义图片显示宽度
 */

- (instancetype)initWithFrame:(CGRect)frame imageWidth:(CGFloat)width;

/**
 * 说明: 设置加载网络图片回调块
 * @param callBack 回调块
 */

- (void)setNetworkLoadingImageBlock:(WillLoadingNetworkImageBlock)callBack;

/**
 * 说明: 设置点击图片回调块
 * @param callBack 回调块
 */

- (void)setClickImageViewBlock:(ClickImageViewBlock)callBack;

/**
 * 说明: 开始进行图片轮播
 */

- (void)startBanner;


@end
