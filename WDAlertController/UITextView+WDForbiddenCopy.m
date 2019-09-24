//
//  UITextView+WDForbiddenCopy.m
//  Demo
//
//  Created by 董雷 on 2019/9/24.
//  Copyright © 2019 董雷. All rights reserved.
//

#import "UITextView+WDForbiddenCopy.h"

@implementation UITextView (WDForbiddenCopy)

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    //禁用选中，复制等操作
    if(action == @selector(paste:))      return NO;
    if(action == @selector(cut:))        return NO;
    if(action == @selector(copy:))       return NO;
    if(action == @selector(select:))     return NO;
    if(action == @selector(selectAll:))  return NO;
    if(action == @selector(delete:))     return NO;
    if(action == @selector(share))       return NO;

    [self resignFirstResponder];
    
    return NO;
}

@end
