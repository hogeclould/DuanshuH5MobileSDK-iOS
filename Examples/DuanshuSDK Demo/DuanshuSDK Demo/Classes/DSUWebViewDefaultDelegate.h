//
//  DSUWebViewDefaultDelegate.h
//  DuanshuSDK
//
//  Created by 苏强 on 2018/3/21.
//  Copyright © 2018年 厚建云计算. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DuanshuSDK/DSUWebViewDelegate.h>

@interface DSUWebViewDefaultDelegate : NSObject<DSUWebViewDelegate>

@end

@interface NSString(URLParameters)
- (NSDictionary *)getURLParameters;
@end
