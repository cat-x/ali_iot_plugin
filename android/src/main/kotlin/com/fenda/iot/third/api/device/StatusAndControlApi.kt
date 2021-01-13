package com.fenda.iot.third.api.device

import android.content.Context
import com.aliyun.alink.linksdk.tmp.api.DeviceManager
import com.aliyun.alink.linksdk.tmp.device.panel.PanelDevice
import com.aliyun.alink.linksdk.tmp.device.panel.listener.IPanelCallback
import com.aliyun.alink.linksdk.tmp.device.panel.listener.IPanelEventCallback
import com.aliyun.alink.linksdk.tools.ALog
import org.json.JSONObject


/**
 * Created by Cat-x on 2020/9/12.
 * For FendaIot
 */
object StatusAndControlApi {


    /**
     * 设备模型SDK
     * 在外网断开时，向云端拉取用户账号下的设备列表会失败，此时可以使用以下接口获取当前可以本地通信控制的设备列表。
     */
    fun getLocalAuthedDeviceDataList() {
        DeviceManager.getInstance().getLocalAuthedDeviceDataList()
    }


    fun deviceCreation(context: Context, iotid: String) {
        //设备创建
        val panelDevice = PanelDevice(iotid);
        //iotid可以通过云端接口获取。具体请参见物的模型服务。

        panelDevice.init(context) { bSuc, o ->

        };
        //context是应用的上下文，IPanelCallback是初始化回调接口
        // bSuc表示初始化结果，true为成功，false为失败
        // o表示具体的数据，失败时是一个AError结构，成功时忽略
    }


    /**
     * 获取设备状态
     */
    fun getStatus(panelDevice: PanelDevice) {
        panelDevice.getStatus(IPanelCallback { bSuc, o ->
            ALog.d("TAG", "getStatus(), request complete,$bSuc")
            val data = JSONObject(o as String?)
        })
        // bSuc表示是否获取成功，true为成功，false为失败
        // o 表示具体的数据，失败时是一个AError结构，成功时是json字符串格式如下
        /* {
            "code":200,
            "data":{
                "status":1
                "time":1232341455
            }
        }
       说明：status表示设备生命周期，目前有以下几个状态，
        0：未激活；1：上线；3：离线；8：禁用；time表示当前状态的开始时间
     */

    }


    /**
     * 获取设备属性
     */
    fun getProperties(panelDevice: PanelDevice) {
        panelDevice.getProperties(IPanelCallback { bSuc, o ->
            ALog.d("TAG", "getProps(), request complete,$bSuc")
            val data = JSONObject(o as String?)
        })
        //bSuc表示是否获取成功，true为成功，false为失败
        //o表示具体的数据，失败时是一个AError结构，成功时是json字符串格式如下
        /* {
           "code":200,
           "data":{
                 "WorkMode": {
                     "time": 1516347450295,
                     "value": 0
                  }
            }
        }
     */
    }


    /**
     * 设置设备属性
     */
    fun setProperties(panelDevice: PanelDevice, paramsStr: String) {
        panelDevice.setProperties(paramsStr, object : IPanelCallback {
            override fun onComplete(bSuc: Boolean, o: Any?) {
                ALog.d("TAG", "setProps(),request complete," + bSuc)
                val data = JSONObject(o as String)
            }

        })
//paramsStr 格式参考如下：
/*
{
    "items":{
        "LightSwitch":0
    },
    "iotId":"s66CDxxxxXH000102"
}
*/
//bSuc表示是否获取成功，true为成功，false为失败
//o表示具体的数据，失败时是一个AError结构，成功时忽略
    }


    /**
     * 调用服务
     */
    fun invokeService(panelDevice: PanelDevice, paramsStr: String) {
        panelDevice.invokeService(paramsStr) { bSuc, o ->
            ALog.d("TAG", "callService(), request complete,$bSuc")
            val data = JSONObject(o as String?)
        }

//paramsStr 格式参考如下
/*
{
    "args":{
        "Saturation":80,
        "LightDuration":50,
        "Hue":325,
        "Value":50
    },
    "identifier":"Rhythm",
    "iotId":"s66CDxxxxItXH000102"
}
*/

//bSuc表示是否获取成功，true为成功，false为失败
//o表示具体的数据，失败时是一个AError结构，成功时忽略
    }

    val TAG = " TAG"

    /**
     * 订阅所有事件
     * App上用户主动解绑一台设备或者在设备端reset，云端会主动向App发送通知。App收到推送通知后，SDK内部会自动清除相关缓存数据，且发出解绑通知。具体的解绑通知格式请参见调用示例。
     */

    fun subAllEvent(panelDevice: PanelDevice, paramsStr: String) {
        panelDevice.subAllEvent(
                IPanelEventCallback { iotid, topic, data ->
                    ALog.d(TAG, "onNofity(),topic = $topic")
                    val jData = JSONObject(data as String)
                },
                IPanelCallback { bSuc, data -> ALog.d(TAG, "doTslTest data:$data") },


//IPanelCallback订阅成功或者失败时回调
//IPanelCallback的onComplete接口回调其中的参数
//bSuc表示是否获取成功，true为成功，false为失败
//o 表示具体的数据。失败时是一个AError结构，不会有事件回调，成功时忽略

//IPanelEventCallback在事件触发时回调
//iotid参数是设备iotid
//topic参数是回调的事件主题字符串
//Object data参数是触发事件的内容，类型为json字符串，格式参考如下
/*
{
    "params": {
      "iotId":"0300MSKL03xxxx4Sv4Za4",
      "productKey":"X5xxxxH7",
      "deviceName":"5gJtxDxxxxpisjX",
      "items":{
        "temperature":{
          "time":1510292697471,
          "value":30
        }
      }
  },
  "method":"thing.properties"
}
*/


//当operation为Unbind时，表示该设备已解绑，解绑通知的格式参考如下
//topic: /sys/${pk}/${dn}/app/down/_thing/event/notify
/*
{
    "identifier":"awss.BindNotify",
    "value":{
            "iotId":"apVtLzgkxxxxV000102",
            "identityId":"5063op37bxxxxxe0bfa9d98037",
            "owned":1,
            "productKey":"a2xxxxxyi",
            "deviceName":"IoT_Dev_33",
            "operation":"Unbind"
    }
}
*/
        )



        /**
         * 清理缓存
        账号退出时需要清理账号缓存的数据。
         */
        fun clearAccessTokenCache() {
            DeviceManager.getInstance().clearAccessTokenCache()
        }


        /**
         * 获取物的模型
         */
        fun getTslByCache(panelDevice: PanelDevice) {
            panelDevice.getTslByCache { bSuc, data -> ALog.d(TAG, "doTslTest data:$data") }
//bSuc表示是否获取成功，true为成功，false为失败
//data 为具体的返回数据，格式为json字符串，失败时为一个AError结构
        }


    }
}