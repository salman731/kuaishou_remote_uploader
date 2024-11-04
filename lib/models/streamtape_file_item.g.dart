// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streamtape_file_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamtapeFileItem _$StreamtapeFileItemFromJson(Map<String, dynamic> json) =>
    StreamtapeFileItem(
      convert: json['convert'] as String?,
      created_at: (json['created_at'] as num?)?.toInt(),
      downloads: (json['downloads'] as num?)?.toInt(),
      link: json['link'] as String?,
      linkid: json['linkid'] as String?,
      name: json['name'] as String?,
      size: (json['size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StreamtapeFileItemToJson(StreamtapeFileItem instance) =>
    <String, dynamic>{
      'convert': instance.convert,
      'created_at': instance.created_at,
      'downloads': instance.downloads,
      'link': instance.link,
      'linkid': instance.linkid,
      'name': instance.name,
      'size': instance.size,
    };
