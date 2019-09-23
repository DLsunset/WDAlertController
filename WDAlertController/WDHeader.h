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

#define WD_color_gray(gray) [UIColor colorWithRed:gray/255.0 green:gray/255.0 blue:gray/255.0 alpha:1]
#define WD_color_rgb(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define WD_color_random [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

#endif /* WDHeader_h */
