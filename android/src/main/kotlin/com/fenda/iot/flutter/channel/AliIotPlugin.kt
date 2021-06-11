package com.fenda.iot.flutter.channel

import android.content.Context
import androidx.annotation.NonNull;
import com.aliyun.alink.linksdk.tmp.api.DeviceManager
import com.aliyun.iot.aep.sdk.IoTSmart
import com.aliyun.iot.aep.sdk.login.ILoginCallback
import com.aliyun.iot.aep.sdk.login.ILogoutCallback
import com.aliyun.iot.aep.sdk.login.LoginBusiness
import com.fenda.iot.third.api.*
import com.fenda.iot.third.api.device.DevicePanelApi
import com.fenda.iot.third.api.device.DispatchNetAPI
import com.fenda.iot.third.api.device.SubDeviceApi
import com.fenda.iot.third.utils.DEBUG
import com.fenda.iot.third.utils.log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


/** AliIotPlugin */
public class AliIotPlugin : FlutterPlugin, MethodCallHandler, BasicMessageChannel.MessageHandler<Any>, EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var eventChannel: EventChannel
    private lateinit var methodChannel: MethodChannel
    private lateinit var basicMessageChannel: BasicMessageChannel<Any>
    private lateinit var context: Context
    private var eventSinkMap: HashMap<String, EventChannel.EventSink?> = HashMap()
    private var devicePanelApi: DevicePanelApi? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "ali_iot_plugin_event", JSONMethodCodec.INSTANCE)
        eventChannel.setStreamHandler(this)
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "ali_iot_plugin_method", JSONMethodCodec.INSTANCE)
        methodChannel.setMethodCallHandler(this);
        basicMessageChannel = BasicMessageChannel(flutterPluginBinding.binaryMessenger, "ali_iot_plugin_message", JSONMessageCodec.INSTANCE)
        basicMessageChannel.setMessageHandler(this)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "ali_iot_plugin")
            channel.setMethodCallHandler(AliIotPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setDebug" -> {
                DEBUG = call.argument<Boolean>("debug") ?: true
                IoTSmart.setDebug(DEBUG)
                result.success(true)
            }
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")

            "requestApi" -> {
                val data = call.arguments?.tranJson()?.toMap()
                log("requestApi data-> $data")
                if (data is Map<*, *>) {
                    ApiTools.request(data as Map<String, *>, { data ->
                        val json = data.toJson()
                        log("onMethodCall requestApi data-> $json")
                        result.success(json)
                    }, { exception ->
                        log("onMethodCall requestApi exception-> $exception")
                        result.error(exception?.localizedMessage ?: "", exception?.message ?: "", exception.toString())
                    })
                }
            }
            "isLogin" -> {
                result.success(LoginBusiness.isLogin())
            }
            "authCodeLogin" -> {
                val authCode = call.arguments?.tranJson()?.getString("authCode")
                if (authCode != null) {
                    LoginBusiness.authCodeLogin(authCode, object : ILoginCallback {
                        override fun onLoginSuccess() {
                            result.success(true)
                        }

                        override fun onLoginFailed(code: Int, message: String) {
                            log("authCodeLogin", "code: $code, str: $message")
                            result.error(code.toString(), message, null)
                        }
                    })
                } else {
                    result.error("-1", "authCode is null", null)
                }
            }
            "login" -> {
                LoginBusiness.login(object : ILoginCallback {
                    override fun onLoginSuccess() {
                        result.success(true)
                    }

                    override fun onLoginFailed(code: Int, message: String) {
                        // LinkToast.makeText(getApplicationContext(), s).show();
                        result.error(code.toString(), message, null)
                    }
                })
            }

            "logout" -> {
                LoginBusiness.logout(object : ILogoutCallback {
                    override fun onLogoutSuccess() {
                        result.success(true)
                        DeviceManager.getInstance().clearAccessTokenCache();
                    }

                    override fun onLogoutFailed(code: Int, message: String) {
                        // LinkToast.makeText(getApplicationContext(), s).show();
                        result.error(code.toString(), message, null)
                    }
                })
            }

            "startDiscovery" -> {
                DispatchNetAPI.startDiscovery(context) { discoveryType, deviceList ->
                    log("onMethodCall startDiscovery", " discoveryType-> $discoveryType ,deviceList-> $deviceList")
                    eventSinkMap["startDiscovery"]?.success(mapOf("discoveryType" to mapOf("type" to discoveryType.type,
                            "description" to discoveryType.description), "deviceList" to deviceList).toJSONObject(true))
                }
                result.success(null)
            }
            "stopDiscovery" -> {
                DispatchNetAPI.stopDiscovery()
                result.success(null)
            }
            "startDevicePanel" -> {
                val iotId = call.arguments?.tranJson()?.getString("iotId")
                if (iotId != null) {
                    devicePanelApi = DevicePanelApi(context, iotId)
                    result.success(true)
                } else {
                    result.error("-1", "iotId is null", null)
                }
            }
            "getDevicePanelProperties" -> {
                devicePanelApi?.getProperties(result)
            }
            "setDevicePanelProperties" -> {
                val params = call.arguments?.tranJson()?.getString("params")
                if (params != null) {
                    devicePanelApi?.setProperties(params, result)
                } else {
                    result.error("-1", "params is null", null)
                }
            }
            "invokeDevicePanelService" -> {
                val params = call.arguments?.tranJson()?.getString("params")
                if (params != null) {
                    devicePanelApi?.invokeService(params)
                } else {
                    result.error("-1", "params is null", null)
                }
            }
            "getDevicePanelStatus" -> {
                devicePanelApi?.getEqStatus(result)
            }
            "stopDevicePanel" -> {
                devicePanelApi = null
                result.success(true)
            }
            "startAddDevice" -> {
                val device = call.arguments.tranJson()?.toDeviceInfo()
                val dispatchNetEventSink: EventChannel.EventSink? = eventSinkMap["startAddDevice"]
                if (device != null && dispatchNetEventSink != null) {
                    DispatchNetAPI.startAddDevice(context, device, dispatchNetEventSink, methodChannel)
                    result.success(true)
                } else {
                    result.error("-1", "device or dispatchNetEventSink is null", null)
                }
            }
            "stopAddDevice" -> {
                DispatchNetAPI.stopAddDevice()
                result.success(null)
            }
            "openSystemWiFi" -> {
                DispatchNetAPI.openSystemWiFi(context, result)
            }
            "getDeviceToken" -> {
                val productKey = call.argument<String>("productKey")
                val deviceName = call.argument<String>("deviceName")
                if (productKey != null && deviceName != null) {
                    DispatchNetAPI.getDeviceToken(context, productKey, deviceName, result)
                }
            }
            "bindByToken" -> {
                val productKey = call.argument<String>("productKey")
                val deviceName = call.argument<String>("deviceName")
                val token = call.argument<String>("token")
                if (productKey != null && deviceName != null && token != null) {
                    DispatchNetAPI.bindByToken(productKey, deviceName, token, result)
                }
            }
            else -> result.notImplemented()
        }

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)
        basicMessageChannel.setMessageHandler(null)
    }

    override fun onMessage(message: Any?, reply: BasicMessageChannel.Reply<Any>) {
        val arguments = message as? Map<*, *>
        if (arguments != null) {
            //方法名标识
            val method = arguments["method"] as String

        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val type = arguments as? String
        log("EventChannel onListen $type", "arguments: $arguments ,events: $events")
        when (type) {
            "startDiscovery" -> {
                eventSinkMap[type] = events
            }
            "startAddDevice" -> {
                eventSinkMap[type] = events
            }
            "gatewayPermit" -> {
                eventSinkMap[type] = events
                SubDeviceApi.registerListener(events)
            }
            "subDevicePanelEvent" -> {
                eventSinkMap[type] = events
                devicePanelApi?.subAllEvents(events)
            }
            else -> log("EventChannel onListen", "not find method to handle: $type")
        }

    }

    override fun onCancel(arguments: Any?) {
        val type = arguments as? String
        log("EventChannel onCancel $type", "arguments: $arguments")
        when (type) {
            "startDiscovery" -> {
                eventSinkMap[type] = null
            }
            "startAddDevice" -> {
                eventSinkMap[type] = null
            }
            "gatewayPermit" -> {
                SubDeviceApi.unRegisterListener()
                eventSinkMap[type] = null
            }
            "subDevicePanelEvent" -> {
                eventSinkMap[type] = null
            }
            else -> log("EventChannel onCancel", "not find method to handle: $type")
        }

    }
}
