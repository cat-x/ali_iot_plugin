//
// Created by Cat-x on 1/7/21.
//

#import <Foundation/Foundation.h>

@class IMSResponse;


@interface AliRequestImpl : NSObject
#pragma mark -

+ (void)queryProductInfoWithKey:(NSString *)key
              completionHandler:(void (^)(NSDictionary *info, NSError *error))completionHandler;

+ (void)requestWithPath:(NSString *)path
                version:(NSString *)version
                 params:(NSDictionary *)params
                 scheme:(NSString *)scheme
               authType:(NSString *_Nullable)authType
      completionHandler:(void (^)(NSError *error, IMSResponse *data))completionHandler;

+ (void)handleLogout;
@end
