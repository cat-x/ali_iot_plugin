//
// Created by Cat-x on 1/12/21.
//

#import "DispatchNetAPIImpI.h"
#import "IMSLifeLog.h"
#import "ILKAddDeviceNotifierImpl.h"

@implementation DispatchNetAPIImpI

+ (void)startDiscovery:(void (^)(NSArray *devices, NSError *err))didFoundBlock {
    IMSLifeLogVerbose(@"开始发现本地设备...");
    [[IMLLocalDeviceMgr sharedMgr] startDiscovery:^(NSArray *devices, NSError *err) {
        if (devices && [devices count] > 0) {
            IMSLifeLogVerbose(@"发现本地设备: %@", devices);
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:devices.count];
            for (IMLCandDeviceModel *device in devices) {
                NSDictionary *dict = device.toJSONDictionary;
                //                NSLog(@"打印字符串：%@",dict);
                [newArray addObject:dict];
            }
            didFoundBlock([newArray copy], err);
            return;
        } else if (err) {
            IMSLifeLogError(@"本地发现设备出错: %@", err);
        }
        didFoundBlock(nil, err);
    }];
}

+ (void)stopDiscovery {
    [[IMLLocalDeviceMgr sharedMgr] stopDiscovery];
}

+ (void)startAddDevice:(IMLCandDeviceModel *)model
              linkType:(NSString *)linkType
              delegate:(id <ILKAddDeviceNotifier>)delegate; {
/**
* 第一步：设置待配网设备信息
*/
//    IMLCandDeviceModel *model = [[IMLCandDeviceModel alloc] init];
//    model.productKey = @"xxx";


    if (linkType != nil && linkType.length > 0) {
        // 设备热点配网：ForceAliLinkTypeSoftAP
        // 蓝牙辅助配网：ForceAliLinkTypeBLE
        // 二维码配网：ForceAliLinkTypeQR
        // 手机热点配网：ForceAliLinkTypePhoneAP
        // 一键配网：ForceAliLinkTypeBroadcast
        // 零配：ForceAliLinkTypeZeroAP

        if ([linkType isEqualToString:@"ForceAliLinkTypeBroadcast"]) {
            ///< 手机热点配网方案，在一般配网方案失败后，可切换到手机热点方案
            model.linkType = ForceAliLinkTypeBroadcast;
        } else if ([linkType isEqualToString:@"ForceAliLinkTypePhoneAP"]) {
            ///< 设备热点配网方案
            model.linkType = ForceAliLinkTypeHotspot;
        } else if ([linkType isEqualToString:@"ForceAliLinkTypeSoftAP"]) {
            ///< 设备热点配网方案
            model.linkType = ForceAliLinkTypeSoftap;
        } else if ([linkType isEqualToString:@"ForceAliLinkTypeBLE"]) {
            ///< 蓝牙辅助配网方案，在一般配网方案失败后，可切换此方案
            model.linkType = ForceAliLinkTypeBLE;
        } else if ([linkType isEqualToString:@"ForceAliLinkTypeQR"]) {
            ///< 二维码配网方案
            model.linkType = ForceAliLinkTypeQR;
        } else if ([linkType isEqualToString:@"ForceAliLinkTypeZeroAP"]) {
            ///< 零配批量配网方案
            model.linkType = ForceAliLinkTypeZeroInBatches;
        } else {
            // 由native SDK自行决定在广播配网，热点配网，路由器配网，路由器配网中选择最优的配网方案；
            model.linkType = ForceAliLinkTypeNone;
        }
    }
    [kLkAddDevBiz setDevice:model];

/**
* 第二步：开始配网
* 设置待配信息，开始配网
*/
    //id<ILKAddDeviceNotifier> a = [[ILKAddDeviceNotifierImpl alloc] init];
//    [kLkAddDevBiz startAddDevice: delegate];
    [[ILKAddDeviceNotifierImpl sharedStartAddDevice] add];   //  调用单例方法，进入配网信息回调流程
}

+ (void)stopAddDevice {
    [kLkAddDevBiz stopAddDevice];
}






@end
