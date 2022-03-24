//package com.mycommunity_app.flutter_mycommunity_app;
//
//import android.app.Activity;
//import android.content.Intent;
//import android.os.Build;
//import android.os.Bundle;
//import android.os.Handler;
//import androidx.annotation.Nullable;
//
//public class SplashActivity extends Activity{
//    Handler handler = new Handler();
//
//    @Override
//    protected void onCreate(@Nullable Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
////        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
//
//        handler.postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                Intent intent = new Intent(SplashActivity.this, MainActivity.class);
//                startActivity(intent);
//                finish();
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ECLAIR) {
//                    overridePendingTransition(0,0 );
//                }
//            }
//        }, 100);
//    }
//}
