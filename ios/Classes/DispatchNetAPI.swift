//
// Created by Cat-x on 1/12/21.
//

import Foundation

class DispatchNetAPI {
    static func startDiscovery(_ didFoundBlock: (([Any]?, Error?) -> Void)!) {
        DispatchNetAPIImpI.startDiscovery(didFoundBlock)
    }

    static func stopDiscovery() {
        DispatchNetAPIImpI.stopDiscovery()
    }

    class func startAddDevice(_ model: IMLCandDeviceModel, _ linkType: String, _ sink: ILKAddDeviceNotifier) {
//        let dispatchNetAPIImpI = DispatchNetAPIImpI()
//        dispatchNetAPIImpI.addDeviceNotifier = sink
        DispatchNetAPIImpI.startAddDevice(model, linkType: linkType, delegate: sink)
    }

    static func stopAddDevice() {
        DispatchNetAPIImpI.stopAddDevice()
    }

    static func openSystemWiFi() {
        var url = URL(string: "App-Prefs:root=WIFI")
        if #available(iOS 10.0, *){
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.openURL(url!)
            }else{
            print("ios 10 打开wifi界面 error")
         }
        }else{
            url =  URL(string: "prefs:root=WIFI")
            //打开wifi界面
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.openURL(url!)
            }
            else
            {
                print("ios 10 以下 打开wifi界面 error")
            }
            
         }
    }

}
