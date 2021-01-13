package com.fenda.iot.third.utils

import android.util.Log

import com.fenda.iot.flutter.channel.BuildConfig


/**
 * Created by Cat-x on 2020/9/17.
 * For FendaIot
 */

const val TAG = "ALI_SDK"
var DEBUG: Boolean = true/*BuildConfig.DEBUG*/

fun log(vararg message: Any, error: Throwable? = null, isMustPrint: Boolean = false) {
    if (isMustPrint) {
        if (error != null) {
            Log.i(TAG, message.joinToString(separator = "  ::  "), error)
        } else {
            Log.i(TAG, message.joinToString(separator = "  ::  "))
        }
    } else if (DEBUG) {
        if (error != null) {
            Log.i(TAG, message.joinToString(separator = "  ::  "), error)
        } else {
            Log.i(TAG, message.joinToString(separator = "  ::  "))
        }
    }
}
