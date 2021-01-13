//
// Created by Cat-x on 1/12/21.
//

#import "DispatchNetAPIImpI.h"
#import "IMSLifeLog.h"


#import <IMSRouter/IMSRouterService.h>
#import <IMLDeviceCenter/IMLDeviceCenter.h>
#import <IMSRouter/UIViewController+IMSRouter.h>

@implementation DispatchNetAPIImpI

+ (void)startDiscovery:(void (^)(NSArray *devices, NSError *err))didFoundBlock {
    IMSLifeLogVerbose(@"开始发现本地设备...");
    [[IMLLocalDeviceMgr sharedMgr] startDiscovery:^(NSArray *devices, NSError *err) {
        if (devices && [devices count] > 0) {
            IMSLifeLogVerbose(@"发现本地设备: %@", devices);
        } else if (err) {
            IMSLifeLogError(@"本地发现设备出错: %@", err);
        }
        didFoundBlock(devices, err);
    }];
}

+ (void)stopDiscovery {
    [[IMLLocalDeviceMgr sharedMgr] stopDiscovery];
}


@end