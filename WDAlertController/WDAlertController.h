//
//  WDAlertController.h
//
//
//  Created by donglei on 2019/8/28.
//  Copyright © 2019 donglei All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class WDAlertAction;

@interface WDAlertController : UIViewController



//**************标题***************


/// 标题
@property (nonatomic, copy) NSString *titleText;

/// 标题颜色
@property (nonatomic, strong) UIColor *titleColor;

/// 标题字体    默认 PingFangSC-Semibold  17
@property (nonatomic, strong) UIFont *titleFont;

/// 富文本标题
@property (nonatomic, copy) NSAttributedString *attributeTitle;



//**************正文***************


/// 正文
@property (nonatomic, copy) NSString *contentText;

/// 富文本正文   若设置了contentText，则此项无效
@property (nonatomic, copy) NSAttributedString *attributeContent;

/// 正文字体   默认  [UIFont systemFontOfSize:15]
@property (nonatomic, strong) UIFont *contentFont;

/// 正文颜色    默认
@property (nonatomic, strong) UIColor *contentColor;

/// 正文行间距，默认5。 这个会影响 attributeContent。
@property (nonatomic, assign) CGFloat contentLineSpace;

/// 默认 NSTextAlignmentLeft。这个会影响 attributeContent。
@property (nonatomic, assign) NSTextAlignment contentAlignment;


//**************自定义view ***************

///可以和标题、正文共存，位置会在正文下面。customView需要有足够确定自身大小的约束,设置frame无效。
@property (nonatomic, strong) UIView *customView;

//**************其他设置 ***************

/// 添加的textFields,如果没添加，则为nil
@property (nonatomic, copy) NSArray *textFields;

///按钮
@property (nonatomic, strong) NSMutableArray <WDAlertAction *>*actions;

///按钮高度  默认44
@property (nonatomic, assign) CGFloat buttonHeight;

///内容的额外上边距， 默认是0
@property (nonatomic, assign) CGFloat topOffset;

///内容的额外下边距， 默认是0. 想增大边距，则设为一个正值
@property (nonatomic, assign) CGFloat bottomOffset;

/// 点击背景蒙层dismiss，默认为NO
@property (nonatomic, assign) BOOL tapDismissEnable;

/// 圆角size，默认为10
@property (nonatomic, assign) CGFloat cornerRadius;

/// 背景蒙版透明度 0 ~ 1，默认0.4
@property (nonatomic, assign) CGFloat dimViewAlpha;

/// 背景蒙版颜色， 默认黑色
@property (nonatomic, strong) UIColor *dimViewColor;

/**
 添加一个简单高斯模糊的背景，
 */
@property (nonatomic, assign) BOOL showBlurBackView;

/// 用于设置弹窗展示区域不是整个屏幕时，应有的边距。
@property (nonatomic, assign) UIEdgeInsets showAreaMarginInsets;

/// 构造方法，传入标题、内容、操作按钮
/// @param title 标题
/// @param content 内容
/// @param actions 操作
+ (instancetype)alertWithTitle:(nullable NSString *)title content:(nullable NSString *)content actions:(NSArray <WDAlertAction *>*)actions;

/// 构造方法。传入标题、内容、操作按钮名称、操作回调、是否展示取消按钮
/// @param title 标题
/// @param content 内容
/// @param actionName 操作按钮名称
/// @param handler 操作回调
/// @param showCancel 是否展示取消按钮
+ (instancetype)alertWithTitle:(nullable NSString *)title content:(nullable NSString *)content actionName:(NSString *)actionName ActionHandle:(nullable void(^)(WDAlertAction *action))handler cancelAction:(BOOL)showCancel;

/// 添加操作按钮。
/// @param action 操作action
- (void)addAction:(WDAlertAction *)action;

/// 添加操作按钮。传入名称、回调
/// @param title 名称
/// @param handler 回调
- (void)addActionWithTitle:(NSString *)title handler:(nullable void(^)(WDAlertAction *action))handler;

- (void)addActionWithTitle:(NSString *)title font:(nullable UIFont *)font color:(nullable UIColor *)titleColor handler:(nullable void(^)(WDAlertAction *action))handler;

- (void)addTextFieldWithConfigurationHandler:(void(^)(UITextField *textField))handler;

/// 以presentController的形式，展示弹窗。
- (void)show;

/// 针对有链接点击事件的富文本
/// @param attributeContent 富文本内容
/// @param handler 点击链接的回调
- (void)setAttributeContent:(NSAttributedString *)attributeContent linkAction:(void(^)(NSString *url,NSRange range))handler;
@end


# pragma mark - WDAlertAction类

@interface WDAlertAction : NSObject

/// 标题
@property (nonatomic, copy) NSString *title;

/// 字体 默认 PingFangSC-Semibold  17
@property (nonatomic, strong) UIFont *font;

/// 文字颜色
@property (nonatomic, strong) UIColor *titleColor;

/// 富文本标题
@property (nonatomic, copy) NSAttributedString *attributeTitle;

/// 点击回调
@property (nonatomic, copy) void(^handler)(WDAlertAction *action);

/// 构造方法。传入标题、操作回调
/// @param title 标题名称
/// @param handler 操作回调
+ (instancetype)actionWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(WDAlertAction *action))handler;
@end

NS_ASSUME_NONNULL_END
