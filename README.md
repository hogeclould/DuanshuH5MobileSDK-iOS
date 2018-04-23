<p align="center" >
  <img src="duanshu_logo.png" title="短书的logo" float=left>
</p>

## 简介
短书H5-Mobile-SDK-iOS.第三方用户通过集成此SDK, 按接口规范重写`获取用户信息`等方法后，第三方App嵌入的短书的H5页面，则能通过js获取对应信息

## 安装
### 通过`cocoapods`安装
```
 pod 'DuanshuSDK', '1.0'
```

***安转注意事项***

> `DuanshuSDK.framework`中js与webview通信，使用了第三方库[WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge), 因此用户在使用的时候需要依赖'WebViewJavascriptBridge'

```
pod 'WebViewJavascriptBridge', '6.0'
```

## SDK使用Example
用户需要使用SDK提供`DSUWebview`加载短书H5页面， 并实现`DSUWebViewDelegate`代理相应的方法，详细使用参见`DuanshuSDK Demo`

```objc
// 初始化配置，需要导入头文件DuanshuSDK/DSUBaseSDK.h
    DSUConfig *config = [[DSUConfig alloc] initWithAppId:@"app_id" appSercet:@"app_secrect"];
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
```

## SDK代理`DSUWebViewDelegate`API
```objc
@protocol DSUWebViewDelegate <NSObject>

@optional


/**
 获取用户信息
 @param param h5传参
 @param complete 成功获取用户信息后回调
 complete 回调参数userInfo格式说明
 {
   "userName": "用户名",
   "userId": "用户id",
   "avatarUrl": "用户头像链接",
   "telephone": "绑定手机号"
 }
 */
- (void)dsu_getUserInfoWithParam:(id)param
                   completeBlock:(DSUCallbackBlock)complete;



/**
 开始录音
 @param param h5传参 格式说明：{"base64_enabled":1}
 @param complete 成功开始录音执行回调
 @param timeoutBlock 录音超过最大时长后（建议最大时长120秒），自动结束录音，自动回调

 timeoutBlock 回调参数userInfo格式说明
 {
   "localPath": "录音文件的本地暂存文件路径"，
   "base64":"录音二进制文件的base64字符串",  // 当dsu_startRecordWithParam参数base64_enabled开启时，需要返回此参数
   "type":"mp3" // 当dsu_startRecordWithParam参数base64_enabled开启时，需要返回此参数
 }
 */
- (void)dsu_startRecordWithParam:(id)param
                   completeBlock:(DSUCallbackBlock)complete
                    timeoutBlock:(DSUCallbackBlock)timeoutBlock;


/**
 结束录音
 @param param h5传参
 @param complete 成功开始录音执行回调
 complete 回调参数userInfo格式说明
 {
   "localPath": "录音文件的本地暂存文件路径"，
    "base64":"录音二进制文件的base64字符串",  // 当dsu_startRecordWithParam参数base64_enabled开启时，需要返回此参数
    "type":"mp3" // 当dsu_startRecordWithParam参数base64_enabled开启时，需要返回此参数
 }
 */
- (void)dsu_stopRecordWithParam:(id)param
                  completeBlock:(DSUCallbackBlock)complete;


/**
 播放音频
 @param param h5传参 格式说明：{"record_url":"http://xxx.mp3"}
 @param complete 成功开始播放执行回调
 @param progressBlock 进度回调  注意：预留接口，暂未实现
 @param endBlock 播放完成后回调

 如果用户调用暂停`pauseVoice`后，又继续调用播放方法，并且URL相同，则原音频继续播放，不重新开始
 */
- (void)dsu_playVoiceWithParam:(id)param
                 completeBlock:(DSUCallbackBlock)complete
                 progressBlock:(DSUProgressBlock)progressBlock
                      endBlock:(DSUCallbackBlock)endBlock;


/**
 暂停音频
 @param param h5传参 格式说明：{"record_url":"http://xxx.mp3"}
 @param complete 成功暂停播放执行回调
 */
- (void)dsu_pauseVoiceWithParam:(id)param
                  completeBlock:(DSUCallbackBlock)complete;

/**
 停止音频
 @param param h5传参 格式说明：{"record_url":"http://xxx.mp3"}
 @param complete 成功停止音频播放执行回调
 */
- (void)dsu_stopVoiceWithParam:(id)param
                 completeBlock:(DSUCallbackBlock)complete;

/**
 选择图片
 @param param h5传参 格式说明：{"count":1, "base64_enabled":1}
 @param complete 选取图片完成后执行回调
 complete 回调参数userInfo格式说明
 1. 当base64_enabled=0或不传
 [
  "图片本地路径1",
  "图片本地路径2"
 ]

 2. 当base64_enabled=1
 [
 {"localPath":"图片本地路径1", "type":"png", "base64":"xxxx"},
 {"localPath":"图片本地路径2", "type":"jpg", "base64":"xxxx"}
 ]
 */
- (void)dsu_chooseImageWithParam:(id)param
                   completeBlock:(DSUCallbackBlock)complete;

/**
 预览图片（单张）
 @param param h5传参 格式说明：{"imgUrl":"http://xxx_1.jpg"}
 @param complete 成功预览图片执行回调
 */
- (void)dsu_previewImageWithParam:(id)param
                    completeBlock:(DSUCallbackBlock)complete;

/**
 预览图片（多张）
 @param param h5传参 格式说明：{
    "position":0,
    "pics":[
        "http://xxx_1.jpg",
        "http://xxx_2.jpg"
    ]
 }
 @param complete 成功预览图片执行回调
 */
- (void)dsu_previewPicWithParam:(id)param
                    completeBlock:(DSUCallbackBlock)complete;

/**
 分享
 @param param h5传参 格式说明：{
    "title": “分享标题”,
    "content": “分享描述”,
    "picurl": “分享图片链接”,
    "url": “分享内容链接”,
    "updateShareData": “1:只更新数据，不弹分享框；0:弹出分享框”,
    "showShareButton": “1:显示分享按钮；0:不显示分享按钮”
 }
 @param complete 成功分享执行回调
*/
- (void)dsu_shareWithParam:(id)param
               completeBlock:(DSUCallbackBlock)complete;


/**
 加载链接
 @param param h5传参 格式说明：{
 "url": “链接地址”
 }
 @param complete 执行回调
 */
- (void)dsu_loadUrlWithParam:(id)param
             completeBlock:(DSUCallbackBlock)complete;

@end
```


## Demo使用注意事项
- 首次使用前，需要先运行pod install
- Demo录用功能使用了第三方库[mp3lame](https://github.com/wuqiong/mp3lame-for-iOS)进行音频转码
  - 需要关闭`bitcode`
- Demo中选择图片功能使用了第三方库[TZImagePickerController](https://github.com/banchichen/TZImagePickerController)
- Demo中图片预览功能使用了第三方库[MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser)

## H5 API 文档
- [H5 API 文档](https://github.com/hogeclould/DuanshuH5MobileSDK-iOS/blob/master/%E7%9F%AD%E4%B9%A6JSSDK%20API%20%E8%AF%B4%E6%98%8E.md)

## 作者
- [短书](http://my.duanshu.com/)

## License
[MIT][LICENSE]

[LICENSE]: https://zh.wikipedia.org/wiki/MIT%E8%A8%B1%E5%8F%AF%E8%AD%89
