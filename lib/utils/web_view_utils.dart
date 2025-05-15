
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:restart/restart.dart';
class WebViewUtils
{

   HeadlessInAppWebView? headlessWebView;
   InAppWebView? WebView;
   String? resultUrl;
   Completer? videoLinkCompleter;
   String? finalUrl;
   Timer? timer;
   late InAppWebViewController inAppWebViewController;
   late InAppWebViewController inAppWebViewController2;

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

   Future<bool> showWebViewDialog(String urlo,String urlExtension,{String? userAgent,Map<String,String>? header,bool isBackground = false,bool isDesktop = false,bool isToGetFollowApi = false,bool isAuto = false,bool incognito = true}) async
   {
     AppController.isVerifyCaptchaShowing = true;
     videoLinkCompleter = Completer();
     finalUrl = "";
     bool isCaptchaOccured = false;
     timer = Timer(Duration(seconds: 40),(){
       videoLinkCompleter!.complete();
     });
     WebView = InAppWebView(
       initialUrlRequest: URLRequest(url: WebUri(urlo),headers: header),
       onWebViewCreated: (controller){
         inAppWebViewController2 = controller;
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
       initialSettings: InAppWebViewSettings(isInspectable: false,useShouldInterceptRequest: !isBackground,useShouldOverrideUrlLoading: !isBackground,preferredContentMode: isDesktop ? UserPreferredContentMode.DESKTOP : UserPreferredContentMode.MOBILE,incognito: incognito,userAgent: isDesktop ?  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36" : userAgent ?? ""),
       shouldInterceptRequest: !isBackground ? (controller,request) async
       {
         request.headers = header;
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
         if(navigation.request.url!.origin.contains("captcha.zt.kuaishou.com"))
           {
             isCaptchaOccured = true;
           }
         return NavigationActionPolicy.ALLOW;
       },

     );
     AlertDialog alert=AlertDialog(
       content: WebView,
       actions: [
         IconButton(onPressed: () async {
           var result = await inAppWebViewController2.evaluateJavascript(source: "document.cookie");
           Clipboard.setData(ClipboardData(text: result.toString()));
           ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('Cookie Copied to clipboard!!!!!!')));
       }, icon: Icon(Icons.copy)),
         IconButton(onPressed: () async {
           String url = await Get.find<AppController>().getRandomLiveUserUrl();
           await inAppWebViewController2.loadUrl(urlRequest: URLRequest(url: WebUri(url),headers: header));
         }, icon: Icon(Icons.refresh_sharp)),
         IconButton(onPressed: () async {
           if (!isToGetFollowApi) {
             var result = await inAppWebViewController2.evaluateJavascript(source: "document.cookie");
           //String cookie = result.toString().split(";").where((cookie)=>cookie.contains("did")).first;
             SharedPrefsUtil.setString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE, result.toString());
             SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, false);
             Get.back();
           } else {
             List<Cookie> cookies = await CookieManager.instance().getCookies(url: WebUri("https://live.kuaishou.com"));
             String Cookies = cookies.map((cookie) => '${cookie.name}=${cookie.value}').toList().join(";");
             SharedPrefsUtil.setString(SharedPrefsUtil.KEY_FOLLOW_LIVE_COOKIE, Cookies);
             Fluttertoast.showToast(
                 msg: Cookies,
                 toastLength: Toast.LENGTH_LONG,
                 gravity: ToastGravity.BOTTOM,
                 timeInSecForIosWeb: 1,
                 backgroundColor: Colors.blue,
                 textColor: Colors.white,
                 fontSize: 16.0
             );
             Get.back();
           }
           await restart();
         }, icon: Icon(Icons.add)),

       ],
     );
     if (!isAuto) {
       await showDialog(context: Get.context!, builder: (_){
              return alert;
            });
     }
     else
       {
         showDialog(context: Get.context!, builder: (_){
           return alert;
         });
         await Future.delayed(Duration(seconds: 35));
       }
     AppController.isVerifyCaptchaShowing = false;
     return isCaptchaOccured;
   }

   /*Future<bool> showWebViewFlutterDialog(String urlo,String urlExtension,{String? userAgent,Map<String,String>? header,bool isBackground = false,bool isDesktop = false,bool isToGetFollowApi = false,bool isAuto = false,bool incognito = true}) async
   {
     AppController.isVerifyCaptchaShowing = true;
     bool isCaptchaOccured = false;
     late final PlatformWebViewControllerCreationParams params;
     if (WebViewPlatform.instance is WebKitWebViewPlatform) {
       params = WebKitWebViewControllerCreationParams(
         allowsInlineMediaPlayback: true,
         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
       );
     } else {
       params = const PlatformWebViewControllerCreationParams();
     }

     final WebViewController controller =
     WebViewController.fromPlatformCreationParams(params);
     // #enddocregion platform_features

     controller
       ..setUserAgent(userAgent)
       ..setJavaScriptMode(JavaScriptMode.unrestricted)
       ..setNavigationDelegate(
         NavigationDelegate(
           onProgress: (int progress) {
             debugPrint('WebView is loading (progress : $progress%)');
           },
           onPageStarted: (String url) {
             debugPrint('Page started loading: $url');
           },
           onPageFinished: (String url) {
             debugPrint('Page finished loading: $url');
           },
           onNavigationRequest: (NavigationRequest request) {
             if(request.url!.contains("captcha.zt.kuaishou.com"))
             {
               isCaptchaOccured = true;
             }
             return NavigationDecision.navigate;
           },
           onHttpError: (HttpResponseError error) {
             debugPrint('Error occurred on page: ${error.response?.statusCode}');
           },
           onUrlChange: (UrlChange change) {
             debugPrint('url change to ${change.url}');
           },
           onHttpAuthRequest: (HttpAuthRequest request) {

           },
         ),
       )
       ..addJavaScriptChannel(
         'Toaster',
         onMessageReceived: (JavaScriptMessage message) {
           print(message.message);
         },
       )
       ..loadRequest(Uri.parse(urlo),headers: header ?? {});



     // setBackgroundColor is not currently supported on macOS.
     if (kIsWeb || !Platform.isMacOS) {
       controller.setBackgroundColor(const Color(0x80000000));
     }

     // #docregion platform_features
     if (controller.platform is AndroidWebViewController) {
       AndroidWebViewController.enableDebugging(true);
       (controller.platform as AndroidWebViewController)
           .setMediaPlaybackRequiresUserGesture(false);
     }
     // #enddocregion platform_features

     webViewFlutterController = controller;
     AlertDialog alert=AlertDialog(
       content: WebViewWidget(controller: webViewFlutterController!),
       actions: [
         IconButton(onPressed: () async {
           if (!isToGetFollowApi) {
             var result = await webViewFlutterController!.runJavaScriptReturningResult("document.cookie");
             // String cookie = result.toString().split(";").where((cookie)=>cookie.contains("did")).first;
             SharedPrefsUtil.setString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE, result.toString());
             SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, false);
             Get.back();
           } else {
             // List<Cookie> cookies = await CookieManager.instance().getCookies(url: WebUri("https://live.kuaishou.com"));
             // String Cookies = cookies.map((cookie) => '${cookie.name}=${cookie.value}').toList().join(";");
             // SharedPrefsUtil.setString(SharedPrefsUtil.KEY_FOLLOW_LIVE_COOKIE, Cookies);
             // Fluttertoast.showToast(
             //     msg: Cookies,
             //     toastLength: Toast.LENGTH_LONG,
             //     gravity: ToastGravity.BOTTOM,
             //     timeInSecForIosWeb: 1,
             //     backgroundColor: Colors.blue,
             //     textColor: Colors.white,
             //     fontSize: 16.0
             // );
             // Get.back();
           }
           await restart();
         }, icon: Icon(Icons.add))
       ],
     );
     if (!isAuto) {
       await showDialog(context: Get.context!, builder: (_){
         return alert;
       });
     }
     else
     {
       showDialog(context: Get.context!, builder: (_){
         return alert;
       });
       await Future.delayed(Duration(seconds: 35));

     }
     AppController.isVerifyCaptchaShowing = false;
     return isCaptchaOccured;
   }*/

  Future disposeWebView() async
  {
    await headlessWebView!.dispose();
  }
}