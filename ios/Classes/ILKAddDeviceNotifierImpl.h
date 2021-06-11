//
//  ILKAddDeviceNotifierImpl.h
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/4/22.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <IMLCandDeviceModel+DeviceInfo.h>


@interface ILKAddDeviceNotifierImpl : NSObject <ILKAddDeviceNotifier>
@property(copy, nonatomic) FlutterEventSink eventSink;
@property(nonatomic, strong) FlutterMethodChannel *methodChannel;

//- (id)initWithSink:(FlutterEventSink)sink;   //带参数的构造函数
- (void)setSink:(FlutterEventSink)sink channel:(FlutterMethodChannel*)channel;     //设置方法传参，不需要再进行初始化

+ (instancetype)sharedStartAddDevice;     //  创建单例模式 sharedStartAddDevice

- (void)add;       // 添加开始配网入口方法

@end

