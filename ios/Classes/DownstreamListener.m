//
//  DownstreamListener.m
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/5/25.
//


#import <AlinkAppExpress/LKAppExpress.h>
#import "DownstreamListener.h"
#import "ExtensionUtils.h"


@interface DownstreamListener () <LKAppExpDownListener>
@end

@implementation DownstreamListener
- (id)initWithSink:(FlutterEventSink)sink topic:(NSString *)topic {
    if (self = [super init]) {
        _eventSink = sink;
        _topic = topic;
    }
    return self;
}

- (void)onDownstream:(NSString *_Nonnull)topic data:(id _Nullable)data {
    NSLog(@"onDownstream topic : %@", topic);
    NSLog(@"onDownstream data : %@", data);
    NSDictionary *replyDict = nil;
    if ([data isKindOfClass:[NSString class]]) {
        NSData *replyData = [data dataUsingEncoding:NSUTF8StringEncoding];
        replyDict = [NSJSONSerialization JSONObjectWithData:replyData options:NSJSONReadingMutableLeaves error:nil];

    } else if ([data isKindOfClass:[NSDictionary class]]) {
        replyDict = data;
    }
    if (replyDict != nil) {
        self.eventSink([ExtensionUtils convertToJsonData:replyDict]);
    }
}

- (BOOL)shouldHandle:(NSString *_Nonnull)topic {
    if ([topic isEqualToString:self.topic]) {
        return YES;//返回YES，说明对此topic感兴趣,SDK会调用[listener onDownstream:data:]
    }
    return NO;
}

@end
