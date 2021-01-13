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
}
