package com.fenda.iot.third.framework

import android.content.Context
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.aliyun.iot.aep.sdk.framework.AApplication
import com.aliyun.iot.aep.sdk.framework.language.LanguageManager
import com.aliyun.iot.aep.sdk.threadpool.ThreadPool.DefaultThreadPool
import com.aliyun.iot.aep.sdk.threadpool.ThreadPool.MainThreadHandler

/**
 * Created by Cat-x on 2020/8/24.
 * For FendaIot
 */
public open class AActivity : AppCompatActivity() {
    private var channelID = 0

    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(LanguageManager.replaceLanguage(newBase))
    }

    override fun onCreate(bundle: Bundle?) {
        super.onCreate(bundle)
    }

    override fun onResume() {
        super.onResume()
        blockChannel(false)
    }

    override fun onPause() {
        super.onPause()
        blockChannel(true)
    }

    override fun onDestroy() {
        super.onDestroy()
        channelID = 0
    }

    protected fun getChannelID(): Int {
        return channelID
    }

    protected fun blockChannel(blocked: Boolean) {
        AApplication.getInstance().bus.blockChannel(channelID, blocked)
    }

    protected fun cancelChannel() {
        AApplication.getInstance().bus.cancelChannel(channelID)
    }

    protected fun postMainThread(runnable: Runnable) {
        MainThreadHandler.getInstance().post(runnable)
    }

    protected fun postSubThread(runnable: Runnable) {
        DefaultThreadPool.getInstance().submit(runnable)
    }
}