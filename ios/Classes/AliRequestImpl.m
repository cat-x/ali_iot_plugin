//
// Created by Cat-x on 1/7/21.
//

#import "AliRequestImpl.h"
#import "IMSLifeLog.h"
#import <IMSApiClient/IMSApiClient.h>
#import <IMSAuthentication/IMSAuthentication.h>
#import <CloudPushSDK/CloudPushSDK.h>
#import <ALBBOpenAccountCloud/ALBBOpenAccountSDK.h>
#import <ALBBOpenAccountCloud/ALBBOpenAccountUser.h>
#import <AlinkAppExpress/AlinkAppExpress.h>
#import <IMSAccount/IMSAccount.h>


NSString *ServerErrorDomain = @"ServerErrorDomain";

@implementation AliRequestImpl

#pragma mark - 添加设备

+ (void)queryProductInfoWithKey:(NSString *)key
              completionHandler:(void (^)(NSDictionary *info, NSError *error))completionHandler {
    NSString *path = @"/thing/detailInfo/queryProductInfo";
    NSString *version = @"1.1.1";

    NSDictionary *params = @{
            @"productKey": key ?: @"",
    };

    [AliRequestImpl requestWithPath:path
                            version:version
                             params:params
                             scheme:nil
                           authType:nil
                  completionHandler:^(NSError *error, id data) {
                      if (completionHandler) {
                          completionHandler(data, error);
                      }
                  }];
}

+ (void)requestWithPath:(NSString *)path
                version:(NSString *)version
                 params:(NSDictionary *)params
                 scheme:(NSString *)scheme
               authType:(NSString *_Nullable)authType
      completionHandler:(void (^)(NSError *error, IMSResponse *data))completionHandler {
    IMSIoTRequestBuilder *builder = [[IMSIoTRequestBuilder alloc] initWithPath:path apiVersion:version params:params];
    if (scheme != nil) {
        [builder setScheme:scheme];
    } else {
        [builder setScheme:@"https://"];
    }
    IMSRequest *request;
    if (authType != nil) {
        request = [[builder setAuthenticationType:authType] build];
    } else {
        request = [[builder setAuthenticationType:IMSAuthenticationTypeIoT] build];
    }


    IMSLifeLogVerbose(@"Request: %@", request);
    [IMSRequestClient asyncSendRequest:request responseHandler:^(NSError *error, IMSResponse *response) {
        IMSLifeLogVerbose(@"Request: %@\nError:%@\nResponse: %d %@", request, error, response.code, response.data);

        if (error == nil && response.code != 200) {
            NSDictionary *info = @{
                    @"message": response.message ?: @"",
                    NSLocalizedDescriptionKey: response.localizedMsg ?: @"",
            };
            error = [NSError errorWithDomain:ServerErrorDomain code:response.code userInfo:info];
        }

        if (completionHandler) {
            completionHandler(error, response);
        }
    }];
}

+ (void)handleLogout {
    NSString *deviceId = [CloudPushSDK getDeviceId];
    [AliRequestImpl unbindAPNSChannelWithDeviceId:deviceId completionHandler:^(NSError *error) {
        if (error) {
            IMSLifeLogVerbose(@"解绑移动推送失败");
        }
    }];

    NSString *topic = @"/account/unbind";
    [[LKAppExpress sharedInstance] invokeWithTopic:topic opts:nil params:@{} respHandler:^(LKAppExpResponse *_Nonnull response) {
        if (![response successed]) {
            IMSLifeLogVerbose(@"解绑长连接推送失败");
        }
    }];

    //发送一个退出登通知，便于其他业务处理退出时候需要执行的操作
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMS_OPENACCOUNT_USER_LOGOUT_OUT" object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[IMSAccountService sharedService] logout];
    });

}

+ (void)unbindAPNSChannelWithDeviceId:(NSString *)deviceId
                    completionHandler:(void (^)(NSError *error))completionHandler {
    NSString *path = @"/uc/unbindPushChannel";
    NSString *version = @"1.0.0";
    NSDictionary *params = @{
            @"deviceId": deviceId ?: @"",
    };

    [AliRequestImpl requestWithPath:path
                            version:version
                             params:params
                             scheme:nil
                           authType:nil
                  completionHandler:^(NSError *error, id data) {
                      if (completionHandler) {
                          completionHandler(error);
                      }
                  }];
}

@end
