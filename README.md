# ali_iot_plugin

阿里飞燕平台 （生活物联网平台） Flutter plugin.

> 基于阿里生活物联网平台的Android和iOS架包实现的Flutter插件，方便开发自有APP

## Get started

### Add dependency

```yaml
dependencies:
  ali_iot_plugin: ^0.0.x #请使用pub上的最新版本
```

1. Android
* AppApplication 需要继承 IotApplication()  
* 按照生活物联网平台  [集成安全图片](https://help.aliyun.com/document_detail/143857.html?spm=a2c4g.11186623.2.6.2e59150biJwvkA)  
* 可能需要集成    implementation 'com.facebook.android:facebook-android-sdk:8.0.0'  

2. iOS
* 按照生活物联网平台  [集成安全图片](https://help.aliyun.com/document_detail/143857.html?spm=a2c4g.11186623.2.6.2e59150biJwvkA)  
* 添加Pod源
```ruby
# github 官方 pod 源
source 'https://github.com/CocoaPods/Specs.git' 

# 阿里云 pod 源
source 'https://github.com/aliyun/aliyun-specs.git' 
```
* 需要在AppDelegate的application方法中调用ALiAppDelegate.application(application,didFinishLaunchingWithOptions:launchOptions)  
```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    ALiAppDelegate.application(application,didFinishLaunchingWithOptions:launchOptions)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```


### What can do
1. 登录
2. 第三方登录
3. 退出登录
4. 请求API通道接口
5. 配网设备
6. 查看设备属性
7. 设置设备属性


### Super simple to use

```dart
import 'package:ali_iot_plugin/index.dart';

CommonAPI.logout();
CommonAPI.authCodeLogin(authCode);

DispatchNetAPI.startDiscovery(callback);
DispatchNetAPI.stopDiscovery();
DispatchNetAPI.listenGatewayPermit(callback);
DispatchNetAPI.stopListenGatewayPermit();

DevicePanelAPI.getDevicePanelProperties()
DevicePanelAPI.setDevicePanelProperties({"items": params, "iotId": iotId})
DevicePanelAPI.getDevicePanelStatus()

static Future<dynamic> requestApi(
    String path,
    String apiVersion, {
    String scheme,
    String host,
    String authType,
    String mockType,
    Map<String, Object> params,
    Map<String, Object> addParam,
    bool handleTimeOut = true,
  }) async {
      return await CommonAPI.requestApi(path, apiVersion,
              scheme: scheme, host: host, authType: authType, mockType: mockType, params: params, addParam: addParam)
          .then((value) => value, onError: (error) {
        print(error);
        if (handleTimeOut && error is PlatformException) {
          if (error.code.contains("timeout") || error.message.contains("timeout") || error.message.contains("Unable to resolve host")) {
            //请求超时
          }
        }
        throw e;
      });
   
  }
```

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
阿里飞燕 生活物联网平台 includes platform-specific implementation code for Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Todo List
目前iOS平台只实现了部分功能，后续待完善

