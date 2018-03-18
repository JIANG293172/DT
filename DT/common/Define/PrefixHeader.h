//
//  PrefixHeader.h
//  bilibili fake
//
//  Created by 翟泉 on 2016/7/4.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#ifndef PrefixHeader_h
#define PrefixHeader_h
#import <Masonry.h>
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"


#define LYNavi(vc) [[UniversalNavigation alloc]initWithRootViewController:vc]
//#define LYGreenColor [UIColor colorWithRed:62.0/255 green:180.0/255 blue:62.0/255 alpha:1]




// 设备类型
#define DeviceIsIpad UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define LYTextSize 12
#define LYMargin 10
#define LYImageSize 112
#define LYGrayColor [UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1]

#define smallWidth SSize.width < SSize.height ? SSize.width : SSize.height
#define verticalLeftMargin 47
#define horizontalLeftMargin 173
#define hypotenuse 160.00 * self.ZoomScale

#define ScreenDirection [UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height ? YES : NO
#endif /* PrefixHeader_h */
// font
#define SystemFontWithPx(x) x*0.5

// color

