//
//  WDAlertController.m
//
//
//  Created by donglei on 2019/8/28.
//  Copyright © 2019 donglei All rights reserved.
//

#import "WDAlertController.h"
#import "WDCustomPresentationController.h"
#import "WDHeader.h"
@interface WDAlertController ()<UIViewControllerTransitioningDelegate,UITextViewDelegate,UIViewControllerAnimatedTransitioning,CALayerDelegate>

//scrollView的content高度
@property (nonatomic, assign) CGFloat height;

//UI控件
@property (nonatomic, strong) UIScrollView *backScroll;     //底层scroll
@property (nonatomic, strong) UIView *topLine;              //scrollView最上面的控件，高度为0，用于作为第一个tempView
@property (nonatomic, strong) UIView *bottomLine;           //scrollView最下面的控件, 高度为0，用于作为最后一个控件
@property (nonatomic, strong) UILabel *titleLabel;          //标题label
@property (nonatomic, strong) UITextView *content;          //内容Label
@property (nonatomic, strong) NSMutableArray *actions;      //按钮集合

@property (nonatomic, strong) UIView *tempView;

//content中富文本的Link点击事件
@property (nonatomic, copy) void(^contentHandler)(NSString *url,NSRange range);

@end

@implementation WDAlertController

# pragma mark - 构造方法
+ (instancetype)alertWithTitle:(NSString *)title content:(NSString *)content actions:(NSArray <WDAlertAction *>*)actions {
    WDAlertController *alert = [[WDAlertController alloc] init];
    alert.titleText = title;
    alert.contentText = content;
    [alert.actions addObjectsFromArray:actions];
    return alert;
}

+ (instancetype)alertWithTitle:(NSString *)title content:(NSString *)content actionName:(NSString *)actionName ActionHandle:(void(^)(WDAlertAction *action))handler cancelAction:(BOOL)showCancel{
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

- (instancetype)init {
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

# pragma mark - show
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

# pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addBackScroll];
    [self addTopLine];
    [self addTitleLabel];
    [self addContent];
    [self addBottomLine];
    
    
    [self layoutActions];   //添加按钮
    [self updateHeight];
}

# pragma mark - 懒加载

- (void)addTopLine {
    _topLine = [[UIView alloc] init];
    [self.backScroll addSubview:_topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.height.offset(0.1);
        make.width.offset(WD_SCREEN_WIDTH * .7);
    }];
    _tempView = _topLine;
}

- (void)addBottomLine {
    _bottomLine = [[UIView alloc] init];
    [self.backScroll addSubview:_topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.height.offset(0.1);
        make.top.equalTo(self.tempView.mas_bottom).offset(20);
    }];
}

- (void)addBackScroll {
    _backScroll = [[UIScrollView alloc] init];
    _backScroll.bounces = NO;
    [self.view addSubview:_backScroll];
    [_backScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.offset(0);
        make.bottom.offset(-55);
    }];
}

- (void)addTitleLabel {
    if (self.titleText.length == self.attributeTitle.length == 0) {
        return;
    }
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = WD_color_gray(17);
    if (self.titleText) _titleLabel.text = _titleText;
    if (self.titleFont) _titleLabel.font = _titleFont;
    if (self.attributeTitle)  _titleLabel.attributedText = _attributeTitle;
    if (self.titleColor) _titleLabel.textColor = _titleColor;
    
    CGFloat titleHeight = [_titleLabel sizeThatFits:CGSizeMake(WD_SCREEN_WIDTH *.7, MAXFLOAT)].height;
    [self.backScroll addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.right.offset(-15);
        make.height.offset(titleHeight);
        make.top.equalTo(self.tempView.mas_bottom).offset(20);
    }];
    _tempView = _titleLabel;
}

- (void)addContent {
    if (self.contentText.length == self.attributeContent.length == 0) {
        return;
    }
    
    _content = [[UITextView alloc] init];
    _content.delegate = self;
    _content.editable = NO;
    if (self.contentText) _content.text = _contentText;
    if (self.contentFont) _content.font = _contentFont;
    if (self.attributeContent)  _content.attributedText = _attributeContent;
    
    CGFloat contentHeight = [_content sizeThatFits:CGSizeMake(WD_SCREEN_WIDTH * .7, MAXFLOAT)].height;
    [self.backScroll addSubview:_content];
    [_content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.right.offset(-15);
        make.top.equalTo(self.tempView.mas_bottom).offset(20);
        make.height.offset(contentHeight);
        make.bottom.offset(0);
    }];
    _tempView = _content;
}

//设置actions按钮
- (void)layoutActions {
    //***************** 按钮 *******************
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = WD_color_gray(221);
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.equalTo(self.backScroll.mas_bottom);
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
}

//MARK: 更新计算高度
- (void)updateHeight {
    
    CGFloat height = .0;
    
    //加标题高度
    if (_titleLabel.text.length || _titleLabel.attributedText.length) {
        height += [_titleLabel sizeThatFits:CGSizeMake(WD_SCREEN_WIDTH * .7, MAXFLOAT)].height + 20;
    }
    //加内容高度
    if (_content.text.length || _content.attributedText.length) {
        height += [_content sizeThatFits:CGSizeMake(WD_SCREEN_WIDTH * .7, MAXFLOAT)].height + 20;
    }
    
    //加bottomLine高度
    height += 20;
    
    //加按钮高度
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

# pragma mark - textView delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    self.contentHandler([URL scheme], characterRange);
    return NO;
}

# pragma mark - setter/getter

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


#pragma mark - 设置自定义转场delegete

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

# pragma mark - UIViewControllerAnimatedTransitioning
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

# pragma mark - WDAlertAction

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
