package com.fenda.iot.third.api.room

import com.fenda.iot.third.api.ApiTools

/**
 * Created by Cat-x on 2020/9/12.
 * For FendaIot
 */
object RoomAPi {

    /**
    调用该接口创建一个新的家

    请求参数
    <br/>=================================
    名称	类型	是否必选	示例值	描述
    name	String	是	xxx的别墅	家的名称。长度为1-20个字符，可以包含大小写英文字母、汉字、数字和空格。
    <br/>=================================
    返回数据
    <br/>=================================
    data	String
    家的 ID，生活物联网平台赋予家的唯一标识符。
     */
    fun createHotel() {
        ApiTools.request {
            path = "/living/home/create"
        }

    }


    /**
    调用该接口删除已创建的家。

    请求参数
    <br/>=================================
    名称	类型	是否必选	示例值	描述
    homeId	String	是		家的ID，生活物联网平台赋予家的唯一标识符。
     */
    fun deleteHotel() {
        ApiTools.request {
            path = "/living/home/delete"
        }

    }

    /**
    更新家的基本信息。

    请求参数
    <br/>=================================
    名称	位置	类型	是否必选	示例值	描述
    name		String	否	xxx的家	家的名称。
    homeId		String	是	c68f1a8f5f5f4a****6ead2f3219	家的ID，生活物联网平台赋予家的唯一标识符。
     */
    fun updateHotel() {
        ApiTools.request {
            path = "/living/home/update"
        }

    }

    /**
    设置用户当前所在的家。

    请求参数
    <br/>=================================
    名称	类型	是否必选	示例值	描述
    homeId	String	是		家的ID，生活物联网平台赋予家的唯一标识符。
     */
    fun setUserInHotel() {
        ApiTools.request {
            path = "/living/home/current/update"
        }

    }

    /**
    获取家的详情。

    请求参数
    <br/>=================================
    名称	类型	是否必选	示例值	描述
    homeId	String	是	50f5op1556f65de314b983fd5bca4f2f2810****	家的ID，生活物联网平台赋予家的唯一标识符。
    <br/>=================================
    返回数据
    <br/>=================================
    名称	类型	描述
    data	JSON
    响应的结果。

    homeId	String
    家的 ID，生活物联网平台赋予家的唯一标识符。

    name	String
    家的名称。

    myRole	String
    用户和家的关系，可取值：ADMIN 和 MEMBER。

    currentHome	Boolean
    表示该 home 是否为当前活跃的家。

    roomCnt	Int
    该家下的房间总数。

    deviceCnt	Int
    归属于该家的设备总数。

    createMillis	Long
    家的创建时间。

    deviceOnlineCnt	Int
    归属于该家的在线设备总数。
     */
    fun getHotelDetail() {
        ApiTools.request {
            path = "/living/home/get"
        }

    }


    /**
    获取家的列表。

    请求参数
    <br/>=================================
    名称	类型	是否必选	示例值	描述
    pageNo	Int	是	1	分页页码，从 1 开始。
    pageSize	Int	是	10	分页大小，大于等于 1，小于等于 20。
    <br/>=================================
    返回数据
    <br/>=================================
    名称	类型	示例值	描述
    data	JSON
    响应的结果。

    total	Long
    满足条件的家总数。

    pageNo	Int
    分页页码。

    pageSize	Int
    分页大小。

    data	JSON
    满足条件家的详情列表。

    homeId	String
    家的ID，生活物联网平台赋予家的唯一标识符。

    name	String
    家的名称。

    currentHome	Boolean
    表示此家是否为用户当前活跃的家。

    myRole	String
    用户和家的关系。可取值为：ADMIN（表示管理员），MEMBER（表示成员）。

    createMillis	Long
    家的创建时间，UNIX时间戳。单位：毫秒。
     */
    fun queryAllHotel() {
        ApiTools.request {
            path = "/living/home/query"
        }

    }
}