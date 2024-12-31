
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';

class WebViewUtils
{

   HeadlessInAppWebView? headlessWebView;
   InAppWebView? WebView;
   String? resultUrl;
   Completer? videoLinkCompleter;
   String? finalUrl;
   Timer? timer;
   late InAppWebViewController inAppWebViewController;

  Future<String> getUrlWithWebView(String urlo,String urlExtension,{Map<String,String>? header,bool isBackground = false}) async
  {
    videoLinkCompleter = Completer();
    finalUrl = "";
    timer = Timer(Duration(seconds: 40),(){
      videoLinkCompleter!.complete();
    });
    //await CookieManager.instance().deleteAllCookies();
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(urlo),headers: header),
      initialSize: Size(1366,768),
      onWebViewCreated:(controller)
      {
        inAppWebViewController = controller;
      },
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

      initialSettings: InAppWebViewSettings(isInspectable: false,useShouldInterceptRequest: !isBackground,useShouldOverrideUrlLoading: !isBackground,preferredContentMode: UserPreferredContentMode.MOBILE,incognito: true),
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

   Future<void> showWebViewDialog(String urlo,String urlExtension,{Map<String,String>? header,bool isBackground = false}) async
   {
     videoLinkCompleter = Completer();
     finalUrl = "";
     timer = Timer(Duration(seconds: 40),(){
       videoLinkCompleter!.complete();
     });
     WebView = InAppWebView(
       initialUrlRequest: URLRequest(url: WebUri(urlo),headers: header),
       onWebViewCreated: (controller){
         inAppWebViewController = controller;
       },
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

       initialSettings: InAppWebViewSettings(isInspectable: false,useShouldInterceptRequest: !isBackground,useShouldOverrideUrlLoading: !isBackground,preferredContentMode: UserPreferredContentMode.MOBILE,incognito: true,/*userAgent: "Mozilla/5.0 (Linux; Android 14; SM-A536B Build/UP1A.231005.007; wv) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.231 Mobile Safari/537.36	"*/),
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
       shouldOverrideUrlLoading: (controller,navigation) async {
         return NavigationActionPolicy.ALLOW;
       },

     );
     AlertDialog alert=AlertDialog(
       content: WebView,
       actions: [
         IconButton(onPressed: () async {
           var result = await inAppWebViewController.evaluateJavascript(source: "document.cookie");
           SharedPrefsUtil.setString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE, result.toString().split(";")[0]);
           SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, false);
           Get.back();
         }, icon: Icon(Icons.add))
       ],
     );
     await showDialog(context: Get.context!, builder: (_){
       return alert;
     });
     //return finalUrl!;
   }
  Future disposeWebView() async
  {
    await headlessWebView!.dispose();
  }
}