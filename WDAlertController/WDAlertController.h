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

/**
 标题
 */
@property (nonatomic, copy) NSString *titleText;

/**
 正文
 */
@property (nonatomic, copy) NSString *contentText;

/**
 富文本标题
 */
@property (nonatomic, copy) NSAttributedString *attributeTitle;

/**
 富文本正文
 */
@property (nonatomic, copy) NSAttributedString *attributeContent;

/**
 标题颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 标题字体
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 正文字体
 */
@property (nonatomic, strong) UIFont *contentFont;

/**
 正文颜色
 */
@property (nonatomic, strong) UIColor *contentColor;
/**
 正文行间距，默认5
 */
@property (nonatomic, assign) CGFloat contentLineSpace;

+ (instancetype)alertWithTitle:(nullable NSString *)title content:(nullable NSString *)content actions:(NSArray <WDAlertAction *>*)actions;
+ (instancetype)alertWithTitle:(nullable NSString *)title content:(nullable NSString *)content actionName:(NSString *)actionName ActionHandle:(nullable void(^)(WDAlertAction *action))handler cancel:(BOOL)showCancel;
- (void)addAction:(WDAlertAction *)action;
- (void)addActionWithTitle:(NSString *)title handler:(nullable void(^)(WDAlertAction *action))handler;

- (void)show;

/**
 针对有链接点击事件的富文本

 @param attributeContent 富文本内容
 @param handler 点击链接的处理
 */
- (void)setAttributeContent:(NSAttributedString *)attributeContent linkAction:(void(^)(NSString *url,NSRange range))handler;
@end


//MARK: WDAlertAction类
@interface WDAlertAction : NSObject

/**
 按钮标题
 */
@property (nonatomic, copy) NSString *title;

/**
 按钮字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 按钮颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 按钮富文本标题
 */
@property (nonatomic, copy) NSAttributedString *attributeTitle;

/**
 按钮点击事件回调
 */
@property (nonatomic, copy) void(^handler)(WDAlertAction *action);

+ (instancetype)actionWithTitle:(nullable NSString *)title Font:(nullable UIFont *)font attributeTitle:(nullable NSAttributedString *)attributeTitle handler:(void (^ __nullable)(WDAlertAction *action))handler;
+ (instancetype)actionWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(WDAlertAction *action))handler;
@end

NS_ASSUME_NONNULL_END
