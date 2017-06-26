//
//  AccCenterController.h
//  SDKDemo
//
//  Created by apple on 2016/11/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef AccCenterController_h
#define AccCenterController_h


#endif /* AccCenterController_h */


#import <UIKit/UIKit.h>
#import "CustomFunction.h"

@protocol AccCenterCallBack <NSObject>

@required

- (void)RspModifyPwdWithAccinfo:(NSMutableDictionary *)accinfo;

@optional

@end

@interface AccCenterController : UIViewController<PostCallBack>

- (id)initWithParent:(UIView *)parent nibname:(NSString *)nibname sdkurl:(NSString *)sdkurl gameid:(NSString *)gameid appkey:(NSString *)appkey owner:(id)owner;
//每次重新开启
- (void)doesAppear:(NSString *)signdata;

@end
