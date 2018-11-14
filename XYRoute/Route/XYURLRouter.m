//
//  XYURLRouter.m
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//

#import "XYURLRouter.h"
#import <objc/runtime.h>

UIKIT_STATIC_INLINE BOOL RouterStringTrimIsNullOrEmpty(NSString* str){
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return ((NSNull *)str==[NSNull null] || str==nil||[str isEqualToString:@""]);
}
static const char routerType;
@implementation NSObject (Router)
-(NSString *)objectRouter
{
    return objc_getAssociatedObject(self, &routerType);
    
}
- (void)setObjectRouter:(NSString *)objectRouter
{
    objc_setAssociatedObject(self, &routerType, objectRouter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@interface XYURLRouter()
@property (nonatomic, strong) NSDictionary *configDic;
@property (nonatomic, strong) NSMutableArray *modelArr;
@property (nonatomic, strong) NSMutableDictionary *blockDic;

@end

@implementation XYURLRouter

+ (instancetype)shareRouter
{
    static dispatch_once_t onceToken;
    static XYURLRouter *router = nil;
    dispatch_once(&onceToken, ^{
        router = [[XYURLRouter alloc] init];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Route" ofType:@"plist"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:plistPath] == YES){ //读取document成功
            router.configDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        }
        router.modelArr = [NSMutableArray array];
        router.blockDic = [NSMutableDictionary dictionary];
    });
    return router;
}
+ (void)addRouterWithBlock:(CallBack)block key:(NSString *)key
{
    if (block) {
        @synchronized([XYURLRouter shareRouter]){
            if (RouterStringTrimIsNullOrEmpty(key)) {
                NSLog(@"添加block，必须添加对应的key");
            }else{
                [[XYURLRouter shareRouter].blockDic setObject:[block copy] forKey:key];
            }
        }
    }
}
+ (void)addRouterWithModel:(NSObject *)object
{
    [self addRouterWithModel:object key:nil];
}
+ (void)addRouterWithModel:(NSObject *)object key:(NSString *)key
{
    if (object) {
        @synchronized([XYURLRouter shareRouter]){
            if (!RouterStringTrimIsNullOrEmpty(key)) {
                object.objectRouter = key;
            }
            [[XYURLRouter shareRouter].modelArr addObject:object];
        }
    }
}
+ (void)pushWithURL:(NSString *)url animated:(BOOL)animated
{
    [self pushWithURL:url query:nil animated:animated];
}
+ (void)pushWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated
{
    [self pushWithURL:url query:query animated:animated callBack:nil];
}
+ (void)pushWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated callBack:(CallBack)back
{
    UIViewController *vc = [self routerWithString:url query:query];
    if (!vc) {
        NSLog(@"没有匹配到VC,查看plist文件添加是否正确");
    }else if ([vc isKindOfClass:[UINavigationController class]]){
        NSLog(@"当前VC为UINavigationController，不能push操作");
    }else{
        if (back) {
            vc.callBack = [back copy];
        }
        //获取属性的列表
        vc = [self setPropertyValueWithVC:vc];
        
        if ([vc isPresentToCurrentViewController]) {
            UINavigationController *naPresent = [[UINavigationController alloc] initWithRootViewController:vc];
            [[XYURLRouter currentViewController] presentViewController:naPresent animated:animated completion:NULL];
        }else{
            UINavigationController *na = [self routerWithNavigation];
            [na pushViewController:vc animated:animated];
        }
        [[XYURLRouter shareRouter].modelArr removeAllObjects];
        [[XYURLRouter shareRouter].blockDic removeAllObjects];
    }
}
+ (void)presentWithURL:(NSString *)url animated:(BOOL)animated
{
    [self presentWithURL:url query:nil animated:animated];
}

+ (void)presentWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated
{
    [self presentWithURL:url query:query animated:YES callBack:NULL];
}
+ (void)presentWithURL:(NSString *)url query:(NSDictionary *)query animated:(BOOL)animated callBack:(CallBack)back
{
    
    UIViewController *vc = [self routerWithString:url query:query];
    if (!vc) {
        NSLog(@"没有匹配到VC,查看plist文件添加是否正确");
    }else{
        if (back) {
            vc.callBack = [back copy];
        }
        //获取属性的列表
        vc = [self setPropertyValueWithVC:vc];
        UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:vc];
        [[XYURLRouter currentViewController] presentViewController:na animated:animated completion:NULL];
        [[XYURLRouter shareRouter].modelArr removeAllObjects];
        [[XYURLRouter shareRouter].blockDic removeAllObjects];
    }
}
+ (UIViewController *)setPropertyValueWithVC:(UIViewController *)vc
{
    Class cls = [vc class];
    while (cls != [UIViewController class]) {
        unsigned int count = 0;
        objc_property_t *propertyList =  class_copyPropertyList(cls, &count);
        for(int i=0;i<count;i++)
        {
            objc_property_t pro = propertyList[i];
            //获取每一个属性的变量名
            const char* proName = property_getName(pro);
            NSString *proNameEncode = [[NSString alloc] initWithCString:proName encoding:NSUTF8StringEncoding];
            if ([[XYURLRouter shareRouter].blockDic objectForKey:proNameEncode]) {
                [vc setValue:[[XYURLRouter shareRouter].blockDic objectForKey:proNameEncode] forKey:proNameEncode];
                [[XYURLRouter shareRouter].blockDic removeObjectForKey:proNameEncode];
            }else{
                [self setValueWithVC:vc property:pro Value:vc.param[proNameEncode]];
            }
        }
        free(propertyList);
        cls = class_getSuperclass(cls);
    }
    return vc;
}
+ (UIViewController *)routerWithString:(NSString *)urlString query:(NSDictionary *)query{
    // 支持对中文字符的编码
    NSString *encodeStr = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [self routerWithURL:[NSURL URLWithString:encodeStr] query:query] ;
}

+ (UIViewController *)routerWithURL:(NSURL *)url query:(NSDictionary *)query
{
    if (!url) {
        NSLog(@"url参数错误");
        return nil;
    }
    if (![url.scheme hasPrefix:@"http://"] && ![url.scheme hasPrefix:@"https://"] && ![url.scheme hasPrefix:URLROUTER]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@type=%@",URLROUTER,url];
        url = [NSURL URLWithString:urlStr];
        if (!url) {
            NSString *encodeStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            url = [NSURL URLWithString:encodeStr];
        }
    }
    UIViewController *currentVC = nil;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithDictionary:[self paramsURL:url]];
    if (query) {
        [paramDic addEntriesFromDictionary:query];
    }
    if ([url.scheme hasPrefix:@"http://"]||[url.scheme hasPrefix:@"https://"]) {
        NSString *calssName = [XYURLRouter shareRouter].configDic[@"web"];
        if (!RouterStringTrimIsNullOrEmpty(calssName)) {
            currentVC = [[NSClassFromString(calssName) alloc] init];
            currentVC.param = paramDic;
            currentVC.originUrl = url;
        }
    }else{
        
        NSString *type = [url.host stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *typeArr = [type componentsSeparatedByString:@"="];
        if (typeArr.count > 2) {
            NSLog(@"url host中，type参数错误");
            return nil;
        }
        NSString *calssName = [XYURLRouter shareRouter].configDic[typeArr.lastObject];
        if (!RouterStringTrimIsNullOrEmpty(calssName)) {
            
            Class vcClass = NSClassFromString(calssName);
            if ([vcClass respondsToSelector:@selector(customViewController)]) {//兼容用storyboard,加载不同xib等VC
                UIViewController *customVC = [vcClass performSelector:@selector(customViewController) withObject:nil];
                if (customVC) {
                    currentVC = customVC;
                }
            }
            if (!currentVC) {
                currentVC = [[vcClass alloc] init];
            }
            currentVC.param = paramDic;
            currentVC.originUrl = url;
        }
    }
    return currentVC;
}
+ (UIViewController*)currentViewController {
    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self currentViewControllerFrom:rootViewController];
}
+ (UINavigationController *)routerWithNavigation
{
    return (UINavigationController *)[self currentViewController].navigationController;
}
// 通过递归拿到当前控制器
+ (UIViewController*)currentViewControllerFrom:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController *)viewController;
        return [self currentViewControllerFrom:navigationController.viewControllers.lastObject];
    }else if([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController *)viewController;
        return [self currentViewControllerFrom:tabBarController.selectedViewController];
    }else if(viewController.presentedViewController != nil) {
        return [self currentViewControllerFrom:viewController.presentedViewController];
    }else {
        return viewController;
    }
}

// 将url的参数部分转化成字典
+ (NSDictionary *)paramsURL:(NSURL *)url {
    
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    if (NSNotFound != [url.absoluteString rangeOfString:@"?"].location) {
        NSString *paramString = [url.absoluteString substringFromIndex:
                                 ([url.absoluteString rangeOfString:@"?"].location + 1)];
        
        NSMutableCharacterSet* delimiterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"&"];
        NSScanner* scanner = [[NSScanner alloc] initWithString:paramString];
        while (![scanner isAtEnd]) {
            NSString* pairString = nil;
            [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
            [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
            NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
            if (kvPair.count == 2) {
                NSString* key = [[kvPair objectAtIndex:0] stringByRemovingPercentEncoding];
                NSString* value = [[kvPair objectAtIndex:1] stringByRemovingPercentEncoding];
                [pairs setValue:[self decodeFromPercentEscapeString:value] forKey:key];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

+(NSString *)decodeFromPercentEscapeString:(NSString *)str
{
    NSMutableString *outputStr = [NSMutableString stringWithString:str];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
/*
 将一个值强类型化为某一属性所需要的值
 */
+(void)setValueWithVC:(UIViewController *)vc property:(objc_property_t)property Value:(id)value
{
    if (property==nil) {
        return;//空值，返回
    }
    ///The format of the attribute string is described in Declared Properties
    const char *property_attribute=property_getAttributes(property);
    ///A C string containing the property's name
    const char *property_name_c=property_getName(property);
    
    NSString *property_name=[NSString stringWithCString:property_name_c encoding:NSUTF8StringEncoding];
    
    NSString *property_str=[NSString stringWithCString:property_attribute encoding:NSUTF8StringEncoding];
    
    value = vc.param[property_name];
    
    //获取编码类型
    NSArray *splitarray=[property_str componentsSeparatedByString:@","];
    if (splitarray.count>0) {
        NSString *first=[splitarray objectAtIndex:0];
        if (![first hasPrefix:@"T"]) {//不是以T打头，字符串分离错误
            NSLog(@"字符串分离错误啦");
            return;
        }
        //判断是否为只读属性
        if ([[splitarray objectAtIndex:1] isEqualToString:@"R"]) {
            return;
        }
        
        //去掉T
        first=[first stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        //T..
        //根据T之后的字符串判断类型，如果不是@，就是基本类型
        if ([first hasPrefix:@"@"]) {//是一个其他类型
            //获取类型
            NSString *class_name=[first stringByReplacingOccurrencesOfString:@"@" withString:@""];
            class_name=[class_name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            Class target_class=NSClassFromString(class_name);
            
            if (target_class==nil) {
                NSLog(@"没有这个类:%@ 和目标值:%@",class_name,[value description]);
                return;
            }
            if ([value isKindOfClass:target_class]) {//值的类型和目标类型相同，直接设置值
                [vc setValue:value forKey:property_name];
            }else if (target_class == [NSNumber class]){
                [vc setValue: @([value doubleValue]) forKey:property_name];
            }else if([target_class isSubclassOfClass:[NSObject class]]){
                NSArray *arr = [NSArray arrayWithArray:[XYURLRouter shareRouter].modelArr];
                for (NSObject *ob in arr) {
                    if (!RouterStringTrimIsNullOrEmpty(ob.objectRouter)) {
                        if ([property_name isEqualToString:ob.objectRouter]) {
                            ob.objectRouter = nil;
                            [vc setValue:ob forKey:property_name];
                            [[XYURLRouter shareRouter].modelArr removeObject:ob];
                            break;
                        }
                    }else{
                        if (target_class == [ob class]) {
                            [vc setValue:ob forKey:property_name];
                            [[XYURLRouter shareRouter].modelArr removeObject:ob];
                            break;
                        }
                    }
                }
            }
        }else{//几个基本类型中的一个
            //获取对应私有变量的名称
            NSString *var_name=[splitarray lastObject];
            if (var_name!=nil&&[var_name hasPrefix:@"V"]) {//如果是私有变量名称，会以V开头
                var_name=[var_name stringByReplacingOccurrencesOfString:@"V" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
            }else{
                NSLog(@"不好意思，找不到var");
                return;
            }
            //获取对应的私有变量
            const char *ivar_name_c=[var_name cStringUsingEncoding:NSUTF8StringEncoding];
            
            Ivar ivar_var=class_getInstanceVariable([vc class], ivar_name_c);
            
            void *ivar_pointer=(uint8_t*)vc+ivar_getOffset(ivar_var);
            if (ivar_pointer==nil) {
                return;
            }
            first = [first lowercaseString];
            if ([first isEqualToString:@"c"]) {//char 接受string类的，string可以强制转换
                if ([value isKindOfClass:[NSString class]]) {
                    char charValue=*[value cStringUsingEncoding:NSUTF8StringEncoding];
                    
                    char *_set=ivar_pointer;
                    *_set=charValue;
                    
                }else if([value isKindOfClass:[NSNumber class]]){//cahr 接受nsnumber类型
                    NSNumber *number=value;
                    char charValue=[number charValue];
                    char *_set=ivar_pointer;
                    *_set=charValue;
                }
            }else if([first isEqualToString:@"d"]){//double 接受nsnumber的类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    double doubleValue=[value doubleValue];
                    double *_set=ivar_pointer;
                    *_set=doubleValue;
                }
            }else if([first isEqualToString:@"i"]){//enum int类型 接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    int intValue=[value intValue];
                    
                    int *_set=ivar_pointer;
                    *_set=intValue;
                }
            }else if([first isEqualToString:@"f"]){//float 类型 接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    float floatValue=[value floatValue];
                    
                    float *_set=ivar_pointer;
                    *_set=floatValue;
                }
            }else if ([first isEqualToString:@"l"]){//long类型  接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    long longValue;
                    if([value isKindOfClass:[NSNumber class]]){
                        longValue=[value longValue];
                    }else{
                        longValue=[value doubleValue];
                    }
                    
                    long *_set=ivar_pointer;
                    *_set=longValue;
                }
            }else if ([first isEqualToString:@"q"]){//long long类型  接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    long long longValue;
                    if([value isKindOfClass:[NSNumber class]]){
                        longValue=[value longLongValue];
                    }else{
                        longValue=[value doubleValue];
                    }
                    
                    long long *_set=ivar_pointer;
                    *_set=longValue;
                }
            }else if ([first isEqualToString:@"b"]){//Bool类型  接受NSNumber类型 nsstring
                //                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                BOOL toValue;
                if([value isKindOfClass:[NSNumber class]]){
                    toValue=[value boolValue];
                }else{
                    toValue=[value boolValue];
                }
                
                long long *_set=ivar_pointer;
                *_set=toValue;
                //                }
            }else if ([first isEqualToString:@"s"]){//short类型  接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    short shortValue=[value shortValue];
                    
                    short *_set=ivar_pointer;
                    *_set=shortValue;
                }
            }else if ([first hasPrefix:@"{CGSize"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGSize *_set=ivar_pointer;
                    *_set = CGSizeFromString(value);
                }
            }else if ([first hasPrefix:@"{CGRect"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGRect *_set=ivar_pointer;
                    *_set = CGRectFromString(value);
                }
            }else if ([first hasPrefix:@"{CGPoint"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGPoint *_set=ivar_pointer;
                    *_set = CGPointFromString(value);
                }
            }else if ([first hasPrefix:@"{CGAffineTransform"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGAffineTransform *_set=ivar_pointer;
                    *_set = CGAffineTransformFromString(value);
                }
            }
            
            else{
                NSLog(@"type错了，不支持:%@ type:%@",var_name,first);
            }
            
        }
    }
    
}

@end
