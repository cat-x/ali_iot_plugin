//
// Created by Cat-x on 1/12/21.
//

#import <Foundation/Foundation.h>
#import <IMSRouter/IMSRouterService.h>
#import <IMLDeviceCenter/IMLDeviceCenter.h>
#import <IMSRouter/UIViewController+IMSRouter.h>

@interface DispatchNetAPIImpI : NSObject
@property(strong, nonatomic) id <ILKAddDeviceNotifier> addDeviceNotifier;
+ (void)startDiscovery:(void (^)(NSArray *devices, NSError *err))didFoundBlock;

/**
 停止发现设备流程
 */
+ (void)stopDiscovery;


/**

 */
+ (void)startAddDevice:(IMLCandDeviceModel *)model
              linkType:(NSString *)linkType
              delegate:(id <ILKAddDeviceNotifier>)delegate;

/**
 停止添加设备
 */
+ (void)stopAddDevice;

@end
