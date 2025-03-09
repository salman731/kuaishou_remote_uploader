

import 'dart:typed_data';

import 'package:get/get.dart';

class DownloadItem
{
  String? name;

  String? downloadUrl;

  String streamTapeUrl;

  String? imageUrl;

  RxBool? isLoading;

  RxBool? isSelected;

  Uint8List? imageBytes;

  bool? isUrlImage = false;

  String? size;

  DownloadItem(this.name, this.downloadUrl,this.imageUrl,this.streamTapeUrl,this.isLoading,this.isSelected,this.imageBytes,this.isUrlImage,this.size);
}