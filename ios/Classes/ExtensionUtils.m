//
//  ExtensionUtils.m
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/4/22.
//

#import "ExtensionUtils.h"
#import <MJExtension/MJExtension.h>
#import <IMSLog/IMSLog.h>
//#import <NSObject+MJKeyValue.h>
//#import <NSObject+MJCoding.h

@implementation ExtensionUtils

+ (NSMutableDictionary *)ob2dict:(NSObject *)object {
    return [object mj_keyValues];
}

+ (void)setDebug:(Boolean)isDebug {
    if (isDebug) {
        //统一设置所有模块的日志 tag 输出级别
        [IMSLog setAllTagsLevel:IMSLogLevelAll];
    } else {
        [IMSLog setAllTagsLevel:IMSLogLevelInfo];
    }


//可选：设置是否开启日志的控制台输出，建议在release版本中不要开启。
    [IMSLog showInConsole:isDebug];
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //    NSRange range = {0,jsonString.length};
    //    //去掉字符串中的空格
    //    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0, mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}

@end
