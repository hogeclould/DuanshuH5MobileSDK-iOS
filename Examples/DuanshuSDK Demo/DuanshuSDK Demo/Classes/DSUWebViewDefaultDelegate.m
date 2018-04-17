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
#import "ExampleViewController.h"


@interface DSUWebViewDefaultDelegate()<TZImagePickerControllerDelegate, MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) DSUCallbackBlock shareComplete;
@end

@implementation DSUWebViewDefaultDelegate
#pragma mark -
#pragma mark DSUWebViewDelegate
- (void)dsu_getUserInfoWithParam:(id)param completeBlock:(DSUCallbackBlock)complete{
   NSDictionary *userInfo = @{
                                @"userId":@"userid_zhangsan_uuid",
                                @"userName":@"张三",
                                @"avatarUrl":@"http://s4.sinaimg.cn/mw690/001E55c8zy70SSUW4gj73&690",
                                @"telephone":@"18651618858"
                              };
    
    complete(0, @"success", userInfo);
}

- (void)dsu_startRecordWithParam:(NSDictionary *)param
                   completeBlock:(DSUCallbackBlock) complete
                    timeoutBlock:(DSUCallbackBlock)timeoutBlock{
    
    BOOL base64_enabled = [param[@"base64_enabled"] boolValue];
    [DSUAudioRecorder dsu_enableBase64:base64_enabled];
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
    BOOL base64_enabled = [param[@"base64_enabled"] boolValue];
    
    
    if (count == 0) {
        count =  1;
    }
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:self];
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        NSString *temp = NSTemporaryDirectory();
        
        // 此处用户可以将图片上传到自己的服务器上，返回远程的图片url地址，返回给h5
        NSMutableArray *urls = [NSMutableArray array];
        for (UIImage *image in photos) {
            NSString *file = [temp stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
            
            NSData *data = UIImagePNGRepresentation(image);
            
            NSString *type = @"png";
            if (data == nil) {
                data = UIImageJPEGRepresentation(image, 0.5);
                type = @"jpg";
            }
            
            [data writeToFile:file atomically:YES];
            if(base64_enabled){
                
                NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
                
                info[@"localPath"] = [NSURL fileURLWithPath:file].absoluteString;
                info[@"type"] = type;
                info[@"base64"] = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                
                [urls addObject:info];
                
            }else{
                [urls addObject:[NSURL fileURLWithPath:file].absoluteString];
            }
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
    NSString *updateShareData = param[@"updateShareData"];
    NSString *showShareButton = param[@"showShareButton"];
    
    NSURL *url = [NSURL URLWithString:@"http://www.duanshu.com/index.html"];
    
    NSURL *imageURL =  [NSURL URLWithString:imageURLString];
    
    NSArray *items = @[title, imageURL, content, url];
    self.items = items;
    self.shareComplete = complete;
    
    if (!updateShareData.boolValue) {

        [self share];
        
    }
    
    // 获取当前页面
    UINavigationController *naviVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = naviVC.viewControllers.lastObject;
    
    // 展示 or 隐藏导航栏左侧按钮
    currentVC.navigationItem.leftBarButtonItem = showShareButton.boolValue ? [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action: @selector(share)] : nil;
    
}

- (void)share {
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:self.items applicationActivities:nil];
    
    __weak typeof(self) weakSelf = self;
    UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"activityType == %@",activityType);
        if (completed == YES) {
            weakSelf.shareComplete(0, @"completed", nil);
        }else{
            weakSelf.shareComplete(0, @"cancle", nil);
        }
        
        weakSelf.shareComplete(0, @"completed", nil);
        
        [activityVC dismissViewControllerAnimated:YES completion:nil];
    };
    activityVC.completionWithItemsHandler = itemsBlock;
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityVC animated:YES completion:nil];
}


- (void)dsu_loadUrlWithParam:(id)param completeBlock:(DSUCallbackBlock)complete{
    NSString *url = param[@"url"];
    
    if([url hasPrefix:@"dingdone://tel"]){
        NSDictionary *params = [url getURLParameters];
        NSString *phoneNumber = params[@"phone_number"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
        
        complete(0, nil, nil);
        
    }else if([url hasPrefix:@"http"]){
        ExampleViewController *vc = [[ExampleViewController alloc] init];
        
        vc.contentURL = [NSURL URLWithString:url];
        
        UINavigationController * navigationController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        
        [navigationController pushViewController:vc animated:YES];
        
        complete(0, nil, nil);
    }
    
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


@implementation NSString(URLParameters)

- (NSDictionary *)getURLParameters {
    
    // 查找参数
    NSRange range = [self rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [self substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params.copy;
}

@end

