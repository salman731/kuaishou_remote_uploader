

import 'package:json_annotation/json_annotation.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';

part 'streamtape_folder.g.dart';

@JsonSerializable()
class StreamTapeFolder
{
  List<StreamTapeFolderItem>? folders;

  StreamTapeFolder({this.folders});

  factory StreamTapeFolder.fromJson(Map<String, dynamic> json) => _$StreamTapeFolderFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$StreamTapeFolderToJson(this);
}