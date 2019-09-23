//
//  WDCustomPresentationController.h
//  WDAlertController
//
//  Created by donglei on 2019/9/18.
//  Copyright © 2019 donglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
NS_ASSUME_NONNULL_BEGIN

@interface WDCustomPresentationController : UIPresentationController

/**
 高度比例占屏幕高度的比例值 0 ~ 1，默认为 1。若设置自定义约束布局，则此设置无效。
 */
@property (nonatomic, assign) CGFloat heightScale;

/**
 自定义modal控制器的大小布局
 */
@property (nonatomic, copy) void(^constrainBlock)(MASConstraintMaker *make);

/**
 其他设置，把要展示的view传出来，随便设置
 */
@property (nonatomic, copy) void(^configSet)(UIView *presentedView);

/**
 设置圆角的选择，默认为UIRectCornerAllCorners
 */
@property (nonatomic, assign) UIRectCorner rectCorner;

/**
 圆角size，默认为(0,0)
 */
@property (nonatomic, assign) CGSize cornerSize;

/**
 背景蒙版透明度 0 ~ 1，默认0.6
 */
@property (nonatomic, assign) CGFloat dimViewAlpha;

/**
 背景蒙版颜色， 默认黑色
 */
@property (nonatomic, strong) UIColor *dimViewColor;

/**
 是否可以点击蒙版处来dismiss, 默认是YES
 */
@property (nonatomic, assign) BOOL tapDismissEnable;


@end

NS_ASSUME_NONNULL_END
