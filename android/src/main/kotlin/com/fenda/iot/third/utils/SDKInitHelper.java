package com.fenda.iot.third.utils;

import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.sdk.android.openaccount.ConfigManager;
import com.aliyun.iot.aep.sdk.IoTSmart;
import com.aliyun.iot.aep.sdk.framework.AApplication;
import com.aliyun.iot.aep.sdk.framework.config.GlobalConfig;
import com.aliyun.iot.aep.sdk.log.ALog;
import com.facebook.FacebookSdk;
import com.fenda.iot.flutter.channel.R;

public class SDKInitHelper {
    private static final String TAG = "SDKInitHelper";

    public static void init(AApplication app) {
        if (app == null) {
            return;
        }
        preInit(app);
        onInit(app);
        //onInitDefault(app);
        postInit(app);
    }

    /**
     * 初始化之前准备工作
     * @param app
     */
    private static void preInit(AApplication app) {
        //要在OA初始化前调用
        ConfigManager.getInstance().setGoogleClientId(app.getString(R.string.server_client_id));

        String appId = app.getString(R.string.facebook_app_id);
        try {
            FacebookSdk.setApplicationId(appId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        ConfigManager.getInstance().setFacebookId(appId);
    }

    /**
     * 默认初始化
     * @param app
     */
    private static void onInitDefault(AApplication app) {
        GlobalConfig.getInstance().setApiEnv(GlobalConfig.API_ENV_PRE);
        GlobalConfig.getInstance().setBoneEnv(GlobalConfig.BONE_ENV_TEST);

        IoTSmart.init(app);
    }
    /**
     * 带参数初始化
     * @param app
     */
    private static void onInit(AApplication app) {
        // 默认的初始化参数
        IoTSmart.InitConfig initConfig = new IoTSmart.InitConfig()
                // REGION_ALL: 支持连接中国大陆和海外多个接入点，REGION_CHINA_ONLY:直连中国大陆接入点，只在中国大陆出货选这个
                .setRegionType(IoTSmart.REGION_CHINA_ONLY)
                // 对应控制台上的测试版（PRODUCT_ENV_DEV）和正式版（PRODUCT_ENV_PROD）(默认)
                // 后面的版本不再推荐用这种方式测试未发布产品，推荐使用IoTSmart.setProductScope接口
                .setProductEnv(IoTSmart.PRODUCT_ENV_DEV)
                // 是否打开日志
                .setDebug(true);

        // 定制三方通道离线推送，目前支持华为、小米、FCM、oppo、vivo
        IoTSmart.PushConfig pushConfig = new IoTSmart.PushConfig();
        pushConfig.fcmApplicationId = "fcmid"; // 替换为从FCM平台申请的id
        pushConfig.fcmSendId = "fcmsendid"; // 替换为从FCM平台申请的sendid
        pushConfig.xiaomiAppId = "XiaoMiAppId"; // 替换为从小米平台申请的AppID
        pushConfig.xiaomiAppkey = "XiaoMiAppKey"; // 替换为从小米平台申请的AppKey
        // 华为、vivo推送通道需要在AndroidManifest.xml里面添加

        pushConfig.oppoAppKey = "oppoAppKey"; // 替换为从oppo平台申请的AppKey
        pushConfig.oppoAppSecret = "oppoAppSecret"; // 替换为从oppo平台申请的AppSecret

        initConfig.setPushConfig(pushConfig);


        GlobalConfig.getInstance().setApiEnv(GlobalConfig.API_ENV_ONLINE);
        GlobalConfig.getInstance().setBoneEnv(GlobalConfig.BONE_ENV_TEST);

        ALog.d(TAG, "initConfig1:" + JSON.toJSONString(initConfig));
        // 切换国内，国外环境，测试版、正式版环境后的初始化参数
        Env env = Env.getInstance();
        ALog.d(TAG, "env:" + env.toString());
        if (env.isSwitched()) {
            if (!TextUtils.isEmpty(env.getApiEnv())) {
                GlobalConfig.getInstance().setApiEnv(env.getApiEnv());
            }
            if (!TextUtils.isEmpty(env.getBoneEnv())) {
                GlobalConfig.getInstance().setBoneEnv(env.getBoneEnv());
            }
            if (!TextUtils.isEmpty(env.getProductEnv())) {
                initConfig.setProductEnv(env.getProductEnv());
            }

            ALog.d(TAG, "initConfig2:" + JSON.toJSONString(initConfig));
        }
        // 初始化
        IoTSmart.init(app, initConfig);

        IoTSmart.setProductScope(IoTSmart.PRODUCT_SCOPE_PUBLISHED);

    }

    /**
     * 初始化后的定制参数
     *
     * @param app application
     */
    private static void postInit(@SuppressWarnings("unused") AApplication app) {

//        OALoginAdapter adapter = (OALoginAdapter) LoginBusiness.getLoginAdapter();
//        if (adapter != null) {
//            adapter.setDefaultLoginClass(OALoginActivity.class);
//        }
//        OpenAccountUIConfigs.AccountPasswordLoginFlow.supportForeignMobileNumbers = true;
//        OpenAccountUIConfigs.AccountPasswordLoginFlow.mobileCountrySelectorActvityClazz = OAMobileCountrySelectorActivity.class;
//
//        OpenAccountUIConfigs.ChangeMobileFlow.supportForeignMobileNumbers = true;
//        OpenAccountUIConfigs.ChangeMobileFlow.mobileCountrySelectorActvityClazz = OAMobileCountrySelectorActivity.class;
//
//        OpenAccountUIConfigs.MobileRegisterFlow.supportForeignMobileNumbers = true;
//        OpenAccountUIConfigs.MobileRegisterFlow.mobileCountrySelectorActvityClazz = OAMobileCountrySelectorActivity.class;
//
//        OpenAccountUIConfigs.MobileResetPasswordLoginFlow.supportForeignMobileNumbers = true;
//        OpenAccountUIConfigs.MobileResetPasswordLoginFlow.mobileCountrySelectorActvityClazz = OAMobileCountrySelectorActivity.class;
//
//        OpenAccountUIConfigs.OneStepMobileRegisterFlow.supportForeignMobileNumbers = true;
//        OpenAccountUIConfigs.OneStepMobileRegisterFlow.mobileCountrySelectorActvityClazz = OAMobileCountrySelectorActivity.class;
    }
}
