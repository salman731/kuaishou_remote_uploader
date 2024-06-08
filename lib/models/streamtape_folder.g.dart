// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streamtape_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamTapeFolder _$StreamTapeFolderFromJson(Map<String, dynamic> json) =>
    StreamTapeFolder(
      folders: (json['folders'] as List<dynamic>?)
          ?.map((e) => StreamTapeFolderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StreamTapeFolderToJson(StreamTapeFolder instance) =>
    <String, dynamic>{
      'folders': instance.folders,
    };
