package com.fenda.iot.third.utils;

import android.annotation.SuppressLint;
import android.text.TextUtils;

import com.aliyun.iot.aep.sdk.framework.AApplication;
import com.aliyun.iot.aep.sdk.framework.utils.SpUtil;

import java.io.Serializable;

public class Env implements Serializable {

    private boolean isSwitched;

    private String productEnv;
    private String apiEnv;
    private String boneEnv;

    private static final String KEY = "env_my_debug_key";

    private static class SingletonHolder {
        @SuppressLint("StaticFieldLeak")
        private static Env INSTANCE = null;
    }

    public static Env getInstance() {
        if (Env.SingletonHolder.INSTANCE == null) {
            Env.SingletonHolder.INSTANCE = getEnv();
        }
        return Env.SingletonHolder.INSTANCE;
    }


    public void storeEnv() {
        SpUtil.putObject(AApplication.getInstance(), KEY, this);
    }

    private static Env getEnv() {
        Env env = SpUtil.getObject(AApplication.getInstance(), KEY, Env.class);
        if (env != null) {
            if (!TextUtils.isEmpty(env.apiEnv)) {
                env.setApiEnv(env.apiEnv);
            }
            if (!TextUtils.isEmpty(env.boneEnv)) {
                env.setBoneEnv(env.boneEnv);
            }
            if (!TextUtils.isEmpty(env.productEnv)) {
                env.setProductEnv(env.productEnv);
            }
            env.setSwitched(env.isSwitched);
        } else {
            env = new Env();
        }
        return env;
    }

    public String getProductEnv() {
        return productEnv;
    }

    public void setProductEnv(String productEnv) {
        this.productEnv = productEnv;
    }

    public String getApiEnv() {
        return apiEnv;
    }

    public void setApiEnv(String apiEnv) {
        this.apiEnv = apiEnv;
    }

    public String getBoneEnv() {
        return boneEnv;
    }

    public void setBoneEnv(String boneEnv) {
        this.boneEnv = boneEnv;
    }


    public boolean isSwitched() {
        return isSwitched;
    }

    public void setSwitched(boolean switched) {
        isSwitched = switched;
    }

    @Override
    public String toString() {
        return "Env{" +
                "productEnv='" + productEnv + '\'' +
                ", apiEnv='" + apiEnv + '\'' +
                ", boneEnv='" + boneEnv + '\'' +
                ", isSwitched='" + isSwitched + '\'' +
                '}';
    }
}
