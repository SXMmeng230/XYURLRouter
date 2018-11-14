//
//  WebViewController.m
//  XYRoute
//
//  Created by 小萌 on 2018/7/3.
//  Copyright © 2018年 sunxm. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "UIViewController+Router.h"
@interface WebViewController ()<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView * webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     WKWebView * webView = [[WKWebView alloc]init];
    [self.view addSubview:webView];
    webView.frame = self.view.bounds;
    webView.navigationDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:self.originUrl]];
    // Do any additional setup after loading the view.
}

//add my info to the new agent

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
