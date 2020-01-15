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
#import "UITextView+WDForbiddenCopy.h"
#import "WDKeyboardManager.h"

@interface WDAlertController ()<UIViewControllerTransitioningDelegate,UITextViewDelegate,UIViewControllerAnimatedTransitioning,WDKeyboardDelegate>

//弹窗高度、宽度
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) BOOL didAppear;

//UI控件
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIScrollView *backScroll;     //底层scroll
@property (nonatomic, strong) UIView *topLine;              //scrollView最上面的控件，高度为0，用于作为第一个tempView
@property (nonatomic, strong) UIView *bottomLine;           //scrollView最下面的控件, 高度为0，用于作为最后一个控件
@property (nonatomic, strong) UILabel *titleLabel;          //标题label
@property (nonatomic, strong) UITextView *content;          //内容Label

@property (nonatomic, strong) UIView *tempView;

@property (nonatomic, strong) NSMutableArray *textFieldsArr;
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
    WDAlertAction *cancel = [WDAlertAction actionWithTitle:@"取消" handler:nil];
    WDAlertAction *action = [WDAlertAction actionWithTitle:actionName handler:handler];
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
        self.titleFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:17];
        self.contentFont = [UIFont systemFontOfSize:15];
        self.contentColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        self.contentLineSpace = 5;
        self.contentAlignment = NSTextAlignmentLeft;
        self.dimViewAlpha = .4;
        self.cornerRadius = 10;
        self.showAreaMarginInsets = UIEdgeInsetsZero;
        self.buttonHeight = 44.0;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self getUsefulController:[self topViewController]]  presentViewController:vc animated:YES completion:nil];
    });
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
    [self updateViewSize];
    
    self.view.layer.cornerRadius = self.cornerRadius;
    self.view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.view.layer.shadowRadius = 10;
    self.view.layer.shadowOpacity = .3;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.clipsToBounds = YES;
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.layer.cornerRadius = self.cornerRadius;
    self.backgroundView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    if (_showBlurBackView) {
        UIVisualEffectView *bacVE = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [self.backgroundView addSubview:bacVE];
        [bacVE mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
    
    [self resetContentText];
    
    [self addBackScroll];
    [self addTopLine];
    [self addTitleLabel];
    [self addContent];
    
    for (UITextField *textField in self.textFieldsArr) {
        [self addTextField:textField];
    }
    [self addCustomView];
    [self addBottomLine];
    
//    [self addTranslucentView];  //底部半透明蒙层
    [self layoutActions];   //添加按钮
    [self.backScroll layoutIfNeeded];
    
    [[WDKeyboardManager defaultManager] addObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat maxHeight = (WD_SCREEN_HEIGHT - WD_SafeAreaTopBar - WD_SafeAreaBottomMargin - self.showAreaMarginInsets.top - self.showAreaMarginInsets.bottom ) * .9;
    
    if (self.customView && [self.customView isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)(self.customView)).scrollEnabled = NO;
        if (self.customView.mas_height) {
            [self.customView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.offset(((UIScrollView *)(self.customView)).contentSize.height);
            }];
        }else {
            [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.offset(((UIScrollView *)(self.customView)).contentSize.height);
            }];
        }
    }
    [self.backScroll layoutIfNeeded];
    self.height = self.backScroll.contentSize.height + _buttonHeight > maxHeight ? maxHeight : self.backScroll.contentSize.height + _buttonHeight ;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.didAppear = YES;
}

- (void)dealloc {
    [[WDKeyboardManager defaultManager] removeObserver:self];
}

# pragma mark - 控件加载
- (void)addBackScroll {
    _backScroll = [[UIScrollView alloc] init];
    _backScroll.bounces = NO;
    [self.backgroundView addSubview:_backScroll];
    [_backScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.offset(0);
        make.bottom.offset(-_buttonHeight);
    }];
}
//MARK: topLine
- (void)addTopLine {
    _topLine = [[UIView alloc] init];
    [self.backScroll addSubview:_topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(0.1);
        make.left.right.offset(0);
        make.top.offset(_topOffset);
        make.width.offset(self.width);
    }];
    _tempView = _topLine;
}
//MARK: bottomLine
- (void)addBottomLine {
    _bottomLine = [[UIView alloc] init];
    [self.backScroll addSubview:_bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(0.1);
        make.left.right.offset(0);
        make.bottom.offset(-_bottomOffset);
        make.top.equalTo(self.tempView.mas_bottom).offset(15);
    }];
}
//MARK: titleLabel
- (void)addTitleLabel {
    //如果没m内容，不加载控件
    if (self.titleText.length == 0 && self.attributeTitle.length == 0) return;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = WD_color_gray(17);
    
    if (self.titleText) _titleLabel.text = _titleText;
    if (self.titleFont) _titleLabel.font = _titleFont;
    if (self.attributeTitle)  _titleLabel.attributedText = _attributeTitle;
    if (self.titleColor) _titleLabel.textColor = _titleColor;
    
    CGFloat titleHeight = [_titleLabel sizeThatFits:CGSizeMake((WD_SCREEN_WIDTH - self.showAreaMarginInsets.left - self.showAreaMarginInsets.right)*.7 - 40, MAXFLOAT)].height;
    [self.backScroll addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.height.offset(titleHeight);
        make.top.equalTo(self.tempView.mas_bottom).offset(20);
    }];
    _tempView = _titleLabel;
}
//MARK: content
- (void)addContent {
    //如果没内容，不加载控件
    if (self.contentText.length == 0 && self.attributeContent.length == 0) return;
    
    _content = [[UITextView alloc] init];
    _content.backgroundColor = [UIColor clearColor];
    _content.delegate = self;
    _content.editable = NO;
    _content.scrollEnabled = NO;
    if (self.contentText) _content.text = _contentText;
    if (self.contentFont) _content.font = _contentFont;
    if (self.attributeContent)  _content.attributedText = _attributeContent;
    
    //获取textView高度
    CGFloat contentHeight = [_content sizeThatFits:CGSizeMake((WD_SCREEN_WIDTH - self.showAreaMarginInsets.left - self.showAreaMarginInsets.right)* .7 - 40, MAXFLOAT)].height;

    [self.backScroll addSubview:_content];
    [_content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.top.equalTo(self.tempView.mas_bottom).offset(10);
        make.height.offset(contentHeight);
    }];
    _tempView = _content;
}

# pragma mark - 自定义视图
- (void)addCustomView {
    if (!self.customView) {
        return;
    }
    [self.backScroll addSubview:self.customView];
    [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.top.equalTo(self.tempView.mas_bottom);
    }];
    
    _tempView = self.customView;
}

- (void)addTextFieldWithConfigurationHandler:(void(^)(UITextField *textField))handler {
    UITextField *textField = [[UITextField alloc] init];
    if (handler) {
        handler(textField);
    }
    [self.textFieldsArr addObject:textField];
}

- (void)addTextField:(UITextField *)textField {
    
    textField.layer.borderColor = WD_color_gray(200).CGColor;
    textField.layer.borderWidth = 0.5;
    textField.font = [UIFont systemFontOfSize:14];
    
    [self.backScroll addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.topMargin.equalTo(self.tempView.mas_bottom).offset(20);
        make.height.offset(30);
    }];
    _tempView = textField;
}

//MARK: 半透明图层
- (void)addTranslucentView {
    
    UIView *view = [[UIView alloc] init];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(.5, 0);
    gradient.endPoint = CGPointMake(.5, 1);
    gradient.frame = CGRectMake(0,0,WD_SCREEN_WIDTH * .7,10);
    UIColor *color1 = WD_color_rgba(255, 255, 255, 0);
    UIColor *color2 = WD_color_rgba(255, 255, 255, .7);
    gradient.colors = [NSArray arrayWithObjects:(id)color1.CGColor,(id)color2.CGColor,nil];
    [view.layer insertSublayer:gradient atIndex:0];

    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backScroll);
        make.height.offset(10);
    }];
}

//MARK: layoutActions
- (void)layoutActions {
    
    UIView *backView = [[UIView alloc] init];
    [self.backgroundView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.equalTo(self.backScroll.mas_bottom);
    }];
    
    if (self.actions.count == 0) {
        return;
    }
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = WD_color_gray(221);
    [backView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.offset(0);
        make.height.offset(0.5);
    }];
    
    if (self.actions.count == 1) {
        UIButton *btn = [self creatBtnWithAction:self.actions[0] withTag:0];
        [backView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.offset(0);
            make.top.offset(.5);
        }];
    }else {
        NSMutableArray *actionBtnArr = [NSMutableArray array];
        for (int i = 0; i < self.actions.count; i++) {
            UIButton *btn = [self creatBtnWithAction:self.actions[i] withTag:i];
            [actionBtnArr addObject:btn];
            [backView addSubview:btn];
            
            if (i < self.actions.count - 1) {
                UIView *line = [[UIView alloc] init];
                line.backgroundColor = WD_color_gray(221);
                [backView addSubview:line];
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(btn.mas_right);
                    make.top.bottom.equalTo(btn);
                    make.width.offset(0.5);
                }];
            }
        }
        [actionBtnArr mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.top.offset(.5);
        }];
        [actionBtnArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:.5 leadSpacing:0 tailSpacing:0];
    }
}

# pragma mark ----- 创建按钮 ----
- (UIButton *)creatBtnWithAction:(WDAlertAction *)action withTag:(NSInteger)tag{
    
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor clearColor];
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
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (action.handler) {
        action.handler(action);
    }
}

# pragma mark - 添加action
- (void)addAction:(WDAlertAction *)action {
    [self.actions addObject:action];
}

- (void)addActionWithTitle:(NSString *)title handler:(void (^)(WDAlertAction * _Nonnull))handler {
    [self.actions addObject:[WDAlertAction actionWithTitle:title handler:handler]];
}

- (void)addActionWithTitle:(NSString *)title font:(nullable UIFont *)font color:(nullable UIColor *)titleColor handler:(nullable void(^)(WDAlertAction *action))handler {
    WDAlertAction *action = [[WDAlertAction alloc] init];
    action.title = title;
    if (font) action.font = font;
    if (titleColor) action.titleColor = titleColor;
    action.handler = handler;
    [self.actions addObject:action];
}

# pragma mark - 设置富文本内容
- (void)setAttributeContent:(NSAttributedString *)attributeContent linkAction:(void(^)(NSString *url,NSRange range))handler {
    self.attributeContent = attributeContent;
    self.contentHandler = handler;
}

# pragma mark - textView delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (self.contentHandler) {
        self.contentHandler([URL scheme], characterRange);
    }
    return NO;
}

# pragma mark - setter/getter

- (NSMutableArray *)textFieldsArr {
    if (!_textFieldsArr) {
        _textFieldsArr = [NSMutableArray array];
    }
    return _textFieldsArr;
}

- (NSArray *)textFields {
    return _textFieldsArr.copy;
}

- (void)setAttributeTitle:(NSAttributedString *)attributeTitle {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeTitle];
    [string addAttribute:NSFontAttributeName value:_titleFont range:NSMakeRange(0, string.length)];
    _attributeTitle = string;
}

- (void)setContentAlignment:(NSTextAlignment)contentAlignment {
    _contentAlignment = contentAlignment;
    self.attributeContent = _attributeContent;
}

- (void)setAttributeContent:(NSAttributedString *)attributeContent {
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attributeContent];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _contentLineSpace;// 字体的行间距
    paragraphStyle.alignment = self.contentAlignment;
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    _attributeContent = string;
    
}

//将普通文本换成富文本，为了增加行间距。
- (void)resetContentText {
    if (_contentText.length == 0) {
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_contentText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _contentLineSpace;// 字体的行间距
    paragraphStyle.alignment = self.contentAlignment;
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

# pragma mark - 更新布局相关操作

- (void)setShowAreaMarginInsets:(UIEdgeInsets)showAreaMarginInsets {
    _showAreaMarginInsets = showAreaMarginInsets;
}

- (void)setWidth:(CGFloat)width {
    _width = width;
}

- (void)updateViewSize {
    self.width = (WD_SCREEN_WIDTH - self.showAreaMarginInsets.left - self.showAreaMarginInsets.right) * .7;
    CGFloat maxHeight = (WD_SCREEN_HEIGHT - WD_SafeAreaTopBar - WD_SafeAreaBottomMargin - self.showAreaMarginInsets.top - self.showAreaMarginInsets.bottom ) * .9;
    if (self.customView && [self.customView isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)(self.customView)).scrollEnabled = NO;
        if (self.customView.mas_height) {
            [self.customView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.offset(((UIScrollView *)(self.customView)).contentSize.height);
            }];
        }else {
            [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.offset(((UIScrollView *)(self.customView)).contentSize.height);
            }];
        }
    }
    [self.backScroll layoutIfNeeded];
    self.height = self.backScroll.contentSize.height + _buttonHeight > maxHeight ? maxHeight : self.backScroll.contentSize.height + _buttonHeight;
}

- (void)layoutSubviewsConstrain {
    [self.topLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(self.width);
    }];
    CGFloat contentHeight = [_content sizeThatFits:CGSizeMake((WD_SCREEN_WIDTH - self.showAreaMarginInsets.left - self.showAreaMarginInsets.right)* .7 - 40, MAXFLOAT)].height;
    [_content mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(contentHeight);
    }];
    CGFloat titleHeight = [_titleLabel sizeThatFits:CGSizeMake((WD_SCREEN_WIDTH - self.showAreaMarginInsets.left - self.showAreaMarginInsets.right) *.7 - 40, MAXFLOAT)].height;
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(titleHeight);
    }];
    
    if (self.didAppear) {
        [UIView animateWithDuration:.25 animations:^{
            [self.backScroll layoutIfNeeded];
        }];
    }
}

- (void)updateLayout {
    [self updateViewSize];
    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset((self.showAreaMarginInsets.top - self.showAreaMarginInsets.bottom) * .5);
        make.centerX.offset((self.showAreaMarginInsets.left - self.showAreaMarginInsets.right) * .5);
        make.width.offset(self.width);
        make.height.offset(self.height);
    }];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:.25 animations:^{
        [self.view.superview layoutIfNeeded];
    }];
    
}

# pragma mark - WDKeyboardDelegate

- (void)keyboardWillChangeWithInfo:(WDKeyboardInfo)info {
    UIEdgeInsets toEdgeInsets = self.showAreaMarginInsets;
    toEdgeInsets.bottom = WD_SCREEN_HEIGHT - info.toFrame.origin.y;
    self.showAreaMarginInsets = toEdgeInsets;
    [self updateLayout];
}
#pragma mark - 设置自定义转场delegete

//给系统提供 你要自定义的转场控制器
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    WDCustomPresentationController *present = [[WDCustomPresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
    
    present.constrainBlock = ^(MASConstraintMaker * _Nonnull make) {
        [self updateViewSize];
        [self layoutSubviewsConstrain];
        make.centerY.offset((self.showAreaMarginInsets.top - self.showAreaMarginInsets.bottom) * .5);
        make.centerX.offset((self.showAreaMarginInsets.left - self.showAreaMarginInsets.right) * .5);
        make.width.offset(self.width);
        make.height.offset(self.height);
    };
    present.tapDismissEnable = self.tapDismissEnable;
    present.dimViewAlpha = self.dimViewAlpha;
    
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
//            fromView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            containerView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else { //被present
        [containerView addSubview:toView];
        toView.transform = CGAffineTransformMakeScale(1.15, 1.15);
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
    action.title = title;
    if (font) action.font = font;
    action.attributeTitle = attributeTitle;
    action.handler = handler;
    return action;
}

+ (instancetype)actionWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(WDAlertAction *action))handler {
    WDAlertAction *action = [[WDAlertAction alloc] init];
    action.title = title;
    action.handler = handler;
    return action;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaultValue];
    }
    return self;
}

- (void)setDefaultValue{
    self.titleColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
    self.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:17];
}

@end
