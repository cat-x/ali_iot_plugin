//
//  IMSAccountThird.m
//  ali_iot_plugin
//
//  Created by Cat-x on 1/11/21.
//

#import "IMSAccountThird.h"
#import <ALBBOpenAccountCloud/ALBBOpenAccountSDK.h>
#import <ALBBOpenAccountSSO/ALBBOpenAccountSSOService.h>
#import <IMSAccount/IMSAccountService.h>


@interface IMSAccountThird () <SSODelegate>
@end

@implementation IMSAccountThird


- (void)loginGetAuthCode:(NSString *)authCode
       completionHandler:(void (^)(NSDictionary *info, NSError *error))completionHandler {
    self.fLoginCallDelegate = completionHandler;
    //自有账号登录并通过Oauth 2.0服务获取AuthCode
    id <ALBBOpenAccountSSOService> ssoService = ALBBService(ALBBOpenAccountSSOService);
    [ssoService oauthWithThirdParty:authCode delegate:self];
}


- (void)openAccountOAuthError:(NSError *)error Session:(ALBBOpenAccountSession *)session {
    if (!error) {
        //登录成功，发送登录成功通知，身份认证SDK会监听该通知并创建和管理用户身份凭证
        NSString *loginNotificationName = [[IMSAccountService sharedService].sessionProvider accountDidLoginSuccessNotificationName];
        [[NSNotificationCenter defaultCenter] postNotificationName:loginNotificationName object:nil];
    } else {
        //处理登录失败
    }
//    [self loginCallDelegate];
    NSDictionary *userInfo = @{};
    if (error == nil) {
        ALBBOpenAccountUser *user = session.getUser;
//        NSDictionary *stu = @{@"accountId":user.accountId,@"openId":user.openId,@"avatarUrl":user.avatarUrl};
        userInfo = user.openaccountInfoDict;
    }
    self.fLoginCallDelegate(userInfo, error);
}
@end
