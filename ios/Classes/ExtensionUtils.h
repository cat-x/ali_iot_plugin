//
//  ExtensionUtils.h
//  ali_iot_plugin
//
//  Created by Vince Cat on 2021/4/22.
//

#import <Foundation/Foundation.h>


@interface ExtensionUtils : NSObject
+ (NSMutableDictionary *)ob2dict:(NSObject *)object;

+ (void)setDebug:(Boolean)isDebug;

+ (NSString *)convertToJsonData:(NSDictionary *)dict;
@end
