import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionUtil{
  //请求定位权限
  static Future<bool> reqestLocation() async {
    SharedPreferences _locationPermission = await SharedPreferences.getInstance();
    Object? locationstatus = _locationPermission.get("locationPermission");
    if(locationstatus != null){
      if(locationstatus.toString() == "1"){
        //检查当前是否还有权限
        return await requestLocationPermisson();
      }

      if(locationstatus.toString() == "0"){
        return false;
      }
    }
    else{
      final Map<Permission, PermissionStatus> statuses = await [Permission.location].request();
      if (statuses[Permission.location] == PermissionStatus.granted){
        _locationPermission.setString("locationPermission", "1");
        return true;
      }
      else if(statuses[Permission.location] == PermissionStatus.denied){
        _locationPermission.setString("locationPermission", "0");
        return false;
      }
      else{
        _locationPermission.setString("locationPermission", "0");
        return false;
      }
    }

    return false;
  }

  //请求存储权限
  static Future<bool> reqestStorage() async {
    SharedPreferences _storagePermission = await SharedPreferences.getInstance();
    Object? storagestatus = _storagePermission.get("storagePermission");
    if(storagestatus != null){
      if(storagestatus.toString() == "1"){
        return await requestStoragePermisson();
      }

      if(storagestatus.toString() == "0"){
        return false;
      }
    }
    else{
      final Map<Permission, PermissionStatus> statuses = await [Permission.storage].request();
      if (statuses[Permission.storage] == PermissionStatus.granted){
        _storagePermission.setString("storagePermission", "1");
        return true;
      }
      else if(statuses[Permission.location] == PermissionStatus.denied){
        _storagePermission.setString("storagePermission", "0");
        return false;
      }
      else{
        _storagePermission.setString("storagePermission", "0");
        return false;
      }
    }

    return false;
  }

  //每次都检查是否有权限
  static Future<bool> requestLocationPermisson() async {
    var status = await Permission.location.status;
    if(status.isDenied || status.isPermanentlyDenied){
      var retStatus = Permission.location.request();
      if(await retStatus.isGranted){
        return true;
      }

      if(await retStatus.isDenied){
        return false;
      }
    }

    return true;
  }

  //每次都检查一下是否有存储权限
  static Future<bool> requestStoragePermisson() async {
    var status = await Permission.storage.status;
    if(status.isDenied || status.isPermanentlyDenied){
      var retStatus = Permission.storage.request();
      if(await retStatus.isGranted){
        return true;
      }

      if(await retStatus.isDenied){
        return false;
      }
    }

    return true;
  }

}