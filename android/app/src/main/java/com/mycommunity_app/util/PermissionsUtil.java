package util;

import android.app.Activity;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;

public class PermissionsUtil {

    private static final int REQUEST_EXTERNAL_STORAGE = 1 ;
    private static String[] PERMISSON_STORAGE = {"android.permission.READ_EXTERNAL_STORAGE",
            "android.permission.WRITE_EXTERNAL_STORAGE"};
    public static void verifyStoragePermissions(Activity activity){
        try {
            int permission = ActivityCompat.checkSelfPermission(activity, "android.permission.WRITE_EXTERNAL_STORAGE");
            if (permission != PackageManager.PERMISSION_GRANTED) {/**【判断是否已经授予权限】**/
                ActivityCompat.requestPermissions(activity, PERMISSON_STORAGE, REQUEST_EXTERNAL_STORAGE);
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }
}
