
import 'package:json_annotation/json_annotation.dart';


part 'streamtape_file_item.g.dart';

@JsonSerializable()
class StreamtapeFileItem
{
  String? convert;
  int? created_at;
  int? downloads;
  String? link;
  String? linkid;
  String? name;
  int? size;

  StreamtapeFileItem(
      {this.convert,
      this.created_at,
      this.downloads,
      this.link,
      this.linkid,
      this.name,
      this.size});

  factory StreamtapeFileItem.fromJson(Map<String, dynamic> json) => _$StreamtapeFileItemFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$StreamtapeFileItemToJson(this);

}