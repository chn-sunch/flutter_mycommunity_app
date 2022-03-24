package util;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import android.util.Log;
import okhttp3.*;

import static android.content.Context.MODE_PRIVATE;

/**
 * author: Wanderer
 * date:   2018/1/9 16:38
 * email:  none
 */

public class OkHttpUtil {
    private final String TAG = "OkHttpDownUtil";

    private OkHttpClient okHttpClient;

    public OkHttpClient getInstance() {
        if(okHttpClient == null){
            // 设置缓存目录
            File okHttPCache = new File(Environment.getDownloadCacheDirectory(), "cache");
            // 设置缓存大小
            int cacheSize = 10*1024*1024;

            synchronized (OkHttpUtil.class){
                okHttpClient = new OkHttpClient.Builder() // 构建者
                        .connectTimeout(15, TimeUnit.SECONDS) // 连接超时
                        .readTimeout(15,TimeUnit.SECONDS)     // 读取超时
                        .writeTimeout(15,TimeUnit.SECONDS)    // 写入超时
                        .cache(new Cache(okHttPCache.getAbsoluteFile(),cacheSize)) // 设置缓存
                        .build(); // 闭环
            }
        }
        return okHttpClient;
    }

    /**
     * get请求
     */

    public void doGet(String url, Callback callback){
        // 获取OkHttpClient对象
        OkHttpClient mHttpClient = getInstance();
        // 获取Request对象
        Request request = new Request.Builder().url(url).build();
        // 获取Call对象
        Call call = mHttpClient.newCall(request);
        // 执行异步请求
        call.enqueue(callback);
    }

    /**
     * post请求
     */
    public void doPost(String url, Map<String,String> parameters,Callback callback){
        // 获取OkHttpClient对象
        OkHttpClient mHttpClient = getInstance();
        // 获取构建者
        FormBody.Builder builder = new FormBody.Builder();
        // 遍历集合
        for (String key: parameters.keySet()) {
            // 添加上传的参数
            builder.add(key,parameters.get(key));
        }
        // 获取Request对象
        Request request = new Request.Builder().url(url).post(builder.build()).build();
        // 获取Call
        Call call = mHttpClient.newCall(request);
        // 执行请求
        call.enqueue(callback);
    }

    //下载
    public void getDownRequest(final String downUrl, final Context context, final  SharedPreferences sharedPreferences,
                               final String service_appversioncode, final long filesize) {
        OkHttpClient mHttpClient = getInstance();

        Request request = new Request.Builder()
                .url(downUrl)
                .get()
                .build();
        Call mCall = mHttpClient.newCall(request);//构建了一个完整的http请求
        mCall.enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {

            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                ResponseBody responseBody = response.body();
                long mAlreadyDownLength = 0;//已经下载长度
                long mTotalLength = responseBody.contentLength();//下载文件的总长度
                InputStream inp = responseBody.byteStream();
                if(filesize != mTotalLength)
                    return;

                context.deleteFile("applib.zip");
                FileOutputStream fileOutputStream = context.openFileOutput("applib.zip", MODE_PRIVATE);
                try {
                    byte[] bytes = new byte[2048];
                    int len = 0;
                    while ((len = inp.read(bytes)) != -1) {
                        mAlreadyDownLength = mAlreadyDownLength + len;
                        fileOutputStream.write(bytes, 0, len);
                    }

                    if(mTotalLength > 10 && (mAlreadyDownLength == mTotalLength)) {
                        ZipUtils.UnZipFolder(context.getFileStreamPath("applib.zip").getPath(), context.getFilesDir().toString() + File.separator + "unzip");
                        //更新本地配置文件
                        SharedPreferences.Editor editor = sharedPreferences.edit();
                        editor.clear();
                        editor.commit();
                        editor.putString("appversioncode", service_appversioncode);
                        editor.commit();
                    }
                } catch (Exception e) {
                    Log.e(TAG, e.toString());

                } finally {
//                    fileOutputStream.close();
                    inp.close();
                }
            }
        });
    }
}
