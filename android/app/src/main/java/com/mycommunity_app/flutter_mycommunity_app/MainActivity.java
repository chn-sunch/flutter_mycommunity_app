package com.mycommunity_app.flutter_mycommunity_app;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import androidx.annotation.NonNull;
import android.util.Log;
import android.os.Bundle;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.plugins.GeneratedPluginRegistrant;
import util.MyLog;
import java.io.File;
import java.io.IOException;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.view.WindowManager;
import android.view.Window;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import com.jarvan.fluwx.handlers.FluwxRequestHandler;
import com.jarvan.fluwx.handlers.WXAPiHandler;

//import com.umeng.analytics.MobclickAgent;
//import com.umeng.commonsdk.UMConfigure;

public class MainActivity extends FlutterActivity {
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
//    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
//        this.registrarFor("name.avioli.unilinks.UniLinksPlugin");
//        UniLinksPlugin.registerWith(null);
//        UniLinksPlugin.registerWith(this.registrarFor("name.avioli.unilinks.UniLinksPlugin"));
//        UMConfigure.preInit(this,"6191c2daba403559f31a97db","Umeng");

        //If you didn't configure WxAPI, add the following code
        //If you didn't configure WxAPI, add the following code
        WXAPiHandler.setupWxApi("wx08bd2f7c9a87beee",this, true);
        Intent intent = new Intent(this, MainActivity.class);
        FluwxRequestHandler.handleRequestInfoFromIntent(intent);
        // 上面添加编译不通过需要给fluwx_no_pay增加 @JvmStatic
        //E:\flutter\.pub-cache\hosted\pub.flutter-io.cn\fluwx_no_pay-3.8.1\android\src\main\kotlin\com\jarvan\fluwx\wxapi\FluwxRequestHandler.kt
        //E:\flutter\.pub-cache\hosted\pub.flutter-io.cn\fluwx_no_pay-3.8.1\android\src\main\kotlin\com\jarvan\fluwx\handlers\WXAPiHandler.kt
        //@JvmStatic
        //    fun setupWxApi(appId: String, context: Context, force: Boolean = true): Boolean {
        //        if (force || !registered) {


        //@JvmStatic
        //    fun handleRequestInfoFromIntent(intent: Intent) {
        //        intent.getBundleExtra(KEY_FLUWX_REQUEST_INFO_BUNDLE)?.run {

    }


}
