package util;


import android.content.Context;
import android.util.Log;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class MyLog {

    private static Boolean MYLOG_SWITCH = true; // 日志文件总开关
    private static Boolean MYLOG_WRITE_TO_FILE = true;// 日志写入文件开关
    private static char MYLOG_TYPE = 'v';// 输入日志类型，w代表只输出告警信息等，v代表输出所有信息
    private static String MYLOG_PATH_SDCARD_DIR = "/log";// 日志文件在sdcard中的路径
    private static int SDCARD_LOG_FILE_SAVE_DAYS = 5;// sd卡中日志文件的最多保存天数
    private static String MYLOGFILEName = "log.txt";// 本类输出的日志文件名称
    private static SimpleDateFormat myLogSdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");// 日志的输出格式
    private static SimpleDateFormat logfile = new SimpleDateFormat("yyyy-MM-dd");// 日志文件格式

    public static void w(String tag, Object msg, Context context) { // 警告信息
        log(tag, msg.toString(), 'w', context);
    }

    public static void e(String tag, Object msg, Context context) { // 错误信息
        log(tag, msg.toString(), 'e', context);
    }

    public static void d(String tag, Object msg, Context context) {// 调试信息
        log(tag, msg.toString(), 'd', context);
    }

    public static void i(String tag, Object msg, Context context) {//
        log(tag, msg.toString(), 'i', context);
    }

    public static void v(String tag, Object msg, Context context) {
        log(tag, msg.toString(), 'v', context);
    }

    public static void w(String tag, String text, Context context) {
        log(tag, text, 'w', context);
    }

    public static void e(String tag, String text, Context context) {
        log(tag, text, 'e', context);
    }

    public static void d(String tag, String text, Context context) {
        log(tag, text, 'd', context);
    }

    public static void i(String tag, String text, Context context) {
        log(tag, text, 'i', context);
    }

    public static void v(String tag, String text, Context context) {
        log(tag, text, 'v', context);
    }

    /**
     * 根据tag, msg和等级，输出日志
     * @param tag
     * @param msg
     * @param level
     */
    private static void log(String tag, String msg, char level, Context context) {
        if (MYLOG_SWITCH) {//日志文件总开关
            if ('e' == level && ('e' == MYLOG_TYPE || 'v' == MYLOG_TYPE)) { // 输出错误信息
                Log.e(tag, msg);
            } else if ('w' == level && ('w' == MYLOG_TYPE || 'v' == MYLOG_TYPE)) {
                Log.w(tag, msg);
            } else if ('d' == level && ('d' == MYLOG_TYPE || 'v' == MYLOG_TYPE)) {
                Log.d(tag, msg);
            } else if ('i' == level && ('d' == MYLOG_TYPE || 'v' == MYLOG_TYPE)) {
                Log.i(tag, msg);
            } else {
                Log.v(tag, msg);
            }
            if (MYLOG_WRITE_TO_FILE)//日志写入文件开关
                writeLogtoFile(String.valueOf(level), tag, msg, context);
        }
    }

    /**
     * 打开日志文件并写入日志
     * @param mylogtype
     * @param tag
     * @param text
     */
    private static void writeLogtoFile(String mylogtype, String tag, String text, Context context) {// 新建或打开日志文件
        Date nowtime = new Date();
        String needWriteFiel = logfile.format(nowtime);
        String needWriteMessage = myLogSdf.format(nowtime) + "    " + mylogtype + "    " + tag + "    " + text;
        File dirPath = context.getExternalFilesDir(MYLOG_PATH_SDCARD_DIR);


        if (!dirPath.exists()){
            dirPath.mkdirs();
        }
        //Log.i("创建文件","创建文件");
        File file = new File(dirPath.toString(), needWriteFiel + MYLOGFILEName);// MYLOG_PATH_SDCARD_DIR
        if (!file.exists()) {
            try {
                //在指定的文件夹中创建文件
                file.createNewFile();
            }
            catch (Exception e) {

            }
        }

        try {
            FileWriter filerWriter = new FileWriter(file, true);// 后面这个参数代表是不是要接上文件中原来的数据，不进行覆盖
            BufferedWriter bufWriter = new BufferedWriter(filerWriter);
            bufWriter.write(needWriteMessage);
            bufWriter.newLine();
            bufWriter.close();
            filerWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 删除制定的日志文件
     */
    public static void delFile(Context context) {// 删除日志文件
        String needDelFiel = logfile.format(getDateBefore());
        File dirPath = context.getExternalFilesDir(null);
        File file = new File(dirPath, needDelFiel + MYLOGFILEName);// MYLOG_PATH_SDCARD_DIR
        if (file.exists()) {
            file.delete();
        }
    }

    /**
     * 得到现在时间前的几天日期，用来得到需要删除的日志文件名
     */
    private static Date getDateBefore() {
        Date nowtime = new Date();
        Calendar now = Calendar.getInstance();
        now.setTime(nowtime);
        now.set(Calendar.DATE, now.get(Calendar.DATE) - SDCARD_LOG_FILE_SAVE_DAYS);
        return now.getTime();
    }
}