
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:butterfly_dialog/butterfly_dialog.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart' as dom;
import 'package:kuaishou_remote_uploader/dialogs/loader_dialog.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_download_status.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:kuaishou_remote_uploader/utils/video_capture_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_view_utils.dart';
import 'package:path_provider/path_provider.dart';


class AppController extends GetxController
{
  String streamTapeUserName = "salmanilyas731@gmail.com";
  String streamTapePassword = "internet50";

  String STREAMTAPE_URL = "https://streamtape.com/";
  String STREAMTAPE_FILE_API_URL = "https://streamtape.com/api/website/filemanager/file/get";
  String STREAMTAPE_REMOTE_UPLOAD_API_URL = "https://streamtape.com/api/website/remotedl/put";
  String STREAMTAPE_DOWNLOADING_STATUS_API_URL = "https://streamtape.com/api/website/remotedl/get";
  String STREAMTAPE_NEW_FOLDER_API_URL = "https://streamtape.com/api/website/filemanager/folder/put";
  String STREAMTAPE_DELETE_API_URL = "https://streamtape.com/api/website/remotedl/del";
  String KOUAISHOU_LIVE_API_URL = "https://klsxvkqw.m.chenzhongtech.com/rest/k/live/byUser?kpn=NEBULA&kpf=OUTSIDE_ANDROID_H5&captchaToken=";

  HeadlessInAppWebView? headlessInAppWebView;
  InAppWebViewController? inAppWebViewController;
  late String currentCookie;
  late String crfToken;
  late Rx<StreamTapeFolderItem> selectedFolder = StreamTapeFolderItem().obs;
  TextEditingController urlTextEditingController = TextEditingController();
  TextEditingController folderTextEditingController = TextEditingController();

  RxBool isLoading = true.obs;

  StreamTapeFolder? streamTapeFolder;
  List<StreamtapeDownloadStatus> downloadingList = [];
  List<StreamtapeDownloadStatus> tempdownloadingList = [];
  Timer? downloadUpdatingTimer;
  RxBool isDownloadStatusUpdating = false.obs;
  Completer downloadingCompleter = Completer();
  late Box downloadingListIdBox;

  ScrollController scrollController = ScrollController();

  String logText = "";
  RxBool isConcurrentProcessing = false.obs;
  RxBool isWebPageProcessing = false.obs;

  /* initTimer()
  {
    downloadUpdatingTimer = Timer.periodic(Duration(seconds: 20), (timer) async {
      if (!isDownloadStatusUpdating.value) {
        await getDownloadingVideoStatus(isUpdateList: true);
      }
    });
  }
*/
  Future<void> loginToStreamTape({bool isRefresh = false}) async
  {
    //CookieManager.instance().deleteAllCookies();
    await SharedPrefsUtil.initSharedPreference();
    isConcurrentProcessing.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CONCURRENT_PROCESS);
    isWebPageProcessing.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_WEB_PAGE_PROCESS);
    downloadingListIdBox = await Hive.openBox("downloadingListId");
    String? cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
    String? csrf = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
    // if(isRefresh)
    //   {
        await CookieManager.instance().deleteAllCookies();
     // }
    if( ((cookie == null || cookie.isEmpty) && (csrf == null || csrf.isEmpty)) || isRefresh)
      {
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
              SharedPrefsUtil.setString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN, crfToken);
              List<Cookie> cookieslist = await CookieManager.instance().getCookies(url: url!);
              List<String> cookieList = [];
              for (final val in cookieslist!) {

                cookieList.add('${val.name}=${val.value}');

              }
              currentCookie = cookieList.join(';');
              SharedPrefsUtil.setString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE, currentCookie);
              await getFolderList();
              //initTimer();
              isLoading.value = false;
              showToast("Webpage Loading Completed .....");
              if (!isConcurrentProcessing.value) {
                await getDownloadingVideoStatus();
              } else {
                await getConcurrentDownloadingVideoStatus();
              }
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
    else
      {
        isLoading.value = true;
        currentCookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
        crfToken = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
        await getFolderList();
        //initTimer();
        isLoading.value = false;
        if (!isConcurrentProcessing.value) {
          await getDownloadingVideoStatus();
        } else {
          await getConcurrentDownloadingVideoStatus();
        }
      }
  }


  Future<void> getFolderList () async
  {

    var bodyMap = {"id":"0","_csrf":crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_FILE_API_URL,bodyMap,headers: {"Cookie":currentCookie});
    streamTapeFolder = StreamTapeFolder.fromJson(jsonDecode(respose));
    String? selectedFolderSP = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER,defaultValue: "");
    if(selectedFolderSP.isNotEmpty)
      {
        selectedFolder.value = streamTapeFolder!.folders!.where((e) => e.name == selectedFolderSP).first;
      }
    else
      {
        selectedFolder.value = streamTapeFolder!.folders!.first;
      }
    //return streamTapeFolder;
  }

  Future<bool> createFolder (String folderName,{String folderId = "0"}) async
  {
    var bodyMap = {"name":folderName,"id":folderId,"_csrf":crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_NEW_FOLDER_API_URL,bodyMap,headers: {"Cookie":currentCookie});
    Map<String,dynamic> jsonMap = jsonDecode(respose);
    if(jsonMap["statusCode"] == 200)
      {
        return true;
      }
    else
      {
        return false;
      }

  }

  Future<void> deleteRemoteUploadVideo (String id,) async
  {
    ButterflyAlertDialog.show(
      context: Get.context!,
      title: 'Delete',
      subtitle: 'Are sure you want to delete it?',
      alertType: AlertType.delete,
      onConfirm: () async {
        LoaderDialog.showLoaderDialog(Get.context!,text: "Deleting......");
        try {
          var bodyMap = {"id":id,"_csrf":crfToken};
          String? respose = await WebUtils.makePostRequest(STREAMTAPE_DELETE_API_URL,bodyMap,headers: {"Cookie":currentCookie});
          Map<String,dynamic> jsonMap = jsonDecode(respose);
          if(jsonMap["statusCode"] == 200)
          {
            LoaderDialog.stopLoaderDialog();
            showToast("Deleted Successfully.....");
            if (!isConcurrentProcessing.value) {
              await getDownloadingVideoStatus(isSync: true);
            } else {
              await getConcurrentDownloadingVideoStatus(isSync: true);
            }


          }
          else
          {
            LoaderDialog.stopLoaderDialog();
            showToast("Unable to delete.....");
          }
        } catch (e) {
          LoaderDialog.stopLoaderDialog();
          showToast("exception:" + e.toString());
        }
      },
    );


  }

  Future<bool> remoteUploadStreamTape (String url,String folder) async
  {
    try {

      if (!isConcurrentProcessing.value) {
        showToast("Uploading to Streamtape .....");
      }
      var bodyMap = {"links":url,"headers":"","folder":folder,"_csrf":crfToken};
      String? response = await WebUtils.makePostRequest(STREAMTAPE_REMOTE_UPLOAD_API_URL, bodyMap,headers: {"Cookie":currentCookie});
      Map<String,dynamic> json = jsonDecode(response);
      if (isConcurrentProcessing.value) {
        await Future.delayed(Duration(seconds: 1));
      }
      return json["statusCode"] == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> getFlvUrlfromKuaihsouLink (String kuaishouLink) async
  {

    if (!isConcurrentProcessing.value) {
      showToast("Fetching Kuaishou Flv Url .....");
    }
    String? orginalUrl = await WebUtils.getOriginalUrl(kuaishouLink);
    WebViewUtils webViewUtils = WebViewUtils();
    String flvurl = await webViewUtils.getUrlWithWebView(orginalUrl!, ".flv");
    await webViewUtils.disposeWebView();
    if (isConcurrentProcessing.value) {
      await Future.delayed(Duration(seconds: 1));
    }
    return flvurl;
  }

  Future<String> getDirectKuaishouFlvUrl (String kuaishouLink) async
  {
     String? orginalLink = await WebUtils.getOriginalUrl(kuaishouLink);
     Uri orginalUri = Uri.parse(orginalLink!);
     String? eid = orginalUri.path.split("/").last;
     String? efid = orginalUri.queryParameters["efid"];
     var requestMap = {"efid":efid,"eid":eid,"source":6,"shareMethod":"card","clientType":"WEB_OUTSIDE_SHARE_H5"};
     var headers = {"Referer":orginalLink,"User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36","Content-Type":"application/json","Accept-Encoding":"gzip, deflate, br","Accept":"*/*"};
     String response = await WebUtils.makePostRequest(KOUAISHOU_LIVE_API_URL, jsonEncode(requestMap),headers: headers);
     Map<String,dynamic> jsonResponse = json.decode(response);
     String finalFlvUrl = jsonResponse["liveStream"]["playUrls"][0]["url"];
     return finalFlvUrl;


  }

  Future startUploading (String links) async
  {
    LoaderDialog.showLoaderDialog(Get.context!,text: "Uploading......");
    List<String> urls = links.split("\n");
    urls.removeWhere((value) => value.isEmpty);
    Set<String> uniquePaths = {};
    for (String url in urls)
      {
         if (url.isNotEmpty) {
           String? flvUrl = await getFlvUrlfromKuaihsouLink(url);
           Uri uri = Uri.parse(flvUrl);
           String currentUrl = uri.origin + uri.path;
           if(flvUrl!.isNotEmpty && !isUrlExistsInDownlodingList(flvUrl) && uniquePaths.add(currentUrl))
             {
               await remoteUploadStreamTape(flvUrl!, selectedFolder.value.id!);
             }
         }
         await Future.delayed(Duration(seconds: 3));
      }

    LoaderDialog.stopLoaderDialog();
    if (logText.contains("captcha")) {
      showmodalBottomSheet(Get.context!, logText);
    }
  }


  Future concurrentStartUploading (String links) async
  {
    LoaderDialog.showLoaderDialog(Get.context!,text: "Uploading......");
    List<String> urls = links.split("\n");
    urls.removeWhere((value) => value.isEmpty);
    List<Future<String>> flvUrlFutureList= [];
    List<Future<void>> streamtapeUploadingFutureList = [];
    List<String> flvUrls = [];
    showToast("Fetching Kuaishou Flv Url .....");
    for (String url in urls)
    {
      if (url.isNotEmpty) {
        if(isWebPageProcessing.value)
          {
            flvUrlFutureList.add(getDirectKuaishouFlvUrl(url));
          }
        else
          {
            flvUrlFutureList.add(getFlvUrlfromKuaihsouLink(url));
          }
      }
    }
    flvUrls = await Future.wait(flvUrlFutureList);
    List<String> distinctFlvUrlsList = removeDuplicateUrls(flvUrls);
    showToast("Uploading to Streamtape .....");
    for(String flvUrl in distinctFlvUrlsList)
      {
        if(flvUrl!.isNotEmpty && !isUrlExistsInDownlodingList(flvUrl))
        {
           streamtapeUploadingFutureList.add(remoteUploadStreamTape(flvUrl!, selectedFolder.value.id!));
        }
      }
    await Future.wait(streamtapeUploadingFutureList);
    LoaderDialog.stopLoaderDialog();
    if (logText.contains("captcha")) {
      showmodalBottomSheet(Get.context!, logText);
    }
  }

  Future getDownloadingVideoStatus({bool isSync = false}) async
  {
    isDownloadStatusUpdating.value = true;
    downloadingCompleter = Completer();
    try {
      if (!isSync) {
        downloadingList.clear();
      }
      this.update(["updateDownloadingList"]);
      String? response = await WebUtils.makeGetRequest(STREAMTAPE_DOWNLOADING_STATUS_API_URL,headers: {"Cookie":currentCookie});
      Map<String,dynamic> jsonMap = jsonDecode(response!);
      List<dynamic> list = (jsonMap["data"] as List<dynamic>);
      if (list.isEmpty) {
        showToast("List is empty from streamtape\n Response :" + response,isError: true);
      }
      if (!isSync) {
        for (dynamic item in list)
             {
               Uint8List? bytes;
               Uint8List bytesBox = getDownloadingLinkId(item["id"]);
               if (item["status"] != "error" ) {
                 if (bytesBox== null || bytesBox.isEmpty) {
                         bytes = await VideoCaptureUtils().captureImage(item["url"], 500);
                         setDownloadingLinkId(item["id"], bytes);
                      }
                 else
                   {
                     bytes = getDownloadingLinkId(item["id"]);
                   }
               }
               downloadingList.add(StreamtapeDownloadStatus(status: item["status"],url: item["url"],imageBytes: bytes,id: item["id"],isThumbnailUpdating: false.obs));

               this.update(["updateDownloadingList"]);

             }
        await deleteAllExcept(downloadingListIdBox, downloadingList.map((value) => value.id).toList());
      } else {

        // For removing links
        //if (downloadingList.length > list.length) {
          tempdownloadingList.clear();
          for(StreamtapeDownloadStatus item in downloadingList)
             {
               bool isExist = list.any((value) => value["id"] == item.id );
               if(!isExist)
                 {
                   tempdownloadingList.add(item);
                 }

             }
          for (StreamtapeDownloadStatus item in tempdownloadingList)
            {
              downloadingList.remove(item);
            }

          this.update(["updateDownloadingList"]);
       // }

        // For adding downloading links
       // if (downloadingList.length < list.length) {
          for (dynamic item in list)
            {
              tempdownloadingList.clear();
              bool isExist = downloadingList.any((value) => value.id == item["id"]);
              if(!isExist)
                {
                  Uint8List? bytes;
                  Uint8List bytesBox = getDownloadingLinkId(item["id"]);
                  if (item["status"] != "error" ) {
                    if (bytesBox== null || bytesBox.isEmpty) {
                      bytes = await VideoCaptureUtils().captureImage(item["url"], 500);
                      setDownloadingLinkId(item["id"], bytes);
                    }
                    else
                    {
                      bytes = getDownloadingLinkId(item["id"]);
                    }
                  }
                  downloadingList.add(StreamtapeDownloadStatus(status: item["status"],url: item["url"],imageBytes: bytes,id: item["id"],isThumbnailUpdating: false.obs));

                  this.update(["updateDownloadingList"]);
                  await scrollToEnd();
                }
            }
       // }
      }
    } catch (e) {
      // isDownloadStatusUpdating.value = false;
      // downloadingCompleter.complete();
      print(e);
    }
    isDownloadStatusUpdating.value = false;
    downloadingCompleter.complete();
  }

  Future getConcurrentDownloadingVideoStatus({bool isSync = false}) async
  {
    isDownloadStatusUpdating.value = true;
    downloadingCompleter = Completer();
    try {
      if (!isSync) {
        downloadingList.clear();
      }
      this.update(["updateDownloadingList"]);
      String? response = await WebUtils.makeGetRequest(STREAMTAPE_DOWNLOADING_STATUS_API_URL,headers: {"Cookie":currentCookie});
      Map<String,dynamic> jsonMap = jsonDecode(response!);
      List<dynamic> list = (jsonMap["data"] as List<dynamic>);
      List<Future<StreamtapeDownloadStatus>> streamtapeStatusList = [];
      if (!isSync) {
        for (dynamic item in list)
        {
          streamtapeStatusList.add(getDownloadingDetailItem(item,500));
        }
        List<StreamtapeDownloadStatus> downloadingListFuture = await Future.wait(streamtapeStatusList);
        downloadingList.addAll(downloadingListFuture);
        this.update(["updateDownloadingList"]);
        await deleteAllExcept(downloadingListIdBox, downloadingList.map((value) => value.id).toList());
      } else {

        // For removing links
        //if (downloadingList.length > list.length) {
        tempdownloadingList.clear();
        for(StreamtapeDownloadStatus item in downloadingList)
        {
          bool isExist = list.any((value) => value["id"] == item.id );
          if(!isExist)
          {
            tempdownloadingList.add(item);
          }

        }
        for (StreamtapeDownloadStatus item in tempdownloadingList)
        {
          downloadingList.remove(item);
        }

        this.update(["updateDownloadingList"]);
        // }

        // For adding downloading links
        // if (downloadingList.length < list.length) {
        for (dynamic item in list)
        {
          tempdownloadingList.clear();
          bool isExist = downloadingList.any((value) => value.id == item["id"]);
          if(!isExist)
          {
            streamtapeStatusList.add(getDownloadingDetailItem(item,500));
          }
        }
        List<StreamtapeDownloadStatus> downloadingListFuture = await Future.wait(streamtapeStatusList);
        downloadingList.addAll(downloadingListFuture);
        this.update(["updateDownloadingList"]);
        await scrollToEnd();
        // }
      }
    } catch (e) {
      // isDownloadStatusUpdating.value = false;
      // downloadingCompleter.complete();
      print(e);
    }
    isDownloadStatusUpdating.value = false;
    downloadingCompleter.complete();
  }

  Future<void> updateVideoThumbnail(StreamtapeDownloadStatus streamtapeDownloadStatus) async
  {
    Uint8List? imageBytes = await VideoCaptureUtils().captureImage(streamtapeDownloadStatus.url!, 500);
    streamtapeDownloadStatus.imageBytes = imageBytes;
    setDownloadingLinkId(streamtapeDownloadStatus.id!, imageBytes);
    this.update(["updateDownloadingList"]);
  }

  bool isUrlExistsInDownlodingList (String url)
  {
    Uri currentUri = Uri.parse(url);
    String currentUrl = currentUri.origin + currentUri.path;
    for (StreamtapeDownloadStatus streamtapeDownloadStatus in downloadingList)
      {
        Uri downloadingUri = Uri.parse(streamtapeDownloadStatus.url!);
        String downloadUrl = downloadingUri.origin + downloadingUri.path;
        if(downloadUrl == currentUrl)
        {
          showToast("Url already exists ($url)",isDurationLong: true);
          return true;
        }
      }
    return false;
  }

  List<String> removeDuplicateUrls(List<String> urls) {
    // Create a set to store unique base URLs (path only)
    Set<String> uniquePaths = {};

    // Create a list to hold the final unique URLs
    List<String> finalUrls = [];

    for (var url in urls) {
      // Parse the URL
      if (url.isNotEmpty) {
        Uri uri = Uri.parse(url);
        // Normalize the URL by getting the path
        String currentUrl = uri.origin + uri.path;

        // Add to set and list if it's a new path
        if (uniquePaths.add(currentUrl)) {
          finalUrls.add(url); // Keep the original URL
        }
      }
    }

    return finalUrls;
  }

  showToast (String text,{bool isDurationLong = false, bool isError = false})
  {
    Fluttertoast.showToast(
        msg: text,
        toastLength: isDurationLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? Colors.red :Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  
  void setDownloadingLinkId (String id,Uint8List? value)
  {
    downloadingListIdBox.put(id, value);
  }

  Uint8List getDownloadingLinkId (String id)
  {
    return downloadingListIdBox.get(id,defaultValue: Uint8List.fromList([]));
  }

  Future<void> deleteAllExcept(Box box, List<String?> keysToKeep) async {
    // Get all keys in the box
    final allKeys = box.keys;

    // Iterate over all keys and delete those not in keysToKeep
    for (var key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await box.delete(key);
      }
    }
  }

  Future<void> scrollToEnd() async {
    await Future.delayed(Duration(milliseconds: 1000));
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void showmodalBottomSheet(BuildContext contxt,String value ) {
    showModalBottomSheet(
      context: contxt,
      builder: (context) {
        return SingleChildScrollView(child: Text(value),);
      }
    );
  }


  Future<StreamtapeDownloadStatus> getDownloadingDetailItem(dynamic item,int seekPosition) async {
      Uint8List? bytes;
      Uint8List bytesBox = getDownloadingLinkId(item["id"]);
      if (item["status"] != "error" ) {
        if (bytesBox== null || bytesBox.isEmpty) {
          final directory = await getTemporaryDirectory();
          final String outputPath = '${directory.path}/${Random().nextInt(10000000)}.jpg';

          String command = '-i ${item["url"]} -ss ${seekPosition / 1000} -vframes 1 $outputPath';

          FFmpegSession session = await FFmpegKit.execute(command);
          final returnCode = await session.getReturnCode();


          if (ReturnCode.isSuccess(returnCode)) {
            File outputFile = File(outputPath);
            bytes = await outputFile.readAsBytes();
            setDownloadingLinkId(item["id"], bytes);
            if(await outputFile.exists())
            {
              await outputFile.delete();
            }
        }
      }
      else
       {
         bytes = getDownloadingLinkId(item["id"]);
       }

    }
   return StreamtapeDownloadStatus(status: item["status"],url: item["url"],imageBytes: bytes,id: item["id"],isThumbnailUpdating: false.obs);
  }



}