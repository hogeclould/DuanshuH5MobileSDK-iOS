//
//  DSUConfig.h
//  DuanshuSDK
//  SDK配置类
//  Created by Firo on 2018/4/18.
//

#import <Foundation/Foundation.h>

@interface DSUConfig : NSObject

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *appSecret;



/**
 初始化并返回一个配置。

 @param appId 从短书申请的AppId
 @param appSecret 从短书申请的AppSecret
 @return 配置的实例
 */
- (instancetype)initWithAppId:(NSString *)appId appSercet:(NSString *)appSecret;

@end
