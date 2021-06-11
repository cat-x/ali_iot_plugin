package com.fenda.iot.third.api

import com.aliyun.alink.business.devicecenter.api.add.DeviceInfo
import com.aliyun.iot.aep.sdk.apiclient.callback.IoTResponse
import com.google.gson.Gson
import io.flutter.plugin.common.JSONUtil
import org.json.JSONArray
import org.json.JSONObject

/**
 * Created by Cat-x on 2020/9/21.
 * For FendaIot
 */
fun IoTResponse.toJson(): JSONObject {

    val json = JSONObject()

    json.put("code", JSONUtil.wrap(code))

    if (id != null) {
        json.put("id", JSONUtil.wrap(id))
    }

    if (localizedMsg != null) {
        json.put("localizedMsg", JSONUtil.wrap(localizedMsg))
    }

    if (message != null) {
        json.put("message", JSONUtil.wrap(message))
    }

    if (data != null) {
        json.put("data", JSONUtil.wrap(data))
    }

    return json
}

fun Any.tranJson(): JSONObject? {
    if (this is JSONObject) {
        return this
    }
    return null
}

fun JSONObject.toObject(): Any? {
    return JSONUtil.unwrap(this)
}

fun JSONObject.toMap(): Map<*, *>? {
    return JSONUtil.unwrap(this) as? Map<*, *>
}

fun Any.toJSONObject(usedGson: Boolean = true): JSONObject {
    val json = JSONObject()
    if (usedGson) {
        json.put("data", Gson().toJson(this))
    } else {
        json.put("data", JSONUtil.wrap(this))
    }

    return json
}

fun Any.toJSONString(): String {
    return Gson().toJson(this)

}

fun JSONObject.toDeviceInfo(): DeviceInfo {
    val deviceInfo = DeviceInfo();
    val productKey = optString("productKey");
    if (!productKey.isNullOrBlank()) {
        deviceInfo.productKey = productKey
    }
    val productId = optString("productId");
    if (!productId.isNullOrBlank()) {
        deviceInfo.productId = productId
    }
    val id = optString("id");
    if (!id.isNullOrBlank()) {
        deviceInfo.id = id
    }
    val linkType = optString("linkType");
    if (!linkType.isNullOrBlank()) {
        deviceInfo.linkType = linkType
    }
    val protocolVersion = optString("protocolVersion");
    if (!protocolVersion.isNullOrBlank()) {
        deviceInfo.linkType = protocolVersion
    }
    return deviceInfo;
}

