
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
import 'package:kuaishou_remote_uploader/models/tiktok_live_response.dart';
import 'package:kuaishou_remote_uploader/models/user_kuaishou.dart';
import 'package:kuaishou_remote_uploader/utils/gist_service.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:kuaishou_remote_uploader/utils/video_capture_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_view_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/src/widgets/text.dart' as txt;
import 'package:random_user_agents/random_user_agents.dart';
import 'package:flutter/services.dart';




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
  String STREAMTAPE_DELETE_FILE_API_URL = "https://streamtape.com/api/website/filemanager/file/del";
  String STREAMTAPE_RENAME_API_URL = "https://streamtape.com/api/website/filemanager/folder/rename";
  String STREAMTAPE_COPY_API_URL = "https://streamtape.com/api/website/filemanager/file/copy";
  String KOUAISHOU_LIVE_API_URL = "https://klsxvkqw.m.chenzhongtech.com/rest/k/live/byUser?kpn=NEBULA&kpf=OUTSIDE_ANDROID_H5&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_2 = "https://livev.m.chenzhongtech.com/rest/k/live/byUser?kpn=GAME_ZONE&kpf=OUTSIDE_ANDROID_H5&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_3 = "https://livev.m.chenzhongtech.com/rest/k/live/byUser?kpn=GAME_ZONE&kpf=UNKNOWN_PLATFORM&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_4 = "https://v.m.chenzhongtech.com/rest/k/live/byUser?kpn=KUAISHOU&kpf=OUTSIDE_ANDROID_H5&captchaToken=";
  String KOUAISHOU_LIVE_API_URL_5 = "https://klsxvkqw.m.chenzhongtech.com/rest/k/live/byUser?kpn=NEBULA&kpf=UNKNOWN_PLATFORM&captchaToken=HEADCgp6dC5jYXB0Y2hhEtMCFJNAWpBNdfMfdnHcCLEyper4lASo9foKIFLNtFTVR_sF6Iafj4fRatV5JSV5JH0vjmIgk97FCjcpSJq42DGH4rdJ0ZllRH1hD-ny_EPyyyTjCURt-UqB8en6q8ll0K5TjY9K09l6_OkjyxX9CVFWkhY_--a9hm3Ay_Uf_iHLrn8_VcKfEHZmxnj7Oh--BoESFnHvVGxFn9TGLKKIozIdafTNtuFFtxY4__UrDLnZGYHQrA6CevqttA5WqE7YQvwXEz_Y7EtIIalOCFxtirZPgOiMQ425gw3XjZzDjQRwYdOge4sJO83maNTVsmX_sgBYETZxOuWmUhSglSGY67ygVPk6B1NwNLH3jesmph4VNGJM6rbi0yWbOtd2yLNWxr-HICvglWV4oDbrN-cczkrYCoYDyjTXRP62iK8x3wnuOrGKTXM_vEymib0kHp8AuGb35oj9GhJxat9v18_vGhz0w0fGzFHTlSooBTACTAIL";
  String KOUAISHOU_MAIN_MOBILE_URL = "https://livev.m.chenzhongtech.com/fw/live/";
  String KOUAISHOU_LIVE_FOLLOW_API = "https://live.kuaishou.com/live_api/follow/living";
  String KOUAISHOU_USER_API = "https://live.kuaishou.com/live_api/profile/public?count=4&pcursor=&principalId=s14042236&hasMore=true";
  String HTTPIE_PROXY_URL = "https://httpie.io/app/api/proxy";
  String USER_AGENT_LIST_URL = "https://gist.githubusercontent.com/eteubert/1dd9692d4dfa2548fbfb550782daa95e/raw/988af488af6994a309756927ac3a380c66e4badf/user_agents.csv";

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
  late Box unfollowUrlListIdBox;
  late Box unfollowUserUrlListBox;
  Box? kuaishouLiveUserListBox;
  Box? tiktokUserUrlListBox;

  ScrollController scrollController = ScrollController();

  String logText = "";
  RxBool isConcurrentProcessing = true.obs;
  RxBool isWebPageProcessing = true.obs;
  RxBool isBackgroundModeEnable = false.obs;
  RxBool isConcurrentUnfollowUploadingEnable = true.obs;
  RxBool isRandomCaptchaUserEnable = true.obs;
  RxBool isUnfollowUploadwithDeplayEnable = true.obs;
  RxBool isUploadingEnable = false.obs;
  RxBool isAutoUnfollowCaptchaVerification = true.obs;
  RxBool isEnableStreamTapeUrlFromEmbeded = false.obs;
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
  RxInt unfollowUserIntervalSliderValue = 5.obs; //
  RxInt unfollowCurrentTime = 1.obs; //
  Timer? backgroundModeTimer;
  RxBool isSliderEnable = true.obs;
  Rx<BackgroundModeTimeEnum> backgroundModeTimeEnumRadioValue = BackgroundModeTimeEnum.ALLTIME.obs;
  Rx<RangeValues> backgroundModeTimeSpecificRangeValue = const RangeValues(0, 6).obs;
  Rx<RangeValues> unfollowApiIntervalRangeValue = const RangeValues(15, 25).obs;
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
  RxInt unfollowLiveStreamOver = 0.obs;
  RxBool isToUpdateFolder = false.obs;
  static bool isVerifyCaptchaShowing = false;
  static bool isUnfollowExceptionOccured = false;

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
    var status = await Permission.manageExternalStorage.request();
    var notification = await Permission.notification.request();
    var ignorebattery = await Permission.ignoreBatteryOptimizations.request();


    isConcurrentProcessing.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CONCURRENT_PROCESS, defaultValue: true);
    isWebPageProcessing.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_WEB_PAGE_PROCESS, defaultValue: true);
    isBackgroundModeEnable.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_BACKGROUNDMODE_ENABLE, defaultValue: false);
    isConcurrentUnfollowUploadingEnable.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_CONCURRENT_UNFOLLOW_USER_UPLOADING, defaultValue: true);
    isRandomCaptchaUserEnable.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_RANDOM_CAPTCHA_USER, defaultValue: false);
    isUnfollowUploadwithDeplayEnable.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_UNFOLLOW_UPLOAD_WITH_DELAY, defaultValue: false);
    isUploadingEnable.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_UPLOADING, defaultValue: false);
    isAutoUnfollowCaptchaVerification.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_AUTO_UNFOLLOW_USER_CAPTCHA_VERIFICATION, defaultValue: true);
    isEnableStreamTapeUrlFromEmbeded.value = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_STREAMTAPE_FETCH_FROM_EMBEDED, defaultValue: false);
    processBackgroundMode();
    midNightSliderValue.value = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_MIDNIGHT_SLIDER, defaultValue: 15); // 12:00 AM -> 06:00 AM
    morningAfterNoonSliderValue.value = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_MORNINGAFTERNOON_SLIDER, defaultValue: 10); // 6:00 AM -> 4:00 PM
    eveningNightSliderValue.value = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_EVENINGNIGHT_SLIDER, defaultValue: 7); // 4:00 PM -> 12:00 AM
    unfollowUserIntervalSliderValue.value = SharedPrefsUtil.getInt(SharedPrefsUtil.KEY_UNFOLLOW_USER_TIMER, defaultValue: 5); // 4:00 PM -> 12:00 AM
    unfollowApiIntervalRangeValue.value = getRangeValuesFromString(SharedPrefsUtil.getString(SharedPrefsUtil.KEY_UNFOLLOW_API_INTERVAL, defaultValue: "15:25"));
    downloadingListIdBox = await Hive.openBox("downloadingListId");
    usernameListIdBox = await Hive.openBox("usernameListIdBox");
    unfollowUrlListIdBox = await Hive.openBox("unfollowUrlListIdBox");
    unfollowUserUrlListBox = await Hive.openBox("unfollowUserUrlListBox");
    tiktokUserUrlListBox = await Hive.openBox("tiktokUserUrlListBox");
    kuaishouLiveUserListBox = await Hive.openBox("kuaishouLiveUserListBox");
    String? cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
    String? csrf = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
    String cookieKuaishou = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE);
    bool isCaptchaRequired = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED);
    bool isAutoCaptcha =  SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_AUTO_UNFOLLOW_USER_CAPTCHA_VERIFICATION,defaultValue: true);


    if(cookie.isNotEmpty && csrf.isNotEmpty && cookieKuaishou.isNotEmpty && (!isCaptchaRequired || isAutoCaptcha))
    {
      await initiateUnfollowUploadingProcess();
    }
    // if(isRefresh)
    //   {
    await CookieManager.instance().deleteAllCookies();
    // }
    if (((cookie == null || cookie.isEmpty) &&
        (csrf == null || csrf.isEmpty)) || isRefresh) {
      if (unfollowUserTimer != null && unfollowUserTimer!.isActive) {
        unfollowUserTimer!.cancel();
      }
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
            await verifyCaptcha();
            if (!SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_FIRST_TIME)) {
              SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_FIRST_TIME, true);
              bool result = await importUsers(isSilent: true);
            }
            await startServicesIfUserAvailable();
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


  Future<void> getFolderList({bool isDeleted = false,bool isResume = false}) async
  {
    if (isResume) {
      isLoading.value = true;
    }
    streamTapeFolder = await fetchFolderList();
    DateTime currentDateTime = DateTime.now();
    String folderName = "Kwai ${currentDateTime.day} ${currentDateTime.month} ${currentDateTime.year % 100}";
    String? selectedFolderSP = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER, defaultValue: "");
    if (selectedFolderSP.isNotEmpty && !isDeleted && folderName == selectedFolderSP) {
       selectedFolder.value = streamTapeFolder!.folders!.where((e) => e.name ==  selectedFolderSP/*"Kwai 1 11 24"*/).first;
    }
    else {

      StreamTapeFolderItem? currentStreamTapeFolder = streamTapeFolder!.folders!.where((e) => e.name ==  folderName).firstOrNull;
      if(currentStreamTapeFolder != null && !isDeleted)
        {
          selectedFolder.value = currentStreamTapeFolder;
          SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, currentStreamTapeFolder.name!);
          SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, currentStreamTapeFolder.id!);
        }
      else
        {
          selectedFolder.value = streamTapeFolder!.folders!.first;
          SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, selectedFolder.value.name!);
          SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, selectedFolder.value.id!);
        }
    }
    if (isResume) {
      isLoading.value = false;
    }
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

  Future<bool> deleteFiles(String ids) async
  {
    var bodyMap = {"id": ids, "_csrf": crfToken,};
    String? respose = await WebUtils.makePostRequest(STREAMTAPE_DELETE_FILE_API_URL, bodyMap, headers: {"Cookie": currentCookie});
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
      return  (false,jsonMap["statusCode"].toString());
    }
  }

  Future<bool> copyStreamTapeFiles(String ids, String toFolderId) async
  {
    try {
      var bodyMap = {"id": ids, "_csrf": crfToken,"to":toFolderId};
      String? respose = await WebUtils.makePostRequest(STREAMTAPE_COPY_API_URL, bodyMap, headers: {"Cookie": currentCookie});
      Map<String, dynamic> jsonMap = jsonDecode(respose);
      if (jsonMap["statusCode"] == 200) {
            return true;
          }
          else {
            return false;
          }
    } catch (e) {
      return false;
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
        DialogUtils.showLoaderDialog(Get.context!, text: "Deleting......".obs);
        try {
          await deleteRemoteUploadingVideo(id);
        } catch (e) {
          DialogUtils.stopLoaderDialog();
          showToast("exception:" + e.toString());
        }
      },
    );
  }

  Future<void> showDeleteDialog(Function onConfirm,{String? title,String? msg}) async
  {
    ButterflyAlertDialog.show(
      context: Get.context!,
      title: title ?? 'Delete',
      subtitle: msg ?? 'Are sure you want to delete it?',
      alertType: AlertType.delete,
      onConfirm: () async {
        onConfirm();
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

  Future<(String,ApiErrorEnum)> getDirectKuaishouFlvUrlOrginal(String kuaishouLink,String did,SocialUser socialUser,{bool isConcurrentProcess = false}) async
  {
    String finalFlvUrl = "";
    ApiErrorEnum error = ApiErrorEnum.NONE;
    try {

      String? orginalLink;
      String referURL = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_UNFOLLOW_USER_REFER_URL);
      if(referURL.isEmpty || isUnfollowExceptionOccured)
        {
          try {
            orginalLink = await WebUtils.getOriginalUrl(kuaishouLink,timeout: Duration(seconds: 25));
            SharedPrefsUtil.setString(SharedPrefsUtil.KEY_UNFOLLOW_USER_REFER_URL, orginalLink!);
            if (isConcurrentProcess && SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_UNFOLLOW_UPLOAD_WITH_DELAY)) {
              int mintoSeconds = SharedPrefsUtil.getInt(SharedPrefsUtil.KEY_UNFOLLOW_USER_TIMER) * 10;
              await Future.delayed(Duration(seconds: getIntBetweenRange(30, mintoSeconds)));
            }
          } catch (e) {
            print(e);
          }
        }
      else
        {
          orginalLink = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_UNFOLLOW_USER_REFER_URL);
        }

      Uri orginalUri = Uri.parse(orginalLink!);
      List<String> updatedSegments = List.from(orginalUri.pathSegments);
      updatedSegments[updatedSegments.length - 1] = socialUser.id!;
      Uri updatedUri = orginalUri.replace(pathSegments: updatedSegments);
      String? eid = updatedUri.path.split("/").last;
      String? efid = updatedUri.queryParameters["efid"];
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
        'x-pie-req-header-host': updatedUri.origin.replaceAll("https://", ""),
        'x-pie-req-header-referer': updatedUri.toString(),
        'x-pie-req-header-user-agent': 'HTTPie',
        'x-pie-req-meta-follow-redirects': 'true',
        'x-pie-req-meta-method': 'POST',
        'x-pie-req-meta-ssl-verify': 'true',
        'x-pie-req-meta-url': 'https://livev.m.chenzhongtech.com/rest/k/live/byUser?kpn=GAME_ZONE&kpf=UNKNOWN_PLATFORM&captchaToken='
      };
      var headers2 = {
        'content-type': 'text/plain;charset=UTF-8',
        'sec-ch-ua': '"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'x-pie-req-header-accept': '*/*',
        'x-pie-req-header-accept-language': 'en-US,en;q=0.9,ur;q=0.8',
        'x-pie-req-header-connection': 'keep-alive',
        'x-pie-req-header-content-type': 'application/json',
        'x-pie-req-header-cookie': did,
        'x-pie-req-header-host': 'livev.m.chenzhongtech.com',
        'x-pie-req-header-origin': 'https://livev.m.chenzhongtech.com',
        'x-pie-req-header-referer': updatedUri.toString().replaceAll("klsxvkqw", "livev").replaceAll("klsg24an", "livev"),
        'x-pie-req-header-sec-ch-ua': '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
        'x-pie-req-header-sec-ch-ua-mobile': '?0',
        'x-pie-req-header-sec-ch-ua-platform': '"Windows"',
        'x-pie-req-header-sec-fetch-dest': 'empty',
        'x-pie-req-header-sec-fetch-mode': 'cors',
        'x-pie-req-header-sec-fetch-site': 'same-origin',
        'x-pie-req-header-user-agent': 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36',
        'x-pie-req-meta-follow-redirects': 'true',
        'x-pie-req-meta-method': 'POST',
        'x-pie-req-meta-ssl-verify': 'true',
        'x-pie-req-meta-url': 'https://livev.m.chenzhongtech.com/rest/k/live/byUser?kpn=GAME_ZONE&kpf=UNKNOWN_PLATFORM&captchaToken=',
        'Content-Type': 'text/plain'
      };
      if (isConcurrentProcess && SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_UNFOLLOW_UPLOAD_WITH_DELAY)) {
        int mintoSeconds = SharedPrefsUtil.getInt(SharedPrefsUtil.KEY_UNFOLLOW_USER_TIMER) * 30;
        await Future.delayed(Duration(seconds: getIntBetweenRange(10, mintoSeconds)));
      }
      String response = await WebUtils.makePostRequest(HTTPIE_PROXY_URL, jsonEncode(requestMap),headers: headers2,timeout: Duration(seconds: 25));
      if(response.isEmpty)
        {
          isUnfollowExceptionOccured = true;
        }
      else
        {
          isUnfollowExceptionOccured = false;
        }
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
          else if (jsonResponse["result"] == 601)
            {
              error = ApiErrorEnum.LIVE_STREAM_OVER;
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


  Future<(String,ApiErrorEnum)> getDirectKuaishouFlvUrlOrginalWithoutHttpie (String kuaishouLink,String did,{bool isConcurrent = false, int unfollowTime = 5}) async
  {
    String finalFlvUrl = "";
    ApiErrorEnum error = ApiErrorEnum.NONE;
    try {
     if (isConcurrent) {
       int mintoSeconds = unfollowTime * 60;
       await Future.delayed(Duration(seconds: getIntBetweenRange(60, mintoSeconds)));
     }
      String? orginalLink = await WebUtils.getOriginalUrl(kuaishouLink,timeout: Duration(seconds: 15));
      if (orginalLink!.isNotEmpty) {
        Uri orginalUri = Uri.parse(orginalLink!);
        String? eid =  orginalUri.path.split("/").last;
        String? efid = orginalUri.queryParameters["efid"];
        var requestMap = {"efid":efid,"eid":eid,"source":6,"shareMethod":"card","clientType":"WEB_OUTSIDE_SHARE_H5"};
        int currentTimeInMillis = DateTime.now().millisecondsSinceEpoch;
        var headers = {"Referer":orginalLink,"Cookie":"${did}","Content-Type":"application/json","Host": orginalUri.origin.replaceAll("https://", ""),"user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"};
        // var headers2 = {
        // "Content-Type": "application/json",
        // "Cookie": "did=$did",
        // "Host": orginalUri.origin,
        // "Referer": orginalLink,
        // "User-Agent": "HTTPie"};
        const String url = "https://livev.m.chenzhongtech.com/rest/k/live/byUser?kpn=GAME_ZONE&kpf=UNKNOWN_PLATFORM&captchaToken=";
        String response = await WebUtils.makePostRequest(url, jsonEncode(requestMap),headers: headers,timeout: Duration(seconds: 15));
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
          else if (jsonResponse["result"] == 601)
          {
            error = ApiErrorEnum.LIVE_STREAM_OVER;
          }
          else
          {
            error = ApiErrorEnum.OTHERS;
          }
        }
      }
    } catch (e) {
      error = ApiErrorEnum.EXCEPTION;
    }
    return (finalFlvUrl,error);

  }

  // Future<(String, String, Map<String, bool>)> getDirectKuaishouFlvUrl_Background(String username, String shareToken, String cookie) async
  // {
  //   Map<String, bool> liveStatusMap = <String, bool>{"online": false, "apiError": false, "exceptionError": false, "offline": false};
  //   String cookie = "did=web_5db7f4c0d9664902af774fd08ebdf769; didv=1730628699000";
  //   String finalFlvUrl = "";
  //   String finalUrl = "https://live.kuaishou.com/u/${username}";
  //   //String shareToken = "X9BGeAzPhrZX1bs";
  //   String? orginalLink = "";
  //   String error = "";
  //   /*try {
  //     orginalLink = await WebUtils.getOriginalUrl(finalUrl,headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 14; 23129RAA4G Build/UKQ1.231207.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.107 Mobile Safari/537.36"},timeout: Duration(seconds: 25));
  //   } catch (e) {
  //     print(e);
  //   }*/
  //   try {
  //
  //     /*if(orginalLink == null || orginalLink!.isEmpty)
  //       {
  //         WebViewUtils webViewUtils = WebViewUtils();
  //         orginalLink = await webViewUtils.getUrlWithWebView(finalUrl!, "",isBackground: true);
  //         await webViewUtils.disposeWebView();
  //       }*/
  //     if (orginalLink!.isEmpty) {
  //       orginalLink = KOUAISHOU_MAIN_MOBILE_URL + username + "?cc=share_wxms&followRefer=151&shareMethod=CARD&kpn=GAME_ZONE&subBiz=LIVE_STEARM_OUTSIDE&shareToken=$shareToken&shareMode=APP&efid=0";
  //     }
  //     Uri orginalUri = Uri.parse(orginalLink!);
  //     String? eid = orginalUri.path
  //         .split("/")
  //         .last;
  //     String? efid = "0";
  //     var requestMap = {"efid": efid, "eid": eid, "source": 6, "shareMethod": "card", "clientType": "WEB_OUTSIDE_SHARE_H5"};
  //     var headers = {
  //       "Referer": orginalLink,
  //       "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
  //       "Content-Type": "application/json",
  //       "Accept-Encoding": "gzip, deflate, br",
  //       "Accept": "*/*",
  //       "Cookie": cookie
  //     };
  //     //  var headers = {"Accept": "*/*",
  //     //    "Accept-Encoding": "gzip, deflate, br",
  //     //    "Accept-Language": "en-US,en;q=0.9,ur;q=0.8",
  //     //    "Access-Control-Allow-Credentials": "true",
  //     //    "Content-Type": "application/json",
  //     //    "Cookie": cookie,
  //     //    "Host": "livev.m.chenzhongtech.com",
  //     //    "Origin": "https://livev.m.chenzhongtech.com",
  //     //    "Referer": orginalLink,
  //     //    "Sec-Ch-Ua": "\"Google Chrome\";v=\"131\", \"Chromium\";v=\"131\", \"Not_A Brand\";v=\"24\"",
  //     //    "Sec-Ch-Ua-Mobile": "?1",
  //     //    "Sec-Ch-Ua-Platform": "Android",
  //     //    "Sec-Fetch-Dest": "",
  //     //    "Sec-Fetch-Mode": "cors",
  //     //    "Sec-Fetch-Site": "same-origin",
  //     //    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
  //     //  };
  //     String response = await WebUtils.makePostRequest(KOUAISHOU_LIVE_API_URL_3, jsonEncode(requestMap), headers: headers);
  //     Map<String, dynamic> jsonResponse = json.decode(response);
  //     if (jsonResponse["error_msg"] == null) {
  //       finalFlvUrl = jsonResponse["liveStream"]["playUrls"][0]["url"] ??= "";
  //       if (jsonResponse["liveStreamEndReason"] != null && jsonResponse["liveStreamEndReason"] == "The Live ended.") {
  //         finalFlvUrl = "";
  //         liveStatusMap["offline"] = true;
  //       }
  //       else {
  //         liveStatusMap["online"] = true;
  //       }
  //     }
  //     else {
  //       liveStatusMap["apiError"] = true;
  //       error = "Username : ${username}\nError Message : " + jsonResponse["error_msg"];
  //     }
  //   } catch (e) {
  //     print(e);
  //     finalFlvUrl = "";
  //     liveStatusMap["exceptionError"] = true;
  //   }
  //   return (finalFlvUrl, error, liveStatusMap);
  // }


  // Future<String?> updateShareToken(List<UserKuaishou> list) async
  // {
  //   String? shareToken;
  //   List<UserKuaishou> shuffleList = List.from(list);
  //   shuffleList.shuffle();
  //   for (UserKuaishou userKuaishou in shuffleList) {
  //     try {
  //       String finalUrl = "https://live.kuaishou.com/u/${userKuaishou.value}";
  //       String? orginalLink = await WebUtils.getOriginalUrl(
  //           finalUrl, headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 14; 23129RAA4G Build/UKQ1.231207.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.107 Mobile Safari/537.36"}, timeout: Duration(seconds: 15));
  //       Uri orginalUri = Uri.parse(orginalLink!);
  //       shareToken = orginalUri.queryParameters["shareToken"];
  //       if (shareToken != null) {
  //         break;
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  //   return shareToken!;
  // }

  // String updateCookie(String currentCookie) {
  //   List<String> list = [
  //     "did=web_5db7f4c0d9664902af774fd08ebdf769; didv=1730628699000",
  //     "did=web_abb8d5daa36a428fbfe7ebdb68830bca; didv=1732683243000",
  //     "did=web_907321761e6e4eff96111b476bc9cad4; didv=1732694096000",
  //     "did=web_618d6ac474dd404a998cf2b641d96843; didv=1732694664000",
  //     "did=web_09abdedb117249279127a0cb9f829e81; didv=1732709899000",
  //     "did=web_2efca5ecf2984f99ad1aab086be65367; didv=1732710789000"
  //     "did=web_81ebb9322ec74073ac601fdb934cb676; didv=1732710974000"
  //   ];
  //   if (currentCookie.isEmpty) {
  //     int index = getIntBetweenRange(0, 4);
  //     String selectedCookie = list[index];
  //     return selectedCookie;
  //   }
  //   else {
  //     String selectedCookie;
  //     do {
  //       int index = getIntBetweenRange(0, 4);
  //       selectedCookie = list[index];
  //     } while (selectedCookie == currentCookie);
  //     return selectedCookie;
  //   }
  // }

  Future<String> getUsernameFromKuaishouUrl(String kuaishouLink) async
  {
    String? orginalLink = await WebUtils.getOriginalUrl(kuaishouLink,timeout:Duration(seconds: 15) );
    Uri orginalUri = Uri.parse(orginalLink!);
    String? eid = orginalUri.path
        .split("/")
        .last;
    return eid;
  }


  // Future<String> getStreamUrlForBackgroundUpload_Web(String userName) async
  // {
  //   String streamUrl = "";
  //   String cookie = "clientid=3; did=web_dfa8864005520444a895fd1cb3c51538; client_key=65890b29; kpn=GAME_ZONE; _did=web_870397124DBD985F; didv=1730628663000; did=web_85aeaebcb9d6490bb484e761a201dd7c; Hm_lvt_86a27b7db2c5c0ae37fee4a8a35033ee=1730628678; kuaishou.live.bfb1s=7206d814e5c089a58c910ed8bf52ace5";
  //   String finalUrl = "https://live.kuaishou.com/u/$userName";
  //   try {
  //     var headers = {"Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
  //       "Accept-Encoding": "gzip, deflate, br, zstd",
  //       "Accept-Language": "en-US,en;q=0.9,ur;q=0.8",
  //       "cache-control": "max-age=0",
  //       "connection": "keep-alive",
  //       "Cookie": cookie,
  //       "Host": "live.kuaishou.com",
  //       "Sec-Ch-Ua": "\"Google Chrome\";v=\"131\", \"Chromium\";v=\"131\", \"Not_A Brand\";v=\"24\"",
  //       "Sec-Ch-Ua-Mobile": "?0",
  //       "Sec-Ch-Ua-Platform": "Windows",
  //       "Sec-Fetch-Dest": "document",
  //       "Sec-Fetch-Mode": "navigate",
  //       "Sec-Fetch-Site": "none",
  //       "Sec-Fetch-User": "?1",
  //       "upgrade-insecure-requests": "1",
  //       "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
  //     };
  //     String? response = await WebUtils.makeGetRequest(finalUrl, headers: headers, timeout: Duration(seconds: 25));
  //     dom.Document document = WebUtils.getDomfromHtml(response!);
  //     String jsonRaw = document
  //         .querySelectorAll("script")
  //         .where((value) => value.text.contains("window.__INITIAL_STATE__"))
  //         .first
  //         .text;
  //     String jsonResponse = getStringBetweenTwoStrings("window.__INITIAL_STATE__ = {", "};", jsonRaw!).replaceAll(":,", ":\"\",").replaceAll("undefined", "\"\"").replaceAll("\"\"\"", "\"");
  //     Map<String, dynamic> jsonEncode = json.decode("{\"" + jsonResponse + "}");
  //
  //     if ((jsonEncode["liveroom"]["playList"][0]["liveStream"] as Map).isNotEmpty && (jsonEncode["liveroom"]["playList"][0]["liveStream"]["playUrls"] as List).isNotEmpty) {
  //       streamUrl = jsonEncode["liveroom"]["playList"][0]["liveStream"]["playUrls"][0]["adaptationSet"]["representation"][0]["url"];
  //     }
  //     print("streamUrl : " + streamUrl);
  //   } catch (e) {
  //     streamUrl = "";
  //     print(e);
  //   }
  //   return streamUrl;
  // }

  // Future<String> getStreamUrlForBackgroundUpload_Web2(String url) async
  // {
  //   String streamUrl = "";
  //   var header = {"user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"};
  //   try{
  //   String? orginalUrl = await WebUtils.getOriginalUrl(url,headers: header);
  //   String? response = await WebUtils.makeGetRequest(orginalUrl!,headers: header);
  //     dom.Document document = WebUtils.getDomfromHtml(response!);
  //     String jsonRaw = document
  //         .querySelectorAll("script")
  //         .where((value) => value.text.contains("window.__INITIAL_STATE__"))
  //         .first
  //         .text;
  //     String jsonResponse = getStringBetweenTwoStrings("window.__INITIAL_STATE__ = {", "};", jsonRaw!).replaceAll(":,", ":\"\",").replaceAll("undefined", "\"\"").replaceAll("\"\"\"", "\"");
  //     Map<String, dynamic> jsonEncode = json.decode("{\"" + jsonResponse + "}");
  //
  //     if ((jsonEncode["liveroom"]["playList"][0]["liveStream"] as Map).isNotEmpty) {
  //       streamUrl = jsonEncode["liveroom"]["playList"][0]["liveStream"]["playUrls"]["h264"]["adaptationSet"]["representation"][0]["url"];
  //     }
  //     print("streamUrl : " + streamUrl);
  //   } catch (e) {
  //     streamUrl = "";
  //     print(e);
  //   }
  //   return streamUrl;
  // }

  // Future<String> getStreamUrlForBackgroundUpload_Mobile(String userName) async
  // {
  //   String finalUrl = "https://live.kuaishou.com/u/$userName";
  //   String? oLink = await WebUtils.getOriginalUrl(finalUrl, headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36"});
  //   String? response = await WebUtils.makeGetRequest(oLink!, headers: {"User-Agent": "Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36"});
  //   return "";
  // }

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

  Future<bool> startUploading_background(String link, List<StreamtapeDownloadStatus> list,{bool isUnfollow = false,bool isTiktok = false}) async
  {
    if (!isUrlExistsInDownlodingList(link, list, isBackground: true)) {
      if (isUnfollow) {
        addUnfollowUsername(link);
      }
      else if(isTiktok)
        {
          addTiktokUsername(link);
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
          bool isTiktokUser = await isUrlExistInTiktokUserListBox(item["url"]);
          downloadingList.add(StreamtapeDownloadStatus(status: item["status"],
              url: item["url"],
              imageBytes: bytes,
              id: item["id"],
              isUnfollowUser: isUnfollowUser,
              isTiktokUser: isTiktokUser,
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
            bool isTiktokUser = await isUrlExistInTiktokUserListBox(item["url"]);
            downloadingList.add(StreamtapeDownloadStatus(status: item["status"],
                url: item["url"],
                imageBytes: bytes,
                id: item["id"],
                isUnfollowUser: isUnfollowUser,
                isTiktokUser: isTiktokUser,
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
          return SingleChildScrollView(child: txt.Text(value),);
        }
    );
  }


  Future<StreamtapeDownloadStatus> getDownloadingDetailItem(dynamic item, int seekPosition) async {
    Uint8List? bytes;
    try {
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
    } catch (e) {
      print(e);
    }
    bool isUnfollowUser = isUrlExistInUnfollowUserListBox(item["url"]);
    bool isTiktokUser = await isUrlExistInTiktokUserListBox(item["url"]);
    return StreamtapeDownloadStatus(status: item["status"],
        url: item["url"],
        imageBytes: bytes,
        id: item["id"],
        isUnfollowUser: isUnfollowUser,
        isTiktokUser: isTiktokUser,
        isThumbnailUpdating: false.obs);
  }

  Future<(String?, String?)?> getMp4UrlFromStreamTapeEmbded(String embededUrl, {bool isVideotoEmbededAllowed = false, Map<String, String>? headers}) async
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
      String dlUrl = "https:/" + ideooLink + "&token=" + token + "&dl=1";
      //String dlUrl = "https:/" + ideooLink + "&dl=1s";
      return (dlUrl, imageUrl);
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to get Streamtape downoad url", toastLength: Toast.LENGTH_LONG, backgroundColor: Colors.red);
    }
  }

  Future<(String?, String?)?> getMp4UrlFromStreamTapeVideo(String embededUrl, {bool isVideotoEmbededAllowed = false, Map<String, String>? headers}) async
  {
    if (isVideotoEmbededAllowed) {
      //embededUrl = embededUrl.replaceAll("/v/", "/e/");
    }
    try {
      dom.Document document = await WebUtils.getDomFromURL_Get(embededUrl, headers: headers);
      String? imageUrl;
      if (document.querySelector("meta[name=\"og:image\"]") != null) {
        imageUrl = document.querySelector("meta[name=\"og:image\"]")!.attributes["content"];
      }
      document.body!.innerHtml;
      String? botlink = document.querySelector("#ideoooolink")!.text;
      List<dom.Element> list = document.querySelectorAll("script");
      String? javaScript = list.where((item) => item.text.contains("document.getElementById('ideoooolink').innerHTML")).first.text;
      String? tokenString = getStringBetweenTwoStrings("document.getElementById('ideoooolink').innerHTML = \"", "')", javaScript);
      String? token = getStringAfterStartStringToEnd("&token=", tokenString);
      String tempUrl  = getStringBefore(botlink, "&token=");
      String dlUrl = "http:/" + tempUrl + "&token=$token&stream=1";
      //String dlUrl = "https:/" + ideooLink + "&dl=1s";
      return (dlUrl, imageUrl);
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to get Streamtape downoad url", toastLength: Toast.LENGTH_LONG, backgroundColor: Colors.red);
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

  String getStringBefore(String input, String delimiter) {
    // Find the index of the delimiter in the input string
    int index = input.indexOf(delimiter);

    // If the delimiter is not found, return the entire string
    if (index == -1) {
      return input;
    }

    // Return the substring before the delimiter
    return input.substring(0, index);
  }

  getDownloadLinks(String id,{bool showLoader  = true}) async
  {
    try {
      isSearching = false;
      if (showLoader) {
        DialogUtils.showLoaderDialog(Get.context!);
      }
      downloadLinks.value = "";
      downloadLinksList = [];
      StringBuffer stringBuffer = StringBuffer("");
      StreamTapeFolder streamTapeFolder = await getFolderFiles(id);
      for (StreamtapeFileItem streamtapeFileItem in streamTapeFolder.files!) {
         downloadLinksList.add(DownloadItem(streamtapeFileItem.name, "Press Download icon to get link....", "", streamtapeFileItem.link!, false.obs, false.obs,Uint8List.fromList([]),false,convertBytes(streamtapeFileItem.size!)));
         //stringBuffer.write(mp4ImageUrl.$1! +"\n\n");
         //downloadLinks.value = stringBuffer.toString();
         this.update(["updateStreamtapeDownloadingList"]);
          }
    } catch (e) {
      print(e);
    }
    if (showLoader) {
      DialogUtils.stopLoaderDialog();
    }
  }


  Future<bool> fetchStreamTapeImageAndDownloadUrl(DownloadItem? downloadItem) async
  {
    downloadItem!.isLoading!.value = true;

    //if (downloadItem!.downloadUrl == null || downloadItem!.downloadUrl == "Press Download icon to get link...."  || downloadItem!.downloadUrl == "Unable to get download url....") {
    try {
      bool isEmbeded = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_STREAMTAPE_FETCH_FROM_EMBEDED, defaultValue: false);
      (String?, String?)? mp4ImageUrl = isEmbeded ? await getMp4UrlFromStreamTapeEmbded(downloadItem.streamTapeUrl!, isVideotoEmbededAllowed: true) : await getMp4UrlFromStreamTapeVideo(downloadItem.streamTapeUrl!, isVideotoEmbededAllowed: false);
      downloadItem!.downloadUrl = mp4ImageUrl!.$1 != null ? mp4ImageUrl!.$1 : "Unable to get download url....";
      downloadItem!.imageUrl = mp4ImageUrl!.$2 != null ? mp4ImageUrl!.$2 : "";
    } catch (e) {
      downloadItem!.downloadUrl =  "Unable to get download url....";
      downloadItem!.imageUrl = "";
    }

    if(downloadItem.imageUrl!.isEmpty && downloadItem.downloadUrl != "Unable to get download url....")
      {
        try {
          downloadItem.imageBytes = await VideoCaptureUtils().captureImage(downloadItem.downloadUrl!, 1000);
          if (downloadItem.imageBytes != null && downloadItem.imageBytes!.isNotEmpty) {
            downloadItem.isUrlImage = true;
          }
        } catch (e) {
          print(e);
        }
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

  List<SocialUser> getAllUserList() {
    final allKeys = usernameListIdBox.keys;
    List<SocialUser> list = [];
    // Iterate over all keys and delete those not in keysToKeep
    for (var key in allKeys) {
      list.add(SocialUser(id: key, value: usernameListIdBox.get(key)));
    }

    return list;
  }

  List<String> getAllUsersListString() {
    return usernameListIdBox.values.map((e) => e.toString()).toList();
  }

  Future deleteUserName(String id) async
  {
    await usernameListIdBox.delete(id);
  }
  Future<void> deleteUserByValue(String valueToDelete) async {
    var keys = usernameListIdBox.keys.cast<String>().toList();
    for (var key in keys) {
      if (usernameListIdBox.get(key) == valueToDelete) {
        await usernameListIdBox.delete(key); // Delete the entry by key
        break;
      }
    }
  }

  Future addUsername(String userName,{bool isImport = false,String? unfollowUserName}) async
  {
    if (unfollowUserName == null) {
      if (!usernameListIdBox.values.toList().any((value) => value.toString().contains(userName))) {
            await usernameListIdBox.put(generateRandomString(10), userName);
          }
          else {
            if (!isImport) {
              showToast("User already exists");
            }
          }
    }
    else
      {
        if (!usernameListIdBox.keys.toList().any((value) => value.toString().contains(unfollowUserName)) && !usernameListIdBox.values.toList().any((value) => value.toString().contains(unfollowUserName))) {
          await usernameListIdBox.put(unfollowUserName, userName);
        }
        else {
          if (!isImport) {
            showToast("User already exists");
          }
        }
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

  Future addTiktokUsername(String url) async
  {
    if(tiktokUserUrlListBox == null)
      {
        tiktokUserUrlListBox = await Hive.openBox("tiktokUserUrlListBox");
      }
    Uri currentUri = Uri.parse(url);
    String currentUrl = currentUri.origin + currentUri.path;
    if (!tiktokUserUrlListBox!.values.toList().any((value) => value.toString().contains(currentUrl))) {
      await tiktokUserUrlListBox!.put(generateRandomString(10), currentUrl);
    }
  }

  Future<bool> isUrlExistInTiktokUserListBox(String url) async
  {
    if(tiktokUserUrlListBox == null)
    {
      tiktokUserUrlListBox = await Hive.openBox("tiktokUserUrlListBox");
    }
    Uri currentUri = Uri.parse(url);
    String currentUrl = currentUri.origin + currentUri.path;
    return tiktokUserUrlListBox!.values.toList().any((value) => value.toString().contains(currentUrl));
  }

  Future<List<StreamtapeDownloadStatus>> getRemoteDownloadingStatus_background() async
  {
    List<StreamtapeDownloadStatus> streamtapeDownloadStatusList = [];
    await SharedPrefsUtil.initSharedPreference();
    if (SharedPrefsUtil
        .getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE)
        .isNotEmpty) {
      String? response = await WebUtils.makeGetRequest(
          STREAMTAPE_DOWNLOADING_STATUS_API_URL, headers: {
        "Cookie": SharedPrefsUtil.getString(
            SharedPrefsUtil.KEY_STREAMTAPE_COOKIE)
      });
      Map<String, dynamic> jsonMap = jsonDecode(response!);
      List<dynamic> list = (jsonMap["data"] as List<dynamic>);

      for (dynamic item in list) {
        if (item["status"] == "error") {
          await deleteRemoteUploadingVideo(
              item["id"], isBackGroundProcess: true);
        }
        streamtapeDownloadStatusList.add(
            StreamtapeDownloadStatus(status: item["status"],
                url: item["url"],
                id: item["id"],
                isThumbnailUpdating: false.obs));
      }
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
    String cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_FOLLOW_LIVE_COOKIE);
    do {
      int time = getIntBetweenRange(1, 3);
      if (exception.isNotEmpty) {
        await Future.delayed(Duration(minutes: time));
      }
      exception = "";
      try {
        var headers = {
          "Cookie": cookie.isEmpty ? "clientid=3; did=web_a608360f69dbdaeaf57ed83a4379d45c; client_key=65890b29; kpn=GAME_ZONE; _did=web_7953587335F02819; did=web_de23d1096e060086a98e5010538a153ef370; kuaishou.live.bfb1s=7206d814e5c089a58c910ed8bf52ace5; userId=1584032460; kuaishou.live.web_st=ChRrdWFpc2hvdS5saXZlLndlYi5zdBKgAWs92ejvNoX5AM32zePUxyCcxSoEKujRcU0BYnk7wW7Js-8og-KalLxNo_Ep38pgFWTFossVMlkdHvE_D-F03kgAkr8RSLRYMQSDwUJ3a7h9Vi0-4Gs6OKZspnAAgEYEmZd7CfABi7H_0XaHqMI2k85kh6YclsTPWu-uB-lfWnwmhGdJUW6IohUoK5GCFqtsdI4q2G2EbmglO962fBOSQ2MaEvrof_XznEP1qd2QsxhyybtifyIgeHh9sNj2MW7bERrK5wkady4h0kaMOEX_AIj5S-JuOLgoBTAB; kuaishou.live.web_ph=bccb3f7173bf22fe9b8d4cd87abea5cfa093; userId=1584032460; showFollowRedIcon=1" : cookie
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
    if (await isServiceRunning()) {
      stopBackgroundService();
    }
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

  Future initiateUnfollowUploadingProcessSequence () async
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
    List<SocialUser> list = getAllUserList();
    List<SocialUser> listFiltered = list.where((user)=>user.value!.contains("<||>UNFOLLOW")).toList();
    await setFolderIfNotSet();
    if (listFiltered.length > 0) {
      int totalMin = getUnfollowMin(listFiltered);
      SharedPrefsUtil.setInt(SharedPrefsUtil.KEY_CURRENT_UNFOLLOW_MIN,totalMin);
      unfollowCurrentTime.value = totalMin;
      unfollowUserTimer = makePeriodicTimer(Duration(minutes: totalMin),fireNow: true,isCustomTimer: true,isUnfollowTimer: true,(timer) async {
        await verifyCaptcha(isAutoCaptchaVerification: SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_AUTO_UNFOLLOW_USER_CAPTCHA_VERIFICATION,defaultValue: true));
        listFiltered = getAllUserList().where((user)=>user.value!.contains("<||>UNFOLLOW")).toList();
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
        unfollowLiveStreamOver.value = 0;
        totalUnfollowUserUploadedProgress.value = "0/${listFiltered.length}";

        for (SocialUser userKuaishou in listFiltered) {
            try {
              String initialUrl = "https://v.kuaishou.com${userKuaishou.value!.replaceAll("<||>UNFOLLOW", "")}";
              String cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE);
              bool isCaptchaRequired = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED);
              if (cookie.isNotEmpty && !isCaptchaRequired) {
                (String,ApiErrorEnum) urlError = await getDirectKuaishouFlvUrlOrginal(initialUrl,cookie,userKuaishou);
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
                        SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, true);
                      }
                      else if(urlError.$2 == ApiErrorEnum.OTHERS)
                      {
                        unfollowUserOthers.value = unfollowUserOthers.value + 1;
                      }
                      else if(urlError.$2 == ApiErrorEnum.OFFLINE)
                      {
                        unfollowUserOffline.value = unfollowUserOffline.value + 1;
                      }
                      else if(urlError.$2 == ApiErrorEnum.LIVE_STREAM_OVER)
                      {
                        unfollowLiveStreamOver.value = unfollowLiveStreamOver.value + 1;
                      }
                  }


              }
            } catch (e) {
              print(e);
            }
            totalUnfollowUserUploadedProgress.value = "${listFiltered.indexOf(userKuaishou)+1}/${listFiltered.length}";
            RangeValues rangeValues = getRangeValuesFromString(SharedPrefsUtil.getString(SharedPrefsUtil.KEY_UNFOLLOW_API_INTERVAL,defaultValue: "15:25"));
            await Future.delayed(Duration(seconds: getIntBetweenRange(rangeValues.start.toInt(), rangeValues.end.toInt())));

        }
        isUnfollowUserProcessing.value = false;
      });
    }
  }
  Future initiateUnfollowUploadingProcess() async
  {
    if (SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_UPLOADING,defaultValue: false)) {
      if(isConcurrentUnfollowUploadingEnable.value)
        {
          await initiateUnfollowUploadingProcessConcurrent();
        }
      else
        {
          await initiateUnfollowUploadingProcessSequence();
        }
    }
  }
  Future initiateUnfollowUploadingProcessConcurrent () async
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
    List<SocialUser> list = getAllUserList();
    List<SocialUser> listFiltered = list.where((user)=>user.value!.contains("<||>UNFOLLOW")).toList();
    await setFolderIfNotSet();
    if (listFiltered.length > 0) {
      int totalMin = getUnfollowMin(listFiltered);
      SharedPrefsUtil.setInt(SharedPrefsUtil.KEY_CURRENT_UNFOLLOW_MIN,totalMin);
      unfollowCurrentTime.value = totalMin;
      unfollowUserTimer = makePeriodicTimer(Duration(minutes: totalMin),fireNow: true,isCustomTimer: true,isUnfollowTimer: true,(timer) async {
        await verifyCaptcha(isAutoCaptchaVerification: SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_ENABLE_AUTO_UNFOLLOW_USER_CAPTCHA_VERIFICATION,defaultValue: true));
        listFiltered = getAllUserList().where((user)=>user.value!.contains("<||>UNFOLLOW")).toList();
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
        unfollowLiveStreamOver.value = 0;
        totalUnfollowUserUploadedProgress.value = "0/${listFiltered.length}";


          try {
            List<Future<(String,ApiErrorEnum)>> futureFlvUrlList = [];
            String cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE);
            bool isCaptchaRequired = SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED);
            if (cookie.isNotEmpty && !isCaptchaRequired) {
              for (SocialUser userKuaishou in listFiltered) {
                String initialUrl = "https://v.kuaishou.com${userKuaishou.value!.replaceAll("<||>UNFOLLOW", "")}";
                futureFlvUrlList.add(getDirectKuaishouFlvUrlOrginal(initialUrl,cookie,userKuaishou,isConcurrentProcess: true));
              }

              List<(String,ApiErrorEnum)> futureFlvUrlListResult = await Future.wait(futureFlvUrlList);

              for(int i = 0;i<futureFlvUrlListResult.length;i++)
                {
                  (String,ApiErrorEnum) result = futureFlvUrlListResult[i];
                  if (result.$2 == ApiErrorEnum.NONE) {
                    if (result.$1.isNotEmpty) {
                      unfollowUserOnline.value  = unfollowUserOnline.value + 1;
                      bool isUploaded = await startUploading_background(result.$1, streamTapeDownloadStatusList,isUnfollow: true);
                      if(isUploaded)
                      {
                        unfollowUserUploaded.value = unfollowUserUploaded.value + 1;
                        await Future.delayed(Duration(seconds: 2));
                      }
                    }
                  }
                  else
                  {
                    if(result.$2 == ApiErrorEnum.CAPTCHA_REQUIRED)
                    {
                      unfollowUserErrorCaptcha.value = unfollowUserErrorCaptcha.value + 1;
                      SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, true);
                    }
                    else if(result.$2 == ApiErrorEnum.EXCEPTION)
                    {
                      unfollowUserError.value = unfollowUserError.value + 1;
                    }
                    else if(result.$2 == ApiErrorEnum.FREQUENT_REQUESTS)
                    {
                      unfollowUserFrequentRequests.value = unfollowUserFrequentRequests.value + 1;
                      SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, true);
                    }
                    else if(result.$2 == ApiErrorEnum.OTHERS)
                    {
                      unfollowUserOthers.value = unfollowUserOthers.value + 1;
                    }
                    else if(result.$2 == ApiErrorEnum.OFFLINE)
                    {
                      unfollowUserOffline.value = unfollowUserOffline.value + 1;
                    }
                    else if(result.$2 == ApiErrorEnum.LIVE_STREAM_OVER)
                    {
                      unfollowLiveStreamOver.value = unfollowLiveStreamOver.value + 1;
                    }
                  }
                   totalUnfollowUserUploadedProgress.value = "${i+1}/${futureFlvUrlListResult.length}";
                }

            }
          } catch (e) {
            print(e);
          }
        isUnfollowUserProcessing.value = false;
      });
    }
  }


  Future<void> createFolderForCurrentDayIfNotExists() async
  {
    DateTime currentDateTime = DateTime.now();
    String folderName = "Kwai ${currentDateTime.day} ${currentDateTime.month} ${currentDateTime.year % 100}";
    if(SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER) != folderName)
      {
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

  Future<void> exportUsers({bool isSilent = false,bool isGist = false}) async {
    // Request storage permission
    if (!isSilent) {
      DialogUtils.showLoaderDialog(Get.context!, text: "Exporting....".obs);
    }

    List<String> userList = getAllUsersListString();
    //if (permissionStatus.isGranted) {
    // Get the download directory
    if (!isGist) {
      List<String>? _exPath = await ExternalPath.getExternalStorageDirectories();
      final downloadDirectory = Directory('${_exPath![0]}/kuaishou_data');
      if (!await downloadDirectory.exists()) {
            await downloadDirectory.create(recursive: true);
          }

      // Prepare the text file
      final filePath = '${downloadDirectory.path}/users.txt';
      final file = File(filePath);


      // Join list items into a single string with line breaks
      String fileContent = userList.join('\n');

      // Write to file
      await file.writeAsString(fileContent);
      if (!isSilent) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(content: txt.Text('File saved to $filePath')));}
    } else {
      (bool,String) gistItem = await GistService.doesFileExist();

      if (gistItem.$1) {
        // Update existing file
        await GistService.updateGist(gistItem.$2, userList.join('\n'));
      } else {
        // Create new file
        await GistService.createGist(userList.join('\n'));
      }
    }

    // Notify the user that the file is saved
    if (!isSilent) {
      // } else {
      //   // Handle permission denied
      //   ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('Storage permission denied')));
      // }
      DialogUtils.stopLoaderDialog();
    }
  }

  Future<bool> importUsers({bool isSilent = false, bool isGist = false}) async {
    List<String> lines = [];
    bool isUserAvailable = true;
    RxString txt = "".obs;
    int importedSuccessfully = 0;
    if (!isSilent) {
      DialogUtils.showLoaderDialog(Get.context!, text: txt,title: "Importing");
    }
    if (!isGist) {
      try {
            // Get the application documents directory
            List<String>? _exPath = await ExternalPath.getExternalStorageDirectories();
            final downloadDirectory = Directory('${_exPath![0]}/kuaishou_data');
            String filePath = '${downloadDirectory.path}/users.txt';

            // Reading the file
            File file = File(filePath);
            if (await file.exists()) {
              lines = await file.readAsLines();
            }
            else {
              if (!isSilent) {
                showToast("Unable to find file....");
              }
              isUserAvailable =  false;
            }
          } catch (e) {
            print('Error reading file: $e');
          }
    } else {
      (bool,String) gistItem = await GistService.doesFileExist();
      if (gistItem.$1) {
        String content = await GistService.getGist(gistItem.$2);
        lines = content.split("\n");
      }
    }

    if(lines.length > 0)
      {
        for(String username in lines)
          {
            txt.value = "(${lines.indexOf(username) + 1}/${lines.length + 1}) $username\n✅ $importedSuccessfully/${lines.indexOf(username) + 1}";
            if(username.contains("<||>UNFOLLOW"))
              {
                try {
                  String initialUrl = "https://v.kuaishou.com${username.replaceAll("<||>UNFOLLOW", "")}";
                  if (!usernameListIdBox.values.toList().any((value) => value.toString().contains(username))) {
                    String usernamefinal = await getUsernameFromKuaishouUrl(initialUrl);
                    await addUsername(username,isImport: true,unfollowUserName: usernamefinal);
                    await Future.delayed(Duration(seconds: 6));
                  }
                  importedSuccessfully++;
                } catch (e) {
                  print(e);
                }
              }
            else
              {
                await addUsername(username,isImport: true);
                importedSuccessfully++;
              }

          }

      }
    else
      {
        isUserAvailable = false;
      }
    if (!isSilent) {
      DialogUtils.stopLoaderDialog();
    }
    return isUserAvailable;
  }

 Future verifyCaptcha({bool isRefresh = false,bool isForced = false,bool isAutoCaptchaVerification = false}) async
  {
    if((SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED) || SharedPrefsUtil.getString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE).isEmpty) || isForced) {
      try {
        if (!AppController.isVerifyCaptchaShowing) {
          String finalUrl = "";
          final u = RandomUserAgents((value) {
            return value.contains("Android");
          });
          if(SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_RANDOM_CAPTCHA_USER,defaultValue: false))
            {
              finalUrl = await getRandomLiveUserUrl();
            }
          else
            {
              //finalUrl = "https://klsxvkqw.m.chenzhongtech.com/fw/live/cyl51666888";
              // finalUrl = "https://klsxvkqw.m.chenzhongtech.com/fw/live/cyl51666888?cc=share_wxms&followRefer=151&shareMethod=CARD&kpn=GAME_ZONE&subBiz=LIVE_STEARM_OUTSIDE&shareId=18392501704090&shareToken=Xa2U4HcNGpFUOAR&shareMode=APP&efid=0&originShareId=18392501704090&shareObjectId=24561342&shareUrlOpened=0&timestamp=1747029341442";
              finalUrl = "https://live.kuaishou.com/u/cyl51666888";
              DialogUtils.showLoaderDialog(Get.context!,text: "Loading....".obs);
              finalUrl = (await WebUtils.getOriginalUrl(finalUrl,headers: {"User-Agent" : u.getUserAgent()},timeout: Duration(seconds: 15)))!;
              DialogUtils.stopLoaderDialog();
            }
          //String captchaUrl = "https://captcha.zt.kuaishou.com/mobile/h5/redirect/index.html?type=1&url=https%3A%2F%2Fcaptcha.zt.kuaishou.com%2Frest%2Fzt%2Fcaptcha%2Fsliding%2Fconfig&jsSdkUrl=https%3A%2F%2Fali2.a.yximgs.com%2Fstatic%2Fcaptcha%2Fsdk%2FkwaiCaptcha.bffe9a4c.umd.min.js&bizName=DEFAULT&redirectUrl=https%3A%2F%2Fklsxvkqw.m.chenzhongtech.com%2Ffw%2Flive%2Fliazi222222%3Fcc%3Dshare_copylink%26followRefer%3D151%26shareMethod%3DTOKEN%26docId%3D5%26kpn%3DNEBULA%26subBiz%3DLIVE_STREAM%26shareId%3D18185139182876%26shareToken%3DX-8cZHQLZoPy92ai%26shareResourceType%3DLIVESTREAM_OTHER%26userId%3D2604786046%26shareType%3D5%26et%3D1_a%252F2004058953446378738_combsearchuser%26shareMode%3DAPP%26efid%3D0%26originShareId%3D18185139182876%26appType%3D21%26shareObjectId%3D2zJLPgunQeI%26shareUrlOpened%3D0%26timestamp%3D1733831547065&redirectType=replace&passDataParamsType=search";
          //await CookieManager.instance().deleteCookies(url: WebUri("https://klsxvkqw.m.chenzhongtech.com"));
          // String? userAgentListResponse = await WebUtils.makeGetRequest(USER_AGENT_LIST_URL);
          // List<String> userAgentList = userAgentListResponse!.split("\n");

          // final listUserAgent =  [
          //   "Mozilla/5.0 (Linux; U; Android 8.1.0; zh-cn; BLA-AL00 Build/HUAWEIBLA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/8.9 Mobile Safari/537.36",
          //   "Mozilla/5.0 (Linux; Android 8.1; PAR-AL00 Build/HUAWEIPAR-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/6.2 TBS/044304 Mobile Safari/537.36 MicroMessenger/6.7.3.1360(0x26070333) NetType/WIFI Language/zh_CN Process/tools",
          //   "Mozilla/5.0 (Linux; Android 8.1.0; ALP-AL00 Build/HUAWEIALP-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/63.0.3239.83 Mobile Safari/537.36 T7/10.13 baiduboxapp/10.13.0.11 (Baidu; P1 8.1.0)",
          //   "Mozilla/5.0 (Linux; Android 6.0.1; OPPO A57 Build/MMB29M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/63.0.3239.83 Mobile Safari/537.36 T7/10.13 baiduboxapp/10.13.0.10 (Baidu; P1 6.0.1)",
          //   "Mozilla/5.0 (Linux; Android 8.1; EML-AL00 Build/HUAWEIEML-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/53.0.2785.143 Crosswalk/24.53.595.0 XWEB/358 MMWEBSDK/23 Mobile Safari/537.36 MicroMessenger/6.7.2.1340(0x2607023A) NetType/4G Language/zh_CN",
          //   "Mozilla/5.0 (Linux; Android 8.0; DUK-AL20 Build/HUAWEIDUK-AL20; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/6.2 TBS/044353 Mobile Safari/537.36 MicroMessenger/6.7.3.1360(0x26070333) NetType/WIFI Language/zh_CN Process/tools",
          //   "Mozilla/5.0 (Linux; U; Android 8.0.0; zh-CN; MHA-AL00 Build/HUAWEIMHA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 UCBrowser/12.1.4.994 Mobile Safari/537.36",
          //   "Mozilla/5.0 (Linux; Android 8.0; MHA-AL00 Build/HUAWEIMHA-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/6.2 TBS/044304 Mobile Safari/537.36 MicroMessenger/6.7.3.1360(0x26070333) NetType/NON_NETWORK Language/zh_CN Process/tools",
          //   "Mozilla/5.0 (Linux; U; Android 8.0.0; zh-CN; MHA-AL00 Build/HUAWEIMHA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/40.0.2214.89 UCBrowser/11.6.4.950 UWS/2.11.1.50 Mobile Safari/537.36 AliApp(DingTalk/4.5.8) com.alibaba.android.rimet/10380049 Channel/227200 language/zh-CN",
          //   "Mozilla/5.0 (Linux; U; Android 8.1.0; zh-CN; EML-AL00 Build/HUAWEIEML-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 UCBrowser/11.9.4.974 UWS/2.13.1.48 Mobile Safari/537.36 AliApp(DingTalk/4.5.11) com.alibaba.android.rimet/10487439 Channel/227200 language/zh-CN",
          //   "Mozilla/5.0 (Linux; U; Android 4.1.2; zh-cn; HUAWEI MT1-U06 Build/HuaweiMT1-U06) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30 baiduboxapp/042_2.7.3_diordna_8021_027/IEWAUH_61_2.1.4_60U-1TM+IEWAUH/7300001a/91E050E40679F078E51FD06CD5BF0A43%7C544176010472968/1",
          //   "Mozilla/5.0 (Linux; Android 8.0; MHA-AL00 Build/HUAWEIMHA-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/6.2 TBS/044304 Mobile Safari/537.36 MicroMessenger/6.7.3.1360(0x26070333) NetType/4G Language/zh_CN Process/tools",
          //   "Mozilla/5.0 (Linux; U; Android 8.0.0; zh-CN; BAC-AL00 Build/HUAWEIBAC-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 UCBrowser/11.9.4.974 UWS/2.13.1.48 Mobile Safari/537.36 AliApp(DingTalk/4.5.11) com.alibaba.android.rimet/10487439 Channel/227200 language/zh-CN",
          //   "Mozilla/5.0 (Linux; U; Android 8.1.0; zh-CN; BLA-AL00 Build/HUAWEIBLA-AL00) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 UCBrowser/11.9.4.974 UWS/2.13.1.48 Mobile Safari/537.36 AliApp(DingTalk/4.5.11) com.alibaba.android.rimet/10487439 Channel/227200 language/zh-CN",
          //   "Mozilla/5.0 (Linux; Android 5.1.1; vivo X6S A Build/LMY47V; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 MQQBrowser/6.2 TBS/044207 Mobile Safari/537.36 MicroMessenger/6.7.3.1340(0x26070332) NetType/4G Language/zh_CN Process/tools",
          // ];

          // String finalUserAgent = listUserAgent[getIntBetweenRange(0, listUserAgent.length)];

          if(finalUrl.isEmpty)
            {
              showToast("Unable to get link....");
              return;
            }
          WebViewUtils webViewUtils = WebViewUtils();
          bool isCaptcha = await webViewUtils.showWebViewDialog(finalUrl, ".flv",/*userAgent: u.getUserAgent(),*/isAuto : isAutoCaptchaVerification,incognito: true,/*header: {"User-Agent":u.getUserAgent()}*/);
          if (!isCaptcha && isAutoCaptchaVerification)
             {
               var result = await webViewUtils.inAppWebViewController2.evaluateJavascript(source: "document.cookie");
               String cookie = result.toString().split(";").where((cookie)=>cookie.contains("did")).first;
               SharedPrefsUtil.setString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE, cookie);
               SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, false);
               Get.back();
             }
           else if (isCaptcha && isAutoCaptchaVerification)
             {
               await saveCaptchaUsersToFile(finalUrl);
               Get.back();
             }
             if (isRefresh)
             {
               await initiateUnfollowUploadingProcess();
             }
        }
      } catch (e) {
        print(e);
      }
    }
  }


  Future<String> getRandomUserUrl () async {
    String finalUrl = "";
    String? captchUser = await getCaptchaUser();
    if (captchUser!.isNotEmpty) {
      finalUrl = captchUser;
    }
    else
      {
        List<SocialUser> list = getAllUserList();
        List<SocialUser> listFiltered = list.where((user)=>user.value!.contains("<||>UNFOLLOW")).toList();
        var randomU = listFiltered[Random().nextInt(listFiltered.length)];
        finalUrl = "https://v.kuaishou.com${randomU.value!.replaceAll("<||>UNFOLLOW", "")}";
      }


    return finalUrl;
  }

  Future<String> getRandomUserUrl2 () async {
    String finalUrl = "";
    List<SocialUser> list = getAllUserList();
    List<SocialUser> listFiltered = list.where((user)=>!user.value!.contains("<||>UNFOLLOW")).toList();
    var randomU = listFiltered[Random().nextInt(listFiltered.length)];
    finalUrl = "https://live.kuaishou.com/u/${randomU.value}";

    return finalUrl;
  }

  Future<String> getRandomLiveUserUrl () async {
    String finalUrl = "";
    List<String> list = kuaishouLiveUserListBox!.get("live_user_id_list").cast<String>();
    var randomU = list[Random().nextInt(list.length)];
    finalUrl = "https://live.kuaishou.com/u/${randomU}";

    return finalUrl;
  }
  Future startServicesIfUserAvailable() async
  {
    List<SocialUser> list = getAllUserList();
    if(list.length > 0)
    {
      await restartBackgroundService();
      await initiateUnfollowUploadingProcess();
    }
  }

  Future setFolderIfNotSet() async
  {

    if (SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER).isEmpty || SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID).isEmpty) {
      StreamTapeFolder rootFolder = await fetchFolderList();
      DateTime currentDateTime = DateTime.now();
      String folderName = "Kwai ${currentDateTime.day} ${currentDateTime.month} ${currentDateTime.year % 100}";
      StreamTapeFolderItem? currentStreamTapeFolder = rootFolder!.folders!.where((e) => e.name ==  folderName).firstOrNull;
      if(currentStreamTapeFolder != null)
      {
        SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, currentStreamTapeFolder.name!);
        SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, currentStreamTapeFolder.id!);
      }
      else
      {
        SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, rootFolder!.folders!.first.name!);
        SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, rootFolder!.folders!.first.id!);
      }
    }
  }

  static RangeValues getRangeValuesFromString (String value)
  {
    List<String> valueList = value.split(":");
    double start = double.parse(valueList[0]);
    double end = double.parse(valueList[1]);
    return RangeValues(start, end);
  }

  deleteDuplicateFiles(String id) async
  {
    try {
      StreamTapeFolder streamTapeFolder = await getFolderFiles(id);

      List<String> duplicateFiles = getDuplicateFilesName(streamTapeFolder.files!);
      List<String> toDeleteFileList = [];
      for(String duplicateFile in duplicateFiles)
            {
              List<StreamtapeFileItem> duplicateStreamtapeFiles = streamTapeFolder.files!.where((item)=> item.name == duplicateFile).toList();
              StreamtapeFileItem largestStreamtapeFile = duplicateStreamtapeFiles.reduce((current, next) {
                return current.size! > next.size! ? current : next;
              });
              for(StreamtapeFileItem streamtapeFileItem in duplicateStreamtapeFiles)
                {
                  if(largestStreamtapeFile.linkid != streamtapeFileItem.linkid)
                    {
                      toDeleteFileList.add(streamtapeFileItem.linkid!);
                    }
                }
            }

      for(StreamtapeFileItem streamtapeFileItem in streamTapeFolder.files!)
          {
            if(convertBytesToMegaBytes(streamtapeFileItem.size!) < 200 || streamtapeFileItem.convert == "error")
            {
              if(!toDeleteFileList.contains(streamtapeFileItem.linkid!))
                {
                  toDeleteFileList.add(streamtapeFileItem.linkid!);
                }
            }
          }
      if (toDeleteFileList.length > 0) {
            String ids = convertListToArrayString(toDeleteFileList);
            await deleteFiles(ids);
          }

      if(toDeleteFileList.length == 0)
            {
              showToast("There is not need to clean it......");
            }
          else
            {
              showToast("Deleted Successfully.....");
            }
    } catch (e) {
      print(e);
    }

  }

  String convertListToArrayString (List<String> list)
  {
    StringBuffer arrayBuffer = StringBuffer("");
    arrayBuffer.write("[");
    for(int i = 0;i < list.length;i++)
      {
        arrayBuffer.write("\"${list[i]}\"");
        if(i != list.length - 1)
          {
            arrayBuffer.write(",");
          }
      }
    arrayBuffer.write("]");
    return arrayBuffer.toString();
  }

  List<String> getDuplicateFilesName(List<StreamtapeFileItem> list)
  {
    Map<String, int> countMap = {};

    // Iterate through the list and populate the countMap
    for (StreamtapeFileItem streamtapeFileItem in list) {
      if (countMap.containsKey(streamtapeFileItem.name!)) {
        countMap[streamtapeFileItem.name!] = countMap[streamtapeFileItem.name]! + 1;
      } else {
        countMap[streamtapeFileItem.name!] = 1;
      }
    }

    // Collect all duplicates
    List<String> duplicates = [];
    countMap.forEach((key, value) {
      if (value > 1) {
        duplicates.add(key);
      }
    });
    return duplicates;
  }

  double convertBytesToMegaBytes (int bytes)
  {
    double kb = bytes / 1024;
    double mb = kb / 1024;
    return mb;
  }

  Future<void> cloneStreamTapeFolder () async
  {
    DialogUtils.showLoaderDialog(Get.context!,text: "Cloning.....".obs);
    DateTime dateTimeNow = DateTime.now();
    DateTime dateTimeBeforeMonth = dateTimeNow.subtract(Duration(days: 30));
    StreamTapeFolder streamTapeFolder = await fetchFolderList();
    for(StreamTapeFolderItem streamTapeFolderItem in streamTapeFolder.folders!)
      {
        if(!streamTapeFolderItem.name!.toLowerCase().contains("clone"))
          {
            DateTime? folderDateTime;
            try {
              List<String> dateList = streamTapeFolderItem.name!.replaceAll("Kwai", "").replaceAll("kwai", "").trim().split(" ");
              int day = int.parse(dateList[0]);
              int month = int.parse(dateList[1]);
              int year = int.parse("20"+dateList[2]);
              folderDateTime = DateTime(year,month,day);
            } catch (e) {
              print(e);
            }
            if(folderDateTime != null && folderDateTime!.isBefore(dateTimeBeforeMonth))
              {
                try {
                  String newFolderName = streamTapeFolderItem.name! + " Clone";
                  List<String> toCopyFileId = [];
                  (bool,String) status = await createFolder(newFolderName);
                  if(status.$1)
                   {
                     StreamTapeFolder streamTapeFolder = await getFolderFiles(streamTapeFolderItem.id!);
                     for(StreamtapeFileItem streamtapeFileItem in streamTapeFolder.files!)
                       {
                         toCopyFileId.add(streamtapeFileItem.linkid!);
                       }
                     String ids = convertListToArrayString(toCopyFileId);
                     bool isCopied = await copyStreamTapeFiles(ids, status.$2);
                     if(isCopied)
                       {
                         showToast(streamTapeFolderItem.name! + " Cloned Successfully.....");
                         await deleteFolder(streamTapeFolderItem.id!);
                       }
                     else
                       {
                         showToast("Erro while cloning (${streamTapeFolderItem.name!})");
                       }
                   }
                  else if (status.$2 == "500")
                    {
                      showToast("Folder already exists.... (${streamTapeFolderItem.name!})");
                    }
                } catch (e) {
                  showToast(e.toString());
                }
              }

          }
      }
    await getFolderList(isResume: true);
    DialogUtils.stopLoaderDialog();
  }


  void cancelUnfollowTimer()
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
  }

  // List<StreamtapeFileItem> singleGroupStreamTapeFiles = [];
  // var groupedByTimeStamp = <int, List<StreamtapeFileItem>>{};
  //
  // for (var streamtapeFileItem in duplicateStreamtapeFiles) {
  //   groupedByTimeStamp.putIfAbsent(streamtapeFileItem.created_at!, () => []).add(streamtapeFileItem);
  // }
  //
  // var result = groupedByTimeStamp.values.toList();
  //
  // for (List<StreamtapeFileItem> group in result) {
  //   if (group.length > 1) {
  //     StreamtapeFileItem largestFilteredStreamtapeFile = group.reduce((current, next) {
  //       return current.size! > next.size! ? current : next;
  //     });
  //     for(StreamtapeFileItem streamtapeFileItem in group)
  //     {
  //       if(largestFilteredStreamtapeFile.linkid != streamtapeFileItem.linkid!)
  //       {
  //         toDeleteFileList.add(streamtapeFileItem.linkid!);
  //       }
  //     }
  //   }
  //   else
  //   {
  //     singleGroupStreamTapeFiles.addAll(group);
  //   }
  // }
  // for(StreamtapeFileItem streamtapeFileItem in singleGroupStreamTapeFiles)
  // {
  // if(largestStreamtapeFile.linkid != streamtapeFileItem.linkid)
  // {
  // toDeleteFileList.add(streamtapeFileItem.linkid!);
  // }
  // }

  String convertBytes(int bytes) {
    String result = "N/A";
    try {
      double mb = bytes / (1024 * 1024);

      // If MB is less than 1024, return the MB value
      if (mb < 1024) {
          result = "${mb.toStringAsFixed(2)} MB";
          } else {
            // Convert MB to GB if greater than 1024
            double gb = mb / 1024;
            result = "${gb.toStringAsFixed(2)} GB";
          }
    } catch (e) {

    }
    return result;
  }

  verifiyCaptchaManual () async {
    //if((SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED) || SharedPrefsUtil.getString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE).isEmpty))
    //{
      WebViewUtils webViewUtils = WebViewUtils();
      webViewUtils.showWebViewDialog("https://klsxvkqw.m.chenzhongtech.com/fw/live/cyl51666888?cc=share_copylink&followRefer=151&shareMethod=TOKEN&docId=5&kpn=NEBULA&subBiz=LIVE_STREAM&shareId=18188504186071&shareToken=X-5rYqLYfLEz116u&shareResourceType=LIVESTREAM_OTHER&userId=24561342&shareType=5&et=1_a%2F2007896619798938993_nle2&shareMode=APP&efid=0&originShareId=18188504186071&appType=21&shareObjectId=pexFVhEe5uk&shareUrlOpened=0&timestamp=173401333806", ".flv");
      await Future.delayed(Duration(seconds: 20));
      var result = await webViewUtils.inAppWebViewController.evaluateJavascript(source: "document.cookie");
      String cookie = result.toString().split(";").where((cookie)=>cookie.contains("did")).first;
      SharedPrefsUtil.setString(SharedPrefsUtil.KEY_KUAISHOU_COOKIE, cookie);
      SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CAPTCHA_VERFICATION_REQUIRED, false);
      Get.back();
    //}
  }

  Future<void> saveCaptchaUsersToFile(String url) async {
    // Request storage permission if needed

    List<String>? _exPath = await ExternalPath.getExternalStorageDirectories();
    final downloadDirectory = Directory('${_exPath![0]}/kuaishou_data');
    if (!await downloadDirectory.exists()) {
      await downloadDirectory.create(recursive: true);
    }

    final filePath = '${downloadDirectory.path}/captchausers.txt';
    final file = File(filePath);

    // Read file if it exists
    if (await file.exists()) {
      final existingContent = await file.readAsLines();
      if (existingContent.contains(url)) {
        print('URL already exists in file.');
        return; // Exit early if URL already exists
      }
    }

    // Write to file
    await file.writeAsString("$url\n", mode: FileMode.append);
    print('URL added to file.');
  }

  Future<String?> getCaptchaUser() async
  {
    String? user = "";
    try {
      List<String> lines = [];
      List<String>? _exPath = await ExternalPath.getExternalStorageDirectories();
      final downloadDirectory = Directory('${_exPath![0]}/kuaishou_data');
      String filePath = '${downloadDirectory.path}/captchausers.txt';

      // Reading the file
      File file = File(filePath);
      if (await file.exists()) {
            lines = await file.readAsLines();
          }
      if (lines.length > 0) {
        user = lines[getIntBetweenRange(0, lines.length)];
      } else {
        user = "";
      }
    } catch (e) {
      print(e);
      return user;
    }
    return user;

  }

  var tiktokHeader = {
    "Sec-Ch-Ua": "\"Not/A)Brand\";v=\"8\", \"Chromium\";v=\"126\"",
    "Sec-Ch-Ua-Mobile": "?0",
    "Sec-Ch-Ua-Platform": "\"Linux\"",
    "Accept-Language": "en-US",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.6478.127 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-User": "?1",
    "Sec-Fetch-Dest": "document",
    "Priority": "u=0, i",
    "Referer": "https://www.tiktok.com/"};

  Future<String> getRoomIdFromUser(String user) async {

    // final response = await httpClient.get(
    //   Uri.parse('https://www.tiktok.com/@$user/live'),
    //   headers: {
    //     'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
    //   },
    // );



    String proxyUrl = "https://www.tiktok.com/@$user/live";

    final content = await WebUtils.makeGetRequest(proxyUrl,headers: tiktokHeader);

    if (content!.contains('Please wait...')) {
      return "";
    }

    final regex = RegExp(
      r'<script id="SIGI_STATE" type="application/json">(.*?)</script>',
      dotAll: true,
    );
    final match = regex.firstMatch(content);

    if (match == null) {
      return "";
    }

    final jsonData = json.decode(match.group(1)!);

    if (!jsonData.containsKey('LiveRoom') && jsonData.containsKey('CurrentRoom')) {
      return "";
    }

    final roomId = jsonData['LiveRoom']?['liveRoomUserInfo']?['user']?['roomId'];

    if (roomId == null) {
      return "";
    }

    return roomId.toString();
  }


  Future<String> getLiveUrl(String roomId) async {
    if (roomId.isEmpty){return "";}

    final jsonResponse = await WebUtils.makeGetRequest("https://webcast.tiktok.com/webcast/room/info/?aid=1988&room_id=$roomId",headers: tiktokHeader);

    final data = json.decode(jsonResponse!);

    if (jsonResponse.contains('This account is private')) {
      return "";
    }

    final streamUrl = data['data']?['stream_url'] ?? {};

    // TODO: Implement m3u8 support if needed later
    String? liveUrlFlv = streamUrl['flv_pull_url']?['FULL_HD1'] ??
        streamUrl['flv_pull_url']?['HD1'] ??
        streamUrl['flv_pull_url']?['SD2'] ??
        streamUrl['flv_pull_url']?['SD1'];

    // If no FLV URL found, fallback to RTMP
    liveUrlFlv ??= streamUrl['rtmp_pull_url'];

    if (liveUrlFlv == null && data['status_code'] == 4003110) {
      return "";
    }

    print('LIVE URL: $liveUrlFlv\n'); // Equivalent to logger.info

    return liveUrlFlv ?? '';
  }

  Future<List<TiktokUser>> getTiktokLiveUserList() async
  {
    List<TiktokUser> usersList = [];
    final Map<String, String> headers = {
      'sec-ch-ua': '"Microsoft Edge";v="135", "Not-A.Brand";v="8", "Chromium";v="135"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'sentry-trace': '9cec17990f854628926e19280736460e-839f81e984c198db-1',
      'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0',
      'x-pie-req-header-accept-encoding': 'gzip, deflate, br, zstd',
      'x-pie-req-header-accept-language': 'en-US,en;q=0.9,ur;q=0.8',
      'x-pie-req-header-cookie': 'sessionid_ss=6dc7e832d898854e8cffb825014c926d',
      'x-pie-req-header-host': 'webcast.tiktok.com',
      'x-pie-req-header-origin': 'https://www.tiktok.com',
      'x-pie-req-header-referer': 'https://www.tiktok.com',
      'x-pie-req-header-sec-ch-ua': '"Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"',
      'x-pie-req-header-sec-ch-ua-mobile': '?0',
      'x-pie-req-header-sec-ch-ua-platform': '"Windows"',
      'x-pie-req-header-sec-fetch-dest': 'empty',
      'x-pie-req-header-sec-fetch-mode': 'cors',
      'x-pie-req-header-sec-fetch-site': 'same-site',
      'x-pie-req-header-user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',
      'x-pie-req-meta-follow-redirects': 'true',
      'x-pie-req-meta-method': 'GET',
      'x-pie-req-meta-ssl-verify': 'true',
      'x-pie-req-meta-url': 'https://webcast.tiktok.com/webcast/feed/?aid=1988&app_language=en&app_name=tiktok_web&browser_language=en-US&browser_name=Mozilla&browser_online=true&browser_platform=Win32&browser_version=5.0%20%28Windows%20NT%2010.0%3B%20Win64%3B%20x64%29%20AppleWebKit%2F537.36%20%28KHTML%2C%20like%20Gecko%29%20Chrome%2F135.0.0.0%20Safari%2F537.36&channel=tiktok_web&channel_id=88&cookie_enabled=true&data_collection_enabled=true&device_id=7484883874386101778&device_platform=web_pc&device_type=web_h264&focus_state=true&from_page=following&history_len=9&is_fullscreen=false&is_non_personalized=0&is_page_visible=true&max_time=0&os=windows&priority_region=CO&referer=&region=US&req_from=live_mt_pc_web_follow_tab_refresh&root_referer=https%3A%2F%2Fwww.tiktok.com%2F&screen_height=1080&screen_width=1920&tz_name=Asia%2FKarachi&user_is_login=true',
    };

    try {
      String? resposne = await WebUtils.makeGetRequest(HTTPIE_PROXY_URL,headers: headers);
      TiktokLiveResponse tiktokLiveResponse = TiktokLiveResponse.fromJson(jsonDecode(resposne!));
      usersList = tiktokLiveResponse.data;
    } catch (e) {
      print(e);
    }

    return usersList;
  }

  Future<void> runWithDelay(
      List<Future Function()> futureFactories,
      Duration delay,
      ) async {
    List<Future> futures = [];

    for (var factory in futureFactories) {
      futures.add(factory());
      await Future.delayed(delay); // Delay before starting the next one
    }

    await Future.wait(futures); // Wait for all to complete
  }



}