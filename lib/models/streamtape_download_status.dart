

import 'dart:typed_data';

import 'package:get/get.dart';

class StreamtapeDownloadStatus
{
  String? status;

  String? url;

  Uint8List? imageBytes;

  String? id;

  RxBool? isThumbnailUpdating;

  StreamtapeDownloadStatus({this.status,this.url,this.imageBytes,this.id,this.isThumbnailUpdating});

}