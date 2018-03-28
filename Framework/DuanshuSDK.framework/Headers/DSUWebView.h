//
//  DSUWebView.h
//  DuanshuSDK
//
//  Created by 苏强 on 2018/3/20.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSUWebViewDelegate.h"

@class WebViewJavascriptBridge;
@interface DSUWebView : UIWebView
@property (nonatomic, weak) id<DSUWebViewDelegate> dsu_delegate; ///< 短书开发api代理方法
@property(nonatomic, readonly) WebViewJavascriptBridge *bridge; ///< 第三方库 https://github.com/marcuswestin/WebViewJavascriptBridge
@property(nonatomic, assign) BOOL logEnabled; ///< 是否开启SDK内部日志消息打印，默认为NO

/**
 在注册UIWebView代理时，必须使用此方法，不能使用UIWebView.delegate进行注册
 @param delegate webview代理方法
 */
- (void)registerBridge:(NSObject<UIWebViewDelegate> *) delegate;
@end
