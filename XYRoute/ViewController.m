//
//  ViewController.m
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//

#import "ViewController.h"
#import "XYURLRouter.h"
#import "UIViewController+Router.h"
#import "Person.h"
#import "Son.h"
#import "WebViewController.h"
#import "Man.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)click:(UIButton *)sender {
    Person *per = [[Person alloc] init];
    per.name = @"行圆";
    per.age = 30;
    [XYURLRouter addRouterWithModel:per key:@"person1"];
    
    
    Person *per1 = [[Person alloc] init];
    per1.name = @"行圆333333";
    per1.age = 10;
    [XYURLRouter addRouterWithModel:per1 key:@"person2"];

    Son *son = [[Son alloc] init];
    son.sonName = @"小远";
    son.age = 10;
    [XYURLRouter addRouterWithModel:son];
    
    Man *man = [[Man alloc] init];
    man.manName = @"男的呀";
    man.age = 21;
    [XYURLRouter addRouterWithModel:man];
//    void(^Handler)(id) = ^(id sender){
//        NSLog(@"%@",sender);
//    };
//    [XYURLRouter addRouterWithModel:Handler key:@"handler"];
    [XYURLRouter addRouterWithBlock:^(id sender){
        NSLog(@"%@",sender);
    } key:@"handlerSender"];
    [XYURLRouter addRouterWithBlock:^(id sender){
        NSLog(@"%@",sender);
    } key:@"handler"];

    [XYURLRouter pushWithURL:@"test?par=%e4%bd%a0%e5%a5%bd&pam=45&m=33.90" query:@{@"isNow":@1,@"pay":@"233"} animated:YES callBack:^(id res,id res1,Son *son,Man *man,NSString *aa,NSString *bb) {
        NSLog(@"这是钱一个 %@ - %@ - %@ - %@ -%@-%@",res,res1,son,man,aa,bb);//第一种方式回调


    }];//http://www.baidu.com?type=1
  
    
//
//    [XYURLRouter pushWithURL:@"https://www.baidu.com" animated:YES];
//    NSLog(@"%@",[XYURLRouter currentViewController]);
    //第二种方式回调
//    [XYURLRouter currentViewController].callBack = ^(id res) {
//        NSLog(@"%@",res);
//    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
