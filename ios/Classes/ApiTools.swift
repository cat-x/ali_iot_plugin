//
// Created by Cat-x on 1/7/21.
//

import Foundation

class ApiTools: NSObject {

    class func request(_ params: [String: Any?], onResponse: @escaping (_ data: IMSResponse?) -> (), onFailure: @escaping (_ error: Error?) -> ()) {
        var path: String = ""
        var version: String = ""
        var scheme: String = ""
        var authType: String? = ""
        var allParams: [AnyHashable: Any]? = nil
        for param in params {
            if (param.value != nil) {
                switch param.key {
                case "path": path = param.value as! String
                case "apiVersion": version = param.value as! String
                case "scheme": scheme = ((param.value as? String == "HTTP") ? "http://" : "https://")
                        //                case  "host" : host = param.value as String
                case "authType": authType = param.value as? String
                        //                case   "mockType" : mockType = param.value as String
                case "params": allParams = (param.value as? [AnyHashable: Any])
                case "addParam":
                    if (param.value is [AnyHashable: Any]) {
                        if (allParams == nil) {
                            allParams = [AnyHashable: Any]()
                        }
                        for (key, value) in (param.value as! [AnyHashable: Any]) {
                            allParams?[key] = value
                        }
                    }
                default:
                    break
                }
            }
        }
        requestImpl(path: path, version: version, params: allParams, scheme: scheme, authType: authType) { error, data in
            if (error == nil) {
                onResponse(data)
            } else {
                onFailure(error)
            }
        }


    }

    private class func requestImpl(path: String, version: String, params parameters: [AnyHashable: Any]?,
                                   scheme: String, authType: String?,
                                   completionHandler: @escaping (_ error: Error?, _ data: IMSResponse?) -> Void) {
        AliRequestImpl.request(withPath: path, version: version, params: parameters ?? [AnyHashable: Any](), scheme: scheme, authType: authType, completionHandler: completionHandler)
        //        let builder = IMSIoTRequestBuilder.init(path: path, apiVersion: version, params: parameters ?? [AnyHashable: Any]());
//        builder.setScheme("https://")
//        let request = builder.setAuthenticationType(IMSAuthenticationTypeIoT).build()
//
//        IMSLifeLogVerbose("Request: %@", request)
//

    }
}
