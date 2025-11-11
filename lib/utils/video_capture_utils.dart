

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';
import 'package:kuaishou_remote_uploader/miscellaneous/side_post_detector.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';

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

  Future<Uint8List?> getFirstFrame(String videoUrl) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      quality: 50,
      timeMs: 0, // First frame
    );
    return thumbnail;
  }

  // Stream<List<Uint8List>> bulkCaptureImageList(String url) async* {
  //   final directory = await getTemporaryDirectory();
  //   String outputPath = '${directory.path}/thumbnails/output_%04d.jpg';
  //   final myDir = Directory('${directory.path}/thumbnails');
  //
  //   if (!await myDir.exists()) {
  //     await myDir.create(recursive: true);
  //     print('Folder created: ${myDir.path}');
  //   }
  //
  //   // Make sure no old thumbnails remain
  //   for (var file in myDir.listSync()) {
  //     if (file.path.endsWith(".jpg") && file.path.contains("output_")) {
  //       await File(file.path).delete();
  //     }
  //   }
  //
  //   // Start FFmpeg asynchronously
  //   FFmpegKit.executeAsync(
  //     '-skip_frame nokey -i "$url" -vsync 0 -frame_pts 1 "$outputPath"',
  //   );
  //
  //   // Accumulated list
  //   List<Uint8List> images = [];
  //
  //   // Watch for new files
  //   await for (final event in myDir.watch(events: FileSystemEvent.create)) {
  //     if (event.path.endsWith(".jpg") && event.path.contains("output_")) {
  //       final file = File(event.path);
  //       if (await file.exists()) {
  //         final bytes = await file.readAsBytes();
  //         images.add(bytes);
  //         yield List<Uint8List>.from(images); // emit a copy of current list
  //         await file.delete();
  //       }
  //     }
  //   }
  // }

  final _controller = StreamController<List<(Uint8List,String)>>.broadcast();
  StreamSubscription<FileSystemEvent>? _watchSub;
  final List<(Uint8List,String)> _images = [];
  FFmpegSession? _ffmpegSession;
  // final _detector = SidePoseDetector();
  Map<String,bool> sidePoseMap = Map();

  Stream<List<(Uint8List,String)>> bulkCaptureImageList(String url) {
    _init(url);
    return _controller.stream;
  }

  Future<void> _init(String url) async {
    final directory = await getTemporaryDirectory();
    String outputPath = '${directory.path}/thumbnails/output_%04d.jpg';
    final myDir = Directory('${directory.path}/thumbnails');

    if (!await myDir.exists()) {
      await myDir.create(recursive: true);
      print('Folder created: ${myDir.path}');
    }

    // Delete old thumbnails
    for (var file in myDir.listSync()) {
      if (file.path.endsWith(".jpg") && file.path.contains("output_")) {
        await File(file.path).delete();
      }
    }

    // Start FFmpeg async
    /*FFmpegKit.executeAsync(
      '-skip_frame nokey -i "$url" -vsync 0 -frame_pts 1 "$outputPath"',
    );*/

    if (!SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_THUMBNAIL_WITH_INTERVAL)) {
      _ffmpegSession = await FFmpegSession.create(FFmpegKitConfig.parseArguments('-skip_frame nokey -i "$url" -vsync 0 -frame_pts 1 "$outputPath"'), null, null, null, null);
    } else {
      int interval = SharedPrefsUtil.getInt(SharedPrefsUtil.KEY_THUMBNAIL_INTERVAL);
      _ffmpegSession = await FFmpegSession.create(FFmpegKitConfig.parseArguments('-i "$url" -vf fps=1/${interval} "$outputPath"'), null, null, null, null);
    }



    FFmpegKitConfig.asyncFFmpegExecute(_ffmpegSession!);

    // FFmpegKit.executeAsync(
    //   '-skip_frame nokey -i "$url" -vsync 0 -frame_pts 1 "$outputPath"', (session) {
    //     _ffmpegSession = session;
    //     print('FFmpeg started');
    //   },
    // );

    // Watch directory
    _watchSub = myDir.watch(events: FileSystemEvent.create).listen((event) async {
      if (event.path.endsWith(".jpg") && event.path.contains("output_")) {
        print("event occured");
        final file = File(event.path);
        await Future.delayed(const Duration(seconds: 1));
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // bool result = false;
          //
          // try {
          //   result = await _detector.isSidePose(file);
          // } catch (e) {
          //   print("Pose detection error: $e");
          // }
          //
          // sidePoseMap[p.basenameWithoutExtension(event.path)] = result;
          // print(sidePoseMap.toString());
          _images.add((bytes,event.path));
          _controller.add(List<(Uint8List,String)>.from(_images)); // emit copy
          //await file.delete();
        }
      }
    });
  }


  Future<void> dispose() async {
    _watchSub?.cancel();
    _controller.close();
   // _detector.close();
    // Cancel FFmpeg
    if (_ffmpegSession != null) {
      FFmpegKit.cancel(_ffmpegSession!.getSessionId());
      print('FFmpeg cancelled');
    }
    final directory = await getTemporaryDirectory();
    final myDir = Directory('${directory.path}/thumbnails');
    for (var file in myDir.listSync()) {
      if (file.path.endsWith(".jpg") && file.path.contains("output_")) {
        await File(file.path).delete();
      }
    }

  }

  }