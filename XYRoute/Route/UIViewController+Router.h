//
//  UIViewController+Router.h
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Back)();
@interface UIViewController (Router)
/**
 跳转url
 */
@property (nonatomic, strong) NSURL *originUrl;
/**
 跳转参数
 */
@property (nonatomic, strong) NSDictionary *param;
/**
 回调函数
 */
@property (nonatomic, copy) Back callBack;

/**
 自定义加载VC

 @return vc
 */
+ (UIViewController *)customViewController;

/**
 是否模态到当前vc，默认NO  当设置YES时，当前vc只能模态出来，
 */
- (BOOL)isPresentToCurrentViewController;
@end
