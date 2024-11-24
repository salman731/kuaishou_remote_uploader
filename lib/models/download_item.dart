

import 'package:get/get.dart';

class DownloadItem
{
  String? name;

  String? downloadUrl;

  String streamTapeUrl;

  String? imageUrl;

  RxBool? isLoading;

  RxBool? isSelected;

  DownloadItem(this.name, this.downloadUrl,this.imageUrl,this.streamTapeUrl,this.isLoading,this.isSelected);
}