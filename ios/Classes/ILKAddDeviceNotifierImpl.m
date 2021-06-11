//
//  ILKAddDeviceNotifierImpl.m
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/4/22.
//
#import "ExtensionUtils.h"
#import "ILKAddDeviceNotifierImpl.h"
#import <IMLDeviceCenter/IMLDeviceCenter.h>
#import "DispatchNetAPIImpI.h"

static ILKAddDeviceNotifierImpl *startAddDevice = nil;
static dispatch_once_t onceToken;

@implementation ILKAddDeviceNotifierImpl

+ (instancetype)sharedStartAddDevice {
    dispatch_once(&onceToken, ^{
        startAddDevice = [[[self class] alloc] init];
    });

    return startAddDevice;
}

//   sink &&  methodChannel   传值方法
- (void)setSink:(FlutterEventSink)sink channel:(FlutterMethodChannel*)channel {
    self.eventSink = sink;
    self.methodChannel = channel;
}

//   开始配网  调用startAddDevice配网接口
- (void)add {
    [kLkAddDevBiz startAddDevice: self];
}

#pragma mark - 回调方法
- (void)notifyPrecheck:(BOOL)success withError:(NSError *)err {
    NSLog(@"notifyPrecheck callback err : %@", err);
}

- (void)notifyProvisionPrepare:(LKPUserGuideCode)guideCode {
    NSLog(@"notifyProvisionPrepare callback guide code : %ld", (long)guideCode);
    int level = 0;
    switch (guideCode) {
        case LKPGuideCodeOnlyInputPwd:
            level = 1;   // :一键广播配网相关引导
            break;
        case LKPGuideCodeWithUserGuide:
            level = 2;   // :手机热点配网相关引导
            break;
        case LKPGuideCodeWithUserGuideForSoftAp:
            level = 3;   // :设备热点配网相关引导
            break;
        case LKPGuideCodeWithUserGuideForQR:
            level = 4;   // :摄像头扫码配网相关引导
            break;
    }
    self.eventSink(@[@"onProvisionPrepare", @(level)]);
    if (guideCode == LKPGuideCodeOnlyInputPwd) {
        //   Native  调用 flutter    方法：toggleProvision  需与flutter上的一致
        [self.methodChannel invokeMethod: @"toggleProvision" arguments: [NSNull null] result:^(id  _Nullable result) {
            if (result != nil){
                //  取值result  获得ssid、password
            NSDictionary *dic = (NSDictionary *)result;
            NSString *ssid = [dic objectForKey:@"ssid"];
            NSString *password = [dic objectForKey:@"password"];
            int timeout = 60;//(单位秒,s);
                // 判断非空
            if (ssid != nil && password != nil) {
            [kLkAddDevBiz toggleProvision:ssid pwd:password timeout:timeout];
            }}}];
    }
}

- (void)notifyProvisioning {
    NSLog(@"notifyProvisioning callback(正在进行配网...) ");
    self.eventSink(@[@"onProvisioning"]);
}

- (void)notifyProvisionResult:(IMLCandDeviceModel *)candDeviceModel withProvisionError:(NSError *)provisionError {
    NSLog(@"配网结果：%@", candDeviceModel);
    NSString *deviceInfoString;
    NSString *errorInfoString;

    if (candDeviceModel != nil) {
        NSDictionary *deviceInfo = [[NSDictionary alloc] init];
        deviceInfo = candDeviceModel.toJSONDictionary;
        deviceInfoString = [ExtensionUtils convertToJsonData:deviceInfo];
        //  配网成功   deviceInfo设置为String    此时的errorCode得到信息为空，防止字典空值崩溃，故设置为NSNull
        NSDictionary *dict = @{@"isSuccess": @(YES), @"deviceInfo": deviceInfoString, @"errorCode": [NSNull null] };
        self.eventSink(@[@"onProvisionedResult", dict]);
    } else {
        if (provisionError != nil) {
        NSLog(@"配网失败，错误信息:%@", provisionError);
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];//初始化了一个空字典（可变）
        //  添加新的键值对象（此处设置为可变字典）
        [dictionary setObject:provisionError.domain forKey:@"dict"];
        NSLog(@"provisionError: %@", provisionError);
        //   跳转convertToJsonData方法，进行：字典--》Jason 数据转换
        errorInfoString = [ExtensionUtils convertToJsonData:dictionary];
        //  配网失败    此时的deviceInfo得到信息为空，防止字典空值崩溃，故设置为NSNull
        NSDictionary *dict = @{@"isSuccess": @(NO), @"deviceInfo": [NSNull null], @"errorCode": errorInfoString };
        self.eventSink(@[@"onProvisionedResult", dict]);
        }
    }
}


@end
