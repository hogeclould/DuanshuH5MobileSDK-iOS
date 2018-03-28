//
//  DSUWebViewDefaultDelegate.m
//  DuanshuSDK Demo
//
//  Created by 苏强 on 2018/3/21.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import "DSUWebViewDefaultDelegate.h"
#import "DSUAudioRecorder.h"
#import "DSUAudioPlayer.h"
#import "TZImagePickerController.h"
#import "MWPhotoBrowser.h"
#import <Social/Social.h>

@interface DSUWebViewDefaultDelegate()<TZImagePickerControllerDelegate, MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@end

@implementation DSUWebViewDefaultDelegate
#pragma mark -
#pragma mark DSUWebViewDelegate
- (void)dsu_getUserInfoWithParam:(id)param completeBlock:(DSUCallbackBlock)complete{
   NSDictionary *userInfo = @{
                                @"userId":@"userid_xxxx",
                                @"userName":@"张三",
                                @"avatarUrl":@"http://xxxx.png",
                                @"telephone": @"186xxxx"
                              };
    
    complete(0, @"success", userInfo);
}

- (void)dsu_startRecordWithParam:(id)param
                   completeBlock:(DSUCallbackBlock) complete
                    timeoutBlock:(DSUCallbackBlock)timeoutBlock{
    
    [DSUAudioRecorder dsu_startRecordCompleteBlock:complete timeoutBlock:timeoutBlock];
}

- (void)dsu_stopRecordWithParam:(id)param
                  completeBlock:(DSUCallbackBlock)complete{
    [DSUAudioRecorder dsu_stopRecordCompleteBlock:complete];
}

- (void)dsu_playVoiceWithParam:(NSDictionary *)param
                 completeBlock:(DSUCallbackBlock)complete
                 progressBlock:(DSUProgressBlock)progressBlock
                      endBlock:(DSUCallbackBlock)endBlock{
    
    if (param == nil || param[@"record_url"] == nil) {
        complete(1, @"无播放地址", @{});
        return;
    }else{
        NSURL *url = [NSURL URLWithString:param[@"record_url"]];
        
        [DSUAudioPlayer playWithURL:url
                      completeBlock:complete
                      progressBlock:progressBlock
                           endBlock:endBlock];
    }
    
}

- (void)dsu_pauseVoiceWithParam:(id)param completeBlock:(DSUCallbackBlock)complete{
    
    NSURL *url = [NSURL URLWithString:param[@"record_url"]];
    [DSUAudioPlayer pauseWithURL:url completeBlock:complete];
}

- (void)dsu_stopVoiceWithParam:(id)param completeBlock:(DSUCallbackBlock)complete{
    
    NSURL *url = [NSURL URLWithString:param[@"record_url"]];
    [DSUAudioPlayer stopWithURL:url completeBlock:complete];
}

- (void)dsu_chooseImageWithParam:(NSDictionary *)param completeBlock:(DSUCallbackBlock)complete{
    
    int count = [param[@"count"] intValue];
    
    if (count == 0) {
        count =  1;
    }
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:self];
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        NSString *temp = NSTemporaryDirectory();
        NSMutableArray *urls = [NSMutableArray array];
        for (UIImage *image in photos) {
            NSString *file = [temp stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
            [UIImagePNGRepresentation(image) writeToFile:file atomically:YES];
            [urls addObject:[NSURL fileURLWithPath:file].absoluteString];
        }
        complete(1, @"选取图片", urls);
    }];
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePickerVc animated:YES completion:nil];
    
}

- (void)dsu_previewImageWithParam:(NSDictionary *)param completeBlock:(DSUCallbackBlock)complete{

    NSString *url = param[@"imgUrl"];
    self.photos = [NSMutableArray array];
    
    [self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];

    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.zoomPhotosToFill = YES;
    browser.alwaysShowControls = NO;
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    browser.autoPlayOnAppear = NO;

    [browser setCurrentPhotoIndex:0];
    
    UINavigationController *navi = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                                    
    [navi pushViewController:browser animated:YES];
}


- (void)dsu_previewPicWithParam:(NSDictionary *)param completeBlock:(DSUCallbackBlock)complete{
    
    int position = [param[@"position"] intValue];
    
    NSArray *photoUrls = param[@"pics"];
    
    if (position > photoUrls.count) {
        position = 0;
    }
    
    self.photos = [NSMutableArray array];
    
    for (NSString *url in photoUrls) {
        [self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
    }
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.zoomPhotosToFill = YES;
    browser.alwaysShowControls = NO;
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:position];
    
    
    UINavigationController *navi = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    [navi pushViewController:browser animated:YES];
}

- (void)dsu_shareWithParam:(NSDictionary *)param completeBlock:(DSUCallbackBlock)complete{
    
    
    NSString *title = param[@"title"];
    NSString *imageURLString = param[@"picurl"];
    NSString *content = param[@"content"];
    NSURL *url = [NSURL URLWithString:@"http://www.duanshu.com/index.html"];
    
    NSURL *imageURL =  [NSURL URLWithString:imageURLString];
    
    NSArray *items = @[title, imageURL, content, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    
    UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"activityType == %@",activityType);
        if (completed == YES) {
            complete(0, @"completed", nil);
        }else{
            complete(0, @"cancle", nil);
        }
        
        complete(0, @"completed", nil);
        
        [activityVC dismissViewControllerAnimated:YES completion:nil];
    };
    activityVC.completionWithItemsHandler = itemsBlock;
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityVC animated:YES completion:nil];
}


#pragma mark -
#pragma MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}




@end
