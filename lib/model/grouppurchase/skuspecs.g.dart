part of 'skuspecs.dart';


Skuspecs _$SkuspecsFromJson(Map<String, dynamic> json) {
  return Skuspecs(
      json['specsid'] as String,
      json['goodpriceid'] as String,
      json['spdata'] as String,
      (json['cost'] as num).toDouble(),
      json['pic'] != null ? json['pic']as String : '',
  );
}