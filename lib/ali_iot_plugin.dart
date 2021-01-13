import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';

class AliIotPlugin {
  static const EventChannel _eventChannel = const EventChannel('ali_iot_plugin_event', JSONMethodCodec());

  static const MethodChannel _methodChannel = const MethodChannel('ali_iot_plugin_method', JSONMethodCodec());

  static const BasicMessageChannel _basicMessageChannel = const BasicMessageChannel('ali_iot_plugin_message', JSONMessageCodec());

  static EventChannel get eventChannel => _eventChannel;

  static MethodChannel get methodChannel => _methodChannel;

  static BasicMessageChannel get basicMessageChannel => _basicMessageChannel;
}

class CommonAPI {
  static Future<String> get platformVersion async {
    final String version = await AliIotPlugin.methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  static dynamic ezRequestApi(
    String path,
    String apiVersion, {
    String scheme,
    String host,
    String authType,
    String mockType,
    Map<String, Object> params,
    Map<String, Object> addParam,
    Function onError,
  }) async {
    try {
      return await requestApi(path, apiVersion,
          scheme: scheme, host: host, authType: authType, mockType: mockType, params: params, addParam: addParam);
    } catch (e) {
      print(e);
      onError(e);
    }
  }

  static Future<dynamic> requestApi(
    String path,
    String apiVersion, {
    String scheme,
    String host,
    String authType,
    String mockType,
    Map<String, Object> params,
    Map<String, Object> addParam,
  }) {
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

  static Future<bool> get isLogin {
    return AliIotPlugin.methodChannel.invokeMethod('isLogin', {});
  }

  static Future<bool> authCodeLogin(String authCode) {
    return AliIotPlugin.methodChannel.invokeMethod('authCodeLogin', {
      "authCode": authCode,
    });
  }

  static Future<bool> login() {
    return AliIotPlugin.methodChannel.invokeMethod('login', {});
  }

  static Future<bool> logout() {
    return AliIotPlugin.methodChannel.invokeMethod('logout');
  }
}

class DispatchNetAPI {
  static StreamSubscription _startDiscoverySubscription;
  static StreamSubscription _gatewayPermitSubscription;

  static startDiscovery(callback(Map discoveryType, List deviceList)) async {
    _startDiscoverySubscription = AliIotPlugin.eventChannel.receiveBroadcastStream("startDiscovery").listen((event) {
      if (event != null) {
        print("startDiscovery event: " + event.toString());
        if (event is Map<String, dynamic>) {
          var data = jsonDecode(event["data"]);
          callback(data["discoveryType"], data["deviceList"]);
        }
      }
    });
    AliIotPlugin.methodChannel.invokeMethod('startDiscovery');
  }

  static stopDiscovery() async {
    _startDiscoverySubscription?.cancel();
    _startDiscoverySubscription = null;
    AliIotPlugin.methodChannel.invokeMethod('stopDiscovery');
  }

  static listenGatewayPermit(callback(Map data)) async {
    _gatewayPermitSubscription = AliIotPlugin.eventChannel.receiveBroadcastStream("gatewayPermit").listen((event) {
      if (event != null) {
        print("listenGatewayPermit event: " + event.toString());
        var data = jsonDecode(event);
        callback(data);
      }
    });
    // AliIotPlugin.methodChannel.invokeMethod('listenGatewayPermit');
  }

  static stopListenGatewayPermit() async {
    _gatewayPermitSubscription?.cancel();
    _gatewayPermitSubscription = null;
    // AliIotPlugin.methodChannel.invokeMethod('stopListenGatewayPermit');
  }

  static dispatchNetBy() async {
    AliIotPlugin.methodChannel.invokeMethod('dispatchNetBy');
  }

  static getDeviceToken() async {
    AliIotPlugin.methodChannel.invokeMethod('getDeviceToken');
  }

  static bindByToken() async {
    AliIotPlugin.methodChannel.invokeMethod('bindByToken', {});
  }
}

class DevicePanelAPI {
  static StreamSubscription _devicePanelEventSubscription;

  static Future<bool> startDevicePanel(String iotId) {
    return AliIotPlugin.methodChannel.invokeMethod('startDevicePanel', {
      "iotId": iotId,
    });
  }

  static Future<bool> stopDevicePanel() async {
    return AliIotPlugin.methodChannel.invokeMethod('stopDevicePanel');
  }

  static Future<String> getDevicePanelProperties() {
    return AliIotPlugin.methodChannel.invokeMethod('getDevicePanelProperties');
  }

  static Future<String> setDevicePanelProperties(Map params) {
    return AliIotPlugin.methodChannel.invokeMethod('setDevicePanelProperties', {
      "params": jsonEncode(params),
    });
  }

  static Future<String> invokeDevicePanelService(String params) {
    return AliIotPlugin.methodChannel.invokeMethod('invokeDevicePanelService', {
      "params": params,
    });
  }

  static Future<String> getDevicePanelStatus() {
    return AliIotPlugin.methodChannel.invokeMethod('getDevicePanelStatus');
  }

  static listenDevicePanelEvent(callback(Map data)) async {
    _devicePanelEventSubscription = AliIotPlugin.eventChannel.receiveBroadcastStream("subDevicePanelEvent").listen((event) {
      if (event != null) {
        print("listenDevicePanelEvent event: " + event.toString());
        var data = jsonDecode(event);
        callback(data);
      }
    });
  }

  static stopListenDevicePanelEvent() async {
    _devicePanelEventSubscription?.cancel();
    _devicePanelEventSubscription = null;
  }
}
