//
//  WDKeyboardManager.h
//  Demo
//
//  Created by 董雷 on 2019/9/26.
//  Copyright © 2019 董雷. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    CGRect fromFrame; ///< Keyboard frame before transition.
    CGRect toFrame;   ///< Keyboard frame after transition.
    NSTimeInterval animationDuration;       ///< Keyboard transition animation duration.
} WDKeyboardInfo;

@protocol WDKeyboardDelegate <NSObject>

- (void)keyboardWillChangeWithInfo:(WDKeyboardInfo)info;

@end

@interface WDKeyboardManager : NSObject

+ (instancetype)defaultManager;

- (void)addObserver:(id<WDKeyboardDelegate>)observer;
- (void)removeObserver:(id<WDKeyboardDelegate>)observer;

@end

NS_ASSUME_NONNULL_END
