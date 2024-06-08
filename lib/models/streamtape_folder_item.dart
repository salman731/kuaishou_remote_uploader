
import 'package:json_annotation/json_annotation.dart';

part 'streamtape_folder_item.g.dart';

@JsonSerializable()
class StreamTapeFolderItem
{
  String? id;

  String? name;

  StreamTapeFolderItem({this.id, this.name});

  factory StreamTapeFolderItem.fromJson(Map<String, dynamic> json) => _$StreamTapeFolderItemFromJson(json);

  Map<String, dynamic> toJson() => _$StreamTapeFolderItemToJson(this);
}