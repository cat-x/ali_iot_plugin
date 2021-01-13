import Flutter
import UIKit


@available(macCatalyst 13.0, *)
public class SwiftAliIotPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    var startDiscoveryEventSink: FlutterEventSink? = nil
    var dispatchNetByEventSink: FlutterEventSink? = nil
    var gatewayPermitEventSink: FlutterEventSink? = nil
    var subDevicePanelEventEventSink: FlutterEventSink? = nil

    var devicePanelApi: DevicePanelApi? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ali_iot_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftAliIotPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "ali_iot_plugin_event", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        eventChannel.setStreamHandler(instance)
        let methodChannel = FlutterMethodChannel(name: "ali_iot_plugin_method", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        methodChannel.setMethodCallHandler(instance.handle(_:result:))
        let basicMessageChannel = FlutterBasicMessageChannel(name: "ali_iot_plugin_message", binaryMessenger: registrar.messenger(), codec: FlutterJSONMessageCodec.sharedInstance())
        basicMessageChannel.setMessageHandler { (message: Any, reply: FlutterReply) in

        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "getPlatformVersion": result("Android ${android.os.Build.VERSION.RELEASE}")
        case "requestApi":
            guard let data = call.arguments as? [String: Any] else {
                result(FlutterError(code: "errArgs", message: "requestApi Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            log("requestApi data-> \(data)")
            do {
                ApiTools.request(data, onResponse: { data in

                    let json = SwiftAliIotPlugin.resultSetToJson(results: data)
                    self.log("onMethodCall requestApi data-> \(json)")
                    DispatchQueue.main.async {
                        result(json)
                    }


                }, onFailure: { error in
                    if let exception: NSError = (error as NSError?) {
                        self.log("onMethodCall requestApi exception-> \(exception)")
                        result(FlutterError(code: "\(exception.code)", message: (exception.userInfo["message"] as? String) ?? "", details: exception.userInfo))
                    }
                })
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "requestApi", message: error.localizedDescription, details: error))
                }
            }
        case "isLogin":
            result(LoginBusiness.isLogin())
        case "authCodeLogin":
            guard let options = call.arguments as? [String: Any], let authCode = options["authCode"] as? String else {
                result(FlutterError(code: "-1", message: "authCodeLogin Error: authCode is null", details: call.arguments.debugDescription))
                return
            }

            LoginBusiness.login(authCode) { dictionary, error in
                if (error == nil) {
                    result(true)
                } else {
                    if let exception: NSError = (error as NSError?) {
                        self.log("authCodeLogin exception-> \(exception)")
                        result(FlutterError(code: "\(exception.code)", message: (exception.userInfo["message"] as? String) ?? "", details: exception.userInfo))
                    }
                }
            }

//      case  "login" :
//
//          LoginBusiness.login(object : ILoginCallback {
//            override fun onLoginSuccess() {
//              result(true)
//            }
//
//            override fun onLoginFailed(code: Int, message: String) {
//              // LinkToast.makeText(getApplicationContext(), s).show();
//              result.error(code.toString(), message, null)
//            }
//          })
//
        case "logout":
            LoginBusiness.logout()
            result(true)
        case "startDiscovery":
            DispatchNetAPI.startDiscovery { anies, error in
                self.log("onMethodCall startDiscovery", " devices->\(anies) ,error->\(error)")
                if let devices = anies as? [IMLCandDeviceModel], self.startDiscoveryEventSink != nil {
                    self.startDiscoveryEventSink!((["discoveryType": "", "deviceList": ""]))
                }

//              startDiscoveryEventSink?.success(mapOf("discoveryType" to mapOf("type" to discoveryType.type,
//              "description" to discoveryType.description), "deviceList" to deviceList).toJSONObject(true))
            }
            result(nil)
        case "stopDiscovery":
            DispatchNetAPI.stopDiscovery()
            result(nil)
//      case  "startDevicePanel" :
//
//          let iotId = call.arguments?.tranJson()?.getString("iotId")
//          if (iotId != null) {
//            devicePanelApi = DevicePanelApi(context, iotId)
//            result(true)
//          } else {
//            result.error("-1", "iotId is null", null)
//          }
//      case  "getDevicePanelProperties" :
//
//          devicePanelApi?.getProperties(result)
//      case  "setDevicePanelProperties" :
//
//          let params = call.arguments?.tranJson()?.getString("params")
//          if (params != null) {
//            devicePanelApi?.setProperties(params,result)
//          } else {
//            result.error("-1", "params is null", null)
//          }
//      case  "invokeDevicePanelService" :
//
//          let params = call.arguments?.tranJson()?.getString("params")
//          if (params != null) {
//            devicePanelApi?.invokeService(params)
//          } else {
//            result.error("-1", "params is null", null)
//          }
//      case  "getDevicePanelStatus" :
//
//          devicePanelApi?.getEqStatus(result)
//
//      case  "stopDevicePanel" :
//
//          devicePanelApi = null
//          result(true)
//
//      case  "dispatchNetBy" :
//
//          let device = call.argument<DeviceInfo>("deviceInfo")
//          if (device != null) {
//            eventSinkMap["dispatchNetBy"]?.let {
//              DispatchNetAPI.dispatchNetBy(context, device, it)
//            }
//          }
//
//      case  "getDeviceToken" :
//
//          let productKey = call.argument<String>("productKey")
//          let deviceName = call.argument<String>("deviceName")
//          if (productKey != null && deviceName != null) {
//            DispatchNetAPI.getDeviceToken(context, productKey, deviceName)
//          }
//
//      case  "bindByToken" :
//
//          let productKey = call.argument<String>("productKey")
//          let deviceName = call.argument<String>("deviceName")
//          let token = call.argument<String>("token")
//          if (productKey != null && deviceName != null && token != null) {
//            DispatchNetAPI.bindByToken(productKey, deviceName, token)
//          }

        default:
            result(FlutterMethodNotImplemented);
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard let type = arguments as? String else {
            return FlutterError(code: "-1", message: "onListen Error: arguments is null", details: nil)
        }
        switch (type) {
        case "startDiscovery": startDiscoveryEventSink = events
        case "dispatchNetBy": dispatchNetByEventSink = events
        case "gatewayPermit":
            gatewayPermitEventSink = events
            SubDeviceApi.registerListener(events)
        case "subDevicePanelEvent":
            subDevicePanelEventEventSink = events
            devicePanelApi?.subAllEvents(events)
        default:
            log("EventChannel onListen", "arguments: \(arguments) ,events: \(events)")
        }

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let type = arguments as? String else {
            return FlutterError(code: "-1", message: "onListen Error: arguments is null", details: nil)
        }
        switch (type) {
        case "startDiscovery": startDiscoveryEventSink = nil
        case "dispatchNetBy": dispatchNetByEventSink = nil
        case "gatewayPermit":
            gatewayPermitEventSink = nil
        case "subDevicePanelEvent":
            subDevicePanelEventEventSink = nil
        default:
            log("EventChannel onCancel", "arguments: \(arguments)")
        }
        return nil
    }

    func log(_ message: String...) {
        print(message)
    }

    static func resultSetToJson(results: IMSResponse?) -> NSDictionary {
//        var resultArr: Array<Dictionary<String, Any>> = []
        var value = Dictionary<String, Any>()


        value["code"] = results?.code()
        value["id"] = nil
        value["localizedMsg"] = results?.localizedMsg()
        value["message"] = results?.message()
        value["data"] = results?.data()

//        return NSArray(array: resultArr)
        return NSDictionary(dictionary: value)
    }
}
