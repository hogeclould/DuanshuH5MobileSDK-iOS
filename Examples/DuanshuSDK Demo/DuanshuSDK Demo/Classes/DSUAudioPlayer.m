//
//  DSUAudioPlayer.m
//  DuanshuSDK Demo
//
//  Created by 苏强 on 2018/3/22.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import "DSUAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


@interface DSUAudioPlayer()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) id playToEndObserver;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;

@property (nonatomic, assign) float lastRate;

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, copy) DSUCallbackBlock completeBlock;
@property (nonatomic, copy) DSUProgressBlock progressBlock;
@property (nonatomic, copy) DSUCallbackBlock endBlock;
@end

@implementation DSUAudioPlayer
+ (instancetype)shareInstance{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    
    return _instance;
}

+ (void)playWithURL:(NSURL *)url
      completeBlock:(DSUCallbackBlock)complete
      progressBlock:(DSUProgressBlock)progressBlock
           endBlock:(DSUCallbackBlock)endBlock{
    
    [[self class].shareInstance playWithURL:url
                              completeBlock:complete
                              progressBlock:progressBlock
                                   endBlock:endBlock];
}

+ (void)pauseWithURL:(NSURL *)url completeBlock:(DSUCallbackBlock)complete{
    [[self class].shareInstance pauseWithURL:url completeBlock:complete];
}

+ (void)stopWithURL:(NSURL *)url completeBlock:(DSUCallbackBlock)complete{
    [[self class].shareInstance stopWithURL:url completeBlock:complete];
}

- (NSURL *)currentUrl {
    
    AVAsset *currentPlayerAsset = self.player.currentItem.asset;
    
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) return nil;

    return [(AVURLAsset *)currentPlayerAsset URL];
}

- (NSTimeInterval)currentTime {
    NSTimeInterval time = CMTimeGetSeconds(self.player.currentTime);
    NSTimeInterval total = CMTimeGetSeconds(self.player.currentItem.duration);
    return time == total ? 0.0f : time;
}

- (void)pauseWithURL:(NSURL *)url completeBlock:(DSUCallbackBlock)complete{
    [self pause];
    complete(1, @"暂停播放", @{@"status":@1});
}

- (void)stopWithURL:(NSURL *)url completeBlock:(DSUCallbackBlock)complete{
    [self pause];
    [self clear];
    self.completeBlock(0, @"停止播放", @{@"status":@1, @"url":self.currentUrl.absoluteString});
    
}


- (void)playWithURL:(NSURL *)url completeBlock:(DSUCallbackBlock)complete progressBlock:(DSUProgressBlock)progressBlock endBlock:(DSUCallbackBlock)endBlock
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    if (session == nil) {
        NSLog(@"🚫Error creating session: %@", [sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
    
    self.completeBlock = complete;
    self.progressBlock = progressBlock;
    self.endBlock = endBlock;
    
    if(self.player && [self.currentUrl.absoluteString isEqualToString:url.absoluteString]){
        [self play];
        return;
    }

    self.player.rate = 0.0f;
    self.playing = NO;
    self.lastRate = 0.0f;
    
    [self removeObserver];
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    [self removeTimeToEndObserver];
    
     self.player = [[AVPlayer alloc] init];
    
    //  https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW8
    
    if (self.asset) {
        [self.asset cancelLoading];
    }
    
    
    self.asset = [AVAsset assetWithURL:url];;
    
    __weak typeof(self) wself = self;

    [self.asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [wself.asset statusOfValueForKey:@"tracks" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded: {
                AVPlayerItem *newItem = [[AVPlayerItem alloc] initWithAsset:wself.asset];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    
                    @try {
                        [wself.player.currentItem removeObserver:wself forKeyPath:@"status" context:nil];
                    }
                    @catch (NSException *exception) { }
                    
                    
                    [wself.player replaceCurrentItemWithPlayerItem:newItem];
                    
                    // Firo:options增加观察新旧值
                    [wself.player.currentItem addObserver:wself forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                    
                    [wself addPlayerItemTimeObserver];
                    
                    [wself addTimeToEndObserver];
                });
                
                
            }
                
            case AVKeyValueStatusLoading:{
                NSLog(@"加载中~");
            } break;
                
            case AVKeyValueStatusFailed:{
                NSLog(@"加载失败");
                dispatch_async(dispatch_get_main_queue(), ^(){
                    
                    if(self.completeBlock){
                        
                        
                        NSDictionary *userInfo = @{@"status":@0,
                                                   @"url":self.currentUrl.absoluteString
                                                   };
                        
                        self.completeBlock(1, @"资源加载失败", userInfo);
                    }
                });
                
                
            }break;
                
            case AVKeyValueStatusCancelled:{
                NSLog(@"取消了~");
            }
                
            default:
                break;
        }
    }];
    
}

- (float)process{
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
    
    if(duration == 0) return 0;
    
    return currentTime/duration;
}


- (void)play
{
    self.playing = YES;
    [self.player play];
}

- (void)pause
{
    self.playing = NO;
    [self.player pause];
    
}

- (void)stop
{
    self.playing = NO;
    self.player.rate = 0.f;
}

- (void)next
{
    
}

- (void)previous
{
    
}

- (void)clear
{
    self.player.rate = 0;
    self.lastRate = 0;
    self.playing = NO;
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    [self removeObserver];
    
    self.player = nil;
    self.asset = nil;
    
}

- (void)pauseTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}


- (void)jumbToTime:(NSTimeInterval )seconds
{
    [self.player.currentItem cancelPendingSeeks];
    
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        [self addPlayerItemTimeObserver];
        [self play];
    }];
}


- (void)addPlayerItemTimeObserver {
    
    CMTime interval =  CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    __weak typeof(self) wself = self;
    void (^callback)(CMTime time) = ^(CMTime time) {
        
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(wself.player.currentItem.duration);
        
        if (self.progressBlock) {
            self.progressBlock(currentTime, duration, wself.currentUrl.absoluteString);
        }
        
    };
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                                                  queue:queue
                                                             usingBlock:callback];
}

/** 对当前item添加播放完成通知 */
- (void)addTimeToEndObserver
{
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    __weak typeof(self) wself = self;
    void (^callback)(NSNotification *note) = ^(NSNotification *notification) {
        
        if (wself.endBlock) {
            wself.endBlock(0, @"播放完成", @{@"status":@1, @"url":wself.currentUrl.absoluteString});
        }
        
        
        [wself clear];
    };
    self.playToEndObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                      object:self.player.currentItem
                                                       queue:queue
                                                  usingBlock:callback];
}

/** 移除当前item播放完成监听 */
- (void)removeTimeToEndObserver
{
    if (self.playToEndObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.playToEndObserver];
        self.playToEndObserver = nil;
    }
    
}



- (void)removeObserver{
    if(self.player.currentItem)
    {
        // 移除监听时，可能监听并不存在，但并不是错误，比如资源不可以播放
        @try {
            [self.player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
            [self.player replaceCurrentItemWithPlayerItem:nil];
        }
        @catch (NSException *exception) {
        }
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // 监听播放状态
    if([keyPath isEqualToString:@"status"])
    {
        // status值未变的情况下也回调了，这边自行判断新旧值，解决方法循环调用影响正常播放，临时措施，根本需要解决频繁回调的原因
        NSInteger new = [change[@"new"] integerValue];
        NSInteger old = [change[@"old"] integerValue];
        if (new == old) {
            return;
        }
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {

            [self play];
            if(self.completeBlock){
                self.completeBlock(0, @"开始播放", @{@"status":@1, @"url":self.currentUrl.absoluteString});
            }
            
        } else {
            if(self.completeBlock){
                self.completeBlock(1, @"播放失败", @{@"status":@0, @"url":self.currentUrl.absoluteString});
            }
        }
    }
    
}

- (void)dealloc
{
    [self removeTimeToEndObserver];
    [self removeObserver];
    self.timeObserver = nil;
    self.asset = nil;
    self.progressBlock = nil;
    self.completeBlock = nil;
    self.endBlock =  nil;
}

@end
