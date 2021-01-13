package com.fenda.iot.third.framework

import android.app.Activity
import android.os.Process
import androidx.annotation.CallSuper
import com.alibaba.sdk.android.openaccount.ConfigManager
import com.aliyun.alink.linksdk.alcs.coap.AlcsCoAP
import com.aliyun.alink.linksdk.tools.ThreadTools
import com.aliyun.iot.aep.sdk.framework.AApplication
import com.fenda.iot.third.utils.SDKInitHelper
import io.flutter.FlutterInjector

/**
 * Created by Cat-x on 2020/10/19.
 * For android
 */
open class IotApplication : AApplication() {

    @CallSuper
    override fun onCreate() {
        super.onCreate()
        initAliSDK(this)
        FlutterInjector.instance().flutterLoader().startInitialization(this)
    }

    private var mCurrentActivity: Activity? = null

    fun getCurrentActivity(): Activity? {
        return mCurrentActivity
    }

    fun setCurrentActivity(mCurrentActivity: Activity?) {
        this.mCurrentActivity = mCurrentActivity
    }


    companion object {
        fun initAliSDK(application: AApplication) {
            with(application) {
                // 其他 SDK, 仅在 主进程上初始化
                val packageName = this.packageName
                if (packageName != ThreadTools.getProcessName(this, Process.myPid())) {
                    return
                }

                ConfigManager.getInstance().bundleName =/* "com.aliyun.iot.demo"*/this.packageName
                SDKInitHelper.init(this)
            }
            AlcsCoAP.setLogLevelEx(4/*com.aliyun.alink.linksdk.tools.ALog.LEVEL_ERROR*/);
        }
    }

}