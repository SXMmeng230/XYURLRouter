//
//  UIViewController+Router.m
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//

#import "UIViewController+Router.h"
#import <objc/runtime.h>
static const char urlType;
static const char paramType;
static const char backType;


@implementation UIViewController (Router)
- (NSString *)originUrl
{
  return objc_getAssociatedObject(self, &urlType);
}
- (void)setOriginUrl:(NSString *)originUrl
{
    objc_setAssociatedObject(self, &urlType, originUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSDictionary *)param
{
    return objc_getAssociatedObject(self, &paramType);
}
- (void)setParam:(NSDictionary *)param
{
    objc_setAssociatedObject(self, &paramType, param, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (Back)callBack
{
    return objc_getAssociatedObject(self, &backType);

}
- (void)setCallBack:(Back)callBack
{
    objc_setAssociatedObject(self, &backType, callBack, OBJC_ASSOCIATION_COPY_NONATOMIC);

}
+ (UIViewController *)customViewController
{
    return nil;
}
- (BOOL)isPresentToCurrentViewController
{
    return NO;
}
@end
