package com.fenda.iot.third.api.device

import android.content.Context
import android.content.Intent
import android.provider.Settings
import androidx.core.content.ContextCompat.startActivity
import com.aliyun.alink.business.devicecenter.api.add.AddDeviceBiz
import com.aliyun.alink.business.devicecenter.api.add.DeviceInfo
import com.aliyun.alink.business.devicecenter.api.add.IAddDeviceListener
import com.aliyun.alink.business.devicecenter.api.add.ProvisionStatus
import com.aliyun.alink.business.devicecenter.api.discovery.*
import com.aliyun.alink.business.devicecenter.base.DCErrorCode
import com.fenda.iot.third.api.ApiTools
import com.fenda.iot.third.api.toJSONObject
import com.fenda.iot.third.api.toJSONString
import com.fenda.iot.third.api.toJson
import com.fenda.iot.third.utils.log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.*
import kotlin.collections.HashMap


/**
 * Created by Cat-x on 2020/9/12.
 * For FendaIot
 */
object DispatchNetAPI {

    private var isStartDiscovery: Boolean = false
    private var isStartAddDevice: Boolean = false

    /** 开始发现设备
     *
     * @param discoveryTypeSet 发现的设备类型 <b>注意：发现蓝牙设备需添加breeze-biz SDK依赖</b>
     * * LOCAL_ONLINE_DEVICE 当前和手机在同一局域网已配网在线的设备
     * * CLOUD_ENROLLEE_DEVICE 零配或智能路由器发现的待配设备
     * * BLE_ENROLLEE_DEVICE 发现的是蓝牙Wi-Fi双模设备（蓝牙模块广播的subType=2即为双模设备）
     * * SOFT_AP_DEVICE 发现的设备热点
     * * BEACON_DEVICE 一键配网发现的待配设备
     *
     * <p></p>
     *
     * @param enrolleeQueryMap 获取零配或智能路由器发现的待配设备[/awss/enrollee/list/get]，请求时需要携带的参数
     * * groupId 空间的ID。生活物联网平台赋予空间的唯一标识符。
     * * productStatusEnv 	产品状态。dev（表示产品开发中）；release（表示产品已发布）。
     *
     */
    fun startDiscovery(context: Context, discoveryTypeSet: EnumSet<DiscoveryType> = EnumSet.allOf(DiscoveryType::class.java), enrolleeQueryMap: HashMap<String, String>? = null, callback: IDeviceDiscoveryListener) {
        if (isStartDiscovery) {
            stopDiscovery()
        }
        isStartDiscovery = true
        LocalDeviceMgr.getInstance().startDiscovery(context, discoveryTypeSet, enrolleeQueryMap, callback)
    }


    /** 停止设备发现
     *
     * * 停止发现本地已配网设备和待配网设备。调用该接口会清除已发现设备列表，确保与启动设备发现startDiscovery()成对调用。
     */
    fun stopDiscovery() {
        isStartDiscovery = false
        try {
            LocalDeviceMgr.getInstance().stopDiscovery()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    /**
     * 设备配网
     * * 1.调用SDK的setDevice接口设置待配网设备信息。
    一键配网需要指定产品型号productKey进行配网。 获取指定产品型号productKey的待配信息有以下两种方式。

    通过直接调用云端接口获取产品列表（非配网SDK提供接口），选择待配网设备对应的产品获取ProductKey。
    通过扫描二维码获得待配设备信息，包含设备ProductKey。

     * *  2.开始配网。
    指定配网方式linkType为ForceAliLinkTypeBroadcast，并调用SDK的startAddDevice接口开始配网。

     * *  3.配网准备阶段，传递Wi-Fi的SSID和password。
    App收到onProvisionPrepare prepareType=1回调后，调用配网SDK的toggleProvision方法，传入当前连接路由器的SSID和password。

     * *  4.监听配网结果。
    可以在配网完成后调用LocalDeviceMgr getDeviceToken接口获取绑定token，并调用基于token方式设备绑定完成设备的绑定。
     */
    fun startAddDevice(context: Context, deviceInfo: DeviceInfo, eventSink: EventChannel.EventSink, methodChannel: MethodChannel) {
        if (isStartAddDevice) {
            stopAddDevice()
        }
        isStartAddDevice = true
        /**
         * 第一步：设置待配网设备信息
         *
         *  // 设备热点配网：ForceAliLinkTypeSoftAP
         *  // 蓝牙辅助配网：ForceAliLinkTypeBLE
         *  // 二维码配网：ForceAliLinkTypeQR
         *  // 手机热点配网：ForceAliLinkTypePhoneAP
         *  // 一键配网：ForceAliLinkTypeBroadcast
         *  // 零配：ForceAliLinkTypeZeroAP
         *
         * * 方式一：指定productKey和productId方式
         * deviceInfo.productKey = "xx"; //必填
         * deviceInfo.productId = "xxx"; //必填，可通过发现接口返回或者根据productKey或云端换取
         * deviceInfo.id = "xxx";// 通过startDiscovery发现的设备会返回该信息，在配网之前设置该信息，其它方式不需要设置
         * deviceInfo.linkType = "ForceAliLinkTypeBLE";
         *
         * * 方式二：不指定型号
         * deviceInfo.productKey = null;
         * deviceInfo.productId = null;
         * deviceInfo.protocolVersion = "2.0";
         * deviceInfo.linkType = "ForceAliLinkTypeBLE";
         */


        //设置待添加设备的基本信息
        AddDeviceBiz.getInstance().setDevice(deviceInfo)

        /**
         * 第二步：开始配网
         * 前置步骤，设置待配信息并开始配网
         */
        AddDeviceBiz.getInstance().startAddDevice(context, object : IAddDeviceListener {
            override fun onPreCheck(b: Boolean, dcErrorCode: DCErrorCode?) {
                // 参数检测回调
                log("startAddDevice", "onPreCheck->", "$b dcErrorCode->$dcErrorCode")
            }

            override fun onProvisionPrepare(prepareType: Int) {
                log("startAddDevice", "onProvisionPrepare->", "prepareType:$prepareType")
                /**
                 * 第三步：配网准备阶段，传入Wi-Fi信息
                 * TODO 修改使用手机当前连接的Wi-Fi的SSID和password
                 */
                eventSink.success(listOf("onProvisionPrepare", prepareType))
                if (prepareType == 1) {
                    methodChannel.invokeMethod("toggleProvision", {}, object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            log("startAddDevice", "toggleProvision->", "success:$result")
                            val arguments = result as? JSONObject
                            if (arguments != null) {
                                //方法名标识
                                val ssid = arguments.optString("ssid")
                                val password = arguments.optString("password")
                                if (!ssid.isNullOrBlank() && !password.isNullOrBlank()) {
                                    AddDeviceBiz.getInstance().toggleProvision(ssid, password, 60)
                                } else {
                                    log("startAddDevice", "toggleProvision->", "had error ssid=>$ssid password=>$password")
                                }
                            }
                        }

                        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                            log("startAddDevice", "toggleProvision->", "error:$errorCode errorMessage:$errorMessage errorDetails:$errorDetails")
                        }

                        override fun notImplemented() {
                            log("startAddDevice", "toggleProvision->", "notImplemented")
                        }
                    });

                }
            }

            override fun onProvisioning() {
                log("startAddDevice", "onProvisioning->")
                // 配网中
                eventSink.success(listOf("onProvisioning"))
            }

            override fun onProvisionStatus(provisionStatus: ProvisionStatus) {
                log("startAddDevice", "onProvisionStatus->", "provisionStatus:$provisionStatus")
                eventSink.success(listOf("onProvisionStatus", provisionStatus.code(), provisionStatus.message(), provisionStatus.extraParams))
                /**
                 * 第四步：配网中，配网UI引导
                 * TODO 根据配网回调做 UI 引导
                 */
                if (provisionStatus == ProvisionStatus.PROVISION_APP_TOKEN) {
                    return
                    // 比如android 10，或者非android 10发现或连接设备热点失败。
                    // 需要引导用户连接设备热点，否则会配网失败
                    deviceInfo.token = provisionStatus.extraParams["appToken"] as String?
                    eventSink.success(listOf("onProvisionedResult", mapOf("isSuccess" to true, "deviceInfo" to deviceInfo.toJSONString(), "errorCode" to null)))
                    return
                }
                if (provisionStatus == ProvisionStatus.SAP_NEED_USER_TO_CONNECT_DEVICE_AP) {
                    // 比如android 10，或者非android 10发现或连接设备热点失败。
                    // 需要引导用户连接设备热点，否则会配网失败
                    return
                }
                if (provisionStatus == ProvisionStatus.SAP_NEED_USER_TO_RECOVER_WIFI) {
                    // 引导用户恢复手机Wi-Fi连接，否则会配网失败
                    return
                }
            }

            override fun onProvisionedResult(isSuccess: Boolean, deviceInfo: DeviceInfo?, errorCode: DCErrorCode?) {
                log("startAddDevice", "onProvisionedResult->", "isSuccess:$isSuccess deviceInfo:$deviceInfo errorCode:$errorCode")
                eventSink.success(listOf("onProvisionedResult", mapOf("isSuccess" to isSuccess, "deviceInfo" to deviceInfo?.toJSONString(), "errorCode" to errorCode?.toJSONString())))
                /**
                 * 第四步：监听配网结果
                 */
                // 如果配网结果包含token，请使用配网成功带的token做绑定。
            }
        })
    }

    fun stopAddDevice() {
        isStartAddDevice = false
        AddDeviceBiz.getInstance().stopAddDevice()
    }


    /** 获取绑定token */
    fun getDeviceToken(context: Context, productKey: String, deviceName: String, resultCallback: MethodChannel.Result) {
        /**
         * 第一步：获取绑定token
         */
        val getTokenParams: GetTokenParams = GetTokenParams()
        getTokenParams.deviceName = deviceName
        getTokenParams.productKey = productKey
        LocalDeviceMgr.getInstance().getDeviceToken(context, getTokenParams, object : IOnTokenGetListerner {
            override fun onSuccess(result: GetTokenResult?) {
                /**
                 * 第二步：调用绑定接口
                 */
                if (result == null) {
                    resultCallback.error("-1", "getDeviceToken onSuccess, but result is null", "")
                } else {
                    resultCallback.success(result.toJSONObject());
                }

            }

            override fun onFail(errorCode: DCErrorCode?) {
                resultCallback.error(errorCode?.code ?: "-1", errorCode?.msg ?: "getDeviceToken errorCode, but errorCode is null", "")
            }
        })

    }

    /**
     * 基于token方式设备绑定
     */
    fun bindByToken(productKey: String, deviceName: String, token: String, result: MethodChannel.Result) {
        val device: MutableMap<String, Any> = HashMap(3)
        device["productKey"] = productKey
        device["deviceName"] = deviceName
        device["token"] = token

        ApiTools.request {
            path = "/awss/token/user/bind"
            apiVersion = "1.0.3"
            params = device
            onFailure = {
                log("bindByToken", "onFailure->", error = it)
                result.error(it?.localizedMessage ?: "", it?.message ?: "", it?.toString() ?: "")
            }

            onResponse = { data ->
                val json = data.toJson()
                log("bindByToken", "onResponse->", json)
                result.success(json)

            }
        }
    }


    fun openSystemWiFi(context: Context, result: MethodChannel.Result) {
        try {
            context.startActivity(Intent(Settings.ACTION_WIFI_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("-1", e.message, e.localizedMessage)
        }

    }

}