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

@interface ExampleViewController ()<UIWebViewDelegate, DSUWebViewDelegate>
@property (nonatomic, strong) ExampleWebView *webView;
@property (nonatomic, strong) DSUWebViewDefaultDelegate *defaultDelegate;
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"短书H5-SDK Demo";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.defaultDelegate = [[DSUWebViewDefaultDelegate alloc] init];
    
    self.webView = [[ExampleWebView alloc] init];
    [self.webView registerBridge:self];
    self.webView.dsu_delegate = self.defaultDelegate;
    self.webView.logEnabled = YES;
    [self.view addSubview:self.webView];
    
    NSURL *mainUrl = [NSBundle mainBundle].bundleURL;
    NSURL *url = [NSURL fileURLWithPath:@"JS_Sdk_files/JS_Sdk.htm" relativeToURL:mainUrl];
    
    NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];

    [self.webView loadHTMLString:htmlString baseURL:mainUrl];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
