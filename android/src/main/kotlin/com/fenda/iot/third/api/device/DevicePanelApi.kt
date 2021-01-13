package com.fenda.iot.third.api.device

import android.content.Context
import android.text.TextUtils
import com.aliyun.alink.linksdk.tmp.device.panel.PanelDevice
import com.aliyun.alink.linksdk.tmp.device.panel.listener.IPanelCallback
import com.aliyun.alink.linksdk.tmp.device.panel.listener.IPanelEventCallback
import com.aliyun.iot.aep.sdk.log.ALog
import com.fenda.iot.third.api.ApiTools
import com.fenda.iot.third.utils.log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Created by Cat-x on 2020/10/22.
 * For android
 */
class DevicePanelApi(val context: Context, val iotId: String, val panelDevice: PanelDevice = PanelDevice(iotId)) {

    val cacheData: MutableMap<String, Any?> = mutableMapOf()

    init {
        initSdk()
    }

    fun initSdk() {
        //        初始化
        panelDevice.init(context, initCallback)
//        TmpSdk.getDeviceManager().discoverDevices(null, false, 5000, object : IDevListener {
//            override fun onSuccess(o: Any, outputParams: OutputParams) {}
//            override fun onFail(o: Any, errorInfo: ErrorInfo) {}
//        })
    }


    /**
     * 获取状态
     */
    fun getEqStatus(result: MethodChannel.Result? = null) {
        panelDevice.getStatus(IPanelCallback { bSuc: Boolean, o: Any? ->
            ApiTools.handler.post {
                if (bSuc) {
                    result?.success(o)
                } else {
                    result?.error("", "getEqStatus fail", o)
                }
            }

        })
    }

    /**
     * 获取设备属性
     */
    fun getProperties(result: MethodChannel.Result? = null) {
        log("DevicePanelApi", "getProperties")
        panelDevice.getProperties(IPanelCallback { bSuc: Boolean, o: Any? ->
            ApiTools.handler.post {
                if (bSuc) {
                    result?.success(o)
                } else {
                    result?.error("", "getProperties fail", o)
                }
            }
        })
    }

    /**
     * 设置设备属性
     */
    fun setProperties(params: String, result: MethodChannel.Result? = null) {
        log("DevicePanelApi", "==params==$params")
        panelDevice.setProperties(params, IPanelCallback { bSuc: Boolean, o: Any? ->
            ApiTools.handler.post {
                if (bSuc) {
                    result?.success(o)
                } else {
                    result?.error("", "setProperties fail", o)
                }
            }

        })
    }

    /**
     * 调用服务
     */
    fun invokeService(params: String?, result: MethodChannel.Result? = null) {
        panelDevice.invokeService(params, IPanelCallback { bSuc: Boolean, o: Any? ->
            log("DevicePanelApi", bSuc.toString() + "invokeServiceCallBack" + o.toString())
            ApiTools.handler.post {
                if (bSuc) {
                    result?.success(o)
                } else {
                    result?.error("", "setProperties fail", o)
                }
            }
        })
    }

    /**
     * 订阅所有事件
     */
    fun subAllEvents(events: EventChannel.EventSink?) {
        log("DevicePanelApi", "subAllEvents")

        /**
         * 订阅事件回调
         *
         * @iotid 参数是设备iotid
         * @topic 参数是回调的事件主题字符串
         * @Object data 是触发事件的内容
         */
        panelDevice.subAllEvents({ iotid: String, topic: String?, data: Any ->
            log("DevicePanelApi", "eventCallback_data:$data")
            if (iotid == iotId) {
                ApiTools.handler.post {

                }
            }
        }, { b: Boolean, o: Any? -> log("DevicePanelApi", b.toString() + "subAllEvents==" + o.toString()) })
    }

    //=========================== 回调==================================
    /**
     * 初始化
     * 成功后获取设备状态 和 设备属性
     */
    private val initCallback = IPanelCallback { initFlag: Boolean, o: Any? ->
        if (initFlag) {
//            getEqStatus()
//            getProperties()
//            subAllEvents()
        }
        if (!initFlag) {
            ALog.e("DevicePanelApi", "initSdk fail")
        }
        if (TextUtils.isEmpty(o.toString())) {
            ALog.e("DevicePanelApi", "initCallback Object is null")
        }
    }


}