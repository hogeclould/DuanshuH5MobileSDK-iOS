//
//  DSUWebViewDelegate.h
//  DuanshuSDK
//
//  Created by 苏强 on 2018/3/21.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, DuanshuMessageCode) {
    
    /**
     *  正常返回
     */
    DSU_CODE_OK = 0,
    /**
     *  用户未登录
     */
    DSU_CODE_NOT_LOGIN = 3,
    /**
     *  网络异常
     */
    DSU_CODE_NET_ERROR = 10,
    
    /**
     *  无权限
     */
    DSU_CODE_NO_AUTH= 11,
    
    /**
     *  方法未被支持
     */
    DSU_CODE_NO_METHOD_SUPPORT= 13,
    
    /**
     *  方法执行异常
     */
    DSU_CODE_METHOD_ERROR = 14
    
    
};

typedef void(^DSUCallbackBlock)(int code, NSString *msg, id userInfo);

typedef void(^DSUProgressBlock)(float currentTime, float duration, NSString * urlString);

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
 @param param h5传参
 @param complete 成功开始录音执行回调
 @param timeoutBlock 录音超过最大时长后（建议最大时长120秒），自动结束录音，自动回调
 
 timeoutBlock 回调参数userInfo格式说明
 {
   "localPath": "录音文件的本地暂存文件路径"
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
   "localPath": "录音文件的本地暂存文件路径"
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
 @param param h5传参 格式说明：{"count":1}
 @param complete 选取图片完成后执行回调
 complete 回调参数userInfo格式说明
 [
  "图片本地路径1",
  "图片本地路径2"
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
    "url": “分享内容链接”
 }
 @param complete 成功分享执行回调
*/
- (void)dsu_shareWithParam:(id)param
               completeBlock:(DSUCallbackBlock)complete;

@end
