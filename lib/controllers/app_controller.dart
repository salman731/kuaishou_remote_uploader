
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:background_mode_new/background_mode_new.dart';
import 'package:butterfly_dialog/butterfly_dialog.dart';
import 'package:cron/cron.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';
import 'package:kuaishou_remote_uploader/dialogs/dialog_utils.dart';
import 'package:kuaishou_remote_uploader/enums/api_error_enum.dart';
import 'package:kuaishou_remote_uploader/enums/background_mode_time_enum.dart';
import 'package:kuaishou_remote_uploader/main.dart';
import 'package:kuaishou_remote_uploader/models/download_item.dart';
import 'package:kuaishou_remote_uploader/models/kuaishou_live_user.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_download_status.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_file_item.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/models/user_kuaishou.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:kuaishou_remote_uploader/utils/video_capture_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_view_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';


class   AppController extends GetxController {
  String streamTapeUserName = "salmanilyas731@gmail.com";
  String streamTapePassword = "internet50";

  String STREAMTAPE_URL = "https://streamtape.com/";
  String STREAMTAPE_FILE_API_URL = "https://streamtape.com/api/website/filemanager/file/get";
  String STREAMTAPE_REMOTE_UPLOAD_API_URL = "https://streamtape.com/api/website/remotedl/put";
  String STREAMTAPE_DOWNLOADING_STATUS_API_URL = "https://streamtape.com/api/website/remotedl/get";
  String STREAMTAPE_NEW_FOLDER_API_URL = "https://streamtape.com/api/website/filemanager/folder/put";
  String STREAMTAPE_DELETE_REMOTE_DOWNLOAD_API_URL = "https://streamtape.com/api/website/remotedl/del";
  String STREAMTAPE_DELETE_FOLDER_API_URL = "https://streamtape.com/api/website/filemanager/folder/del";
  String STREAMTAPE_RENAME_API_URL = "https://streamtape.com/api/website/filemanager/folder/rename";
  String KOUAISHOU_LIVE_API_URL = "https://klsxvkqw.m.chenzhongtech.com/rest/k/live/byUser?kpn=NEBULA&kpf=OUTSIDE_ANDROID_H5&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_2 = "https://livev.m.chenzhongtech.com/rest/k/live/byUser?kpn=GAME_ZONE&kpf=OUTSIDE_ANDROID_H5&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_3 = "https://livev.m.chenzhongtech.com/rest/k/live/byUser?kpn=GAME_ZONE&kpf=UNKNOWN_PLATFORM&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_4 = "https://v.m.chenzhongtech.com/rest/k/live/byUser?kpn=KUAISHOU&kpf=OUTSIDE_ANDROID_H5&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_5 = "https://klsxvkqw.m.chenzhongtech.com/rest/k/live/byUser?kpn=NEBULA&kpf=UNKNOWN_PLATFORM&captchaToken=HEADCgp6dC5jYXB0Y2hhEtMCFJNAWpBNdfMfdnHcCLEyper4lASo9foKIFLNtFTVR_sF6Iafj4fRatV5JSV5JH0vjmIgk97FCjcpSJq42DGH4rdJ0ZllRH1hD-ny_EPyyyTjCURt-UqB8en6q8ll0K5TjY9K09l6_OkjyxX9CVFWkhY_--a9hm3Ay_Uf_iHLrn8_VcKfEHZmxnj7Oh--BoESFnHvVGxFn9TGLKKIozIdafTNtuFFtxY4__UrDLnZGYHQrA6CevqttA5WqE7YQvwXEz_Y7EtIIalOCFxtirZPgOiMQ425gw3XjZzDjQRwYdOge4sJO83maNTVsmX_sgBYETZxOuWmUhSglSGY67ygVPk6B1NwNLH3jesmph4VNGJM6rbi0yWbOtd2yLNWxr-HICvglWV4oDbrN-cczkrYCoYDyjTXRP62iK8x3wnuOrGKTXM_vEymib0kHp8AuGb35oj9GhJxat9v18_vGhz0w0fGzFHTlSooBTACTAIL";
  String KOUAISHOU_MAIN_MOBILE_URL = "https://livev.m.chenzhongtech.com/fw/live/";
  String KOUAISHOU_LIVE_FOLLOW_API = "https://live.kuaishou.com/live_api/follow/living";
  String KOUAISHOU_USER_API = "https://live.kuaishou.com/live_api/profile/public?count=4&pcursor=&principalId=s14042236&hasMore=true";
  String HTTPIE_PROXY_URL = "https://httpie.io/app/api/proxy";

  HeadlessInAppWebView? headlessInAppWebView;
  InAppWebViewController? inAppWebViewController;
  late String currentCookie;
  late String crfToken;
  late Rx<StreamTapeFolderItem> selectedFolder = StreamTapeFolderItem().obs;
  late Rx<StreamTapeFolderItem> selectedDownloadFolder = StreamTapeFolderItem().obs;
  TextEditingController urlTextEditingController = TextEditingController();
  TextEditingController folderTextEditingController = TextEditingController();
  TextEditingController searchFileTextEditingController = TextEditingController();
  TextEditingController usernameTextEditingController = TextEditingController();

  RxBool isLoading = true.obs;

  StreamTapeFolder? streamTapeFolder;
  List<StreamtapeDownloadStatus> downloadingList = [];
  List<StreamtapeDownloadStatus> tempdownloadingList = [];
  Timer? downloadUpdatingTimer;
  RxBool isDownloadStatusUpdating = false.obs;
  Completer downloadingCompleter = Completer();
  late Box downloadingListIdBox;
  late Box usernameListIdBox;
  late Box unfollowUserUrlListBox;

  ScrollController scrollController = ScrollController();

  String logText = "";
  RxBool isConcurrentProcessing = true.obs;
  RxBool isWebPageProcessing = true.obs;
  RxBool isBackgroundModeEnable = false.obs;
  RxString downloadLinks = "".obs;
  List<DownloadItem> downloadLinksList = [];
  List<DownloadItem> filterdownloadLinksList = [];
  bool isSearching = false;

  List<DownloadItem> get currentDownloadList => isSearching ? filterdownloadLinksList : downloadLinksList;
  RxBool isUploading = false.obs;
  StringBuffer doneUplodingCopyText = StringBuffer("");
  RxBool isGoingToRenameFolder = false.obs;
  RxDouble midNightSliderValue = 1.0.obs; // 12:
  RxDouble morningAfterNoonSliderValue = 1.0.obs;
  RxDouble eveningNightSliderValue = 1.0.obs; //
  RxInt unfollowUserIntervalSliderValue = 1.obs; //
  RxInt unfollowCurrentTime = 1.obs; //
  Timer? backgroundModeTimer;
  RxBool isSliderEnable = true.obs;
  Rx<BackgroundModeTimeEnum> backgroundModeTimeEnumRadioValue = BackgroundModeTimeEnum.ALLTIME.obs;
  Rx<RangeValues> backgroundModeTimeSpecificRangeValue = const RangeValues(0, 6).obs;
  RxBool isBackgroundModeRangeSliderVisible = false.obs;
  RxBool isBackGroundModeTimeRadioButtonsVisible = false.obs;
  Timer? unfollowUserTimer;
  RxBool isUnfollowUserProcessing = false.obs;
  RxString unfollowUploadRemainingTime = "".obs;
  List<StopWatchTimer> unfollowUserStopwatch = [];
  RxInt unfollowUserUploaded = 0.obs;
  RxString totalUnfollowUserUploadedProgress = "".obs;
  RxInt unfollowUserOnline = 0.obs;
  RxInt unfollowUserErrorCaptcha = 0.obs;
  RxInt unfollowUserError = 0.obs;
  RxInt unfollowUserFrequentRequests = 0.obs;
  RxInt unfollowUserOthers = 0.obs;
  RxInt unfollowUserOffline = 0.obs;

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
    isConcurrentProcessing.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CONCURRENT_PROCESS, defaultValue: true);
    isWebPageProcessing.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_WEB_PAGE_PROCESS, defaultValue: true);
    isBackgroundModeEnable.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_BACKGROUNDMODE_ENABLE, defaultValue: false);
    processBackgroundMode();
    midNightSliderValue.value = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_MIDNIGHT_SLIDER, defaultValue: 25); // 12:00 AM -> 06:00 AM
    morningAfterNoonSliderValue.value = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_MORNINGAFTERNOON_SLIDER, defaultValue: 15); // 6:00 AM -> 4:00 PM
    eveningNightSliderValue.value = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_EVENINGNIGHT_SLIDER, defaultValue: 10); // 4:00 PM -> 12:00 AM
    unfollowUserIntervalSliderValue.value = SharedPrefsUtil.getInt(SharedPrefsUtil.KEY_UNFOLLOW_USER_TIMER, defaultValue: 15); // 4:00 PM -> 12:00 AM
    downloadingListIdBox = await Hive.openBox("downloadingListId");
    usernameListIdBox = await Hive.openBox("usernameListIdBox");
    unfollowUserUrlListBox = await Hive.openBox("unfollowUserUrlListBox");
    String? cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
    String? csrf = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
    // if(isRefresh)
    //   {
    await CookieManager.instance().deleteAllCookies();
    // }
    if (((cookie == null || cookie.isEmpty) && (csrf == null || csrf.isEmpty)) || isRefresh) {
      unfollowUserTimer!.cancel();
      headlessInAppWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(STREAMTAPE_URL)),
        initialSize: Size(1366, 768),
        initialSettings: InAppWebViewSettings(isInspectable: false, userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",incognito: false),
        onWebViewCreated: (controller) {
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
          if (loginTxt == "Account Panel") {
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
          if ((loginTxt == "Login") && url!.rawValue == STREAMTAPE_URL) {
            await inAppWebViewController!.evaluateJavascript(source: ""
                "var clickEvent = new MouseEvent(\"click\", {\"view\": window,\"bubbles\": true,\"cancelable\": false});"
                "var element = document.querySelector(\".navbar-nav li:nth-child(2) a\");"
                "element.dispatchEvent(clickEvent);");
            return;
          }


          // login script
          if (url!.rawValue == STREAMTAPE_URL + "login") {
            dom.Element? formElement = document.querySelector("#w0");
            if (formElement != null) {
              await inAppWebViewController!.evaluateJavascript(source: ""
                  "document.querySelector(\"input[type=email]\").value = \"${streamTapeUserName}\";"
                  "document.querySelector(\"input[type=password]\").value = \"${streamTapePassword}\";"
                  "const form = document.querySelector(\"#w0\");"
                  "form.submit();");
            }
          }
        },
      );
      await headlessInAppWebView!.run();
    }
    else {
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

    //FlutterBackgroundService().invoke("setAsBackground");
  }


  Future<void> getFolderList({bool isDeleted = false}) async
  {
    streamTapeFolder = await fetchFolderList();
    String? selectedFolderSP = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER, defaultValue: "");
    if (selectedFolderSP.isNotEmpty && !isDeleted) {
      selectedFolder.value = streamTapeFolder!.folders!.where((e) => e.name == selectedFolderSP).first;
    }
    else {
      selectedFolder.value = streamTapeFolder!.folders!.first;
    }
    selectedDownloadFolder.value = streamTapeFolder!.folders!.first;
    //return streamTapeFolder;
  }

  Future<StreamTapeFolder> fetchFolderList ({bool isBackground = false}) async
  {
    if (isBackground) {
      crfToken = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
      currentCookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
    }
    var bodyMap = {"id": "0", "_csrf": crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_FILE_API_URL, bodyMap, headers: {"Cookie": currentCookie});
    return StreamTapeFolder.fromJson(jsonDecode(respose));
  }

  Future<StreamTapeFolder> getFolderFiles(String id) async
  {
    var bodyMap = {"id": id, "_csrf": crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_FILE_API_URL, bodyMap, headers: {"Cookie": currentCookie});
    return StreamTapeFolder.fromJson(jsonDecode(respose));
  }

  Future<bool> renameFolder(String name, String id) async
  {
    var bodyMap = {"id": id, "_csrf": crfToken, "name": name};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_RENAME_API_URL, bodyMap, headers: {"Cookie": currentCookie});
    Map<String, dynamic> jsonMap = jsonDecode(respose);
    if (jsonMap["statusCode"] == 200) {
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> deleteFolder(String id) async
  {
    var bodyMap = {"id": id, "_csrf": crfToken,};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_DELETE_FOLDER_API_URL, bodyMap, headers: {"Cookie": currentCookie});
    Map<String, dynamic> jsonMap = jsonDecode(respose);
    if (jsonMap["statusCode"] == 200) {
      return true;
    }
    else {
      return false;
    }
  }

  Future<(bool,String)> createFolder(String folderName, {String folderId = "0",bool isBackground = false}) async
  {
    if (isBackground) {
      crfToken = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
      currentCookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
    }
    var bodyMap = {"name": folderName, "id": folderId, "_csrf": crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_NEW_FOLDER_API_URL, bodyMap, headers: {"Cookie": currentCookie});
    Map<String, dynamic> jsonMap = jsonDecode(respose);
    if (jsonMap["statusCode"] == 200) {
      return (true,jsonMap["id"].toString());
    }
    else {
      return  (true,jsonMap["id"].toString());
    }
  }

  Future<void> showDeleteRemoteUploadingDialog(String id,) async
  {
    ButterflyAlertDialog.show(
      context: Get.context!,
      title: 'Delete',
      subtitle: 'Are sure you want to delete it?',
      alertType: AlertType.delete,
      onConfirm: () async {
        DialogUtils.showLoaderDialog(Get.context!, text: "Deleting......");
        try {
          await deleteRemoteUploadingVideo(id);
        } catch (e) {
          DialogUtils.stopLoaderDialog();
          showToast("exception:" + e.toString());
        }
      },
    );
  }

  Future<void> showReauthenticateStreamtapeDialog() async
  {
    ButterflyAlertDialog.show(
      context: Get.context!,
      title: 'Reauthenticate',
      subtitle: 'Are sure you want to reauthenticate?',
      alertType: AlertType.warning,
      onConfirm: () async {
        await loginToStreamTape(isRefresh: true);
      },
    );
  }


  Future<void> deleteRemoteUploadingVideo(String id, {bool isBackGroundProcess = false}) async
  {
    if (isBackGroundProcess) {
      crfToken = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
      currentCookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
    }
    var bodyMap = {"id": id, "_csrf": crfToken};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_DELETE_REMOTE_DOWNLOAD_API_URL, bodyMap, headers: {"Cookie": currentCookie});
    Map<String, dynamic> jsonMap = jsonDecode(respose);
    if (jsonMap["statusCode"] == 200) {
      if (!isBackGroundProcess) {
        DialogUtils.stopLoaderDialog();
        showToast("Deleted Successfully.....");
        if (!isConcurrentProcessing.value) {
          await getDownloadingVideoStatus(isSync: true);
        } else {
          await getConcurrentDownloadingVideoStatus(isSync: true);
        }
      }
    }
    else {
      if (!isBackGroundProcess) {
        DialogUtils.stopLoaderDialog();
        showToast("Unable to delete.....");
      }
    }
  }

  Future<bool> remoteUploadStreamTape(String url, String folder, {bool isBackGroundProcess = false}) async
  {
    try {
      if (!isConcurrentProcessing.value && !isBackGroundProcess) {
        showToast("Uploading to Streamtape .....");
      }
      if (isBackGroundProcess) {
        crfToken = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
        currentCookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
      }
      var bodyMap = {"links": url, "headers": "", "folder": folder, "_csrf": crfToken};
      String? response = await WebUtils.makePostRequest(STREAMTAPE_REMOTE_UPLOAD_API_URL, bodyMap, headers: {"Cookie": currentCookie});
      Map<String, dynamic> json = jsonDecode(response);
      if (isConcurrentProcessing.value) {
        await Future.delayed(Duration(seconds: 1));
      }
      return json["statusCode"] == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> getFlvUrlfromKuaihsouLink(String kuaishouLink, {bool isForBackground = false}) async
  {
    if (!isConcurrentProcessing.value && isForBackground) {
      showToast("Fetching Kuaishou Flv Url .....");
    }
    String? orginalUrl = await WebUtils.getOriginalUrl(kuaishouLink);
    WebViewUtils webViewUtils = WebViewUtils();
    String flvurl = await webViewUtils.getUrlWithWebView(orginalUrl!, ".flv");
    await webViewUtils.disposeWebView();
    if (isConcurrentProcessing.value && isForBackground) {
      await Future.delayed(Duration(seconds: 1));
    }
    return flvurl;
  }

  Future<String> getDirectKuaishouFlvUrl(String kuaishouLink,{Function(String)? onError}) async
  {
    String finalFlvUrl = "";
    String userEid = "";
    try {
      String? orginalLink = await WebUtils.getOriginalUrl(kuaishouLink);
      Uri orginalUri = Uri.parse(orginalLink!);
      String? eid = orginalUri.path
              .split("/")
              .last;
      userEid = eid;
      String? efid = orginalUri.queryParameters["efid"];
      var requestMap = {"efid": efid, "eid": eid, "source": 6, "shareMethod": "card", "clientType": "WEB_OUTSIDE_SHARE_H5"};
      List<String> cookiesList = [
        "did=web_313b9e6716eb48398bc8937adb783c3a; didv=1733746775000",
        "did=web_618d6ac474dd404a998cf2b641d96843; didv=1732694664000",
        "did=web_ad92a0bba2054b2ab7fe2c9809f94b81; didv=1733750007000",
        "did=web_907321761e6e4eff96111b476bc9cad4; didv=1732694096000",
        "did=web_7ae9ac987837437f89a6c3cabe4096aa; didv=1733752741000"];
      int index = getIntBetweenRange(0, 5);
      var headers = {
            "Referer": orginalLink,
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
            "Content-Type": "application/json",
            "Accept-Encoding": "gzip, deflate, br",
            "Accept": "*/*",
            "Cookie":cookiesList[index]
          };
      String response = await WebUtils.makePostRequest(KOUAISHOU_LIVE_API_URL_4, jsonEncode(requestMap), headers: headers);
      Map<String, dynamic> jsonResponse = json.decode(response);
      if (jsonResponse["error_msg"] == null) {
        finalFlvUrl = jsonResponse["liveStream"]["playUrls"][0]["url"];
        if (jsonResponse["liveStreamEndReason"] != null && jsonResponse["liveStreamEndReason"] == "The Live ended.") {
          finalFlvUrl = "";
          if(onError != null)
            {
              onError("User ($eid) : Live stream is ended");
            }
        }
      }else{
        if(onError != null)
        {
          onError("User ($eid) : " + jsonResponse["error_msg"] + " " + (jsonResponse["captchaConfig"] == null ? "" : "Captcha Warning...."));
        }
      }
    } catch (e) {
      showToast("Unable to get Link : ${e.toString()}");
      if(onError != null)
        {
          onError("User ($userEid) : " + e.toString());
        }
    }
    return finalFlvUrl;
  }

  Future<(String,ApiErrorEnum)> getDirectKuaishouFlvUrlOrginal (String kuaishouLink,String did) async
  {
    String finalFlvUrl = "";
    ApiErrorEnum error = ApiErrorEnum.NONE;
    try {
      String? orginalLink = await WebUtils.getOriginalUrl(kuaishouLink);
      Uri orginalUri = Uri.parse(orginalLink!);
      String? eid = orginalUri.path.split("/").last;
      String? efid = orginalUri.queryParameters["efid"];
      var requestMap = {"efid":efid,"eid":eid,"source":6,"shareMethod":"card","clientType":"WEB_OUTSIDE_SHARE_H5"};
      int currentTimeInMillis = DateTime.now().millisecondsSinceEpoch;
      var headers = {"Referer":orginalLink,"Cookie":"${did}","Content-Type":"application/json"};
      // var headers2 = {
      // "Content-Type": "application/json",
      // "Cookie": "did=$did",
      // "Host": orginalUri.origin,
      // "Referer": orginalLink,
      // "User-Agent": "HTTPie"};
      var headersHttpie = {
        'content-type': 'text/plain;charset=UTF-8',
        'sec-ch-ua': '"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'x-pie-req-header-content-type': 'application/json',
        'x-pie-req-header-cookie': '${did}',
        'x-pie-req-header-host': orginalUri.origin.replaceAll("https://", ""),
        'x-pie-req-header-referer': orginalLink,
        'x-pie-req-header-user-agent': 'HTTPie',
        'x-pie-req-meta-follow-redirects': 'true',
        'x-pie-req-meta-method': 'POST',
        'x-pie-req-meta-ssl-verify': 'true',
        'x-pie-req-meta-url': 'https://klsxvkqw.m.chenzhongtech.com/rest/k/live/byUser?kpn=NEBULA&kpf=UNKNOWN_PLATFORM&captchaToken=HEADCgp6dC5jYXB0Y2hhEtMCFJNAWpBNdfMfdnHcCLEyper4lASo9foKIFLNtFTVR_sF6Iafj4fRatV5JSV5JH0vjmIgk97FCjcpSJq42DGH4rdJ0ZllRH1hD-ny_EPyyyTjCURt-UqB8en6q8ll0K5TjY9K09l6_OkjyxX9CVFWkhY_--a9hm3Ay_Uf_iHLrn8_VcKfEHZmxnj7Oh--BoESFnHvVGxFn9TGLKKIozIdafTNtuFFtxY4__UrDLnZGYHQrA6CevqttA5WqE7YQvwXEz_Y7EtIIalOCFxtirZPgOiMQ425gw3XjZzDjQRwYdOge4sJO83maNTVsmX_sgBYETZxOuWmUhSglSGY67ygVPk6B1NwNLH3jesmph4VNGJM6rbi0yWbOtd2yLNWxr-HICvglWV4oDbrN-cczkrYCoYDyjTXRP62iK8x3wnuOrGKTXM_vEymib0kHp8AuGb35oj9GhJxat9v18_vGhz0w0fGzFHTlSooBTACTAIL'
      };
      String response = await WebUtils.makePostRequest(HTTPIE_PROXY_URL, jsonEncode(requestMap),headers: headersHttpie);
      Map<String,dynamic> jsonResponse = json.decode(response);
      if (jsonResponse["result"] == 1) {
        finalFlvUrl = jsonResponse["liveStream"]["playUrls"][0]["url"];
        if (jsonResponse["liveStreamEndReason"] != null) {
              finalFlvUrl = "";
              error = ApiErrorEnum.OFFLINE;
            }
      }
      else if (jsonResponse["result"] == 2)
        {
          error = ApiErrorEnum.FREQUENT_REQUESTS;
        }
      else if (jsonResponse["result"] == 2214)
      {
        error = ApiErrorEnum.OFFLINE;
      }
      else
        {
          if(jsonResponse["result"] == 2001 && jsonResponse["captchaConfig"] != null)
            {
              error = ApiErrorEnum.CAPTCHA_REQUIRED;
            }
          else
            {
              error = ApiErrorEnum.OTHERS;
            }
        }
    } catch (e) {
      error = ApiErrorEnum.EXCEPTION;
    }
    return (finalFlvUrl,error);

  }

  Future<(String, String, Map<String, bool>)> getDirectKuaishouFlvUrl_Background(String username, String shareToken, String cookie) async
  {
    Map<String, bool> liveStatusMap = <String, bool>{"online": false, "apiError": false, "exceptionError": false, "offline": false};
    String cookie = "did=web_5db7f4c0d9664902af774fd08ebdf769; didv=1730628699000";
    String finalFlvUrl = "";
    String finalUrl = "https://live.kuaishou.com/u/${username}";
    //String shareToken = "X9BGeAzPhrZX1bs";
    String? orginalLink = "";
    String error = "";
    /*try {
      orginalLink = await WebUtils.getOriginalUrl(finalUrl,headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 14; 23129RAA4G Build/UKQ1.231207.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.107 Mobile Safari/537.36"},timeout: Duration(seconds: 25));
    } catch (e) {
      print(e);
    }*/
    try {

      /*if(orginalLink == null || orginalLink!.isEmpty)
        {
          WebViewUtils webViewUtils = WebViewUtils();
          orginalLink = await webViewUtils.getUrlWithWebView(finalUrl!, "",isBackground: true);
          await webViewUtils.disposeWebView();
        }*/
      if (orginalLink!.isEmpty) {
        orginalLink = KOUAISHOU_MAIN_MOBILE_URL + username + "?cc=share_wxms&followRefer=151&shareMethod=CARD&kpn=GAME_ZONE&subBiz=LIVE_STEARM_OUTSIDE&shareToken=$shareToken&shareMode=APP&efid=0";
      }
      Uri orginalUri = Uri.parse(orginalLink!);
      String? eid = orginalUri.path
          .split("/")
          .last;
      String? efid = "0";
      var requestMap = {"efid": efid, "eid": eid, "source": 6, "shareMethod": "card", "clientType": "WEB_OUTSIDE_SHARE_H5"};
      var headers = {
        "Referer": orginalLink,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
        "Content-Type": "application/json",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept": "*/*",
        "Cookie": cookie
      };
      //  var headers = {"Accept": "*/*",
      //    "Accept-Encoding": "gzip, deflate, br",
      //    "Accept-Language": "en-US,en;q=0.9,ur;q=0.8",
      //    "Access-Control-Allow-Credentials": "true",
      //    "Content-Type": "application/json",
      //    "Cookie": cookie,
      //    "Host": "livev.m.chenzhongtech.com",
      //    "Origin": "https://livev.m.chenzhongtech.com",
      //    "Referer": orginalLink,
      //    "Sec-Ch-Ua": "\"Google Chrome\";v=\"131\", \"Chromium\";v=\"131\", \"Not_A Brand\";v=\"24\"",
      //    "Sec-Ch-Ua-Mobile": "?1",
      //    "Sec-Ch-Ua-Platform": "Android",
      //    "Sec-Fetch-Dest": "",
      //    "Sec-Fetch-Mode": "cors",
      //    "Sec-Fetch-Site": "same-origin",
      //    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
      //  };
      String response = await WebUtils.makePostRequest(KOUAISHOU_LIVE_API_URL_3, jsonEncode(requestMap), headers: headers);
      Map<String, dynamic> jsonResponse = json.decode(response);
      if (jsonResponse["error_msg"] == null) {
        finalFlvUrl = jsonResponse["liveStream"]["playUrls"][0]["url"] ??= "";
        if (jsonResponse["liveStreamEndReason"] != null && jsonResponse["liveStreamEndReason"] == "The Live ended.") {
          finalFlvUrl = "";
          liveStatusMap["offline"] = true;
        }
        else {
          liveStatusMap["online"] = true;
        }
      }
      else {
        liveStatusMap["apiError"] = true;
        error = "Username : ${username}\nError Message : " + jsonResponse["error_msg"];
      }
    } catch (e) {
      print(e);
      finalFlvUrl = "";
      liveStatusMap["exceptionError"] = true;
    }
    return (finalFlvUrl, error, liveStatusMap);
  }


  Future<String?> updateShareToken(List<UserKuaishou> list) async
  {
    String? shareToken;
    List<UserKuaishou> shuffleList = List.from(list);
    shuffleList.shuffle();
    for (UserKuaishou userKuaishou in shuffleList) {
      try {
        String finalUrl = "https://live.kuaishou.com/u/${userKuaishou.value}";
        String? orginalLink = await WebUtils.getOriginalUrl(
            finalUrl, headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 14; 23129RAA4G Build/UKQ1.231207.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.107 Mobile Safari/537.36"}, timeout: Duration(seconds: 15));
        Uri orginalUri = Uri.parse(orginalLink!);
        shareToken = orginalUri.queryParameters["shareToken"];
        if (shareToken != null) {
          break;
        }
      } catch (e) {
        print(e);
      }
    }
    return shareToken!;
  }

  String updateCookie(String currentCookie) {
    List<String> list = [
      "did=web_5db7f4c0d9664902af774fd08ebdf769; didv=1730628699000",
      "did=web_abb8d5daa36a428fbfe7ebdb68830bca; didv=1732683243000",
      "did=web_907321761e6e4eff96111b476bc9cad4; didv=1732694096000",
      "did=web_618d6ac474dd404a998cf2b641d96843; didv=1732694664000",
      "did=web_09abdedb117249279127a0cb9f829e81; didv=1732709899000",
      "did=web_2efca5ecf2984f99ad1aab086be65367; didv=1732710789000"
      "did=web_81ebb9322ec74073ac601fdb934cb676; didv=1732710974000"
    ];
    if (currentCookie.isEmpty) {
      int index = getIntBetweenRange(0, 4);
      String selectedCookie = list[index];
      return selectedCookie;
    }
    else {
      String selectedCookie;
      do {
        int index = getIntBetweenRange(0, 4);
        selectedCookie = list[index];
      } while (selectedCookie == currentCookie);
      return selectedCookie;
    }
  }

  Future<String> getUsernameFromKuaishouUrl(String kuaishouLink) async
  {
    String? orginalLink = await WebUtils.getOriginalUrl(kuaishouLink);
    Uri orginalUri = Uri.parse(orginalLink!);
    String? eid = orginalUri.path
        .split("/")
        .last;
    return eid;
  }


  Future<String> getStreamUrlForBackgroundUpload_Web(String userName) async
  {
    String streamUrl = "";
    String cookie = "clientid=3; did=web_dfa8864005520444a895fd1cb3c51538; client_key=65890b29; kpn=GAME_ZONE; _did=web_870397124DBD985F; didv=1730628663000; did=web_85aeaebcb9d6490bb484e761a201dd7c; Hm_lvt_86a27b7db2c5c0ae37fee4a8a35033ee=1730628678; kuaishou.live.bfb1s=7206d814e5c089a58c910ed8bf52ace5";
    String finalUrl = "https://live.kuaishou.com/u/$userName";
    try {
      var headers = {"Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Accept-Encoding": "gzip, deflate, br, zstd",
        "Accept-Language": "en-US,en;q=0.9,ur;q=0.8",
        "cache-control": "max-age=0",
        "connection": "keep-alive",
        "Cookie": cookie,
        "Host": "live.kuaishou.com",
        "Sec-Ch-Ua": "\"Google Chrome\";v=\"131\", \"Chromium\";v=\"131\", \"Not_A Brand\";v=\"24\"",
        "Sec-Ch-Ua-Mobile": "?0",
        "Sec-Ch-Ua-Platform": "Windows",
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Site": "none",
        "Sec-Fetch-User": "?1",
        "upgrade-insecure-requests": "1",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      };
      String? response = await WebUtils.makeGetRequest(finalUrl, headers: headers, timeout: Duration(seconds: 25));
      dom.Document document = WebUtils.getDomfromHtml(response!);
      String jsonRaw = document
          .querySelectorAll("script")
          .where((value) => value.text.contains("window.__INITIAL_STATE__"))
          .first
          .text;
      String jsonResponse = getStringBetweenTwoStrings("window.__INITIAL_STATE__ = {", "};", jsonRaw!).replaceAll(":,", ":\"\",").replaceAll("undefined", "\"\"").replaceAll("\"\"\"", "\"");
      Map<String, dynamic> jsonEncode = json.decode("{\"" + jsonResponse + "}");

      if ((jsonEncode["liveroom"]["playList"][0]["liveStream"] as Map).isNotEmpty && (jsonEncode["liveroom"]["playList"][0]["liveStream"]["playUrls"] as List).isNotEmpty) {
        streamUrl = jsonEncode["liveroom"]["playList"][0]["liveStream"]["playUrls"][0]["adaptationSet"]["representation"][0]["url"];
      }
      print("streamUrl : " + streamUrl);
    } catch (e) {
      streamUrl = "";
      print(e);
    }
    return streamUrl;
  }

  Future<String> getStreamUrlForBackgroundUpload_Web2(String url) async
  {
    String streamUrl = "";
    var header = {"user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"};
    try{
    String? orginalUrl = await WebUtils.getOriginalUrl(url,headers: header);
    String? response = await WebUtils.makeGetRequest(orginalUrl!,headers: header);
      dom.Document document = WebUtils.getDomfromHtml(response!);
      String jsonRaw = document
          .querySelectorAll("script")
          .where((value) => value.text.contains("window.__INITIAL_STATE__"))
          .first
          .text;
      String jsonResponse = getStringBetweenTwoStrings("window.__INITIAL_STATE__ = {", "};", jsonRaw!).replaceAll(":,", ":\"\",").replaceAll("undefined", "\"\"").replaceAll("\"\"\"", "\"");
      Map<String, dynamic> jsonEncode = json.decode("{\"" + jsonResponse + "}");

      if ((jsonEncode["liveroom"]["playList"][0]["liveStream"] as Map).isNotEmpty) {
        streamUrl = jsonEncode["liveroom"]["playList"][0]["liveStream"]["playUrls"]["h264"]["adaptationSet"]["representation"][0]["url"];
      }
      print("streamUrl : " + streamUrl);
    } catch (e) {
      streamUrl = "";
      print(e);
    }
    return streamUrl;
  }

  Future<String> getStreamUrlForBackgroundUpload_Mobile(String userName) async
  {
    String finalUrl = "https://live.kuaishou.com/u/$userName";
    String? oLink = await WebUtils.getOriginalUrl(finalUrl, headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36"});
    String? response = await WebUtils.makeGetRequest(oLink!, headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36"});
    return "";
  }

  Future startUploading(String links) async
  {
    //LoaderDialog.showLoaderDialog(Get.context!,text: "Uploading......");
    isUploading.value = true;
    List<String> urls = links.split("\n");
    urls.removeWhere((value) => value.isEmpty);
    Set<String> uniquePaths = {};
    for (String url in urls) {
      if (url.isNotEmpty) {
        String? flvUrl;
        if (isWebPageProcessing.value) {
          flvUrl = await getDirectKuaishouFlvUrl(url);
        }
        else {
          flvUrl = await getFlvUrlfromKuaihsouLink(url);
        }
        Uri uri = Uri.parse(flvUrl);
        String currentUrl = uri.origin + uri.path;
        if (flvUrl!.isNotEmpty && !isUrlExistsInDownlodingList(flvUrl, downloadingList) && uniquePaths.add(currentUrl)) {
          await remoteUploadStreamTape(flvUrl!, selectedFolder.value.id!);
        }
      }
      await Future.delayed(Duration(seconds: 3));
    }

    //LoaderDialog.stopLoaderDialog();
    isUploading.value = false;
    if (logText.contains("captcha")) {
      showmodalBottomSheet(Get.context!, logText);
    }
  }

  Future<bool> startUploading_background(String link, List<StreamtapeDownloadStatus> list,{bool isUnfollow = false}) async
  {
    if (!isUrlExistsInDownlodingList(link, list, isBackground: true)) {
      if (isUnfollow) {
        addUnfollowUsername(link);
      }
      await remoteUploadStreamTape(link!, SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID), isBackGroundProcess: true);
      await Future.delayed(Duration(seconds: getIntBetweenRange(1, 3)));
      return true;
    }
    else {
      return false;
    }
  }

  Future concurrentStartUploading(String links) async
  {
    //LoaderDialog.showLoaderDialog(Get.context!,text: "Uploading......");
    isUploading.value = true;
    List<String> urls = links.split("\n");
    urls.removeWhere((value) => value.isEmpty);
    List<Future<String>> flvUrlFutureList = [];
    List<Future<void>> streamtapeUploadingFutureList = [];
    List<String> flvUrls = [];
    showToast("Fetching Kuaishou Flv Url .....");
    for (String url in urls) {
      if (url.isNotEmpty) {
        if (isWebPageProcessing.value) {
          flvUrlFutureList.add(getDirectKuaishouFlvUrl(url));
        }
        else {
          flvUrlFutureList.add(getFlvUrlfromKuaihsouLink(url));
        }
      }
    }
    flvUrls = await Future.wait(flvUrlFutureList);
    List<String> distinctFlvUrlsList = removeDuplicateUrls(flvUrls);
    showToast("Uploading to Streamtape .....");
    for (String flvUrl in distinctFlvUrlsList) {
      if (flvUrl!.isNotEmpty && !isUrlExistsInDownlodingList(flvUrl, downloadingList)) {
        streamtapeUploadingFutureList.add(remoteUploadStreamTape(flvUrl!, selectedFolder.value.id!));
      }
    }
    await Future.wait(streamtapeUploadingFutureList);
    isUploading.value = false;
    //LoaderDialog.stopLoaderDialog();
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
      String? response = await WebUtils.makeGetRequest(STREAMTAPE_DOWNLOADING_STATUS_API_URL, headers: {"Cookie": currentCookie});
      Map<String, dynamic> jsonMap = jsonDecode(response!);
      List<dynamic> list = (jsonMap["data"] as List<dynamic>);
      if (!isSync) {
        for (dynamic item in list) {
          Uint8List? bytes;
          Uint8List? bytesBox = getDownloadingLinkId(item["id"]);
          if (item["status"] != "error") {
            if (bytesBox == null || bytesBox.isEmpty) {
              bytes = await VideoCaptureUtils().captureImage(item["url"], 500);
              setDownloadingLinkId(item["id"], bytes);
            }
            else {
              bytes = getDownloadingLinkId(item["id"]);
            }
          }
          bool isUnfollowUser = isUrlExistInUnfollowUserListBox(item["url"]);
          downloadingList.add(StreamtapeDownloadStatus(status: item["status"],
              url: item["url"],
              imageBytes: bytes,
              id: item["id"],
              isUnfollowUser: isUnfollowUser,
              isThumbnailUpdating: false.obs));

          this.update(["updateDownloadingList"]);
        }
        await deleteAllExcept(downloadingListIdBox, downloadingList.map((value) => value.id).toList());
        //await deleteAllExcept(unfollowUserUrlListBox, downloadingList.map((value) => value.url).toList());
      } else {
        // For removing links
        //if (downloadingList.length > list.length) {
        tempdownloadingList.clear();
        for (StreamtapeDownloadStatus item in downloadingList) {
          bool isExist = list.any((value) => value["id"] == item.id);
          if (!isExist) {
            tempdownloadingList.add(item);
          }
        }
        for (StreamtapeDownloadStatus item in tempdownloadingList) {
          downloadingList.remove(item);
        }

        this.update(["updateDownloadingList"]);
        // }

        // For adding downloading links
        // if (downloadingList.length < list.length) {
        for (dynamic item in list) {
          tempdownloadingList.clear();
          bool isExist = downloadingList.any((value) => value.id == item["id"]);
          if (!isExist) {
            Uint8List? bytes;
            Uint8List? bytesBox = getDownloadingLinkId(item["id"]);
            if (item["status"] != "error") {
              if (bytesBox == null || bytesBox.isEmpty) {
                bytes = await VideoCaptureUtils().captureImage(item["url"], 500);
                setDownloadingLinkId(item["id"], bytes);
              }
              else {
                bytes = getDownloadingLinkId(item["id"]);
              }
            }
            bool isUnfollowUser = isUrlExistInUnfollowUserListBox(item["url"]);
            downloadingList.add(StreamtapeDownloadStatus(status: item["status"],
                url: item["url"],
                imageBytes: bytes,
                id: item["id"],
                isUnfollowUser: isUnfollowUser,
                isThumbnailUpdating: false.obs));

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
      String? response = await WebUtils.makeGetRequest(STREAMTAPE_DOWNLOADING_STATUS_API_URL, headers: {"Cookie": currentCookie});
      Map<String, dynamic> jsonMap = jsonDecode(response!);
      List<dynamic> list = (jsonMap["data"] as List<dynamic>);
      List<Future<StreamtapeDownloadStatus>> streamtapeStatusList = [];
      if (!isSync) {
        for (dynamic item in list) {
          streamtapeStatusList.add(getDownloadingDetailItem(item, 500));
        }
        List<StreamtapeDownloadStatus> downloadingListFuture = await Future.wait(streamtapeStatusList);
        downloadingList.addAll(downloadingListFuture);
        this.update(["updateDownloadingList"]);
        await deleteAllExcept(downloadingListIdBox, downloadingList.map((value) => value.id).toList());
        //await deleteAllExcept(unfollowUserUrlListBox, downloadingList.map((value) => value.url).toList());
      } else {
        // For removing links
        //if (downloadingList.length > list.length) {
        tempdownloadingList.clear();
        for (StreamtapeDownloadStatus item in downloadingList) {
          bool isExist = list.any((value) => value["id"] == item.id);
          if (!isExist) {
            tempdownloadingList.add(item);
          }
        }
        for (StreamtapeDownloadStatus item in tempdownloadingList) {
          downloadingList.remove(item);
        }

        this.update(["updateDownloadingList"]);
        // }

        // For adding downloading links
        // if (downloadingList.length < list.length) {
        for (dynamic item in list) {
          tempdownloadingList.clear();
          bool isExist = downloadingList.any((value) => value.id == item["id"]);
          if (!isExist) {
            streamtapeStatusList.add(getDownloadingDetailItem(item, 500));
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

  bool isUrlExistsInDownlodingList(String url, List<StreamtapeDownloadStatus> list, {bool isBackground = false}) {
    Uri currentUri = Uri.parse(url);
    String currentUrl = currentUri.origin + currentUri.path;
    for (StreamtapeDownloadStatus streamtapeDownloadStatus in list) {
      Uri downloadingUri = Uri.parse(streamtapeDownloadStatus.url!);
      String downloadUrl = downloadingUri.origin + downloadingUri.path;
      if (downloadUrl == currentUrl) {
        if (!isBackground) {
          showToast("Url already exists ($url)", isDurationLong: true);
        }
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

  showToast(String text, {bool isDurationLong = false, bool isError = false}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: isDurationLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? Colors.red : Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void setDownloadingLinkId(String id, Uint8List? value) {
    downloadingListIdBox.put(id, value);
  }

  Uint8List? getDownloadingLinkId(String id) {
    return downloadingListIdBox.get(id, defaultValue: Uint8List.fromList([]));
  }

  void setUsernameId(String id, String? value) {
    usernameListIdBox.put(id, value);
  }

  Uint8List? getUsernameId(String id) {
    return usernameListIdBox.get(id, defaultValue: "");
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

  void showmodalBottomSheet(BuildContext contxt, String value) {
    showModalBottomSheet(
        context: contxt,
        builder: (context) {
          return SingleChildScrollView(child: Text(value),);
        }
    );
  }


  Future<StreamtapeDownloadStatus> getDownloadingDetailItem(dynamic item, int seekPosition) async {
    Uint8List? bytes;
    Uint8List? bytesBox = getDownloadingLinkId(item["id"]);
    if (item["status"] != "error") {
      if (bytesBox == null || bytesBox.isEmpty) {
        final directory = await getTemporaryDirectory();
        final String outputPath = '${directory.path}/${Random().nextInt(10000000)}.jpg';

        String command = '-i ${item["url"]} -ss ${seekPosition / 1000} -vframes 1 $outputPath';

        FFmpegSession session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();


        if (ReturnCode.isSuccess(returnCode)) {
          File outputFile = File(outputPath);
          bytes = await outputFile.readAsBytes();
          setDownloadingLinkId(item["id"], bytes);
          if (await outputFile.exists()) {
            await outputFile.delete();
          }
        }
      }
      else {
        bytes = getDownloadingLinkId(item["id"]);
      }
    }
    bool isUnfollowUser = isUrlExistInUnfollowUserListBox(item["url"]);
    return StreamtapeDownloadStatus(status: item["status"],
        url: item["url"],
        imageBytes: bytes,
        id: item["id"],
        isUnfollowUser: isUnfollowUser,
        isThumbnailUpdating: false.obs);
  }

  Future<(String?, String?)?> getMp4UrlFromStreamTape(String embededUrl, {bool isVideotoEmbededAllowed = false, Map<String, String>? headers}) async
  {
    if (isVideotoEmbededAllowed) {
      embededUrl = embededUrl.replaceAll("/v/", "/e/");
    }
    try {
      dom.Document document = await WebUtils.getDomFromURL_Get(embededUrl, headers: headers);
      String? imageUrl;
      if (document.querySelector("meta[name=\"og:image\"]") != null) {
        imageUrl = document.querySelector("meta[name=\"og:image\"]")!.attributes["content"];
      }
      String? ideooLink = document.querySelector("#ideoolink")!.text;
      List<dom.Element> list = document.querySelectorAll("script");
      String? javaScript = list[9].text;
      String? tokenString = getStringBetweenTwoStrings("<script>document.getElementById('ideoolink').innerHTML =", "')", javaScript);
      String? token = getStringAfterStartStringToEnd("&token=", tokenString);
      String dlUrl = "https:/" + ideooLink + "&token=" + token + "&dl=1s";
      //String dlUrl = "https:/" + ideooLink + "&dl=1s";
      return (dlUrl, imageUrl);
    } catch (e) {
      Fluttertoast.showToast(msg: "", toastLength: Toast.LENGTH_LONG, backgroundColor: Colors.red);
    }
  }

  String getStringBetweenTwoStrings(String start, String end, String str) {
    final startIndex = str.indexOf(start);
    final endIndex = str.indexOf(end, startIndex + start.length);

    return str.substring(startIndex + start.length, endIndex); // brown fox jumps
  }

  String getStringAfterStartStringToEnd(String start, String str) {
    final startIndex = str.indexOf(start);

    return str.substring(startIndex + start.length, str.length);
  }


  getDownloadLinks(String id) async
  {
    isSearching = false;
    DialogUtils.showLoaderDialog(Get.context!);
    downloadLinks.value = "";
    downloadLinksList = [];
    StringBuffer stringBuffer = StringBuffer("");
    StreamTapeFolder streamTapeFolder = await getFolderFiles(id);
    streamTapeFolder.files!.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    for (StreamtapeFileItem streamtapeFileItem in streamTapeFolder.files!) {
      downloadLinksList.add(DownloadItem(streamtapeFileItem.name, "Press Download icon to get link....", "", streamtapeFileItem.link!, false.obs, false.obs));
      //stringBuffer.write(mp4ImageUrl.$1! +"\n\n");
      //downloadLinks.value = stringBuffer.toString();
      this.update(["updateStreamtapeDownloadingList"]);
    }
    DialogUtils.stopLoaderDialog();
  }


  Future<bool> fetchStreamTapeImageAndDownloadUrl(DownloadItem? downloadItem) async
  {
    downloadItem!.isLoading!.value = true;

    //if (downloadItem!.downloadUrl == null || downloadItem!.downloadUrl == "Press Download icon to get link...."  || downloadItem!.downloadUrl == "Unable to get download url....") {
    try {
      (String?, String?)? mp4ImageUrl = await getMp4UrlFromStreamTape(downloadItem.streamTapeUrl!, isVideotoEmbededAllowed: true);

      downloadItem!.downloadUrl = mp4ImageUrl!.$1 != null ? mp4ImageUrl!.$1 : "Unable to get download url....";
      downloadItem!.imageUrl = mp4ImageUrl!.$2 != null ? mp4ImageUrl!.$2 : "";
    } catch (e) {
      downloadItem!.downloadUrl =  "Unable to get download url....";
      downloadItem!.imageUrl = "";
    }
    //}

    downloadItem!.isLoading!.value = false;

    update(["updateStreamtapeDownloadingList"]);
    return true;
  }

  List<List<T>> getbatchList<T>(List<T> list, int batchSize) {
    if (batchSize <= 0) {
      throw ArgumentError("Batch size must be greater than zero.");
    }

    List<List<T>> batches = [];
    int length = list.length;
    int i = 0;

    while (i < length) {
      int end = (i + batchSize < length) ? i + batchSize : length;
      List<T> currentBatch = list.sublist(i, end);

      // Check if the next batch would be less than half of batchSize
      if (end < length) {
        int nextBatchSize = length - end;
        if (nextBatchSize < (batchSize / 2)) {
          // Include the next batch in the current batch
          currentBatch.addAll(list.sublist(end, length));
          end = length; // Adjust the end to the length of the list
        }
      }

      batches.add(currentBatch);
      i = end; // Move to the start of the next batch
    }

    return batches;
  }

  selectOrUnselectAllItems() {
    List<DownloadItem> filteredDownloadList = currentDownloadList.where((downloadItem) => isStreamTapeDownloadUrlLoaded(downloadItem)).toList();
    if(filteredDownloadList.isEmpty)
      {
        showToast("No Links Found....");
        return;
      }
    bool isSelectedAll = filteredDownloadList.every((item) => item.isSelected!.value == true);
    bool isDeSelectedAll = filteredDownloadList.every((item) => item.isSelected!.value == false);

    for (DownloadItem downloadtItem in filteredDownloadList) {
      if (isSelectedAll) {
        downloadtItem.isSelected!.value = false;
      }
      else if (isDeSelectedAll) {
        downloadtItem.isSelected!.value = true;
      }
      else if (!isSelectedAll && !isDeSelectedAll) {
        downloadtItem.isSelected!.value = true;
      }
    }
    update(["updateCopyFloatingActionButtonVisibility"]);
  }

  loadAllItemsLinks() async
  {
    List<DownloadItem> filteredDownloadList = currentDownloadList.where((downloadItem) => !isStreamTapeDownloadUrlLoaded(downloadItem)).toList();
    List<List<DownloadItem>> downloadListBatch = getbatchList(filteredDownloadList, 5);
    for (List<DownloadItem> downloadItemList in downloadListBatch) {
      List<Future<bool>> fetchStreamTapeImageAndDownloadUrlFutureList = [];
      for (DownloadItem downloadItem in downloadItemList) {
        fetchStreamTapeImageAndDownloadUrlFutureList.add(fetchStreamTapeImageAndDownloadUrl(downloadItem));
      }
      await Future.wait(fetchStreamTapeImageAndDownloadUrlFutureList);
      await Future.delayed(Duration(seconds: 2));
    }
  }

  String getKuaishouLink(String text) {
    RegExp exp = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    RegExpMatch? match = exp.firstMatch(text);
    return text.substring(match!.start, match!.end);
  }

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }

  List<UserKuaishou> getAllUserList() {
    final allKeys = usernameListIdBox.keys;
    List<UserKuaishou> list = [];
    // Iterate over all keys and delete those not in keysToKeep
    for (var key in allKeys) {
      list.add(UserKuaishou(id: key, value: usernameListIdBox.get(key)));
    }

    return list;
  }

  Future deleteUserName(String id) async
  {
    await usernameListIdBox.delete(id);
  }

  Future addUsername(String userName) async
  {
    if (!usernameListIdBox.values.toList().any((value) => value.toString().contains(userName))) {
      await usernameListIdBox.put(generateRandomString(10), userName);
    }
    else {
      showToast("User already exists");
    }
  }

  Future addUnfollowUsername(String url) async
  {
    if (!unfollowUserUrlListBox.values.toList().any((value) => value.toString().contains(url))) {
      await unfollowUserUrlListBox.put(generateRandomString(10), url);
    }
  }

  bool isUrlExistInUnfollowUserListBox(String url)
  {
    return unfollowUserUrlListBox.values.toList().any((value) => value.toString().contains(url));
  }

  Future<List<StreamtapeDownloadStatus>> getRemoteDownloadingStatus_background() async
  {
    List<StreamtapeDownloadStatus> streamtapeDownloadStatusList = [];
    await SharedPrefsUtil.initSharedPreference();
    String? response = await WebUtils.makeGetRequest(STREAMTAPE_DOWNLOADING_STATUS_API_URL, headers: {"Cookie": SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE)});
    Map<String, dynamic> jsonMap = jsonDecode(response!);
    List<dynamic> list = (jsonMap["data"] as List<dynamic>);

    for (dynamic item in list) {
      if (item["status"] == "error") {
        await deleteRemoteUploadingVideo(item["id"], isBackGroundProcess: true);
      }
      streamtapeDownloadStatusList.add(StreamtapeDownloadStatus(status: item["status"],
          url: item["url"],
          id: item["id"],
          isThumbnailUpdating: false.obs));
    }
    return streamtapeDownloadStatusList;
  }


  int getIntBetweenRange(int min, int max) {
    final _random = new Random();

    /**
     * Generates a positive random integer uniformly distributed on the range
     * from [min], inclusive, to [max], exclusive.
     */
    return min + _random.nextInt(max - min);
  }

  (int, int) getDelayTimeRage(int totalTime, int listLenght) {
    int secs = totalTime * 60;
    int timerPerUser = (secs / listLenght).toInt();
    int max = (timerPerUser / 2.3).toInt();
    int min = (max / 2).toInt();
    return (min, max);
  }

  Future<(List<ListElement>, String)> getLiveUserList(Function((String, int, bool)) callback) async
  {
    List<ListElement> list = [];
    String exception = "";
    do {
      int time = getIntBetweenRange(1, 3);
      if (exception.isNotEmpty) {
        await Future.delayed(Duration(minutes: time));
      }
      exception = "";
      try {
        var headers = {
          "Cookie": "clientid=3; did=web_dfa8864005520444a895fd1cb3c51538; client_key=65890b29; kpn=GAME_ZONE; _did=web_870397124DBD985F; didv=1730628663000; did=web_85aeaebcb9d6490bb484e761a201dd7c; Hm_lvt_86a27b7db2c5c0ae37fee4a8a35033ee=1730628678; userId=1584032460; userId=1584032460; kuaishou.live.bfb1s=9b8f70844293bed778aade6e0a8f9942; showFollowRedIcon=1; kuaishou.live.web_st=ChRrdWFpc2hvdS5saXZlLndlYi5zdBKgAduhWJuSZsFgEigNcXjuUANOh_bKu9KgEgCO2gJI8Lmi3VCz_BmBJbMOzQB1nG27Md_Un9EApYm3a0z1f30Gqjimq1DVTvswD2Z8r9uTlWkCskDe6mRkpFSRr3deu5c0w70xQjBSqy2peLWJQINA6zvmosJnYpgBtc_KEOGiefwhkrxJIFj5XLxz6JWxDjTQgpT5R9dn3Y-PRlA5Z3PB_YYaErZBy_JDfEY0lUogcFFbVS54zCIgz9mS_5B75NRPjfU30fUAOStq_FhwI8ZpQ0wSTisSi58oBTAB; kuaishou.live.web_ph=94ca92257e728995d3cf2ac2279002dfa289"
        };
        String? reponse = await WebUtils.makeGetRequest(KOUAISHOU_LIVE_FOLLOW_API, headers: headers, timeout: Duration(seconds: 15));
        KuaishouLiveUser kuaishouLiveUser = KuaishouLiveUser.fromJson(jsonDecode(reponse!));
        list = kuaishouLiveUser.data!.list;
        callback(("", 0, false));
      } catch (e) {
        print(e);
        exception = e.toString();
        callback((exception, time, true));
      }
    } while (exception.isNotEmpty);
    return (list, exception);
  }

  void initBackgroundModeWithTime(int start, int end) async {
    backgroundModeTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();

      if (start == 0 && now.hour == 23 && now.minute == 59) {
        BackgroundMode.start();
      }
      else if (start != 0) {
        if ((start - 1) == now.hour && now.minute == 59) {
          BackgroundMode.start();
        }
      }

      if (now.hour >= start && now.hour <= end) {
        BackgroundMode.disable();
        BackgroundMode.bringToForeground();
      }
      if (now.hour > end && (now.hour - 1 == end)) {
        BackgroundMode.disable();
      }
    });
  }

  void initBackgroundMode() async {
    BackgroundMode.start();
    backgroundModeTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      BackgroundMode.disable();
      BackgroundMode.bringToForeground();
    });
  }

  Future restartBackgroundService({bool isToEnableSlider = true}) async
  {
    showToast('Restarting Background Service.....');
    if (isToEnableSlider) {
      isSliderEnable.value = false;
      Timer(Duration(seconds: 6), () {
        isSliderEnable.value = true;
      });
    }
    stopBackgroundService();
    await Future.delayed(Duration(seconds: 2));
    startBackgroundService();
  }


  processBackgroundMode()
  {
    if(isBackgroundModeEnable.value)
    {
      isBackGroundModeTimeRadioButtonsVisible.value = true;
      backgroundModeTimeEnumRadioValue.value = BackgroundModeTimeEnum.values.firstWhere((value) => value.name == SharedPrefsUtil.getString(SharedPrefsUtil.KEY_BACKGROUNDMODE_TIME,defaultValue: BackgroundModeTimeEnum.ALLTIME.name));
      isBackgroundModeRangeSliderVisible.value = isBackgroundModeEnable.value && SharedPrefsUtil.getString(SharedPrefsUtil.KEY_BACKGROUNDMODE_TIME,defaultValue: BackgroundModeTimeEnum.ALLTIME.name) == BackgroundModeTimeEnum.TIMESPECIFIC.name;
      String backgroundTimeRageValue = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_BACKGROUNDMODE_TIME_RANGE,defaultValue: "");
      if(backgroundTimeRageValue.isNotEmpty && isBackgroundModeRangeSliderVisible.value)
      {
        List<String> valueList = backgroundTimeRageValue.split(":");
        double start = double.parse(valueList[0]);
        double end = double.parse(valueList[1]);
        backgroundModeTimeSpecificRangeValue.value = RangeValues(start, end);
      }


      if(backgroundModeTimer != null && backgroundModeTimer!.isActive)
        {
          backgroundModeTimer!.cancel();
          backgroundModeTimer == null;
        }

      if(backgroundModeTimeEnumRadioValue.value == BackgroundModeTimeEnum.ALLTIME)
      {
        initBackgroundMode();
      }
      else
      {
        initBackgroundModeWithTime(backgroundModeTimeSpecificRangeValue.value.start.toInt(),backgroundModeTimeSpecificRangeValue.value.end.toInt());
      }

    }
    else
    {
      if(backgroundModeTimer != null &&backgroundModeTimer!.isActive)
      {
        backgroundModeTimer!.cancel();
        BackgroundMode.disable();
      }
    }
  }

  Future uploadUnfollowUserWithWebView (int min) async
  {
    if(unfollowUserTimer != null)
      {
        unfollowUserTimer!.cancel();
        unfollowUserTimer == null;
      }
    for(StopWatchTimer stopwatch in unfollowUserStopwatch)
      {
        stopwatch.onStopTimer();
      }
    unfollowUserStopwatch = [];
    List<UserKuaishou> list = getAllUserList();
    List<UserKuaishou> listFiltered = list.where((user)=>user.value!.contains("<||>UNFOLLOW")).toList();
    if (listFiltered.length > 0) {
      int totalMin = getUnfollowMin(listFiltered);
      SharedPrefsUtil.setInt(SharedPrefsUtil.KEY_CURRENT_UNFOLLOW_MIN,totalMin);
      unfollowCurrentTime.value = totalMin;
      unfollowUserTimer = makePeriodicTimer(Duration(minutes: totalMin),fireNow: true,isCustomTimer: true,isUnfollowTimer: true,(timer) async {
        final stopWatchTimer = StopWatchTimer(
            mode: StopWatchMode.countDown,
            presetMillisecond: StopWatchTimer.getMilliSecFromMinute(SharedPrefsUtil.getInt(SharedPrefsUtil.KEY_CURRENT_UNFOLLOW_MIN,)), // millisecond => minute.
            onChangeRawSecond: (value) async {
              unfollowUploadRemainingTime.value = "Next in : ${formatTime(value)}";
            }
        );
        stopWatchTimer.onStartTimer();
        unfollowUserStopwatch.add(stopWatchTimer);
        isUnfollowUserProcessing.value = true;
        List<StreamtapeDownloadStatus> streamTapeDownloadStatusList = await getRemoteDownloadingStatus_background();
        unfollowUserUploaded.value = 0;
        unfollowUserOnline.value = 0;
        unfollowUserError.value = 0;
        unfollowUserErrorCaptcha.value = 0;
        unfollowUserFrequentRequests.value = 0;
        unfollowUserOthers.value = 0;
        unfollowUserOffline.value = 0;
        totalUnfollowUserUploadedProgress.value = "0/${listFiltered.length}";
        for (UserKuaishou userKuaishou in listFiltered) {
            try {
              String initialUrl = "https://v.kuaishou.com${userKuaishou.value!.replaceAll("<||>UNFOLLOW", "")}";
            //   String url = await getFlvUrlfromKuaihsouLink(initialUrl);
            //   if (url.isNotEmpty) {
            //     unfollowUserOnline.value  = unfollowUserOnline.value + 1;
            //     bool isUploaded = await startUploading_background(url, streamTapeDownloadStatusList);
            //     if(isUploaded)
            //     {
            //       unfollowUserUploaded.value = unfollowUserUploaded.value + 1;
            //     }
            //   }
            // } catch (e) {
            //   print(e);
            // }
            // totalUnfollowUserUploadedProgress.value = "${listFiltered.indexOf(userKuaishou)+1}/${listFiltered.length}";
            // await Future.delayed(Duration(seconds: getIntBetweenRange(20, 30)));
              //List<String> cookie = ["web_907321761e6e4eff96111b476bc9cad4","web_5db7f4c0d9664902af774fd08ebdf769","web_618d6ac474dd404a998cf2b641d96843"];
              String cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE);
              bool isCaptchaRequired = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED);
              if (cookie.isNotEmpty && !isCaptchaRequired) {
                (String,ApiErrorEnum) urlError = await getDirectKuaishouFlvUrlOrginal(initialUrl,cookie);
                if (urlError.$2 == ApiErrorEnum.NONE) {
                  if (urlError.$1.isNotEmpty) {
                     unfollowUserOnline.value  = unfollowUserOnline.value + 1;
                     bool isUploaded = await startUploading_background(urlError.$1, streamTapeDownloadStatusList,isUnfollow: true);
                     if(isUploaded)
                       {
                         unfollowUserUploaded.value = unfollowUserUploaded.value + 1;
                       }
                   }
                }
                else
                  {
                    if(urlError.$2 == ApiErrorEnum.CAPTCHA_REQUIRED)
                      {
                        unfollowUserErrorCaptcha.value = unfollowUserErrorCaptcha.value + 1;
                        SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, true);
                      }
                    else if(urlError.$2 == ApiErrorEnum.EXCEPTION)
                      {
                        unfollowUserError.value = unfollowUserError.value + 1;
                      }
                    else if(urlError.$2 == ApiErrorEnum.FREQUENT_REQUESTS)
                      {
                        unfollowUserFrequentRequests.value = unfollowUserFrequentRequests.value + 1;
                      }
                      else if(urlError.$2 == ApiErrorEnum.OTHERS)
                      {
                        unfollowUserOthers.value = unfollowUserOthers.value + 1;
                      }
                      else if(urlError.$2 == ApiErrorEnum.OFFLINE)
                      {
                        unfollowUserOffline.value = unfollowUserOffline.value + 1;
                      }
                  }
              }
            } catch (e) {
              print(e);
            }
            totalUnfollowUserUploadedProgress.value = "${listFiltered.indexOf(userKuaishou)+1}/${listFiltered.length}";
            await Future.delayed(Duration(seconds: getIntBetweenRange(35, 40)));

        }
        isUnfollowUserProcessing.value = false;
      });
    }
  }


  Future<void> createFolderOnNextDay() async
  {
    DateTime currentDateTime = DateTime.now();
     if(currentDateTime.hour == 0)
       {
        String folderName = "Kwai ${currentDateTime.day} ${currentDateTime.month} ${currentDateTime.year % 100}";
        StreamTapeFolder streamTapeFolder = await fetchFolderList(isBackground: true);
        bool isFolderExist = streamTapeFolder.folders!.any((folder)=> folder.name == folderName);
        if(!isFolderExist)
          {(bool,String) statusId = await createFolder(folderName,isBackground: true);
          if (statusId.$1) {
            SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_NEW_FOLDER_CREATED, true);
            SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, folderName);
            SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, statusId.$2);
          }}
      }
  }

  bool isStreamTapeDownloadUrlLoaded (DownloadItem downloadItem)
  {
    return downloadItem!.downloadUrl != null && downloadItem!.downloadUrl != "Press Download icon to get link...."  && downloadItem!.downloadUrl != "Unable to get download url....";
  }

}