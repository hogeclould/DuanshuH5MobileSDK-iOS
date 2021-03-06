//
//  ExampleViewController.m
//  DuanshuSDK Demo
//
//  Created by 苏强 on 2018/3/20.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import "ExampleViewController.h"
#import "ExampleWebView.h"
#import "DSUWebViewDefaultDelegate.h"
#import "DSUScanViewController.h"
#import <DuanshuSDK/DSUBaseSDK.h>

@interface ExampleViewController ()<UIWebViewDelegate, DSUWebViewDelegate>
@property (nonatomic, strong) ExampleWebView *webView;
@property (nonatomic, strong) DSUWebViewDefaultDelegate *defaultDelegate;
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"二维码" style:UIBarButtonItemStylePlain target:self action: @selector(scan)];
    
    self.navigationItem.title = @"短书H5-SDK Demo";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化配置
    DSUConfig *config = [[DSUConfig alloc] initWithAppId:@"AppId" appSercet:@"AppSecret"];
    // 初始化SDK
    [DuanshuSDK.shared initializeSDKWithConfig:config];
    
    // demo 提供了代理默认实现， 可供参考
    self.defaultDelegate = [[DSUWebViewDefaultDelegate alloc] init];
    
    self.webView = [[ExampleWebView alloc] init];
    
    // 在注册UIWebView代理时，必须使用此方法
    [self.webView registerBridge:self];
    
    // 用户可重写的API
    self.webView.dsu_delegate = self.defaultDelegate;
    
    // 开启日志
    self.webView.logEnabled = YES;
    
    [self.view addSubview:self.webView];
    
    if(self.contentURL == nil){

//        NSURL *mainUrl = [NSBundle mainBundle].bundleURL;
//        NSURL *url = [NSURL fileURLWithPath:@"JS_Sdk_files/JS_Sdk1.htm" relativeToURL:mainUrl];
//
//        NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//        [self.webView loadHTMLString:htmlString baseURL:mainUrl];
        
        NSURL *demoURL = [NSURL URLWithString:@"http://file.dingdone.com/dddoc/jssdk/Duanshu-h5sdk-API-Demo.html"];
        
         [self.webView loadRequest:[NSURLRequest requestWithURL:demoURL]];
        
    }else{
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.contentURL]];
    }
    
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)scan{
    
    DSUScanViewController *vc = [[DSUScanViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:NO];
    
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"%p", __func__);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"%p", __func__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"%p", __func__);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%p", __func__);
}


- (void)dealloc {
    self.webView.delegate = nil;
    [self.webView stopLoading];
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
