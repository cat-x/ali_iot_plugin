import Flutter
import UIKit
import CoreLocation

@available(macCatalyst 13.0, *)
public class SwiftAliIotPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    static var DEBUG: Bool = false
    static let TOPIC_PATH: String = "/thing/topo/add/status"
    var startDiscoveryEventSink: FlutterEventSink? = nil
    var startAddDeviceEventSink: FlutterEventSink? = nil
    var gatewayPermitEventSink: FlutterEventSink? = nil
    var subDevicePanelEventEventSink: FlutterEventSink? = nil

    var devicePanelApi: DevicePanelApi? = nil
    var methodChannel:FlutterMethodChannel? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ali_iot_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftAliIotPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "ali_iot_plugin_event", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        eventChannel.setStreamHandler(instance)
        let methodChannel = FlutterMethodChannel(name: "ali_iot_plugin_method", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        methodChannel.setMethodCallHandler(instance.handle(_:result:))
        instance.methodChannel = methodChannel
        let basicMessageChannel = FlutterBasicMessageChannel(name: "ali_iot_plugin_message", binaryMessenger: registrar.messenger(), codec: FlutterJSONMessageCodec.sharedInstance())
        basicMessageChannel.setMessageHandler { (message: Any, reply: FlutterReply) in

        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "setDebug":
            guard let options = call.arguments as? [String: Any], let debug = options["debug"] as? Bool else {
                result(FlutterError(code: "-1", message: "setDebug Error: debug is null", details: call.arguments.debugDescription))
                return
            }
            SwiftAliIotPlugin.DEBUG = debug
            ExtensionUtils.setDebug(debug)
            result(true)
        case "getPlatformVersion": result("iOS \(UIDevice.current.systemVersion)")
        case "requestApi":
            guard let data = call.arguments as? [String: Any] else {
                result(FlutterError(code: "errArgs", message: "requestApi Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            log("requestApi data-> \(data)")
            do {
                try ApiTools.request(data, onResponse: { data in

                    let json = SwiftAliIotPlugin.resultSetToJson(results: data)
                    self.log("onMethodCall requestApi data-> \(json)")
                    DispatchQueue.main.async {
                        result(json)
                    }


                }, onFailure: { error in
                    if let exception: NSError = (error as NSError?) {
                        self.log("onMethodCall requestApi exception-> \(exception)")
                        ///Error Domain=ServerErrorDomain Code=403 \"请求被禁止\" UserInfo={message=no access device auth, NSLocalizedDescription=请求被禁止}"
                        var message = "";
                        message += (exception.userInfo["NSLocalizedDescription"] as? String ?? "");
                        message += "\n";
                        message += (exception.userInfo["message"] as? String ?? "");
                        result(FlutterError(code: "domain:\(exception.domain), code:\(exception.code)", message: message,
                                details: nil))
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
                if let devices = anies as? [NSDictionary], self.startDiscoveryEventSink != nil {
                    devices.forEach { dictionary in
                        if let dataString = self.dicValueString(["discoveryType": ["type:": dictionary["linkType"], "description": ""], "deviceList": [dictionary]]) {
                            self.startDiscoveryEventSink?(["data": dataString])
                        }
                    }
                }
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
        case "startAddDevice":
            guard let data = call.arguments as? [String: Any] else {
                result(FlutterError(code: "errArgs", message: "startAddDevice Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            log("startAddDevice data-> \(data)")

            let deviceModel: IMLCandDeviceModel = IMLCandDeviceModel()

            let productKey: String? = data["productKey"] as? String;
            if (!(productKey?.isEmpty ?? true)) {
                deviceModel.productKey = productKey
            }
            let productId: String? = data["productId"] as? String;
            if (!(productId?.isEmpty ?? true)) {
                deviceModel.productId = productId
            }

            let id: String? = data["id"] as? String;
            if (!(productId?.isEmpty ?? true)) {
                deviceModel.iotId = id
            }

            let linkType: String? = data["linkType"] as? String;
            if (!(linkType?.isEmpty ?? true)) {
                // 设备热点配网：ForceAliLinkTypeSoftAP
                // 蓝牙辅助配网：ForceAliLinkTypeBLE
                // 二维码配网：ForceAliLinkTypeQR
                // 手机热点配网：ForceAliLinkTypePhoneAP
                // 一键配网：ForceAliLinkTypeBroadcast
                // 零配：ForceAliLinkTypeZeroAP
                var type = ForceAliLinkType.none;
                switch linkType {
                case "ForceAliLinkTypeBroadcast":
                    type = ForceAliLinkType.init(rawValue: 1)!
                    ///< 手机热点配网方案，在一般配网方案失败后，可切换到手机热点方案
                case "ForceAliLinkTypePhoneAP":
                    type = ForceAliLinkType.init(rawValue: 2)!
                    ///< 设备热点配网方案
                case "ForceAliLinkTypeSoftAP":
                    type = ForceAliLinkType.init(rawValue: 3)!

                    ///< 蓝牙辅助配网方案，在一般配网方案失败后，可切换此方案
                case "ForceAliLinkTypeBLE":
                    type = ForceAliLinkType.init(rawValue: 5)!
                    ///< 二维码配网方案
                case "ForceAliLinkTypeQR":
                    type = ForceAliLinkType.init(rawValue: 6)!
                    ///< 零配批量配网方案
                case "ForceAliLinkTypeZeroAP":
                    type = ForceAliLinkType.init(rawValue: 7)!
                default:
                    // 由native SDK自行决定在广播配网，热点配网，路由器配网，路由器配网中选择最优的配网方案；
                    type = ForceAliLinkType.none;
                }
                deviceModel.linkType = type
            }

            let protocolVersion: String? = data["protocolVersion"] as? String;
            if (!(protocolVersion?.isEmpty ?? true)) {
                deviceModel.protocolVersion = protocolVersion
            }

            if let sink = startAddDeviceEventSink {
                                        
                let tAddDeviceImpl = ILKAddDeviceNotifierImpl.sharedStartAddDevice();
                tAddDeviceImpl?.setSink(sink, channel: methodChannel)
                DispatchNetAPI.startAddDevice(deviceModel, linkType ?? "", tAddDeviceImpl as! ILKAddDeviceNotifier)

                result(true)
                return
            }
            result(false)
        case "stopAddDevice":
            DispatchNetAPI.stopAddDevice()
            result(true)
        case "openSystemWiFi":
            DispatchNetAPI.openSystemWiFi()
            result(true)
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
        case "startAddDevice": startAddDeviceEventSink = events
        case "gatewayPermit":
            gatewayPermitEventSink = events
            SubDeviceApi.registerListener(SwiftAliIotPlugin.TOPIC_PATH, events) { error in
                if (error != nil) {
                    self.log("EventChannel onListen gatewayPermit Error: \(error?.localizedDescription ?? "nil")")
                }
            }
        case "subDevicePanelEvent":
            subDevicePanelEventEventSink = events
            devicePanelApi?.subAllEvents(events)
        default:
            log("EventChannel onListen", "arguments: \(arguments ?? "nil") ,events: \(events)")
        }

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let type = arguments as? String else {
            return FlutterError(code: "-1", message: "onListen Error: arguments is null", details: nil)
        }
        switch (type) {
        case "startDiscovery": startDiscoveryEventSink = nil
        case "startAddDevice": startAddDeviceEventSink = nil
        case "gatewayPermit":
            SubDeviceApi.unRegisterListener(SwiftAliIotPlugin.TOPIC_PATH) { error in
                if (error != nil) {
                    self.log("EventChannel onCancel gatewayPermit Error: \(error?.localizedDescription ?? "nil")")
                }
            }
            gatewayPermitEventSink = nil
        case "subDevicePanelEvent":
            subDevicePanelEventEventSink = nil
        default:
            log("EventChannel onCancel", "arguments: \(arguments ?? "nil")")
        }
        return nil
    }

    func log(_ message: String...) {
        //AliIotPlugin
        print("AliIotPlugin", message)
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


    // Cat: 字典转字符串
    func dicValueString(_ dic: [String: Any]) -> String? {
        let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        return str
    }

    // Cat: 字符串转字典
    func stringValueDic(_ str: String) -> [String: Any]? {
        let data = str.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!,
                options: .mutableContainers) as? [String: Any] {
            return dict
        }

        return nil
    }


}
