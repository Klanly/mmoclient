//
//  SDKinit.h
//  SDKDemo
//
//  Created by apple on 2016/11/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef SDKinit_h
#define SDKinit_h


#endif /* SDKinit_h */


#import <UIKit/UIKit.h>
#import "CustomFunction.h"

@protocol InitCallBack <NSObject>

@required

- (void)RspInit:(NSDictionary *)data;

@optional

@end

@interface SDKinit : NSObject<PostCallBack>

- (id)initWithOwner:(id)owner sdkurl:(NSString *)sdkurl appkey:(NSString *)appkey;

- (void)Init:(NSString *)gameid version:(NSString *)version type:(NSString *)type sdkversion:(NSString *)sdkversion chkvalue:(NSString *)chkvalue;

@end
