//
// Created by Cat-x on 1/12/21.
//

import Foundation

class SubDeviceApi {
    class func registerListener(_ topic: String, _ eventSink: @escaping FlutterEventSink, completionHandler: ((Error?) -> Void)!) {
        SubDeviceApiImpl.subscribe(topic, completionHandler: completionHandler, eventSink: eventSink)
    }

    class func unRegisterListener(_ topic: String, completionHandler: ((Error?) -> Void)!) {
        SubDeviceApiImpl.unsubscribe(topic, completionHandler: completionHandler)
    }
}
