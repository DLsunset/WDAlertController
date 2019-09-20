//
//  WDAlertController.m
//
//
//  Created by donglei on 2019/8/28.
//  Copyright © 2019 donglei All rights reserved.
//

#import "WDAlertController.h"
#import "WDCustomPresentationController.h"
@interface WDAlertController ()<UIViewControllerTransitioningDelegate,UITextViewDelegate,UIViewControllerAnimatedTransitioning,CALayerDelegate>

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *content;
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, copy) void(^contentHandler)(NSString *url,NSRange range);

@end

@implementation WDAlertController

+ (instancetype)alertWithTitle:(NSString *)title content:(NSString *)content actions:(NSArray <WDAlertAction *>*)actions {
    WDAlertController *alert = [[WDAlertController alloc] init];
    alert.titleText = title;
    alert.contentText = content;
    [alert.actions addObjectsFromArray:actions];
    return alert;
}

+ (instancetype)alertWithTitle:(NSString *)title content:(NSString *)content actionName:(NSString *)actionName ActionHandle:(void(^)(WDAlertAction *action))handler cancel:(BOOL)showCancel{
    WDAlertController *alert = [[WDAlertController alloc] init];
    alert.titleText = title;
    alert.contentText = content;
    WDAlertAction *cancel = [WDAlertAction actionWithTitle:@"取消" Font:nil attributeTitle:nil handler:nil];
    WDAlertAction *action = [WDAlertAction actionWithTitle:actionName Font:nil attributeTitle:nil handler:handler];
    if (showCancel) {
        [alert.actions addObjectsFromArray:@[action, cancel]];
    }else {
        [alert.actions addObject:action];
    }
    return alert;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        self.contentFont = [UIFont systemFontOfSize:15];
        self.contentColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        self.contentLineSpace = 5;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        
    }
    return self;
}

- (void)show {
    [self presentVc:self];
}

- (void)presentVc:(UIViewController *)vc {
    [[self getUsefulController:[self topViewController]]  presentViewController:vc animated:YES completion:nil];
}

//获取顶层可用的控制器
- (UIViewController *)getUsefulController:(UIViewController *)vc {
    if (vc.isBeingDismissed) {
        return  [self getUsefulController:vc.presentingViewController];
    }
    return vc;
}

//获取最顶层控制器
- (UIViewController *)topViewController{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //****************** title ******************
    UILabel *title = [[UILabel alloc] init];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
    if (self.titleText) title.text = _titleText;
    if (self.titleFont) title.font = _titleFont;
    if (self.attributeTitle)  title.attributedText = _attributeTitle;
    if (self.titleColor) title.textColor = _titleColor;
    
    CGFloat titleHeight = [title sizeThatFits:CGSizeMake(260, 100)].height + 45;
    if (title.text.length == 0 && title.attributedText.length == 0) {
        titleHeight = 25;
    }
    [self.view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.height.offset(titleHeight);
        make.top.offset(0);
        make.width.offset(260);
    }];
    
    //****************** content ******************
    UITextView *content = [[UITextView alloc] init];
    content.delegate = self;
    content.editable = NO;
    if (self.contentText) content.text = _contentText;
    if (self.contentFont) content.font = _contentFont;
    if (self.attributeContent)  content.attributedText = _attributeContent;
    
    CGFloat contentHeight = [content sizeThatFits:CGSizeMake(260, 400)].height + 25;
    if (content.text.length == 0 && content.attributedText.length == 0) {
        contentHeight = 0;
    }
    [self.view addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(title.mas_bottom).offset(0);
        make.height.offset(contentHeight);
        make.width.offset(260);
    }];
    
    //***************** 按钮 *******************
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.equalTo(content.mas_bottom);
        make.height.offset(55).priority(500);
    }];
    
    if (self.actions.count == 0) {
    }else if (self.actions.count == 1) {
        UIButton *btn = [self creatBtnWithAction:self.actions[0] withTag:0];
        [backView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.offset(0);
            make.top.offset(1);
        }];
    }else {
        NSMutableArray *actionBtnArr = [NSMutableArray array];
        for (int i = 0; i < self.actions.count; i++) {
            UIButton *btn = [self creatBtnWithAction:self.actions[i] withTag:i];
            [actionBtnArr addObject:btn];
            [backView addSubview:btn];
        }
        [actionBtnArr mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.top.offset(1);
        }];
        [actionBtnArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:1 leadSpacing:0 tailSpacing:0];
    }
    
    _titleLabel = title;
    _content = content;
    
    [self updateHeight];
}

//MARK: 更新计算高度
- (void)updateHeight {
    
    CGFloat height = .0;
    
    //如果有标题，那就根据  文本高度+45  来确定标题需要的高度，如果没有标题则需要 25 的空白高度
    if (_titleLabel.text.length || _titleLabel.attributedText.length) {
        height += [_titleLabel sizeThatFits:CGSizeMake(260, 100)].height + 45;
    }else {
        height += 25;
    }
    
    //如果有内容，那内容高度为 文本高度+25， 没有内容，则为0
    if (_content.text.length || _content.attributedText.length) {
        height += [_content sizeThatFits:CGSizeMake(260, 400)].height + 25;
    }
    height += 55;
    _height = height;
}

//MARK: 创建按钮
- (UIButton *)creatBtnWithAction:(WDAlertAction *)action withTag:(NSInteger)tag{
    
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.tag = tag;
    [btn setTitle:action.title forState:UIControlStateNormal];
    [btn setTitleColor:action.titleColor forState:UIControlStateNormal];
    btn.titleLabel.font = action.font;
    [btn setAttributedTitle:action.attributeTitle forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)actionClick:(UIButton *)sender {
    WDAlertAction *action = self.actions[sender.tag];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (action.handler) {
        action.handler(action);
    }
}

- (void)addAction:(WDAlertAction *)action {
    [self.actions addObject:action];
}

- (void)addActionWithTitle:(NSString *)title handler:(void (^)(WDAlertAction * _Nonnull))handler {
    [self.actions addObject:[WDAlertAction actionWithTitle:title handler:handler]];
}

- (void)setAttributeContent:(NSAttributedString *)attributeContent linkAction:(void(^)(NSString *url,NSRange range))handler {
    self.attributeContent = attributeContent;
    self.contentHandler = handler;
}

# pragma mark ================== textView delegate ======================

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    self.contentHandler([URL scheme], characterRange);
    return NO;
}

# pragma mark ================== setter/getter ======================

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
}

- (void)setAttributeTitle:(NSAttributedString *)attributeTitle {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeTitle];
    [string addAttribute:NSFontAttributeName value:_titleFont range:NSMakeRange(0, string.length)];
    _attributeTitle = string;
}

- (void)setContentText:(NSString *)contentText {
    _contentText = contentText;
    [self resetContentText];
}

- (void)setAttributeContent:(NSAttributedString *)attributeContent {
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeContent];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _contentLineSpace;// 字体的行间距
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName value:_contentFont range:NSMakeRange(0, string.length)];
    _attributeContent = string;
    
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
}

- (void)setContentFont:(UIFont *)contentFont {
    _contentFont = contentFont;
    [self resetContentText];
}

- (void)setContentColor:(UIColor *)contentColor {
    _contentColor = contentColor;
    [self resetContentText];
}

- (void)resetContentText {
    if (_contentText.length == 0) {
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_contentText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _contentLineSpace;// 字体的行间距
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName value:_contentFont range:NSMakeRange(0, string.length)];
    [string addAttribute:NSForegroundColorAttributeName value:_contentColor range:NSMakeRange(0, string.length)];
    _attributeContent = string;
}

- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}


#pragma mark ========== 设置自定义转场delegete ==========

//给系统提供 你要自定义的转场控制器
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    WDCustomPresentationController *present = [[WDCustomPresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
    present.constrainBlock = ^(MASConstraintMaker * _Nonnull make) {
        make.center.offset(0);
        make.width.offset(295);
        make.height.offset(self->_height);
    };
    present.dimViewAlpha = .2;
    present.rectCorner = UIRectCornerAllCorners;
    present.cornerSize = CGSizeMake(10, 10);
    
    return present;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

# pragma mark ================== UIViewControllerAnimatedTransitioning ======================
//返回动画事件
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}
//所有的过渡动画事务都在这个方法里面完成
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{

    //取出转场前后的视图控制器
    UIViewController * fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //取出转场前后视图控制器上的视图view
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    //这里有个重要的概念containerView，要做转场动画的视图就必须要加入containerView上才能进行，可以理解containerView管理着所有做转场动画的视图
    UIView *containerView = [transitionContext containerView];
    
    if (fromVC == self) {  //dismiss
        [containerView addSubview:fromView];
        containerView.alpha = 1;
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromView.transform = CGAffineTransformMakeScale(1.05, 1.05);
            containerView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else { //被present
        [containerView addSubview:toView];
        toView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        containerView.alpha = 0;
        [UIView animateWithDuration:.25 animations:^{
            toView.transform = CGAffineTransformIdentity;
            containerView.alpha = 1;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end

# pragma mark ================== WDAlertAction ======================

@implementation WDAlertAction

+ (instancetype)actionWithTitle:(nullable NSString *)title Font:(nullable UIFont *)font attributeTitle:(nullable NSAttributedString *)attributeTitle handler:(void (^ __nullable)(WDAlertAction *action))handler {
    
    WDAlertAction *action = [[WDAlertAction alloc] init];
    [action setDefaultValue];
    action.title = title;
    if (font) action.font = font;
    action.attributeTitle = attributeTitle;
    action.handler = handler;
    return action;
}

+ (instancetype)actionWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(WDAlertAction *action))handler {
    WDAlertAction *action = [[WDAlertAction alloc] init];
    [action setDefaultValue];
    action.title = title;
    action.handler = handler;
    return action;
}

- (void)setDefaultValue{
    self.titleColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
    self.font = [UIFont systemFontOfSize:18];
}

@end
