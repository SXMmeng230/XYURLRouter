//
//  XYURLRouter.h
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewController+Router.h"

#define URLROUTER @"bh://"

typedef void(^CallBack)();

@interface NSObject (Router)
@property (nonatomic, copy) NSString *objectRouter;
@end
@interface XYURLRouter : NSObject
/**
 跳转页面
 
 @param url url
 @param animated 是否有动画
 */
+ (void)pushWithURL:(NSString *)url animated:(BOOL)animated;
/**
 跳转页面

 @param url url
 @param query 参数，会合并url中的参数
 @param animated 是否有动画
 */
+ (void)pushWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated;

/**
 跳转页面

 @param url url
 @param query 参数，会合并url中的参数
 @param animated 是否有动画
 @param back 回调，如果需要 
 */
+ (void)pushWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated callBack:(CallBack)back;

/**
 模态跳转

 @param url url
 @param animated 动画
 */
+ (void)presentWithURL:(NSString *)url animated:(BOOL)animated;

/**
 模态跳转

 @param url url
 @param query 参数
 @param animated 动画
 */
+ (void)presentWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated;

/**
 模态跳转

 @param url url
 @param query 参数
 @param animated 动画
 @param back 回调
 */
+ (void)presentWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated callBack:(CallBack)back;

/**
 添加block回调

 @param block blok
 @param key key值
 */
+ (void)addRouterWithBlock:(CallBack)block key:(NSString *)key;

/**
 当跳转下一页面时，需要传递的模型，此方法可以添加多个不同类型，并且在push之前调用

 @param object 模型
 */
+ (void)addRouterWithModel:(NSObject *)object;

/**
 当跳转下一页面时，需要传递的模型，此方法可以添加多个相同或者不同类型的模型,并且在push之前调用

 @param object 模型
 @param key push到VC中，VC中模型对应的字符串
 */
+ (void)addRouterWithModel:(NSObject *)object key:(NSString *)key;

/**
 当前控制器vc
 */
+ (UIViewController*)currentViewController;
@end
