package com.fenda.iot.third.api

import android.os.Handler
import android.os.Looper
import com.aliyun.iot.aep.sdk.apiclient.IoTAPIClientFactory
import com.aliyun.iot.aep.sdk.apiclient.callback.IoTCallback
import com.aliyun.iot.aep.sdk.apiclient.callback.IoTResponse
import com.aliyun.iot.aep.sdk.apiclient.emuns.Scheme
import com.aliyun.iot.aep.sdk.apiclient.request.IoTRequest
import com.aliyun.iot.aep.sdk.apiclient.request.IoTRequestBuilder
import java.lang.Exception
import java.util.*

/**
 * Created by Cat-x on 2020/9/12.
 * For FendaIot
 */
@Suppress("unused")
object ApiTools {
    val handler by lazyOf(Handler(Looper.myLooper()!!))

    @Suppress("HasPlatformType")
    val apiClient = IoTAPIClientFactory().client

    fun request(requestParams: Map<String, *>, onResponse: ((IoTResponse) -> Unit)? = null, onFailure: ((Exception?) -> Unit)? = null) {
        request {
            this.onResponse = { handler.post { onResponse?.invoke(it) } }
            this.onFailure = { handler.post { onFailure?.invoke(it) } }
            for (param in requestParams) {
                if (param.value != null) {
                    when (param.key) {
                        "path" -> path = param.value as String
                        "apiVersion" -> apiVersion = param.value as String
                        "scheme" -> scheme = if (param.value == "HTTPS") Scheme.HTTPS else Scheme.HTTP
                        "host" -> host = param.value as String
                        "authType" -> authType = param.value as String
                        "mockType" -> mockType = param.value as String
                        "params" -> params = param.value as MutableMap<String, *>
                        "addParam" -> {
                            for (entry in (param.value as Map<String, *>)) {
                                addParam = entry.toPair()
                            }
                        }
                    }
                }
            }
        }

    }

    fun request(@IoTRequestDsl init: RequestBuilder.() -> Unit) {
        val request = RequestBuilder()
        request.init()
        if (request.isIotAuth) {
            request.setAuthType("iotAuth")
        }
        apiClient.send(request.build(), object : IoTCallback {
            override fun onFailure(ioTRequest: IoTRequest?, exception: Exception?) {
                request.callback?.onFailure(ioTRequest, exception)
                request.onFailure?.invoke(exception)
            }

            override fun onResponse(ioTRequest: IoTRequest?, ioTResponse: IoTResponse?) {
                request.callback?.onResponse(ioTRequest, ioTResponse)
                request.onResponse?.invoke(ioTResponse ?: emptyIoTResponse)
            }
        })
    }

    @DslMarker
    annotation class IoTRequestDsl

    val emptyIoTResponse: IoTResponse = object : IoTResponse {
        override fun getId(): String? {
            return null
        }

        override fun getCode(): Int {
            return -1
        }

        override fun getMessage(): String? {
            return null
        }

        override fun getLocalizedMsg(): String? {
            return null
        }

        override fun getData(): Any? {
            return null
        }

        override fun getRawData(): ByteArray? {
            return null
        }

    }

    fun test() {
        request {
            addParam = "" to 1
            val a = scheme
            onResponse = {

            }
        }
    }

}