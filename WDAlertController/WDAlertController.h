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

/// 标题
@property (nonatomic, copy) NSString *titleText;

/// 正文
@property (nonatomic, copy) NSString *contentText;

/// 富文本标题
@property (nonatomic, copy) NSAttributedString *attributeTitle;

/// 富文本正文
@property (nonatomic, copy) NSAttributedString *attributeContent;

/// 标题颜色
@property (nonatomic, strong) UIColor *titleColor;

/// 标题字体
@property (nonatomic, strong) UIFont *titleFont;

/// 正文字体
@property (nonatomic, strong) UIFont *contentFont;

/// 正文颜色
@property (nonatomic, strong) UIColor *contentColor;

/// 正文行间距，默认5, 只对普通文本contentText生效，对富文本attributeContent无效
@property (nonatomic, assign) CGFloat contentLineSpace;

/// 默认 NSTextAlignmentLeft
@property (nonatomic, assign) NSTextAlignment contentAlignment;

/// 点击背景蒙层dismiss，默认为NO
@property (nonatomic, assign) BOOL tapDismissEnable;

/// 设置圆角的选择，默认为UIRectCornerAllCorners
@property (nonatomic, assign) UIRectCorner rectCorner;

/// 圆角size，默认为(10,10)
@property (nonatomic, assign) CGSize cornerSize;

/// 背景蒙版透明度 0 ~ 1，默认0.2
@property (nonatomic, assign) CGFloat dimViewAlpha;

/// 背景蒙版颜色， 默认黑色
@property (nonatomic, strong) UIColor *dimViewColor;

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

/// 字体
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
