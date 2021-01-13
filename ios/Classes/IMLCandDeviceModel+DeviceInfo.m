//
//  IMLCandDeviceModel+DeviceInfo.m
//  ali_iot_plugin
//
//  Created by Cat-x on 1/12/21.
//


#import "IMLCandDeviceModel+DeviceInfo.h"

@implementation IMLCandDeviceModel (DeviceInfo)

- (NSDictionary *)deviceInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];

    if (self.productKey) {
        info[@"productKey"] = self.productKey;
    }

    if (self.deviceName) {
        info[@"deviceName"] = self.deviceName;
    }

    if (self.regProductKey) {
        info[@"regProductKey"] = self.regProductKey;
    }

    if (self.regDeviceName) {
        info[@"regDeviceName"] = self.regDeviceName;
    }

    if (self.addDeviceFrom) {
        info[@"addDeviceFrom"] = self.addDeviceFrom;
    }

    if (self.token) {
        info[@"token"] = self.token;
    }

    if (self.devType) {
        info[@"devType"] = self.devType;
    }

    info[@"linkType"] = @(self.linkType);

    return info;
}

@end