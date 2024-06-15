
import 'dart:async';
import 'dart:ui';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewUtils
{

   HeadlessInAppWebView? headlessWebView;
   String? resultUrl;
   Completer? videoLinkCompleter;
   String? finalUrl;
   Timer? timer;

  Future<String> getUrlWithWebView(String url,String urlExtension,{Map<String,String>? header}) async
  {
    videoLinkCompleter = Completer();
    finalUrl = "";
    timer = Timer(Duration(seconds: 20),(){
      videoLinkCompleter!.complete();
    });
    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url),headers: header),
      initialSize: Size(1366,768),
      initialSettings: InAppWebViewSettings(isInspectable: false,useShouldInterceptRequest: true,useShouldOverrideUrlLoading: true,/*userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"*/),
      shouldInterceptRequest: (controller,request) async
        {
          if(request.url.rawValue.contains(urlExtension))
            {
              if(finalUrl!.isEmpty)
                {
                  finalUrl = request.url.rawValue;
                  timer!.cancel();
                  videoLinkCompleter!.complete();
                }
            }
        },

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