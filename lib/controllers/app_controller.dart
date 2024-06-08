
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:kuaishou_remote_uploader/dialogs/loader_dialog.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/utils/web_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_view_utils.dart';


class AppController extends GetxController
{
  String streamTapeUserName = "salmanilyas731@gmail.com";
  String streamTapePassword = "internet50";

  String STREAMTAPE_URL = "https://streamtape.com/";
  String STREAMTAPE_FILE_API_URL = "https://streamtape.com/api/website/filemanager/file/get";
  String STREAMTAPE_REMOTE_UPLOAD_API_URL = "https://streamtape.com/api/website/remotedl/put";

  HeadlessInAppWebView? headlessInAppWebView;
  InAppWebViewController? inAppWebViewController;
  late String currentCookie;
  late String crfToken;
  late Rx<StreamTapeFolderItem> selectedFolder = StreamTapeFolderItem().obs;
  TextEditingController urlTextEditingController = TextEditingController();

  Completer? loadCompleter;

  Future<void> loginToStreamTape() async
  {
    //CookieManager.instance().deleteAllCookies();
    loadCompleter = Completer();
    headlessInAppWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(STREAMTAPE_URL)),
      initialSize: Size(1366,768),
      initialSettings: InAppWebViewSettings(isInspectable: false,useShouldInterceptRequest: true,useShouldOverrideUrlLoading: true),
      onWebViewCreated: (controller)
      {
        inAppWebViewController = controller;
      },
      onLoadStart: (controller, url) async {
        LoaderDialog.showLoaderDialog(Get.context!,text: "Getting Login Info.....");
      },
     /* shouldInterceptRequest: (controller,request) async
      {
        if(request.url.rawValue.contains("https://streamtape.com/accpanel"))
        {
          request!.headers!["cookie"];

        }
      },
      shouldOverrideUrlLoading: (controller,request) async
      {
        if(request.request.url!.rawValue.contains("https://streamtape.com/accpanel"))
        {
          request!;

        }
      },*/
      onLoadStop: (controller, url) async {
        String? html = await inAppWebViewController!.getHtml();
        dom.Document document = WebUtils.getDomfromHtml(html!);
        String loginTxt = document.querySelector('.navbar-nav li:nth-child(3) a')!.text;
        // Code to get cookie on request of url
        if(loginTxt == "Account Panel")
          {
            crfToken = document.querySelector("meta[name=\"csrf-token\"]")!.attributes["content"]!;
            List<Cookie> cookieslist = await CookieManager.instance().getCookies(url: url!);
            List<String> cookieList = [];
            for (final val in cookieslist!) {

              cookieList.add('${val.name}=${val.value}');

            }
            currentCookie = cookieList.join(';');
            LoaderDialog.stopLoaderDialog();
            loadCompleter!.complete();
          }
        // Click on login or account panel
        if((loginTxt == "Account Panel" || loginTxt == "Login") && url!.rawValue == STREAMTAPE_URL)
          {
            await inAppWebViewController!.evaluateJavascript(source: ""
                "var clickEvent = new MouseEvent(\"click\", {\"view\": window,\"bubbles\": true,\"cancelable\": false});"
                "var element = document.querySelector('.navbar-nav li:nth-child(2) a');"
                "element.dispatchEvent(clickEvent);");
            return;

          }


        // login script
        if(url!.rawValue == STREAMTAPE_URL+"login")
          {
            dom.Element? formElement = document.querySelector("#w0");
            if(formElement != null)
            {
              await inAppWebViewController!.evaluateJavascript(source: ""
                  "document.querySelector(\"input[type=email]\").value = \"${streamTapeUserName}\";"
                  "document.querySelector(\"input[type=password]\").value = \"${streamTapePassword}\";"
                  "const form = document.querySelector(\"#w0\");"
                  "form.submit();" );
            }
          }


      },
    );
    await headlessInAppWebView!.run();
  }


  Future<StreamTapeFolder> getFolderList () async
  {
    await loadCompleter!.future;
    StreamTapeFolder streamTapeFolder;
    var bodyMap = {"id":"0","_csrf":crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_FILE_API_URL,bodyMap,headers: {"Cookie":currentCookie});
    streamTapeFolder = StreamTapeFolder.fromJson(jsonDecode(respose));
    selectedFolder.value = streamTapeFolder.folders!.first;
    return streamTapeFolder;
    //return streamTapeFolder;
  }

  Future<bool> remoteUploadStreamTape (String url,String folder) async
  {
    try {
      var bodyMap = {"links":url,"headers":"","folder":folder,"_csrf":crfToken};
      String? response = await WebUtils.makePostRequest(STREAMTAPE_REMOTE_UPLOAD_API_URL, bodyMap,headers: {"Cookie":currentCookie});
      Map<String,dynamic> json = jsonDecode(response);
      return json["statusCode"] == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> getFlvUrlfromKuaihsouLink (String kuaishouLink) async
  {
    String? orginalUrl = await WebUtils.getOriginalUrl(kuaishouLink);
    String flvurl = await WebViewUtils().getUrlWithWebView(orginalUrl!, ".flv");
    return flvurl;
  }

  Future startUploading (String links) async
  {
    LoaderDialog.showLoaderDialog(Get.context!,text: "Uploading......");
    List<String> urls = links.split("\n");

    for (String url in urls)
      {
         String? flvUrl = await getFlvUrlfromKuaihsouLink(url);
         await remoteUploadStreamTape(flvUrl!, selectedFolder.value.id!);
      }

    LoaderDialog.stopLoaderDialog();
  }

}