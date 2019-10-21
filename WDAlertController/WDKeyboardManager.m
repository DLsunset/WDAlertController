//
//  WDKeyboardManager.m
//  
//
//  Created by 董雷 on 2019/9/26.
//  Copyright © 2019 董雷. All rights reserved.
//

#import "WDKeyboardManager.h"

@implementation WDKeyboardManager

{
    NSHashTable *_observers;
}

+ (instancetype)defaultManager {
    static WDKeyboardManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WDKeyboardManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChange:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChange:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}
# pragma mark - add/remove observer
- (void)addObserver:(id<WDKeyboardDelegate>)observer {
    [_observers addObject:observer];
}

- (void)removeObserver:(id<WDKeyboardDelegate>)observer {
    [_observers removeObject:observer];
}

# pragma mark - keyboardWillChange
- (void)keyboardWillChange:(NSNotification *)info {
    WDKeyboardInfo prama;
    prama.fromFrame = [info.userInfo[@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    prama.toFrame = [info.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    prama.animationDuration = [info.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    for (id<WDKeyboardDelegate>observer in _observers) {
        if ([observer respondsToSelector:@selector(keyboardWillChangeWithInfo:)]) {
            [observer keyboardWillChangeWithInfo:prama];
        }
    }
}

@end
