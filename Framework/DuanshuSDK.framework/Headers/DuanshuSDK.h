//
//  DuanshuSDK.h
//  DuanshuSDK
//
//  Created by Firo on 2018/4/18.
//

#import <Foundation/Foundation.h>
#import "DSUConfig.h"

@interface DuanshuSDK : NSObject

@property (class, readonly, strong) DuanshuSDK *shared;/**< 使用单例访问接口*/

/**
 初始化 SDK.
 使用 SDK 前必须先初始化 SDK.

 @param config SDK配置
 */
- (void)initializeSDKWithConfig:(DSUConfig *)config;

@end
