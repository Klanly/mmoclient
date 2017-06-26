//
//  InAppPurchaseManager.h
//  HFSDK
//
//  Created by apple on 2016/12/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef InAppPurchaseManager_h
#define InAppPurchaseManager_h


#endif /* InAppPurchaseManager_h */


#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "TransactionServer.h"
#import "ISNDataConvertor.h"
#import "CustomFunction.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@protocol ApplePayCallBack <NSObject>

@required

- (void)RspRequestErr:(NSString *)errcode errmsg:(NSString *)errmsg;
- (void)RspLoadStore:(SKProductsResponse *)response;
- (void)RspPayFailed:(NSString *)errmsg;
- (void)RspPayFinished:(NSString *)orderid receipt:(NSString *)receipt;

@optional

@end

@interface InAppPurchaseManager : NSObject<SKProductsRequestDelegate, SKRequestDelegate, PurchaseCallBack, PostCallBack> {
    NSMutableDictionary * _products;
    TransactionServer *_storeSever;
    id<ApplePayCallBack> _delegate;
}

+ (InAppPurchaseManager *) instance;

- (void)loadStore:(NSArray *)productIds sdkurl:(NSString *)sdkurl serverid:(NSString *)serverid callbackurl:(NSString *)callbackurl delegate:(id)delegate;
- (void)buyProduct:(NSString *)productId gameid:(NSString *)gameid appkey:(NSString *)appkey signdata:(NSString *)signdata orderno:(NSString *)orderno;

@end
