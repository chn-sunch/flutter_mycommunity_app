
import 'package:json_annotation/json_annotation.dart';
part 'securitytoken.g.dart';

@JsonSerializable()
class SecurityToken{

  String ossAccessKeyId = "";
  String policy = "";
  String signature = "";
  String dir = "";
  String host = "";
  String expire = "";



  SecurityToken(this.ossAccessKeyId, this.policy, this.signature, this.dir, this.host, this.expire);
}