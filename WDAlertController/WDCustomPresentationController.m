//
//  WDCustomPresentationController.m
//  WDAlertController
//
//  Created by donglei on 2019/9/18.
//  Copyright © 2019 donglei. All rights reserved.
//

#import "WDCustomPresentationController.h"

@interface WDCustomPresentationController ()

@property (nonatomic, strong) UIView *dimView;

@end

@implementation WDCustomPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.dimViewAlpha = 0.6;
        self.dimViewColor = [UIColor blackColor];
        self.rectCorner = UIRectCornerAllCorners;
        self.cornerSize = CGSizeMake(0, 0);
        self.heightScale = 1;
        self.tapDismissEnable = NO;
    }
    return self;
}

//容器视图 将要布局子控件
- (void)containerViewWillLayoutSubviews {
    
    //获取容器视图
    UIView *contanerView = self.containerView;
    
    //获取展示的控制器的View
    UIView *presentedView = self.presentedView;
    [contanerView addSubview:presentedView];
    presentedView.frame = CGRectMake(0, CGRectGetHeight(contanerView.bounds) * (1 - _heightScale), CGRectGetWidth(contanerView.bounds), CGRectGetHeight(contanerView.bounds) * _heightScale);
    
    //修改展示控制器的VIew的frame 或者  mas
    if (_constrainBlock) {
//        [presentedView mas_makeConstraints:_constrainBlock];
        [presentedView mas_updateConstraints:_constrainBlock];
        [contanerView layoutIfNeeded];
    }
    
    // 其他设置
    if (self.configSet) {
        self.configSet(presentedView);
    }
    
    // 设置圆角
    if (!CGSizeEqualToSize(_cornerSize, CGSizeMake(0, 0)) ) {
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: presentedView.bounds byRoundingCorners:_rectCorner cornerRadii:_cornerSize];
        // 创建 layer
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = presentedView.bounds;
        //赋值
        maskLayer.path = maskPath.CGPath;
        presentedView.layer.mask = maskLayer;
    }
    
    // 设置蒙版颜色 改变透明度
    self.dimView.backgroundColor = self.dimViewColor;
    self.dimView.alpha = self.dimViewAlpha;
    
}

- (UIView *)dimView {
    if (!_dimView) {
        _dimView = [[UIView alloc] init];
        [self.containerView insertSubview:_dimView atIndex:0];
        [_dimView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.offset(0);
        }];
        if (self.tapDismissEnable) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [_dimView addGestureRecognizer:tap];
        }
    }
    return _dimView;
}

//销毁控制器
- (void)tapAction:(UITapGestureRecognizer *)sender {
    [self.presentedViewController.view endEditing:YES];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
