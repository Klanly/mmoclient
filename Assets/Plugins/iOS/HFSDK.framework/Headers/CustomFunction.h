//
//  CustomFunction.h
//  MyAlert
//
//  Created by apple on 2016/11/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef CustomFunction_h
#define CustomFunction_h


#endif /* CustomFunction_h */

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@protocol PostCallBack <NSObject>

@required

- (void)RspPost:(NSString *)funcID result:(NSDictionary *)dic;

@optional

@end

@interface CustomFunction : NSObject


- (NSString *)md5:(NSMutableDictionary *)dic appkey:(NSString *)appkey;

- (id)init:(id)owner sdkurl:(NSString *)sdkurl;

// 初始化
- (void)Init:(NSString *)gameid version:(NSString *)version type:(NSString *)type sdkversion:(NSString *)sdkversion chkvalue:(NSString *)chkvalue;
// 游客注册
- (void)RegisterGuest:(NSString *)gameid imei:(NSString *)imei chkvalue:(NSString *)chkvalue;
// 生成验证码
- (void)Generatevalidcode:(NSString *)gameid signdata:(NSString *)signdata phoneno:(NSString *)phoneno type:(NSString *)type chkvalue:(NSString *)chkvalue;
// 注册
- (void)Register:(NSString *)gameid username:(NSString *)username password:(NSString *)password phoneno:(NSString *)phoneno email:(NSString *)email imei:(NSString *)imei validcode:(NSString *)validcode chkvalue:(NSString *)chkvalue;
// 快速注册
- (void)QuickRegister:(NSString *)gameid password:(NSString *)password imei:(NSString *)imei chkvalue:(NSString *)chkvalue;
// 登陆
- (void)Login:(NSString *)gameid username:(NSString *)username password:(NSString *)password imei:(NSString *)imei chkvalue:(NSString *)chkvalue;
// 免密登陆
- (void)Login:(NSString *)gameid signdata:(NSString *)signdata imei:(NSString *)imei chkvalue:(NSString *)chkvalue;
// 登出
- (void)Logout:(NSString *)gameid signdata:(NSString *)signdata chkvalue:(NSString *)chkvalue;
// 修改密码
- (void)ModifyPwd:(NSString *)gameid signdata:(NSString *)signdata oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd chkvalue:(NSString *)chkvalue;
// 修改用户信息
- (void)ModifyUserinfo:(NSString *)gameid signdata:(NSString *)signdata nickname:(NSString *)nickname email:(NSString *)email birthday:(NSString *)birthday gender:(NSString *)gender chkvalue:(NSString *)chkvalue;
// 查询用户信息
- (void)QueryUserinfo:(NSString *)gameid signdata:(NSString *)signdata chkvalue:(NSString *)chkvalue;
// 手机认证
- (void)AuthPhone:(NSString *)gameid signdata:(NSString *)signdata phoneno:(NSString *)phoneno validcode:(NSString *)validcode chkvalue:(NSString *)chkvalue;
// 实名认证
- (void)AuthName:(NSString *)gameid signdata:(NSString *)signdata name:(NSString *)name idno:(NSString *)idno chkvalue:(NSString *)chkvalue;
// 获取链接
- (void)GetUrllist:(NSString *)gameid type:(NSString *)type chkvalue:(NSString *)chkvalue;
// 验证账号是否存在
- (void)ChkAccount:(NSString *)gameid username:(NSString *)username chkvalue:(NSString *)chkvalue;
// 充值密码
- (void)ResetPwd:(NSString *)gameid username:(NSString *)username newpwd:(NSString *)newpwd validcode:(NSString *)validcode chkvalue:(NSString *)chkvalue;
// 检查手机号是否可用
- (void)ChkPhone:(NSString *)gameid phoneno:(NSString *)phoneno chkvalue:(NSString *)chkvalue;

//苹果支付委托
- (void)ApplePayOrder:(NSString *)gameid signdata:(NSString *)signdata merpriv:(NSString *)merpriv orderno:(NSString *)orderno productcode:(NSString *)productcode productdesc:(NSString *)productdesc serverid:(NSString *)serverid amount:(NSString *)amount callbackurl:(NSString *)callbackurl chkvalue:(NSString *)chkvalue;
//苹果支付完成
- (void)ApplePayFinished:(NSString *)gameid signdata:(NSString *)signdata orderno:(NSString *)orderno receipt:(NSString *)receipt chkvalue:(NSString *)chkvalue;

@end
