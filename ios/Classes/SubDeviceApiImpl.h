//
//  SubDeviceApiImpl.h
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/5/25.
//
#import <Flutter/Flutter.h>

@interface SubDeviceApiImpl : NSObject
+ (void)subscribe:(NSString *)topic completionHandler:(void (^)(NSError *error))completionHandler eventSink:(FlutterEventSink)eventSink;

+ (void)unsubscribe:(NSString *)topic completionHandler:(void (^)(NSError *error))completionHandler;
@end
