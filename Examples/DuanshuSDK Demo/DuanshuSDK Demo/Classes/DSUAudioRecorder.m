//
//  DSUAudioRecorder.m
//  DuanshuSDK Demo
//
//  Created by 苏强 on 2018/3/21.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//


#define kDUANSHU_RECORD_CAF_NAME @"record.caf"      //录制文件名
#define kDUANSHU_RECORD_MP3_NAME @"record.mp3"      //转换成mp3格式后文件名
#define kDUANSHU_RECORD_DIRECTRY @"record"          //沙盒下保存目文件夹名

#import "DSUAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "CommonCrypto/CommonDigest.h"
#import "lame.h"

static const NSInteger kMaxTimeInterval = 120;


@interface DSUAudioRecorder()<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) DSUCallbackBlock recordCallback;

@property (nonatomic, copy) DSUCallbackBlock playCallback;

@property (nonatomic, copy) DSUCallbackBlock timeoutCallback;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, copy) NSString *playingUrlStr;
@end

@implementation DSUAudioRecorder

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)dsu_startRecordCompleteBlock:(DSUCallbackBlock) complete timeoutBlock:(DSUCallbackBlock)timeoutBlock{
    AVAudioSession *sharedSession = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission permissionStatus = [sharedSession recordPermission];
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:{
            if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            // 已授权，可以录音
                            complete(0, @"开始录音", @{@"status":@(1)});
                            
                            [[DSUAudioRecorder shareInstance] startRecorderWithCallback:complete timeoutBlock:timeoutBlock];
                            
                        } else {
                            // 没有权限
                            complete(11, @"没有权限", @{@"status":@(0)});
                        }
                    });
                }];
            }
        }
            break;
        case AVAudioSessionRecordPermissionDenied: {
            
            NSLog(@"已经拒绝麦克风弹框");
            complete(11, @"没有权限", @{@"status":@(0)});
        }
            break;
        case AVAudioSessionRecordPermissionGranted:
            NSLog(@"已经允许麦克风弹框");
            complete(0, @"开始录音", @{@"status":@(1)});
            [[DSUAudioRecorder shareInstance] startRecorderWithCallback:complete timeoutBlock:timeoutBlock];
            break;
    }
}

+ (void)dsu_stopRecordCompleteBlock:(DSUCallbackBlock) complete{
    [[DSUAudioRecorder shareInstance] stopRecorderWithCallback:complete];
}


#pragma mark - Record API

- (void)startRecorderWithCallback:(DSUCallbackBlock)callback timeoutBlock:(DSUCallbackBlock)timeoutBlock{
    
    self.timeoutCallback = timeoutBlock;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil) {
        NSLog(@"🚫Error creating session: %@", [sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
    
    NSDictionary *settings = @{
                               AVSampleRateKey : [NSNumber numberWithFloat:8000.f],
                               AVFormatIDKey : @(kAudioFormatLinearPCM),
                               AVNumberOfChannelsKey : @2,
                               AVEncoderAudioQualityKey : @(AVAudioQualityLow)
                               };
    
    NSError *error;
    if (self.recorder) {
        if ([self.recorder isRecording])
            [self.recorder stop];
        self.recorder = nil;
    }
    
    NSURL *recordedFile = [NSURL fileURLWithPath:[self recordFilePath]];
    
    if (recordedFile) {
        [self deleteFileAtPath:recordedFile.path];
    }
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:settings error:&error];
    [self.recorder prepareToRecord];
    [self.recorder record];
    [self addTimerWithCallback:self.timeoutCallback];
    
    callback(0, @"success", @{});
    
    NSLog(@"✅Start record!");
    
}

- (void)stopRecorderWithCallback:(DSUCallbackBlock)callback {
    
    if (![self.recorder isRecording]) {
        NSLog(@"🚫Not recording");
    } else {
        CGFloat currentTime = ceilf(self.recorder.currentTime);
        [self.recorder stop];
        self.recordCallback = callback;
        [self removeTimer];
        NSLog(@"✅Stop record!");
        NSString *originPath = [self recordFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:originPath]) {
            
            NSLog(@"🚫Record file is not exist!");
            return;
        }
        
        NSString *mp3File = [self mp3FilePath];
        BOOL convertSuccess = [self convertPCMFile:originPath toMP3File:mp3File];
        
        
        if (convertSuccess) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//            NSData *data = [NSData dataWithContentsOfFile:mp3File];
//            userInfo[@"audioDuration"] = @(currentTime);
            userInfo[@"localPath"] = [NSURL fileURLWithPath:mp3File].absoluteString;
//            userInfo[@"audioData"] = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            callback(0, @"结束录音", userInfo);
        }else{
            callback(0, @"录音转码错误", @{@"status":@(0)});
        }
        
    }
    
}

#pragma mark - Audio Play API

- (void)playVoiceWithUrl:(NSString *)url callback:(DSUCallbackBlock)callback {
    
    if ([self.playingUrlStr isEqualToString:url]) {
        if (![self.player isPlaying]) {
            
            [self audioPlay];
            
        }
        return;
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && [url hasSuffix:@".mp3"]) {
        
        NSString *path = [self getFilePathWithUrlStr:url];
        if (![self isFileDownloadedAtPath:path]) {
            
            NSData *audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            [self saveData:audioData withUrlStr:url];
            
        }
        
        if (self.player) {
            
            [self clearPlayer];
            
        }
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
        
        if (!self.player) {
            
            NSLog(@"🚫Player did not load properly:%@", error.description);
            
        } else {
            
            self.playingUrlStr = url;
            self.player.delegate = self;
            self.playCallback = callback;
            [self audioPlay];
            
        }
    }
    
}

- (void)pauseVoicWithUrl:(NSString *)url {
    
    if ([url isEqualToString:self.playingUrlStr] && [self.player isPlaying]) {
        
        [self audioPause];
        
    }
    
}

- (void)stopVoiceWithUrl:(NSString *)url {
    
    if ([url isEqualToString:self.playingUrlStr]) {
        
        [self audioStop];
    }
    
}

#pragma mark - Play Aciton

- (void)audioPlay {
    
    [self.player play];
    NSLog(@"✅Audio Play!");
    
}

- (void)audioPause {
    
    [self.player pause];
    NSLog(@"✅Audio Pause!");
    
}

- (void)audioStop {
    
    [self.player stop];
    [self clearPlayer];
    NSLog(@"✅Audio Stop!");
    
}

#pragma mark - Helper

- (void)addTimerWithCallback:(DSUCallbackBlock)callback {
    
    [self removeTimer];
    // 最多录制多少时间，自动停止
    
    __weak typeof(self) wself = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kMaxTimeInterval
                                                 repeats:NO
                                                   block:^(NSTimer * _Nonnull timer) {
                                                       [wself stopRecorderWithCallback:callback];
                                                   }];
    
}

- (void)removeTimer {
    
    if (self.timer && [self.timer isValid]) {
        NSLog(@"✅Remove timer!");
        [self.timer invalidate];
        self.timer = nil;
        
    }
}

- (void)deleteFileAtPath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    
}

- (NSString *)recordFilePath {
    
    return [NSTemporaryDirectory() stringByAppendingFormat:kDUANSHU_RECORD_CAF_NAME];
    
}

- (NSString *)mp3FilePath {
    
    return [NSTemporaryDirectory() stringByAppendingFormat:kDUANSHU_RECORD_MP3_NAME];
    
}

- (NSString *)getFilePathWithUrlStr:(NSString *)urlStr {
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directryPath = [path stringByAppendingPathComponent:kDUANSHU_RECORD_DIRECTRY];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    
    BOOL isDirExist = [fm fileExistsAtPath:directryPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir)) {
        
        BOOL bCreateDir = [fm createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(!bCreateDir){
            
            NSLog(@"🚫Create Audio Directory Failed.");
            
        }
        NSLog(@"✅Create Audio Directory Succeed:%@.", directryPath);
        
    }
    NSString *fileName = [[self _md5:urlStr] stringByAppendingPathExtension:@"mp3"];
    
    return [directryPath stringByAppendingPathComponent:fileName];
    
}

- (BOOL)isFileDownloadedAtPath:(NSString *)path {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

- (void)uploadRecord {
    
}

- (void)saveData:(NSData *)data withUrlStr:(NSString *)urlStr {
    
    BOOL isSuccess = [data writeToFile:[self getFilePathWithUrlStr:urlStr] atomically:YES];
    if (isSuccess) {
        
        NSLog(@"✅Save succeed!");
        
    } else {
        
        NSLog(@"🚫Save failed!");
        
    }
}

/*-----------Convert to mp3-----------*/
- (BOOL)convertPCMFile:(NSString *)cafFilePath toMP3File:(NSString *)mp3FilePath {
    [self deleteFileAtPath:mp3FilePath];

    BOOL convertSuccess = NO;
    NSLog(@"cafFilePath :%@  mp3FielPath :%@", cafFilePath, mp3FilePath);
    @try {
        NSLog(@"mp3FilePath :%@", mp3FilePath);
        
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");    //source
        fseek(pcm, 4 * 1024, SEEK_CUR);                                     //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");   //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_num_channels(lame, 2);
        lame_set_in_samplerate(lame, 8000);
        lame_set_out_samplerate(lame, 8000);
        lame_set_brate(lame, 128);
        lame_set_quality(lame, 5);
        lame_set_mode(lame, STEREO);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        convertSuccess = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"🚫%@", [exception description]);
        
    }
    
    return convertSuccess;
}

- (void)clearPlayer {
    
    self.player.delegate = nil;
    self.playingUrlStr = nil;
    self.playCallback = nil;
    self.player = nil;
    
}

- (NSString *)_md5:(NSString *)srcString{
    if (srcString.length == 0) {
        return @"";
    }
    const char *cStr = [srcString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

@end
