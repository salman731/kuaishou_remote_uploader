

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoCaptureUtils
{
  Future<Uint8List?> captureImage(String url,int seekPosition) async {
    Uint8List imageBytes = Uint8List.fromList([]);
    final directory = await getTemporaryDirectory();
    final String outputPath = '${directory.path}/${Random().nextInt(10000000)}.jpg';

    String command = '-i $url -ss ${seekPosition / 1000} -vframes 1 $outputPath';

    FFmpegSession session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();


    if (ReturnCode.isSuccess(returnCode)) {
      File outputFile = File(outputPath);
      imageBytes = await outputFile.readAsBytes();
      if(await outputFile.exists())
      {
        await outputFile.delete();
      }
      return imageBytes;
    } else {
      return null;
    }
  }
}