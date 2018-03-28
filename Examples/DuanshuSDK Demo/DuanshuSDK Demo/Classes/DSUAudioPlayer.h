//
//  DSUAudioPlayer.h
//  DuanshuSDK Demo
//
//  Created by 苏强 on 2018/3/22.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DuanshuSDK/DSUWebViewDelegate.h>


@class AVPlayer;
@interface DSUAudioPlayer : NSObject
@property (nonatomic, readonly) AVPlayer *player;

@property (nonatomic, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic, assign, readonly) float process;  //[0-1]

@property (strong, nonatomic, readonly) NSURL *currentUrl;

@property (assign, nonatomic, readonly) NSTimeInterval currentTime;


+ (void)playWithURL:(NSURL *)url
      completeBlock:(DSUCallbackBlock)complete
      progressBlock:(DSUProgressBlock)progressBlock
           endBlock:(DSUCallbackBlock)endBlock;

+ (void)pauseWithURL:(NSURL *)url completeBlock:(DSUCallbackBlock)complete;

+ (void)stopWithURL:(NSURL *)url completeBlock:(DSUCallbackBlock)complete;

@end
