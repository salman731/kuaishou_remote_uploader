
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';

class WebViewUtils
{

   HeadlessInAppWebView? headlessWebView;
   String? resultUrl;
   Completer? videoLinkCompleter;
   String? finalUrl;
   Timer? timer;

  Future<String> getUrlWithWebView(String url,String urlExtension,{Map<String,String>? header,bool isBackground = false}) async
  {
    videoLinkCompleter = Completer();
    finalUrl = "";
    timer = Timer(Duration(seconds: 20),(){
      videoLinkCompleter!.complete();
    });
    //await CookieManager.instance().deleteAllCookies();
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url),headers: header),
      initialSize: Size(1366,768),

      onLoadStart: (controller,url) async {
        print(url!.rawValue!);
      },
      onLoadStop: (controller,url) async {
        if (isBackground && finalUrl!.isEmpty) {
          finalUrl = await controller.getHtml();
          timer!.cancel();
          videoLinkCompleter!.complete();
        }
        //Get.find<AppController>().showToast("onLoadStop " + url!.origin + url!.path,isDurationLong: true);
      },
      onConsoleMessage: (controller, consoleMessage) {
      },

      initialSettings: InAppWebViewSettings(isInspectable: false,useShouldInterceptRequest: !isBackground,useShouldOverrideUrlLoading: !isBackground,),
      shouldInterceptRequest: !isBackground ? (controller,request) async
        {
          Get.find<AppController>().logText  += "url: ${request.url.origin}\n";
          if(request.url.rawValue.contains(urlExtension))
            {
              if(finalUrl!.isEmpty)
                {
                  finalUrl = request.url.rawValue;
                  timer!.cancel();
                  videoLinkCompleter!.complete();
                }
            }
        } : null,

    );
    if(headlessWebView!.isRunning())
      {
        await headlessWebView!.dispose();
      }
    await headlessWebView!.run();
    await videoLinkCompleter!.future;
    return finalUrl!;
  }

  Future disposeWebView() async
  {
    await headlessWebView!.dispose();
  }
}