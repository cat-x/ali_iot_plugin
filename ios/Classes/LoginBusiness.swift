//
// Created by Cat-x on 1/8/21.
//

import Foundation

class LoginBusiness {
    static func isLogin() -> Bool {
        return IMSAccountService.shared().isLogin()
    }

    static func logout() {
        AliRequestImpl.handleLogout()
    }

    static func login(_ authCode: String,completionHandler: (([AnyHashable : Any]?, Error?) -> Void)!) {
        let iMSAccountThird = IMSAccountThird()
        iMSAccountThird.fLoginCallDelegate = completionHandler;
        iMSAccountThird.loginGetAuthCode(authCode, completionHandler: completionHandler)

    }

}
