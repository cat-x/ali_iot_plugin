//
//  SubDeviceApiImpl.m
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/5/25.
//

//
// Created by Cat-x on 1/12/21.
//

#import "SubDeviceApiImpl.h"
#import <AlinkAppExpress/LKAppExpress.h>
#import "DownstreamListener.h"
#import "IMSLifeLog.h"

@implementation SubDeviceApiImpl
static DownstreamListener *downListner = nil;

+ (void)subscribe:(NSString *)topic completionHandler:(void (^)(NSError *error))completionHandler eventSink:(FlutterEventSink)eventSink {
//以订阅用户所绑定的设备属性变化事件为例，详细的使用说明请参考 api reference
    [[LKAppExpress sharedInstance] subscribe:topic complete:^(NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(error);
            if (error == nil) {
                IMSLifeLogVerbose(@"订阅成功");
                downListner = [[DownstreamListener new] initWithSink:eventSink topic:topic];//sdk不会strong持有此listener，开发者自己保证listener不被释放.
                [[LKAppExpress sharedInstance] addDownStreamListener:YES listener:downListner];
            } else {
                IMSLifeLogError(@"订阅失败: %@", error);
            }
        });
    }];
}

+ (void)unsubscribe:(NSString *)topic completionHandler:(void (^)(NSError *error))completionHandler {
// 详细的使用说明请参考 api reference
    [[LKAppExpress sharedInstance] unsubscribe:topic complete:^(NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(error);
            [[LKAppExpress sharedInstance] removeDownStreamListener:downListner];
            if (error == nil) {
                downListner = nil;
                IMSLifeLogVerbose(@"取消订阅成功");
            } else {
                IMSLifeLogError(@"取消订阅失败: %@", error);
            }
        });
    }];
}

@end
