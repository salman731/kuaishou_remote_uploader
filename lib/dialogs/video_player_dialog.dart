
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/dialogs/loader_dialog.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerDialog
{
  static late VideoPlayerController _controller;
  static Completer? videoCompleter;

  static showLoaderDialog(BuildContext context,String url) async{

    LoaderDialog.showLoaderDialog(context,text: "Loading Player");
    videoCompleter = Completer();
    _controller =  VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((value){
        videoCompleter!.complete();
      });
    await videoCompleter!.future;
    LoaderDialog.stopLoaderDialog();
      AlertDialog alert=AlertDialog(
        content: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
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