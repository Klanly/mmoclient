//
//  TransactionServer.h
//
//  Created by Osipov Stanislav on 1/16/13.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"
#import "ISN_NSData+Base64.h"
#import "ISN_Reachability.h"
//#import "ISNDataConvertor.h"

@protocol PurchaseCallBack <NSObject>

@required

- (void)RspPayFailed:(NSString *)errmsg;
- (void)RspPayFinished:(NSString *)receipt;

@optional

@end

@interface TransactionServer : NSObject <SKPaymentTransactionObserver> {
    id<PurchaseCallBack> _delegate;
}

- (id)initWithDelegate:(id)delegate;
- (void) verifyLastPurchase:(NSString *) verificationURL;

@end
