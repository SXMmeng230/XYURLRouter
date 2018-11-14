//
//  TestViewController.m
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//

#import "TestViewController.h"
#import "UIViewController+Router.h"
@interface TestViewController ()
@property (nonatomic, strong) NSNumber *pay;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    NSLog(@"par的值为：%@",self.par);
//    NSLog(@"age的值为：%d",self.age);
    NSLog(@"pay的值为：%@",self.pay);
//    NSLog(@"m的值为：%.f",self.m);
    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(100, 200, 100, 30)];
    label.textColor = [UIColor blueColor];
    [self.view addSubview:label];
    label.text = self.par;
//    NSLog(@"person的值为：%@ age:%d",self.person.name,self.person.age);
        NSLog(@"son的值为：%@ age:%d",self.son.sonName,self.son.age);
        NSLog(@"man的值为：%@ age:%d",self.man.manName,self.man.age);
        NSLog(@"person1的值为：%@ age1:%d",self.person1.name,self.person1.age);
        NSLog(@"person2的值为：%@ age2:%d",self.person2.name,self.person2.age);

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.callBack) {
        self.callBack(@123,@"3232",self.son,self.man,@"12",@"dfd");
    }
    if (self.handlerSender) {
        self.handlerSender(@"112458765476");
    }
    if (self.handler) {
        self.handler(@"113");

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
