//
//  Entrance.h
//  SDKDemo
//
//  Created by apple on 2016/11/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef Entrance_h
#define Entrance_h


#endif /* Entrance_h */

#import <UIKit/UIKit.h>
#import "SDKinit.h"
#import "LoginViewController.h"
#import "AccCenterController.h"
#import "InAppPurchaseManager.h"

@protocol RspCallBack <NSObject>

@required

- (void)RspInit:(NSDictionary *)data;
- (void)RspLogin:(NSDictionary *)data;
- (void)RspLogout:(NSDictionary *)data;

- (void)RspLoadFailed:(NSString *)errcode errmsg:(NSString *)errmsg;
- (void)RspLoadStore:(NSArray *)productInfos invalidInfos:(NSArray *)invalidInfos;
- (void)RspPayFailed:(NSString *)errmsg;
- (void)RspPayFinished:(NSString *)orderId receipt:(NSString *)receipt;

@optional

@end

@interface Entrance : NSObject<InitCallBack, LoginCallBack, AccCenterCallBack, ApplePayCallBack>

//Entrance实例
+ (Entrance *) instance;

//初始化
- (void)sdkInit:(id)owner gameid:(NSString *)gameid appkey:(NSString *)appkey version:(NSString *)version;
//登陆
- (void)sdkLogin;
//用户中心
- (void)sdkAccCenter;
//Logout
- (void)sdkLogout;

//加载所有支付项目
- (void)loadStore:(NSArray *)productIds serverid:(NSString *)serverid callbackurl:(NSString *)callbackurl;
//购买指定产品
- (void)buyProduct:(NSString *)productId orderno:(NSString *)orderno;

@end
