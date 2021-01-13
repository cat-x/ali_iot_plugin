package com.fenda.iot.third.utils

import android.content.Context
import com.aliyun.iot.aep.oa.OALanguageHelper
import com.aliyun.iot.aep.sdk.IoTSmart
import java.util.*

/**
 * Created by feijie.xfj on 18/5/22.
 */
object OALanguageUtils {

    @JvmStatic
    fun attachBaseContext(newBase: Context): Context {
        setLanguage()
        return newBase
    }

    private fun setLanguage() {
        val language = IoTSmart.getLanguage()?.toLowerCase(Locale.US)
        log("OALanguageUtils", "setLanguage: $language")
        when (language) {
            "zh-CN".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale.SIMPLIFIED_CHINESE)
            "en-US".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale.US)
            "fr-FR".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale.FRANCE)
            "de-DE".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale.GERMANY)
            "ja-JP".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale.JAPAN)
            "ko-KR".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale.KOREA)
            "es-ES".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale("es", "ES"))
            "ru-RU".toLowerCase(Locale.US) -> OALanguageHelper.setLanguageCode(Locale("ru", "RU"))
            else -> OALanguageHelper.setLanguageCode(Locale.US)
        }
    }
}