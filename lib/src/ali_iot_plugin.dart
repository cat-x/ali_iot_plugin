import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

const String TAG = "AliIotPlugin";

class AliIotPlugin {
  static bool debug = true;

  static const EventChannel _eventChannel = const EventChannel('ali_iot_plugin_event', JSONMethodCodec());

  static const MethodChannel _methodChannel = const MethodChannel('ali_iot_plugin_method', JSONMethodCodec());

  static const BasicMessageChannel _basicMessageChannel = const BasicMessageChannel('ali_iot_plugin_message', JSONMessageCodec());

  static EventChannel get eventChannel => _eventChannel;

  static MethodChannel get methodChannel => _methodChannel;

  static BasicMessageChannel get basicMessageChannel => _basicMessageChannel;
}

class CommonAPI {
  CommonAPI._();

  static set debug(bool debug) {
    try {
      print("$TAG : setDebug =>$debug");
      AliIotPlugin.debug = debug;
      AliIotPlugin.methodChannel.invokeMethod('setDebug', {"debug": debug});
    } catch (e) {
      print(e);
    }
  }

  static Future<String?> get platformVersion async {
    if (AliIotPlugin.debug) {
      print("$TAG : platformVersion");
    }
    final String? version = await AliIotPlugin.methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  // static dynamic ezRequestApi(
  //   String path,
  //   String apiVersion, {
  //   String scheme,
  //   String host,
  //   String authType,
  //   String mockType,
  //   Map<String, Object> params,
  //   Map<String, Object> addParam,
  //   Function onError,
  // }) async {
  //   if (AliIotPlugin.debug) {
  //     print("$TAG : ezRequestApi");
  //   }
  //   try {
  //     return await requestApi(path, apiVersion,
  //         scheme: scheme, host: host, authType: authType, mockType: mockType, params: params, addParam: addParam);
  //   } catch (e) {
  //     print(e);
  //     onError(e);
  //   }
  // }

  static Future<dynamic> requestApi(
    String path,
    String apiVersion, {
    String? scheme,
    String? host,
    String? authType,
    String? mockType,
    Map<String, Object?>? params,
    Map<String, Object?>? addParam,
  }) {
    if (AliIotPlugin.debug) {
      print("$TAG : requestApi");
    }
    var data = AliIotPlugin.methodChannel.invokeMethod('requestApi', {
      "path": path,
      "apiVersion": apiVersion,
      "scheme": scheme,
      "host": host,
      "authType": authType,
      "mockType": mockType,
      "params": params,
      "addParam": addParam
    });
    // print("requestApi -> $data");
    return data;
  }

  static Future<bool?> get isLogin {
    if (AliIotPlugin.debug) {
      print("$TAG : isLogin");
    }
    return AliIotPlugin.methodChannel.invokeMethod('isLogin', {});
  }

  static Future<bool?> authCodeLogin(String authCode) {
    if (AliIotPlugin.debug) {
      print("$TAG : authCodeLogin $authCode");
    }
    return AliIotPlugin.methodChannel.invokeMethod('authCodeLogin', {
      "authCode": authCode,
    });
  }

  static Future<bool?> login() {
    if (AliIotPlugin.debug) {
      print("$TAG : login");
    }
    return AliIotPlugin.methodChannel.invokeMethod('login', {});
  }

  static Future<bool?> logout() {
    if (AliIotPlugin.debug) {
      print("$TAG : logout");
    }
    return AliIotPlugin.methodChannel.invokeMethod('logout');
  }
}

class DispatchNetAPI {
  DispatchNetAPI._();

  static StreamSubscription? _startDiscoverySubscription;
  static StreamSubscription? _gatewayPermitSubscription;
  static StreamSubscription? _dispatchNetSubscription;

  static startDiscovery(callback(Map discoveryType, List deviceList)) async {
    if (AliIotPlugin.debug) {
      print("$TAG : startDiscovery");
    }
    _startDiscoverySubscription = AliIotPlugin.eventChannel.receiveBroadcastStream("startDiscovery").listen((event) {
      if (event != null) {
        print("$TAG : startDiscovery event: " + event.toString());
        if (event is Map<String, dynamic>) {
          var data = jsonDecode(event["data"]);
          callback(data["discoveryType"], data["deviceList"]);
        }
      }
    });
    AliIotPlugin.methodChannel.invokeMethod('startDiscovery');
  }

  static stopDiscovery() async {
    if (AliIotPlugin.debug) {
      print("$TAG : stopDiscovery");
    }
    try {
      if (_startDiscoverySubscription != null) {
        _startDiscoverySubscription?.cancel();
        _startDiscoverySubscription = null;
      }
    } catch (e) {
      print(e);
    }
    AliIotPlugin.methodChannel.invokeMethod('stopDiscovery');
  }

  static listenGatewayPermit(callback(Map data)) async {
    if (AliIotPlugin.debug) {
      print("$TAG : listenGatewayPermit");
    }
    _gatewayPermitSubscription = AliIotPlugin.eventChannel.receiveBroadcastStream("gatewayPermit").listen((event) {
      if (event != null) {
        print("$TAG : listenGatewayPermit event: " + event.toString());
        var data = jsonDecode(event);
        callback(data);
      }
    });
    // AliIotPlugin.methodChannel.invokeMethod('listenGatewayPermit');
  }

  static stopListenGatewayPermit() async {
    if (AliIotPlugin.debug) {
      print("$TAG : stopListenGatewayPermit");
    }
    try {
      _gatewayPermitSubscription?.cancel();
    } catch (e) {
      print(e);
    }
    _gatewayPermitSubscription = null;
    // AliIotPlugin.methodChannel.invokeMethod('stopListenGatewayPermit');
  }

  ///
  /// [linkType] 应该为下列值：
  ///
  ///   设备热点配网：ForceAliLinkTypeSoftAP <br>
  ///    蓝牙辅助配网：ForceAliLinkTypeBLE <br>
  ///    二维码配网：ForceAliLinkTypeQR <br>
  ///    手机热点配网：ForceAliLinkTypePhoneAP <br>
  ///    一键配网：ForceAliLinkTypeBroadcast <br>
  ///    零配：ForceAliLinkTypeZeroAP <br>
  ///
  static Future<bool?> startAddDevice(
    String linkType,
    callback(String stage, dynamic stageData), {
    String? productKey,
    String? productId,
    String? id,
    String? protocolVersion,
    ValueGetter<Future<Map<String, String>>>? getWifi,
  }) async {
    assert(linkType == "ForceAliLinkTypeBroadcast" && getWifi != null, "一键配网 需要提供wifi和密码");
    assert(linkType == "ForceAliLinkTypeBroadcast" && productKey != null, "一键配网 需要提供码productKey");
    Map data = {"productKey": productKey, "productId": productId, "id": id, "linkType": linkType, "protocolVersion": protocolVersion};
    if (AliIotPlugin.debug) {
      print("$TAG : startAddDevice $data");
    }
    _dispatchNetSubscription = AliIotPlugin.eventChannel.receiveBroadcastStream("startAddDevice").listen((event) {
      if (event != null) {
        print("$TAG : startAddDevice event: " + event.toString());
        if (event is List) {
          final stage = event.first;
          var stageData;
          switch (stage) {
            case "onProvisionPrepare":
              stageData = event.last; //int
              break;
            case "onProvisioning":
              stageData = ""; //String
              break;
            case "onProvisionStatus":
              stageData = {"code": event[1], "message": event[2], "extraParams": event[3]}; //Map
              break;
            case "onProvisionedResult":
              var temp = event.last as Map; //{"isSuccess":bool,"deviceInfo":String."errorCode":String}
              stageData = {
                "isSuccess": temp["isSuccess"],
                "deviceInfo": jsonDecode(temp["deviceInfo"] ?? "{}"),
                "errorCode": jsonDecode(temp["errorCode"] ?? "{}"),
              };
              break;
          }
          callback(stage, stageData);
        }
      }
    });
    AliIotPlugin._methodChannel.setMethodCallHandler((MethodCall methodCall) {
      print("$TAG : _methodChannelHandler $methodCall");
      switch (methodCall.method) {
        case 'toggleProvision':
          assert(getWifi != null, "toggleProvision is null, 一键配网 需要提供wifi和密码");
          return getWifi!();
        default:
          return Future<dynamic>.value();
      }
    });
    return AliIotPlugin.methodChannel.invokeMethod('startAddDevice', data);
  }

  static stopAddDevice() async {
    if (AliIotPlugin.debug) {
      print("$TAG : stopAddDevice");
    }
    try {
      _dispatchNetSubscription?.cancel();
    } catch (e) {
      print(e);
    }
    _dispatchNetSubscription = null;
    AliIotPlugin.methodChannel.invokeMethod('stopAddDevice');
  }

  static openSystemWiFi() async {
    if (AliIotPlugin.debug) {
      print("$TAG : openSystemWiFi");
    }
    AliIotPlugin.methodChannel.invokeMethod('openSystemWiFi');
  }

  static Future<Map?> getDeviceToken() async {
    if (AliIotPlugin.debug) {
      print("$TAG : getDeviceToken");
    }
    var result = await AliIotPlugin.methodChannel.invokeMethod('getDeviceToken');
    if (result is Map<String, dynamic>) {
      final data = jsonDecode(result["data"]);
      return data;
    }
    return null;
  }

  static Future<dynamic> bindByToken(String productKey, String deviceName, String token) async {
    if (AliIotPlugin.debug) {
      print("$TAG : bindByToken");
    }
    return AliIotPlugin.methodChannel.invokeMethod('bindByToken', {"productKey": productKey, "deviceName": deviceName, "token": token});
  }
}

class DevicePanelAPI {
  DevicePanelAPI._();

  static StreamSubscription? _devicePanelEventSubscription;

  static Future<bool?> startDevicePanel(String iotId) {
    if (AliIotPlugin.debug) {
      print("$TAG : startDevicePanel $iotId");
    }
    return AliIotPlugin.methodChannel.invokeMethod('startDevicePanel', {
      "iotId": iotId,
    });
  }

  static Future<bool?> stopDevicePanel() async {
    if (AliIotPlugin.debug) {
      print("$TAG : stopDevicePanel");
    }
    return AliIotPlugin.methodChannel.invokeMethod('stopDevicePanel');
  }

  static Future<String?> getDevicePanelProperties() {
    if (AliIotPlugin.debug) {
      print("$TAG : getDevicePanelProperties");
    }
    return AliIotPlugin.methodChannel.invokeMethod('getDevicePanelProperties');
  }

  static Future<String?> setDevicePanelProperties(Map params) {
    if (AliIotPlugin.debug) {
      print("$TAG : setDevicePanelProperties $params");
    }
    return AliIotPlugin.methodChannel.invokeMethod('setDevicePanelProperties', {
      "params": jsonEncode(params),
    });
  }

  static Future<String?> invokeDevicePanelService(String params) {
    if (AliIotPlugin.debug) {
      print("$TAG : invokeDevicePanelService $params");
    }
    return AliIotPlugin.methodChannel.invokeMethod('invokeDevicePanelService', {
      "params": params,
    });
  }

  static Future<String?> getDevicePanelStatus() {
    if (AliIotPlugin.debug) {
      print("$TAG : getDevicePanelStatus");
    }
    return AliIotPlugin.methodChannel.invokeMethod('getDevicePanelStatus');
  }

  static listenDevicePanelEvent(callback(Map data)) async {
    if (AliIotPlugin.debug) {
      print("$TAG : listenDevicePanelEvent");
    }
    _devicePanelEventSubscription = AliIotPlugin.eventChannel.receiveBroadcastStream("subDevicePanelEvent").listen((event) {
      if (event != null) {
        print("$TAG : listenDevicePanelEvent event: " + event.toString());
        var data = jsonDecode(event);
        callback(data);
      }
    });
  }

  static stopListenDevicePanelEvent() async {
    if (AliIotPlugin.debug) {
      print("$TAG : stopListenDevicePanelEvent");
    }
    try {
      _devicePanelEventSubscription?.cancel();
    } catch (e) {
      print(e);
    }
    _devicePanelEventSubscription = null;
  }
}
