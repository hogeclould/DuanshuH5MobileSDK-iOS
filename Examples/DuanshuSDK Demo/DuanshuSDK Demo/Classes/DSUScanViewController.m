//
//  DSUScanViewController.m
//  DuanshuSDK Demo
//
//  Created by 苏强 on 2018/3/29.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import "DSUScanViewController.h"
#import "ExampleViewController.h"

#import <AVFoundation/AVFoundation.h>
@interface DSUScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation DSUScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input){
        [self.captureSession addInput:input];
    }else{
        NSLog(@"%@", error);
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    [self.captureSession addOutput:output];
    
    // 先加入session，在设置metadataObjectTypes
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.captureSession startRunning];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat previewLayerW = 200;
    CGFloat previewLayerH = 200;
    CGFloat previewLayerX = (width - previewLayerW) * 0.5;
    CGFloat previewLayerY = (height - previewLayerH) * 0.5;;
    
    self.previewLayer.frame = CGRectMake(previewLayerX, previewLayerY, previewLayerW, previewLayerH);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *qrString = nil;
    
    for( AVMetadataObject *meta in metadataObjects){
        if(meta.type == AVMetadataObjectTypeQRCode){
            qrString = ((AVMetadataMachineReadableCodeObject *)meta).stringValue;
        }
    }
    
    NSLog(@"%@", qrString);
    
    ExampleViewController *vc = [[ExampleViewController alloc] init];
    
    vc.contentURL = [NSURL URLWithString:qrString];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    NSMutableArray *array = self.navigationController.viewControllers.mutableCopy;
    
    [array removeObjectAtIndex:array.count - 2];
    
    self.navigationController.viewControllers = array;
    
    
    [self.captureSession stopRunning];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
