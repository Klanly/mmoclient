//
//  LoginViewController.h
//  SDKDemo
//
//  Created by apple on 2016/11/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef LoginViewController_h
#define LoginViewController_h


#endif /* LoginViewController_h */


#import <UIKit/UIKit.h>
#import "CustomFunction.h"

@protocol LoginCallBack <NSObject>

@required

- (void)RspAccInfo:(NSMutableDictionary *)accinfo;
- (void)RspLogin:(NSDictionary *)data;
- (void)RspLogout:(NSDictionary *)data;

@optional

@end

@interface LoginViewController : UIViewController<PostCallBack>

//外部方法
- (id)initWithParent:(UIView *)parent nibname:(NSString *)nibname owner:(id)owner sdkurl:(NSString *)sdkurl gameid:(NSString *)gameid appkey:(NSString *)appkey imei:(NSString *)imei;
- (void)doesAppear:(NSDictionary *)accinfos;

- (void)loginWithDelay:(NSInteger)seconds signdata:(NSString *)signdata showacc:(NSString *)showacc;
- (void)logoutWithSigndata:(NSString *)signdata;

@end
