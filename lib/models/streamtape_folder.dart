

import 'package:json_annotation/json_annotation.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_file_item.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';

part 'streamtape_folder.g.dart';

@JsonSerializable()
class StreamTapeFolder
{
  List<StreamTapeFolderItem>? folders;

  List<StreamtapeFileItem>? files;

  StreamTapeFolder({this.folders,this.files});

  factory StreamTapeFolder.fromJson(Map<String, dynamic> json) => _$StreamTapeFolderFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$StreamTapeFolderToJson(this);
}