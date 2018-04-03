//
//  DSUAudioRecorder.h
//  DuanshuSDK Demo
//
//  Created by 苏强 on 2018/3/21.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DuanshuSDK/DSUWebViewDelegate.h>


@interface DSUAudioRecorder : NSObject
+ (void)dsu_enableBase64:(BOOL)enable;
+ (void)dsu_startRecordCompleteBlock:(DSUCallbackBlock) complete timeoutBlock:(DSUCallbackBlock)timeoutBlock;

+ (void)dsu_stopRecordCompleteBlock:(DSUCallbackBlock) complete;
@end
