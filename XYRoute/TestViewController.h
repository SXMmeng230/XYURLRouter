//
//  TestViewController.h
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "Son.h"
#import "Man.h"
typedef void(^EventHandler)(id sender);

@interface TestViewController : UIViewController
@property (nonatomic, copy) NSString *par;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) double m;

@property (nonatomic, strong) Person *person1;
@property (nonatomic, strong) Person *person2;

@property (nonatomic, strong) Son *son;
@property (nonatomic, strong) Man *man;
@property (nonatomic, copy) EventHandler handler;

@property (nonatomic, assign) BOOL isNow;
@property (nonatomic, copy) EventHandler handlerSender;



@end
