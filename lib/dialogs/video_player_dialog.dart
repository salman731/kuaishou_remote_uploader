
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/dialogs/dialog_utils.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerDialog
{
  static late VideoPlayerController _controller;
  static Completer? videoCompleter;

  static showLoaderDialog(BuildContext context,String url,{bool isToShowSlider = false}) async{

    DialogUtils.showLoaderDialog(context,text: "Loading Player");
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
}