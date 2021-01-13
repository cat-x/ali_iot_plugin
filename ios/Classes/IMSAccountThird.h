//
// Created by Cat-x on 1/11/21.
//

#import <Foundation/Foundation.h>
#import <ALBBOpenAccountCloud/ALBBOpenAccountSDK.h>
#import <ALBBOpenAccountSSO/ALBBOpenAccountSSOService.h>
#import <IMSAccount/IMSAccountService.h>

//typedef void (^OnLoginSuccess)(NSDictionary *info);
//typedef void (^OnLoginFailed)(NSError *error);

@interface IMSAccountThird : NSObject
@property(weak, nonatomic) id <SSODelegate> loginCallDelegate;

- (void)loginGetAuthCode:(NSString *)authCode
       completionHandler:(void (^)(NSDictionary *info, NSError *error))completionHandler;
@end
