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

/// 富文本正文   若设置了contentText，则此项无效
@property (nonatomic, copy) NSAttributedString *attributeContent;

/// 标题颜色
@property (nonatomic, strong) UIColor *titleColor;

/// 标题字体
@property (nonatomic, strong) UIFont *titleFont;

/// 正文字体
@property (nonatomic, strong) UIFont *contentFont;

/// 正文颜色
@property (nonatomic, strong) UIColor *contentColor;


/// 添加的textFields,如果没添加，则为nil
@property (nonatomic, copy) NSArray *textFields;

/// 正文行间距，默认5
@property (nonatomic, assign) CGFloat contentLineSpace;

/// 默认 NSTextAlignmentLeft
@property (nonatomic, assign) NSTextAlignment contentAlignment;

///按钮集合
@property (nonatomic, strong) NSMutableArray <WDAlertAction *>*actions;

/// 点击背景蒙层dismiss，默认为NO
@property (nonatomic, assign) BOOL tapDismissEnable;

/// 圆角size，默认为10
@property (nonatomic, assign) CGFloat cornerRadius;

/// 背景蒙版透明度 0 ~ 1，默认0.4
@property (nonatomic, assign) CGFloat dimViewAlpha;

/// 背景蒙版颜色， 默认黑色
@property (nonatomic, strong) UIColor *dimViewColor;

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
