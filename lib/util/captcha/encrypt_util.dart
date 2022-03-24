
import 'dart:convert';

import 'package:steel_crypt/steel_crypt.dart';
//import 'package:encrypt/encrypt.dart';

class EncryptUtil {

  ///aes加密
  /// [key]AesCrypt加密key
  /// [content] 需要加密的内容字符串
  static String aesEncode({required String key, required String content}) {
    var encodekey = utf8.encode(key);
    var temsecretKey = base64Encode(encodekey);

    var aesEncrypter = AesCrypt(key: temsecretKey, padding: PaddingAES.pkcs7).ecb;
    return aesEncrypter.encrypt(inp: content);
  }

  ///aes解密
  /// [key]aes解密key
  /// [content] 需要加密的内容字符串
  static String aesDecode({required String key,required String content}) {
    var aesEncrypter = AesCrypt(key: key, padding: PaddingAES.pkcs7).ecb;
    return aesEncrypter.decrypt(enc: content);
  }





}