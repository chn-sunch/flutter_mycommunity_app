package com.mycommunity_app.flutter_mycommunity_app;

import android.app.Activity;
import android.app.Application;
import androidx.annotation.CallSuper;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.util.Log;
import android.text.TextUtils;
//import io.flutter.view.FlutterMain;
import util.MyLog;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import okhttp3.*;
import org.json.JSONException;
import org.json.JSONObject;
import util.OkHttpUtil;
//import util.PermissionsUtil;

import java.io.File;
import java.io.IOException;

/**
 * Flutter implementation of {@link android.app.Application}, managing application-level global
 * initializations.
 *
 * <p>Using this {@link android.app.Application} is not required when using APIs in the package
 * {@code io.flutter.embedding.android} since they self-initialize on first use.
 */
public class MyApplication extends Application  {
    //String serverUrl = "http://120.55.99.199:8080";
    //static String serverUrl = "http://192.168.10.102:8081";
    //String serverUrl = "http://121.199.1.188:8080";
    String serverUrl = "https://api.chulaiwanba.com/";


    final String TAG = "MyApplication";
    OkHttpUtil okHttpUtil = new OkHttpUtil();

    @Override
    @CallSuper
    public void onCreate() {

        super.onCreate();

        String url = serverUrl + "/Patch/getNewPatch?cputype=" + getCpuABI();
        okHttpUtil.doGet(url, new Callback() {
            public void onFailure(Call call, IOException e) {
                Log.e("failure:", e.toString());
            }

            public void onResponse(Call call, Response response)
                    throws IOException {
                String str = response.body().string();
                String versioncode = getAppVersionName(getApplicationContext());
                MyLog.d("app version ", versioncode, getApplicationContext());

                try {
                    JSONObject jsonObject = new JSONObject(str);
                    String data = jsonObject.getString("data");
                    if(data != null && data != "") {
                        JSONObject Jarray = jsonObject.getJSONObject("data");
                        String downloadurl = Jarray.getString("downloadurl");
                        String service_appversioncode = Jarray.getString("appversioncode");
                        String appversionsize = Jarray.getString("appversionsize");
                        SharedPreferences sharedPreferences = getSharedPreferences("android_data", Context.MODE_PRIVATE);
                        String local_appversioncode = sharedPreferences.getString("appversioncode", versioncode);
                        MyLog.d("server app version ", local_appversioncode, getApplicationContext());

                        ///1.判断本地库与服务器版本是否一致
                        ///2.判断本地库是否存在历史补丁文件，为了回滚历史补丁文件不删除,如果补丁不存在就从服务器下载
                        if (!local_appversioncode.equals(service_appversioncode)) {
                            File file = new File(getFilesDir().toString() + File.separator + "unzip" + File.separator + "applib_" + service_appversioncode);
                            if (!file.isFile()) {
                                ///1.如果服务器版本与本地不一致则下载fultter patch 件zip,注：rar包解压是收费的
                                ///2.zip名称是applib.zip 文件路径是data/data/files/applib.zip
                                ///3.对zip进行解压 applib.so的格式是 applib_1.0.1.so
                                ///4.下载成功后更新本地配置库
                                MyLog.d("patch loading...", file.getPath(), getApplicationContext());
                                okHttpUtil.getDownRequest(downloadurl, getApplicationContext(), sharedPreferences, service_appversioncode, Long.parseLong(appversionsize));
//                            Log.e(TAG, "patch loading.....");
                            } else {
//                            Log.e(TAG, "patch loaded");
                            }
                        } else {
                            MyLog.d("app version ", local_appversioncode.toString(), getApplicationContext());
//                        Log.e(TAG, "local: " + local_appversioncode.toString());
//                        Log.e(TAG, "server patch is the same as local patch ");
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });
//        FlutterMain.startInitialization(this);
    }

    private Activity mCurrentActivity = null;

    public Activity getCurrentActivity() {
        return mCurrentActivity;
    }

    public void setCurrentActivity(Activity mCurrentActivity) {
        this.mCurrentActivity = mCurrentActivity;
    }

    public String getCpuABI() {

        if (Build.VERSION.SDK_INT >= 21) {
            for (String cpu : Build.SUPPORTED_ABIS) {
                if (!TextUtils.isEmpty(cpu)) {
                    return cpu;
                }
            }
        } else {
            //return Build.CPU_ABI;
            return "";
        }

        return "";
    }

    /**
     * 获取当前app version name
     */
    public String getAppVersionName(Context context) {
        String appVersionName = "";
        try {
            PackageInfo packageInfo = context.getApplicationContext()
                    .getPackageManager()
                    .getPackageInfo(context.getPackageName(), 0);
            appVersionName = packageInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            Log.e("", e.getMessage());
        }
        return appVersionName;
    }

}