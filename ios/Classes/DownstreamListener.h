//
//  DownstreamListener.h
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface DownstreamListener : NSObject
@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic) NSString *topic;

- (id)initWithSink:(FlutterEventSink)sink topic:(NSString *)topic;   //带参数的构造函数
@end
