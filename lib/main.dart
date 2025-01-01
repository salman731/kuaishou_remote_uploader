import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:background_mode_new/background_mode_new.dart';
import 'package:butterfly_dialog/butterfly_dialog.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/dialogs/dialog_utils.dart';
import 'package:kuaishou_remote_uploader/dialogs/video_player_dialog.dart';
import 'package:kuaishou_remote_uploader/enums/background_mode_time_enum.dart';
import 'package:kuaishou_remote_uploader/models/kuaishou_live_user.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_download_status.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/models/user_kuaishou.dart';
import 'package:kuaishou_remote_uploader/streamtape_download_screen.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:kuaishou_remote_uploader/utils/video_capture_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_view_utils.dart';
import 'package:kuaishou_remote_uploader/widgets/custom_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

final service = FlutterBackgroundService();
Future<void> startBackgroundService() async {
  await service.startService();
}

void stopBackgroundService() {
  service.invoke("stopService");
}

Future<bool> isServiceRunning () async
{
  return await service.isRunning();
}

const notificationChannelId = 'my_foreground';

const notificationId = 888;

Future<void> initializeService() async {

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.defaultImportance, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: true,
      notificationChannelId: notificationChannelId, // this must match with notification channel you created above.
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

bool isBetweenTime(int minhour,int maxHour)
{
  DateTime now = DateTime.now();

  // Check if the current hour is greater than or equal to 18 (6 PM)
  if (now.hour >= minhour && now.hour <=maxHour) {
    return true;
  } else {
    return false;
  }
}

int getIntBetweenRange(int min, int max)
{
  final _random = new Random();
  /**
   * Generates a positive random integer uniformly distributed on the range
   * from [min], inclusive, to [max], exclusive.
   */
  return min + _random.nextInt(max - min);
}

Timer makePeriodicTimer(
    Duration duration,
    void Function(Timer? timer) callback, {List<Duration>? timeSpecificDuration,bool fireNow = false, bool isCustomTimer = false,bool isUnfollowTimer = false}) {
  Timer timer = isCustomTimer ? isUnfollowTimer ? unfollowLaunchTimer(duration, callback: callback) : launchTimer(duration,timeSpecificDuration!,callback: callback) : Timer.periodic(duration, callback);
  if (fireNow) {
    callback(timer);
  }
  return timer;
}

Duration getDurationBaseOnTime (List<Duration> list)
{
  if(isBetweenTime(0,5)) // Midnight
      {
        return list[0];
  }
  else if(isBetweenTime(6,15)) // morning afternoon
      {
    return list[1];
  }
  else // evening night
      {
    return list[2];
  }
}

Timer launchTimer(Duration duration,List<Duration> timeSpecificDurationList,{ required Function callback})
{
  return Timer(duration, () {

    callback(null);
    if(isBetweenTime(0,5)) // Midnight
      {
        launchTimer(timeSpecificDurationList[0],timeSpecificDurationList,callback: callback);
      }
    else if(isBetweenTime(6,15)) // morning afternoon
      {
        launchTimer(timeSpecificDurationList[1],timeSpecificDurationList,callback: callback);
      }
    else if(isBetweenTime(16,23)) // evening night
      {
        launchTimer(timeSpecificDurationList[2],timeSpecificDurationList,callback: callback);
      }

  });
}

Timer unfollowLaunchTimer(Duration duration,{ required Function callback})
{
  return Timer(duration, () {

      List<UserKuaishou> list = Get.find<AppController>().getAllUserList();
      List<UserKuaishou> listFiltered = list.where((user)=>user.value!.contains("<||>UNFOLLOW")).toList();
      int totalMin = getUnfollowMin(listFiltered);
      SharedPrefsUtil.setInt(SharedPrefsUtil.KEY_CURRENT_UNFOLLOW_MIN, totalMin);
      Get.find<AppController>().unfollowCurrentTime.value = totalMin;
      callback(null);
      unfollowLaunchTimer(Duration(minutes: totalMin),callback: callback);


  });
}

int getUnfollowMin(List<UserKuaishou> userList)
{
  int userListSize = userList.length;
  int randomMin = getIntBetweenRange(9, 14);
  int totalminPerUser = ((userListSize * getIntBetweenRange(35,40)) / 60).ceil() ;
  int totalMin = totalminPerUser + randomMin;
  return totalMin;
}

Future<void> showNotification({required String title,required String content}) async
{
  await FlutterLocalNotificationsPlugin().show(
    notificationId,
    title,
    content,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        'MY FOREGROUND SERVICE',
        icon: 'ic_bg_service_small',
        ongoing: true,
      ),
    ),
  );
}

String formatTime(int seconds) {
  int minutes = seconds ~/ 60;  // Integer division for minutes
  int remainingSeconds = seconds % 60;  // Get the remainder for seconds

  // Format as mm:ss (e.g., "03:05")
  return '${minutes.toString().padLeft(2, '0')} : ${remainingSeconds.toString().padLeft(2, '0')}';
}



@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) async {
    await service.stopSelf();
  });
  await SharedPrefsUtil.initSharedPreference();
  int midNightDuration = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_MIDNIGHT_SLIDER,defaultValue: 15).toInt(); // 12:00 AM -> 06:00 AM
  int morningAfterNoonDuration = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_MORNINGAFTERNOON_SLIDER,defaultValue: 10).toInt(); // 6:00 AM -> 4:00 PM
  int eveningNightDuration = SharedPrefsUtil.getDouble(SharedPrefsUtil.KEY_EVENINGNIGHT_SLIDER,defaultValue: 7).toInt(); // 4:00 PM -> 12:00 AM
  List<Duration> listDuration = [Duration(minutes: midNightDuration),Duration(minutes: morningAfterNoonDuration),Duration(minutes: eveningNightDuration)];

  int userOnline = 0;
  int userNewUploaded = 0;
  int userOldUploaded = 0;


  Timer timer = makePeriodicTimer(getDurationBaseOnTime(listDuration),timeSpecificDuration:listDuration,(timer) async {
    bool isProcessingDone = false;
    bool isError = false;
    String remainingTime = "";
    String errorMsg = "";
    await SharedPrefsUtil.reloadSharedPreferences();
    String? cookie = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_COOKIE);
    String? csrf = SharedPrefsUtil.getString(SharedPrefsUtil.KEY_STREAMTAPE_CSRF_TOKEN);
    final stopWatchTimer = StopWatchTimer(
        mode: StopWatchMode.countDown,
        presetMillisecond: StopWatchTimer.getMilliSecFromMinute(getDurationBaseOnTime(listDuration).inMinutes), // millisecond => minute.
        onChangeRawSecond: (value) async {
          if(cookie.isEmpty && csrf.isEmpty)
          {
            await showNotification(title: "Uploading Service",content: "⏳ Waiting for Streamtape Login......");
          }
          remainingTime = "Next in : ${formatTime(value)}";
          if (isProcessingDone) {
            await showNotification(title: "Uploading Service (${remainingTime})",content: "✅ User Online: ${userOnline} | Newly Uploaded User: ${userNewUploaded} | Current User Uploading: ${userOldUploaded}");
          }
          else if (isError)
            {
              await showNotification(title: "Uploading Service (${remainingTime})",content: "Exception : " + errorMsg);
            }
         }
    );
    stopWatchTimer.onStartTimer();
    if(cookie.isEmpty && csrf.isEmpty)
    {
      return;
    }
    if (service is AndroidServiceInstance) {
      //print("This is background service" + DateTime.now().toString());

      AppController appController = Get.put(AppController());
      await appController.setFolderIfNotSet();
      final appDocumentDirectory = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDirectory.path);
      await Hive.close();
      appController.usernameListIdBox = await Hive.openBox("usernameListIdBox");
      List<UserKuaishou> list = appController.getAllUserList();
      await appController.createFolderOnNextDay();

      List<StreamtapeDownloadStatus> streamTapeDownloadStatusList = await appController.getRemoteDownloadingStatus_background();
      List<StopWatchTimer> listStopWatchTimer = [];
      await showNotification(title: "Uploading Service (${remainingTime})",content: "Fetching Live User List......");

      (List<ListElement>,String) liveUserList = await appController.getLiveUserList((exTime) async {
        if(!exTime.$3)
          {
            for(StopWatchTimer stopwatch in listStopWatchTimer)
            {
              stopwatch.onStopTimer();
            }
            listStopWatchTimer = [];
          }

        StopWatchTimer stopWatchTimer = StopWatchTimer(
            mode: StopWatchMode.countDown,
            presetMillisecond: StopWatchTimer.getMilliSecFromMinute(exTime.$2), // millisecond => minute.
            onChangeRawSecond: (value) async {
              remainingTime = "Re-Trying in : ${formatTime(value)}";
              await showNotification(title: "Uploading Service ($remainingTime)",content: "Exception Occured : " + exTime.$1);
            },
            onEnded: () async {
              await showNotification(title: "Uploading Service (${remainingTime})",content: "Fetching Live User List......");
              }
        );
        stopWatchTimer.onStartTimer();
        listStopWatchTimer.add(stopWatchTimer);
      });

      for(StopWatchTimer stopwatch in listStopWatchTimer)
      {
        stopwatch.onStopTimer();
      }

      await showNotification(title: "Uploading Service (${remainingTime})",content: "Fetched Successfully | User : ${liveUserList.$1.length} ");
      userOnline = liveUserList.$1.length;
      userNewUploaded = 0;
      userOldUploaded = 0;
      if (liveUserList.$1.length > 0) {
        for (UserKuaishou userKuaishou in list) {

          await showNotification(title: "Uploading Service (${remainingTime} (${list.indexOf(userKuaishou) + 1}/${list.length})) ",content: "⏳ UPLOADING ON STREAMTAPE : ${userKuaishou.value!}");
          for (ListElement user in liveUserList.$1) {

            if (user.author!.id!.toLowerCase() == userKuaishou.value!.toLowerCase()) {

                String url = user.playUrls.first.adaptationSet!.representation.first.url!;
                if (url.isNotEmpty) {
                  bool isUploaded = await appController.startUploading_background(user.playUrls.first.adaptationSet!.representation.first.url!, streamTapeDownloadStatusList);

                  if (isUploaded) {
                    userNewUploaded++;
                  } else {
                    userOldUploaded++;
                  }
                }
              }

            }
          }
        isProcessingDone = true;
        await showNotification(title: "Uploading Service (${remainingTime})",content: "✅ User Online: ${userOnline} | Newly Uploaded User: ${userNewUploaded} | Current User Uploading: ${userOldUploaded}");
      }
      else
        {
          if(liveUserList.$2.isNotEmpty)
            {
              isError = true;
              errorMsg = liveUserList.$2;
              await showNotification(title: "Uploading Service (${remainingTime})",content: "Exception : " + errorMsg);
            }
          else
            {
              await showNotification(title: "Uploading Service (${remainingTime})",content: "❌ User list is empty.....");
            }
        }
    }
    // });
  },fireNow: true,isCustomTimer: true);

}
  //Timer.periodic(const Duration(minutes: 20),
//"Uploading in Progress : ${userKuaishou.value}"

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await initializeService();
  await SharedPrefsUtil.initSharedPreference();
  startBackgroundService();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kuaishou Remote Uploader',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  MyHomePage(title: 'Kuaishou Remote Uploader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
   MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  AppController appController = Get.put(AppController());

  String? previousTextFieldTxt = "";
  late AppLifecycleListener appLifecycleListener;
  AppLifecycleState? previousState;
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();



  @override
  void initState() {
   /* Future.delayed(Duration(seconds: 5),(){
      FlutterBackgroundService().invoke("setAsBackground");
    });*/
    //initAutoStart();

    Future.delayed(Duration(seconds: 0),() async{
      await appController.loginToStreamTape();
      appLifecycleListener = AppLifecycleListener(
          onResume: () async {
            if (previousState!= null && !appController.isDownloadStatusUpdating.value) {
              await SharedPrefsUtil.reloadSharedPreferences();
              await appController.verifyCaptcha(isRefresh: true);
              DateTime currentDateTime = DateTime.now();
              String folderName = "Kwai ${currentDateTime.day} ${currentDateTime.month} ${currentDateTime.year % 100}";
              if(appController.selectedFolder.value.name != folderName && folderName == SharedPrefsUtil.getString(SharedPrefsUtil.KEY_SELECTED_FOLDER, defaultValue: ""))
              {
                  await appController.getFolderList(isResume: true);
              }
              // if(SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_NEW_FOLDER_CREATED,defaultValue: false))
              //   {
              //     await appController.getFolderList();
              //     SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_NEW_FOLDER_CREATED,false);
              //   }
              if (!SharedPrefsUtil.getBool(SharedPrefsUtil.KEY_IS_CONCURRENT_PROCESS,defaultValue: true)) {
                await appController.getDownloadingVideoStatus();
              } else {
                await appController.getConcurrentDownloadingVideoStatus();
              }
              previousState = null;
            }
          },
          onStateChange: (value){
            if(value == AppLifecycleState.paused)
            {
              previousState = value;
            }
            else
            {
              previousState == null;
            }
          }

      );
      //await appController.initiateUnfollowUploadingProcess();
    });

  }



  getTextColor(String status)
  {
    if(status == "downloading")
      {
        return Colors.green;
      }
    else if (status == "error")
      {
        return Colors.red;
      }
    else
      {
        return Colors.black;
      }
  }

  Future<void> reauthenticate() async
  {
    await appController.loginToStreamTape(isRefresh: true);
  }

  /*Future<void> initAutoStart() async {
    try {
      //check auto-start availability.
      var test = await (isAutoStartAvailable as FutureOr<bool>);
      print(test);
      //if available then navigate to auto-start setting page.
      if (test) await getAutoStartPermission();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
  }*/


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (item) async {
              switch(item)
                  {
                case "refresh":
                  //WebViewUtils webViewUtils = WebViewUtils();
                  //String? oLink = await WebUtils.getOriginalUrl("https://v.kuaishou.com/9rBZxQ");
                  //webViewUtils.showWebViewDialog("https://klsxvkqw.m.chenzhongtech.com/fw/live/cyl51666888?cc=share_copylink&followRefer=151&shareMethod=TOKEN&docId=5&kpn=NEBULA&subBiz=LIVE_STREAM&shareId=18188504186071&shareToken=X-5rYqLYfLEz116u&shareResourceType=LIVESTREAM_OTHER&userId=24561342&shareType=5&et=1_a%2F2007896619798938993_nle2&shareMode=APP&efid=0&originShareId=18188504186071&appType=21&shareObjectId=pexFVhEe5uk&shareUrlOpened=0&timestamp=173401333806", ".flv");
                  await appController.showReauthenticateStreamtapeDialog();
                  //await appController.getLiveUserList();
                  // var header = {"user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"};
                  // String? orginalUrl = await WebUtils.getOriginalUrl("https://v.kuaishou.com/cx20Ka",headers: header);
                  // String? response = await WebUtils.makeGetRequest(orginalUrl!,headers: header);
                  // print(response);
                  // String? response2 = await appController.getStreamUrlForBackgroundUpload_Web2("https://v.kuaishou.com/cx20Ka");
                  // print(response2);
                 case "streamtape_downloader":
                  Get.to(StreamtapeDownloadScreen());
                case "add_user":
                  DialogUtils.showUserListDialog(context);
                case "restart_background_service":
                  appController.restartBackgroundService(isToEnableSlider: false);
                case "export_users":
                  appController.saveListToFile();
                case "import_users":
                  bool isAdded = await appController.importUsersToHive();
                  if (isAdded) {
                    appController.restartBackgroundService(isToEnableSlider: false);
                  }

              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(value: "add_user", child: Text('Add User')),
              PopupMenuItem<String>(value: "restart_background_service", child: Text('Restart Background Service')),
              PopupMenuItem<String>(value: "refresh", child: Text('Refresh')),
              PopupMenuItem<String>(value: "export_users", child: Text('Export Users')),
              PopupMenuItem<String>(value: "import_users", child: Text('Import Users')),
              PopupMenuItem<String>(value: "streamtape_downloader", child: Text('Streamtape Downloader')),
              PopupMenuItem(
                child: Obx(()=> CheckboxListTile(
                  activeColor: Colors.blue,
                  value: appController.isConcurrentProcessing.value,
                  onChanged: (value){
                    appController.isConcurrentProcessing.value = !appController.isConcurrentProcessing.value;
                    SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_CONCURRENT_PROCESS, appController.isConcurrentProcessing.value);
                  },
                  title: Text("Enable Concurrent Processing"),
                ),

                ),
              ),
              PopupMenuItem(
                child: Obx(()=> CheckboxListTile(
                  activeColor: Colors.blue,
                  value: appController.isWebPageProcessing.value,
                  onChanged: (value){
                    appController.isWebPageProcessing.value = !appController.isWebPageProcessing.value;
                    SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_IS_WEB_PAGE_PROCESS, appController.isWebPageProcessing.value);
                  },
                  title: Text("Enable Web Page Processing"),
                ),

                ),
              ),
              PopupMenuItem(
                child: Obx(()=> CheckboxListTile(
                  activeColor: Colors.blue,
                  value: appController.isBackgroundModeEnable.value,
                  onChanged: (value){
                    appController.isBackgroundModeEnable.value = !appController.isBackgroundModeEnable.value;
                    SharedPrefsUtil.setBool(SharedPrefsUtil.KEY_BACKGROUNDMODE_ENABLE, appController.isBackgroundModeEnable.value);
                    appController.processBackgroundMode();
                  },
                  title: Text("Enable Background Mode"),
                ),

                ),
              ),
              PopupMenuItem(child: Obx(()=> appController.isBackGroundModeTimeRadioButtonsVisible.value ? Row(
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                title: const Text('Forever'),
                                leading: Radio<BackgroundModeTimeEnum>(
                                  value: BackgroundModeTimeEnum.ALLTIME,
                                  groupValue: appController.backgroundModeTimeEnumRadioValue.value,
                                  onChanged: (BackgroundModeTimeEnum? value) {
                                    appController.backgroundModeTimeEnumRadioValue.value = BackgroundModeTimeEnum.ALLTIME;
                                    SharedPrefsUtil.setString(SharedPrefsUtil.KEY_BACKGROUNDMODE_TIME, BackgroundModeTimeEnum.ALLTIME.name);
                                    appController.processBackgroundMode();
                                    //SharedPrefsUtil.setString(SharedPrefsUtil.KEY_BACKGROUNDMODE_TIME_RANGE, "");
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text('Time Specific'),
                                leading: Radio<BackgroundModeTimeEnum>(
                                  value: BackgroundModeTimeEnum.TIMESPECIFIC,
                                  groupValue: appController.backgroundModeTimeEnumRadioValue.value,
                                  onChanged: (BackgroundModeTimeEnum? value) {
                                    appController.backgroundModeTimeEnumRadioValue.value = BackgroundModeTimeEnum.TIMESPECIFIC;
                                    SharedPrefsUtil.setString(SharedPrefsUtil.KEY_BACKGROUNDMODE_TIME, BackgroundModeTimeEnum.TIMESPECIFIC.name);
                                    appController.processBackgroundMode();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ) : SizedBox.shrink(),
              )

              ),
              PopupMenuItem(child: Obx(()=> appController.isBackgroundModeRangeSliderVisible.value ? Column(mainAxisAlignment: MainAxisAlignment.start,children: [
                Text("Background Mode Time Interval (24 H) (${appController.backgroundModeTimeSpecificRangeValue.value.start.toInt()} -> ${appController.backgroundModeTimeSpecificRangeValue.value.end.toInt()})"),
                RangeSlider(
                  values: appController.backgroundModeTimeSpecificRangeValue.value,
                  max: 23,
                  min: 0,
                  divisions: 24,
                  labels: RangeLabels(
                    appController.backgroundModeTimeSpecificRangeValue.value.start.toInt().toString(),
                    appController.backgroundModeTimeSpecificRangeValue.value.end.toInt().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    print("range slider is changing......");
                    appController.backgroundModeTimeSpecificRangeValue.value = values;

                  },
                  onChangeEnd: (RangeValues values){
                    SharedPrefsUtil.setString(SharedPrefsUtil.KEY_BACKGROUNDMODE_TIME_RANGE, "${values.start.toInt()}:${values.end.toInt()}");
                    appController.processBackgroundMode();
                  },
                )
              ],) : SizedBox.shrink(),
              ),),
              PopupMenuItem(
                child: Obx(()=>  Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Mid Night Background Interval 12:00 AM -> 06:00 AM (${appController.midNightSliderValue.value.toInt()} min)"),
                    Opacity(
                      opacity: appController.isSliderEnable.value ? 1 : 0.5,
                      child: Slider(
                        value: appController.midNightSliderValue.value,
                        max: 100,
                        min: 1,
                        divisions: 100,
                        label: appController.midNightSliderValue.toInt().toString(),
                        onChanged: appController.isSliderEnable.value ?  (double value) {
                          appController.midNightSliderValue.value = value.toInt().toDouble();
                        } : null,
                        onChangeEnd: (value) async{
                          SharedPrefsUtil.setDouble(SharedPrefsUtil.KEY_MIDNIGHT_SLIDER, value.toDouble());
                          if(isBetweenTime(0,5)) {
                            await appController.restartBackgroundService();
                          }
                        },
                      ),
                    ),


                  ],
                )),
              ),
              PopupMenuItem(
                child: Obx(()=> Column(mainAxisAlignment: MainAxisAlignment.start,children: [
                  Text("Morning Afternoon Background Interval 6:00 AM -> 4:00 PM (${appController.morningAfterNoonSliderValue.value.toInt()} min)"),
                   Opacity(
                     opacity: appController.isSliderEnable.value ? 1 : 0.5,
                     child: Slider(
                      value: appController.morningAfterNoonSliderValue.value,
                      max: 100,
                      min: 1,
                      divisions: 100,
                      label: appController.morningAfterNoonSliderValue.toInt().toString(),
                      onChanged: appController.isSliderEnable.value ?  (double value) {
                        appController.morningAfterNoonSliderValue.value = value.toInt().toDouble();
                      } : null,
                       onChangeEnd: (value) async {
                         SharedPrefsUtil.setDouble(SharedPrefsUtil.KEY_MORNINGAFTERNOON_SLIDER, value.toDouble());
                         if(isBetweenTime(6,15)){
                           await appController.restartBackgroundService();
                         }
                       }
                                       ),
                   ),


                ],)),
              ),
              PopupMenuItem(
                child: Obx(()=> Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Text("Evening Night Background Interval 4:00 PM -> 12:00 AM (${appController.eveningNightSliderValue.value.toInt()} min)"),
                  Opacity(
                    opacity: appController.isSliderEnable.value ? 1 : 0.5,
                    child: Slider(
                      value: appController.eveningNightSliderValue.value,
                      max: 100,
                      min: 1,
                      divisions: 100,
                      label: appController.eveningNightSliderValue.toInt().toString(),
                      onChanged: appController.isSliderEnable.value ? (double value) {
                        appController.eveningNightSliderValue.value = value.toInt().toDouble();
                      } : null,
                      onChangeEnd: (value) async {
                        SharedPrefsUtil.setDouble(SharedPrefsUtil.KEY_EVENINGNIGHT_SLIDER, value.toDouble());
                        if(isBetweenTime(16,23))
                          {
                            await appController.restartBackgroundService();
                          }

                      }
                    ),
                  ),
                ],)),
              ),
              PopupMenuItem(
                child: Obx(()=> Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text((appController.isUnfollowUserProcessing.value ? "Unfollow User Uploading in Progress (Interval Duration : ${appController.unfollowCurrentTime.value} min)" :"Unfollow User Background Timer (Interval Duration : ${appController.unfollowCurrentTime.value} min)") + " " + appController.unfollowUploadRemainingTime.value),
                    Text("Total Unfollowed User : ${appController.totalUnfollowUserUploadedProgress.value}",style: TextStyle(color: Colors.purpleAccent),),
                    Text("User Uploaded : ${appController.unfollowUserUploaded.value}",style: TextStyle(color: Colors.green),),
                    Text("Users Online : ${appController.unfollowUserOnline.value}",style: TextStyle(color: Colors.blue),),
                    Text("Users Offline : ${appController.unfollowUserOffline.value}",style: TextStyle(color: Colors.orange),),
                    Text("Execption Errors : ${appController.unfollowUserError.value}",style: TextStyle(color: Colors.redAccent),),
                    Text("Captcha Errors : ${appController.unfollowUserErrorCaptcha.value}",style: TextStyle(color: Colors.red),),
                    Text("Frequent Requests : ${appController.unfollowUserFrequentRequests.value}",style: TextStyle(color: Colors.indigo),),
                    Text("Other Errors : ${appController.unfollowUserOthers.value}",style: TextStyle(color: Colors.black54),),
                    // Opacity(
                    //   opacity: appController.isUnfollowUserProcessing.value ? 0.5 : 1,
                    //   child: Slider(
                    //       value: appController.unfollowUserIntervalSliderValue.value.toDouble(),
                    //       max: 100,
                    //       min: 1,
                    //       divisions: 100,
                    //       label: appController.unfollowUserIntervalSliderValue.toString(),
                    //       onChanged: !appController.isUnfollowUserProcessing.value ?  (double value) {
                    //         appController.unfollowUserIntervalSliderValue.value = value.toInt();
                    //       } : null,
                    //       onChangeEnd: (value) async {
                    //         SharedPrefsUtil.setInt(SharedPrefsUtil.KEY_UNFOLLOW_USER_TIMER, value.toInt());
                    //         await appController.uploadUnfollowUserWithWebView(value.toInt());
                    //
                    //       }
                    //   ),
                    // ),
                  ],)),
              )
            ],

          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:Obx(()=>appController.isLoading.value
              ? Center(child: CircularProgressIndicator()) : Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                  Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(// Background color
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2.0,
                    ),
                  ), //     <-- TextField expands to this height.
                  child: TextField(
                    controller: appController.folderTextEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          if(!appController.isGoingToRenameFolder.value)
                            {
                              bool isFolderExists = appController.streamTapeFolder!.folders!.any((value) => appController.folderTextEditingController.text.trim() == value.name);
                              if(!isFolderExists)
                              {
                                DialogUtils.showLoaderDialog(context,text: "Creating folder.....");
                                (bool,String) isFolderCreated =  await appController.createFolder(appController.folderTextEditingController.text.trim());
                                if(isFolderCreated.$1)
                                {
                                  appController.folderTextEditingController.clear();
                                  await appController.getFolderList();
                                  appController.showToast("Folder Created Successfully");
                                }
                                else
                                {
                                  appController.showToast("There is error while creating folder");
                                }
                                DialogUtils.stopLoaderDialog();
                              }
                              else
                              {
                                appController.showToast("Folder already exists");
                              }
                            }
                          else
                            {
                              DialogUtils.showLoaderDialog(context,text: "Renaming folder....");
                              bool isUpdated = await appController.renameFolder(appController.folderTextEditingController.text, appController.selectedFolder.value.id!);
                              if(isUpdated)
                              {
                                SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, appController.folderTextEditingController.text);
                                appController.folderTextEditingController.clear();
                                appController.isGoingToRenameFolder.value = false;
                                appController.update(["updateFolderIcons"]);
                                appController.showToast("Folder Renamed Successfully...");
                              }
                              else
                              {
                                appController.showToast("There is error while renaming folder");
                              }
                              await appController.getFolderList();
                              DialogUtils.stopLoaderDialog();

                            }

                        },
                        icon: Obx(()=> appController.isGoingToRenameFolder.value ? Icon(Icons.update) : Icon(Icons.create_new_folder)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Obx(()=>Center(
                  child: Row(
                    children: [
                      /*Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(// Background color
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.black, // Border color
                              width: 2.0,
                            ),
                          ),
                          child: DropdownButton<StreamTapeFolderItem>(
                            value: appController.selectedFolder.value,
                            //iconEnabledColor: AppColors.red,
                            isExpanded: true,
                            onChanged: ( newValue) {
                              appController.selectedFolder.value = newValue!;
                              SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, newValue.name!);
                              SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, newValue.id!);
                            },
                            items:appController.streamTapeFolder!.folders!.map((StreamTapeFolderItem value) {
                              return DropdownMenuItem<StreamTapeFolderItem>(
                                value: value,
                                child: Text("${value.name}"),
                              );
                            }).toList(),
                            //dropdownColor: Colors.black, // Dropdown background color
                            underline: SizedBox(), // Remove default underline
                          ),
                        ),
                      ),*/
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(// Background color
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.black, // Border color
                              width: 2.0,
                            ),
                          ),
                          child: DropDownTextField(
                            initialValue: appController.selectedFolder.value.name,
                            textFieldDecoration: InputDecoration(
                              border: InputBorder.none
                            ),
                            clearOption: false,
                            textFieldFocusNode: textFieldFocusNode,
                            searchFocusNode: searchFocusNode,
                            // searchAutofocus: true,
                            dropDownItemCount: 10,
                            searchShowCursor: false,
                            enableSearch: true,
                            searchKeyboardType: TextInputType.text,
                            dropDownList: appController.streamTapeFolder!.folders!.map((StreamTapeFolderItem value) {
                              return DropDownValueModel(name: value.name!, value: value.id);
                            }).toList(),
                            onChanged: (val) {
                              appController.selectedFolder.value = StreamTapeFolderItem(name:val.name!,id:val.value!)!;
                              SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, val.name!);
                              SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, val.value!);
                            },
                          ),
                        ),
                      ),
                      GetBuilder<AppController>(
                        id:"updateFolderIcons",
                        builder: (_){
                          if(!appController.isGoingToRenameFolder.value)
                            {
                              return IconButton(
                                onPressed: () async {
                                  appController.isGoingToRenameFolder.value = true;
                                  appController.folderTextEditingController.text = appController.selectedFolder.value.name!;
                                  appController.update(["updateFolderIcons"]);
                                },
                                icon: Icon(Icons.drive_file_rename_outline),
                              );
                            }
                          else
                            {
                              return IconButton(
                                onPressed: () async {
                                  appController.isGoingToRenameFolder.value = false;
                                  appController.folderTextEditingController.text = "";
                                  appController.update(["updateFolderIcons"]);
                                },
                                icon: Icon(Icons.cancel),
                              );
                            }
                        },
                      ),
                        Obx(()=> Opacity(
                          opacity: appController.isGoingToRenameFolder.value ? 0.5 : 1,
                          child: IconButton(
                              onPressed: appController.isGoingToRenameFolder.value ? null : () async {
                                ButterflyAlertDialog.show(
                                  context: Get.context!,
                                  title: 'Delete',
                                  subtitle: 'Are sure you want to delete it?',
                                  alertType: AlertType.delete,
                                  onConfirm: () async {
                                    bool isDeleted = await appController.deleteFolder(appController.selectedFolder.value.id!);
                                    DialogUtils.showLoaderDialog(context,text: "Deleting folder....");
                                    if(isDeleted)
                                    {
                                      appController.showToast("Folder Deleted Successfully...");
                                    }
                                    else
                                    {
                                      appController.showToast("There is error while deleting folder");
                                    }
                                    await appController.getFolderList(isDeleted: true);
                                    DialogUtils.stopLoaderDialog();
                                  },
                                );
                              },
                              icon: Icon(Icons.delete_forever),
                            ),
                        ),
                        )

                    ],
                  ),
                ),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(// Background color
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2.0,
                    ),
                  ),
                  height: 150, //     <-- TextField expands to this height.
                  child: TextField(
                    controller: appController.urlTextEditingController,
                    maxLines: null, // Set this
                    expands: true, // and this
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(border: InputBorder.none,),
                    onChanged: (value){
                      // Move cursor to next line when url is pasted;
                      if(value.length - previousTextFieldTxt!.length > 1)
                        {
                          appController.urlTextEditingController.text = value + "\n";
                          previousTextFieldTxt = value + "\n";
                          return;
                        }
                      previousTextFieldTxt = value;
                    },
                  ),
                ),
                SizedBox(height: 10,),
                GetBuilder<AppController>(
                  id: "updateDownloadingList",
                  builder: (_)
                  {
                    return Column(

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Total Downloading Links :" + appController.downloadingList.length.toString()),
                              SizedBox(width: 10,),
                              Obx(()=>appController.isDownloadStatusUpdating.value ? Center(child: SizedBox(height: 36,width: 36, child: CircularProgressIndicator()),)  :IconButton(
                                onPressed: () async {
                                    if (!appController.isConcurrentProcessing.value) {
                                      await appController.getDownloadingVideoStatus();
                                    } else {
                                      await appController.getConcurrentDownloadingVideoStatus();
                                    }
                                  }, icon: Icon(Icons.refresh),iconSize: 36,))
                        ],),

                        Container(
                          padding: EdgeInsets.all(12),
                          //height: 300,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              controller: appController.scrollController,
                              itemCount: appController.downloadingList.length,
                              itemBuilder: (context,index){
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Text((index+1).toString(),style:TextStyle(fontSize: 15,color: getTextColor(appController.downloadingList[index]!.status!) )),
                                      SizedBox(width: 5,),
                                      GetBuilder<AppController>(
                                        id : "updateVideoThumbnail",
                                        builder: (_) {
                                          return InkWell(
                                            onTap: () async {
                                              await VideoPlayerDialog.showLoaderDialog(Get.context!, appController.downloadingList[index].url!);
                                            },
                                            child: SizedBox(
                                              height: 150,
                                              width: 100,
                                              child: appController.downloadingList[index]!.imageBytes == null ? Text("No Image Found") : Image.memory(appController.downloadingList[index]!.imageBytes!,)
                                            ),
                                          );
                                        },

                                      ),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(appController.downloadingList[index]!.url!,style: TextStyle(fontSize: 10,color: getTextColor(appController.downloadingList[index]!.status!) ),),
                                      )),
                                      Obx( ()=> !appController.downloadingList[index].isThumbnailUpdating!.value ? IconButton(onPressed: () async {
                                        appController.downloadingList[index].isThumbnailUpdating!.value = true;
                                          await appController.updateVideoThumbnail(appController.downloadingList[index]);
                                        appController.downloadingList[index].isThumbnailUpdating!.value = false;
                                        }, icon: Icon(Icons.refresh),iconSize: 24,) : SizedBox(width : 24,height:24,child: CircularProgressIndicator(strokeWidth: 2,))
                                      ),
                                      IconButton(onPressed: () async {
                                        await appController.showDeleteRemoteUploadingDialog(appController.downloadingList[index]!.id!);
                                      }, icon: Icon(Icons.delete),iconSize: 24,),
                                      appController.downloadingList[index]!.isUnfollowUser! ? Container(width: 12,height: 12,decoration: BoxDecoration(color:Colors.green,shape: BoxShape.circle),) : SizedBox.shrink(),

                                    ],
                                  ),
                                );
                                // return ListTile(onTap: () async {
                                //   await VideoPlayerDialog.showLoaderDialog(Get.context!, appController.downloadingList[index].url!);
                                // },
                                //  leading: Text((index+1).toString(),style:TextStyle(fontSize: 10,color: getTextColor(appController.downloadingList[index]!.status!) )),
                                //  title: Padding(
                                //  padding: const EdgeInsets.all(8.0),
                                //  child: Text(appController.downloadingList[index]!.url!,style: TextStyle(fontSize: 10,color: getTextColor(appController.downloadingList[index]!.status!) ),),
                                // ));
                              }),
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ))
        ),
      ),
      floatingActionButton: Obx(()=> Opacity(
        opacity: appController.isUploading.value ? 0.5 : 1,
        child: FloatingActionButton(
            onPressed: !appController.isUploading.value ? () async  {
                FocusManager.instance.primaryFocus?.unfocus();
               if(appController.isConcurrentProcessing.value)
                 {
                   await appController.concurrentStartUploading(appController.urlTextEditingController.text);
                 }
               else
                 {
                   await appController.startUploading(appController.urlTextEditingController.text);
                 }
               await Future.delayed(Duration(seconds: 1));
               //if (!appController.isDownloadStatusUpdating.value) {
               await appController.downloadingCompleter.future;
               if (!appController.isConcurrentProcessing.value) {
                 await appController.getDownloadingVideoStatus(isSync: true);
               } else {
                 await appController.getConcurrentDownloadingVideoStatus(isSync: true);
               }
               //}
               appController.urlTextEditingController.clear();
               previousTextFieldTxt = "";
            } : null,
            tooltip: 'Upload',
            child: !appController.isUploading.value ? const Icon(Icons.upload) : CircularProgressIndicator(),
          ),
      ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
