
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:kuaishou_remote_uploader/dialogs/loader_dialog.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_download_status.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_view_utils.dart';


class AppController extends GetxController
{
  String streamTapeUserName = "salmanilyas731@gmail.com";
  String streamTapePassword = "internet50";

  String STREAMTAPE_URL = "https://streamtape.com/";
  String STREAMTAPE_FILE_API_URL = "https://streamtape.com/api/website/filemanager/file/get";
  String STREAMTAPE_REMOTE_UPLOAD_API_URL = "https://streamtape.com/api/website/remotedl/put";
  String STREAMTAPE_DOWNLOADING_STATUS_API_URL = "https://streamtape.com/api/website/remotedl/get";

  HeadlessInAppWebView? headlessInAppWebView;
  InAppWebViewController? inAppWebViewController;
  late String currentCookie;
  late String crfToken;
  late Rx<StreamTapeFolderItem> selectedFolder = StreamTapeFolderItem().obs;
  TextEditingController urlTextEditingController = TextEditingController();

  RxBool isLoading = true.obs;

  StreamTapeFolder? streamTapeFolder;
  List<StreamtapeDownloadStatus> downloadingList = [];
  Timer? downloadUpdatingTimer;
  bool isDownloadStatusUpdating = false;

  initTimer()
  {
    downloadUpdatingTimer = Timer.periodic(Duration(seconds: 20), (timer) async {
      if (!isDownloadStatusUpdating) {
        await getDownloadingVideoStatus(isUpdateList: true);
      }
    });
  }

  Future<void> loginToStreamTape() async
  {
    //CookieManager.instance().deleteAllCookies();
    await SharedPrefsUtil.initSharedPreference();
    headlessInAppWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(STREAMTAPE_URL)),
      initialSize: Size(1366,768),
      initialSettings: InAppWebViewSettings(isInspectable: false,userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"),
      onWebViewCreated: (controller)
      {
        inAppWebViewController = controller;
      },
      onLoadStart: (controller, url) async {
        showToast("Webpage Start Loading.....");
        isLoading.value = true;
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
            streamTapeFolder = await getFolderList();
            await getDownloadingVideoStatus();
            initTimer();
            isLoading.value = false;
            showToast("Webpage Loading Completed .....");
            return;
          }
        // Click on login or account panel
        if((loginTxt == "Login") && url!.rawValue == STREAMTAPE_URL)
          {
            await inAppWebViewController!.evaluateJavascript(source: ""
                "var clickEvent = new MouseEvent(\"click\", {\"view\": window,\"bubbles\": true,\"cancelable\": false});"
                "var element = document.querySelector(\".navbar-nav li:nth-child(2) a\");"
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

    StreamTapeFolder streamTapeFolder;
    var bodyMap = {"id":"0","_csrf":crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_FILE_API_URL,bodyMap,headers: {"Cookie":currentCookie});
    streamTapeFolder = StreamTapeFolder.fromJson(jsonDecode(respose));
    String? selectedFolderSP = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER,defaultValue: "");
    if(selectedFolderSP.isNotEmpty)
      {
        selectedFolder.value = streamTapeFolder.folders!.where((e) => e.name == selectedFolderSP).first;
      }
    else
      {
        selectedFolder.value = streamTapeFolder.folders!.first;
      }
    return streamTapeFolder;
    //return streamTapeFolder;
  }

  Future<bool> remoteUploadStreamTape (String url,String folder) async
  {
    try {
      showToast("Uploading to Streamtape .....");
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

    showToast("Fetching Kuaishou Flv Url .....");
    String? orginalUrl = await WebUtils.getOriginalUrl(kuaishouLink);
    WebViewUtils webViewUtils = WebViewUtils();
    String flvurl = await webViewUtils.getUrlWithWebView(orginalUrl!, ".flv");
    await webViewUtils.disposeWebView();
    return flvurl;
  }

  Future startUploading (String links) async
  {
    LoaderDialog.showLoaderDialog(Get.context!,text: "Uploading......");
    List<String> urls = links.split("\n");

    for (String url in urls)
      {
         String? flvUrl = await getFlvUrlfromKuaihsouLink(url);
         if(flvUrl!.isNotEmpty && !isUrlExistsInDownlodingList(flvUrl))
           {
             await remoteUploadStreamTape(flvUrl!, selectedFolder.value.id!);
           }
      }

    LoaderDialog.stopLoaderDialog();
  }

  Future getDownloadingVideoStatus({bool isUpdateList = false}) async
  {
    isDownloadStatusUpdating = true;
    try {
      downloadingList.clear();
      String? response = await WebUtils.makeGetRequest(STREAMTAPE_DOWNLOADING_STATUS_API_URL,headers: {"Cookie":currentCookie});
      Map<String,dynamic> jsonMap = jsonDecode(response!);
      List<dynamic> list = (jsonMap["data"] as List<dynamic>);
      for (dynamic item in list)
            {

              downloadingList.add(StreamtapeDownloadStatus(status: item["status"],url: item["url"]));
            }
      if(isUpdateList)
            {
              this.update(["updateDownloadingList"]);
            }
    } catch (e) {
      isDownloadStatusUpdating = false;
      print(e);
    }
    isDownloadStatusUpdating = false;
  }

  bool isUrlExistsInDownlodingList (String url)
  {
    Uri currentUri = Uri.parse(url);
    String currentUrl = currentUri.origin + currentUri.path;
    for (StreamtapeDownloadStatus streamtapeDownloadStatus in downloadingList)
      {
        Uri downloadingUri = Uri.parse(streamtapeDownloadStatus.url!);
        String downloadUrl = downloadingUri.origin + downloadingUri.path;
        if(downloadUrl == currentUrl && streamtapeDownloadStatus.status == "downloading")
        {
          return true;
        }
      }
    return false;
  }

  showToast (String text)
  {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}