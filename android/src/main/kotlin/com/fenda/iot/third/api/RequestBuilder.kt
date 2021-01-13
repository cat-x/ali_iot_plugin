package com.fenda.iot.third.api

import com.aliyun.iot.aep.sdk.apiclient.callback.IoTCallback
import com.aliyun.iot.aep.sdk.apiclient.callback.IoTResponse
import com.aliyun.iot.aep.sdk.apiclient.emuns.Scheme
import com.aliyun.iot.aep.sdk.apiclient.request.IoTRequest
import com.aliyun.iot.aep.sdk.apiclient.request.IoTRequestBuilder
import java.util.*

/**
 * Created by Cat-x on 2020/9/12.
 * For FendaIot
 */
class RequestBuilder : IoTRequestBuilder() {


    var isIotAuth: Boolean = true

    var scheme: Scheme
        set(value) {
            setScheme(value)
        }
        @Deprecated("noGetter")
        get() = error("noGetter")

    var host: String
        set(value) {
            setHost(value)
        }
        @Deprecated("noGetter")
        get() = error("noGetter")

    var path: String
        set(value) {
            setPath(value)
        }
        @Deprecated("noGetter")
        get() = error("noGetter")

    var apiVersion: String
        set(value) {
            setApiVersion(value)
        }
        @Deprecated("noGetter")
        get() = error("noGetter")

    var authType: String
        set(value) {
            setAuthType(value)
            isIotAuth = false
        }
        @Deprecated("noGetter")
        get() = error("noGetter")

    var mockType: String
        set(value) {
            setMockType(value)
        }
        @Deprecated("noGetter")
        get() = error("noGetter")


    var params: MutableMap<String, *>
        set(value) {
            setParams(value)
        }
        @Deprecated("noGetter")
        get() = error("noGetter")

    var addParam: Pair<String, Any?>
        set(value) {
            val (key, content) = value
            when (content) {
                is String -> addParam(key, content)
                is Int -> addParam(key, content)
                is Long -> addParam(key, content)
                is Float ->addParam(key, content)
                is Double ->addParam(key, content)
                is List<*> ->addParam(key, content)
                is Map<*,*> ->addParam(key, content)
            }
        }
        @Deprecated("noGetter")
        get() = error("noGetter")


    var callback: IoTCallback? = null

    var onFailure: ((Exception?) -> Unit)? = null

    var onResponse: ((IoTResponse) -> Unit)? = null


}