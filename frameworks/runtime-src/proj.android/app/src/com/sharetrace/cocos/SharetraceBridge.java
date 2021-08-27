package com.sharetrace.cocos;

import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONObject;

import cn.net.shoot.sharetracesdk.AppData;
import cn.net.shoot.sharetracesdk.ShareTrace;
import cn.net.shoot.sharetracesdk.ShareTraceInstallListener;
import cn.net.shoot.sharetracesdk.ShareTraceWakeUpListener;

public class SharetraceBridge {
    private static final String TAG = "SharetraceBridge";
    private static final String KEY_CODE = "code";
    private static final String KEY_MSG = "msg";
    private static final String KEY_PARAMSDATA = "paramsData";
    private static final String KEY_CHANNEL = "channel";

    private static AppData cacheWakeupData = null;
    private static boolean hasWakeupRegister = false;
    private static int wakeupfuncId = -1;


    public static void getInstallTrace(int seconds, final int funcId, final Cocos2dxActivity cocos2dxActivity) {
        int defaultTimeout = 10;
        if (seconds > 0) {
            defaultTimeout = seconds;
        }
        int timeoutMs = defaultTimeout * 1000;
        ShareTrace.getInstallTrace(new ShareTraceInstallListener() {
            @Override
            public void onInstall(AppData appData) {
                if (appData == null) {
                    JSONObject json = extractToResult(-1, "Extract data fail.", "", "");
                    installCallback(json.toString(), cocos2dxActivity, funcId);
                    return;
                }
                JSONObject json = extractToResult(200, "Success",
                        appData.getParamsData(),
                        appData.getChannel());
                installCallback(json.toString(), cocos2dxActivity, funcId);
            }

            @Override
            public void onError(int code, String message) {

            }
        }, timeoutMs);

    }

    public static void registerWakeupTrace(final Cocos2dxActivity cocos2dxActivity, final int funcId) {
        hasWakeupRegister = true;
        wakeupfuncId = funcId;
        if (cacheWakeupData != null) {
            AppData appData = cacheWakeupData;
            JSONObject json = extractToResult(200, "Success",
                    appData.getParamsData(),
                    appData.getChannel());
            wakeupCallback(json.toString(), cocos2dxActivity);
            cacheWakeupData = null;
        }
    }

    public static void getWakeupTrace(Intent intent, final Cocos2dxActivity cocos2dxActivity) {
        ShareTrace.getWakeUpTrace(intent, new ShareTraceWakeUpListener() {
            @Override
            public void onWakeUp(AppData appData) {
//                    Log.d(TAG, "onWakeUp: " + appData.toString());
                if (appData == null) {
                    return;
                }

                if (hasWakeupRegister) {
                    JSONObject json = extractToResult(200, "Success",
                            appData.getParamsData(),
                            appData.getChannel());
                    wakeupCallback(json.toString(), cocos2dxActivity);
                    cacheWakeupData = null;
                } else {
                    cacheWakeupData = appData;
                }
            }
        });
    }

    private static JSONObject extractToResult(int code, String msg, String paramsData, String channel) {
        JSONObject json = new JSONObject();

        try {
            json.put(KEY_CODE, code);
            json.put(KEY_MSG, msg);
            json.put(KEY_PARAMSDATA, defaultValue(paramsData));
            json.put(KEY_CHANNEL, defaultValue(channel));
        } catch (Throwable e) {
            Log.e(TAG, "extractToResult error, " + e.getMessage());
        }

        return json;
    }

    private static String defaultValue(String str) {
        if (TextUtils.isEmpty(str)) {
            return "";
        }

        return str;
    }

    private static void installCallback(final String data, Cocos2dxActivity cocos2dxActivity, final int funcId) {
        if (cocos2dxActivity == null) {
            return;
        }
        cocos2dxActivity.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(funcId, data);
                Cocos2dxLuaJavaBridge.releaseLuaFunction(funcId);
            }
        });

    }

    private static void wakeupCallback(final String data, Cocos2dxActivity cocos2dxActivity) {
        if (cocos2dxActivity == null || wakeupfuncId == -1) {
            return;
        }
        cocos2dxActivity.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(wakeupfuncId, data);
            }
        });
    }
}
