
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/dialogs/dialog_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:better_player/better_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPlayerDialog
{
  static late VideoPlayerController _controller;
  static Completer? videoCompleter;

  static showVideoPlayerDialog(BuildContext context,String url,{bool isToShowSlider = false}) async{

    DialogUtils.showLoaderDialog(context,text: "Loading Player".obs);
    videoCompleter = Completer();
    _controller =  VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((value){
        videoCompleter!.complete();
      });
    await videoCompleter!.future;
    Duration totalDuration = _controller.value.duration;
    RxDouble seekSliderValue = 1.0.obs;
    DialogUtils.stopLoaderDialog();
      AlertDialog alert=AlertDialog(
        content: Column(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            if(isToShowSlider)...[
              Obx(()=> Slider(
                value: seekSliderValue.value,
                max: totalDuration.inMinutes.toDouble(),
                min: 1,
                divisions: totalDuration.inMinutes,
                label: seekSliderValue.toInt().toString(),
                onChanged: (double value) {
                  seekSliderValue.value  = value.toInt().toDouble();
                },
                onChangeEnd: (value) async{
                  _controller.seekTo(Duration(minutes: value.toInt()));
                },
              ),
              ),
            ]
          ],
        ),);
      _controller.play();
      await showDialog(barrierDismissible: false,
        context:context,
        builder:(BuildContext context){
          return alert;
        },
      );

      await _controller.dispose();

  }

  static late BetterPlayerController _betterPlayerController;

  static showBetterPlayerDialog(BuildContext context, String url) async {

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 2000,
        maxBufferMs: 3000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        autoDispose: true,
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        autoDetectFullscreenAspectRatio: true,
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableFullscreen: true,
          enablePlaybackSpeed: true,
          controlBarColor: Colors.transparent,

        ),
      ),
      betterPlayerDataSource: dataSource,
    );



    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 9 / 16,
            child: BetterPlayer(controller: _betterPlayerController),
          ),
        ],
      ),
    );

    // AlertDialog alert1 = AlertDialog(
    //   content: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       VideoWithSeekPreview(videoUrl: url)
    //     ],
    //   ),
    // );

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    //_betterPlayerController.dispose();
  }
}




class VideoWithSeekPreview extends StatefulWidget {
  final String videoUrl;
  const VideoWithSeekPreview({super.key, required this.videoUrl});

  @override
  State<VideoWithSeekPreview> createState() => _VideoWithSeekPreviewState();
}

class _VideoWithSeekPreviewState extends State<VideoWithSeekPreview> {
  late BetterPlayerController _betterPlayerController;
  Timer? _thumbnailDebounce;
  Uint8List? _currentThumbnail;
  Duration _currentSeekPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 2000,
        maxBufferMs: 3000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
    );
    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        autoDispose: true,
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        autoDetectFullscreenAspectRatio: true,
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableFullscreen: true,
          enablePlaybackSpeed: true,
          controlBarColor: Colors.transparent,

        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    // Listen for position changes (simulate drag)
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
        _onSeekBarDrag(event.parameters!["duration"] as Duration);
      }
    });
  }

  void _onSeekBarDrag(Duration position) {
    _currentSeekPosition = position;
    _thumbnailDebounce?.cancel();
    _thumbnailDebounce = Timer(const Duration(milliseconds: 500), () async {
      final thumb = await VideoThumbnail.thumbnailData(
        video: widget.videoUrl,
        timeMs: position.inMilliseconds,
        quality: 75,
        imageFormat: ImageFormat.JPEG,
      );
      print("_onSeekBarDrag");
      if (mounted) {
        setState(() => _currentThumbnail = thumb);
      }
    });
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    _thumbnailDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(aspectRatio: 9/16,child: BetterPlayer(controller: _betterPlayerController)),

        // Thumbnail overlay
        if (_currentThumbnail != null)
          Positioned(
            bottom: 60,
            left: MediaQuery.of(context).size.width *
                (_currentSeekPosition.inMilliseconds /
                    (_betterPlayerController.videoPlayerController?.value.duration
                        ?.inMilliseconds ??
                        1)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                _currentThumbnail!,
                width: 120,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}
