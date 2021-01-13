package com.fenda.iot.third.api.device

import com.aliyun.alink.linksdk.channel.core.base.AError
import com.aliyun.alink.linksdk.channel.mobile.api.IMobileDownstreamListener
import com.aliyun.alink.linksdk.channel.mobile.api.IMobileSubscrbieListener
import com.aliyun.alink.linksdk.channel.mobile.api.MobileChannel
import com.fenda.iot.third.utils.log
import io.flutter.plugin.common.EventChannel

/**
 * Created by Cat-x on 2020/10/21.
 * For android
 */
object SubDeviceApi {


    private const val TOPIC_PATH = "/thing/topo/add/status"
    private var events: EventChannel.EventSink? = null

    private val mTopicListener: IMobileSubscrbieListener = object : IMobileSubscrbieListener {
        override fun onSuccess(topic: String) {
            log("SubDeviceApi", "subscribe onSuccess, topic = $topic")
        }

        override fun onFailed(topic: String, error: AError) {
            log("SubDeviceApi", "subscribe onFailed, topic = $topic")
        }

        override fun needUISafety(): Boolean {
            return false
        }
    }

    private val mDownStreamListener: IMobileDownstreamListener = object : IMobileDownstreamListener {
        override fun onCommand(method: String, data: String) {
            log("SubDeviceApi", "接收到Topic = $method, data=$data")
            if (method == TOPIC_PATH) {
                events?.success(data)
            }

        }

        override fun shouldHandle(method: String): Boolean {
            return TOPIC_PATH.equals(method, ignoreCase = true)
        }
    }
    private var maybeRegister = false

    fun registerListener(events: EventChannel.EventSink?) {
        this.events = events;
        if (maybeRegister) {
            return
        }
        maybeRegister = true
        MobileChannel.getInstance().subscrbie(TOPIC_PATH, mTopicListener)
        log("SubDeviceApi", "subscribe $TOPIC_PATH")
        MobileChannel.getInstance().registerDownstreamListener(true, mDownStreamListener)
        log("SubDeviceApi", "register $TOPIC_PATH")

    }

    fun unRegisterListener() {
        MobileChannel.getInstance().unSubscrbie(TOPIC_PATH, mTopicListener)
        log("SubDeviceApi", "unSubscribe $TOPIC_PATH")
        MobileChannel.getInstance().unRegisterDownstreamListener(mDownStreamListener)
        log("SubDeviceApi", "unRegister $TOPIC_PATH")
        events = null
        maybeRegister = false
    }
}