//
//  AliAppDelegate.m
//  ali_iot_plugin
//
//  Created by Cat-x on 1/8/21.
//

#import "ALiAppDelegate.h"


#import <IMSIotSmart/IMSIotSmart.h>
#import <IMSIotSmart/IMSIotSmart+options.h>


#import <IMSLog/IMSLog.h>


#if __has_include(<IMSOpenAccountCustom/IMSOpenAccountCustom.h>)
#import <IMSOpenAccountCustom/IMSOpenAccountCustom.h>
#endif

#if __has_include(<IMSDebug/IMSDebug.h>)
#import <IMSDebug/IMSDebug.h>
#endif


@implementation ALiAppDelegate

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 1、提供debug调试功能，支持切换安全图片，serverEnv、boneEnv外部客户请默认release
    NSString *authCode;
    NSString *serverEnv;
    NSString *boneEnv;
#if __has_include(<IMSDebug/IMSDebug.h>)
    NSDictionary *dict = [[IMSDebugEnv sharedInstance] reSetDebugDict];
    authCode = dict[@"authCode"];
    serverEnv = dict[@"serverEnv"];
    boneEnv = dict[@"boneEnv"];
#else
    authCode = @"product";
    serverEnv = @"release";
    boneEnv = @"release";
#endif

    // 2、设置在控制台显示日志
    [IMSLog setAllTagsLevel:IMSLogLevelVerbose];
    [IMSLog showInConsole:YES];

    // 3、IMSSmartSDK初始化：regionType、
    IMSIotSmartConfig *config = [IMSIotSmartConfig new];
    config.regionType = REGION_CHINA_ONLY;
    if ([authCode isEqualToString:@"product"]) {
        config.appType = APP_TYPE_PRODUCTION;
    } else {
        config.appType = APP_TYPE_DEVELOP;
    }
    [[IMSIotSmart sharedInstance] setConfig:config];
    [[IMSIotSmart sharedInstance] setAuthCode:@"china_production"];

    IMSIotSmartEnvironment *env = [[IMSIotSmartEnvironment alloc] init];
    env.serverEnv = serverEnv;
    env.boneEnv = boneEnv;
    [[IMSIotSmart sharedInstance] setEnvironment:env];
    [[IMSIotSmart sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    // 4、支持OASDK设置多语言
#if __has_include(<IMSOpenAccountCustom/IMSOpenAccountCustom.h>)
    // 设置OA 模块多语言:设置语言前缀：de、en、es、fr、ja、ko、ru、zh、hi、it、pt、pl、nl
    NSString *language = [IMSIotSmart sharedInstance].getLanguage;
    [[IMSiLopOALanguageManage shareInstance] setOpenAccountModuleLanguageWithLanguagePrefix:[language substringToIndex:2]];
#endif


    return YES;
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //如果App没有集成移动应用推送能力，此处无需要调用
    [[IMSIotSmart sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //如果App没有集成移动应用推送能力，此处无需要调用
    [[IMSIotSmart sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //如果App没有集成移动应用推送能力，此处无需要调用
    [[IMSIotSmart sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}


@end
