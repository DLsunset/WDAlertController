//
//  WDHeader.h
//  
//
//  Created by 董雷 on 2019/9/23.
//  Copyright © 2019 董雷. All rights reserved.
//

#ifndef WDHeader_h
#define WDHeader_h

#define WD_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define WD_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define WD_SafeAreaTopBar ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 44 : 20)
#define WD_SafeAreaBottomMargin ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0)

#define WD_color_gray(gray) [UIColor colorWithRed:gray/255.0 green:gray/255.0 blue:gray/255.0 alpha:1]
#define WD_color_rgb(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define WD_color_rgba(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define WD_color_random WD_color_rgb(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


#endif /* WDHeader_h */
