//
// Created by Cat-x on 1/12/21.
//

#import <Foundation/Foundation.h>


@interface DispatchNetAPIImpI : NSObject

+ (void)startDiscovery:(void (^)(NSArray *devices, NSError *err))didFoundBlock;

/**
 停止发现设备流程
 */
+ (void)stopDiscovery;

@end