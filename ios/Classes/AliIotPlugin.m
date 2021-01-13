#import "AliIotPlugin.h"
#if __has_include(<ali_iot_plugin/ali_iot_plugin-Swift.h>)
#import <ali_iot_plugin/ali_iot_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ali_iot_plugin-Swift.h"
#endif

@implementation AliIotPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAliIotPlugin registerWithRegistrar:registrar];
}
@end
