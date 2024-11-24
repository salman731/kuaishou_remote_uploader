import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:butterfly_dialog/butterfly_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/dialogs/dialog_utils.dart';
import 'package:kuaishou_remote_uploader/dialogs/video_player_dialog.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_download_status.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/models/user_kuaishou.dart';
import 'package:kuaishou_remote_uploader/streamtape_download_screen.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:kuaishou_remote_uploader/utils/video_capture_utils.dart';
import 'package:kuaishou_remote_uploader/utils/web_utils.dart';
import 'package:kuaishou_remote_uploader/widgets/custom_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

const notificationChannelId = 'my_foreground';

const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
        print("This is background service" + DateTime.now().toString());

        AppController appController = Get.put(AppController());
        final appDocumentDirectory = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDirectory.path);
        appController.usernameListIdBox = await Hive.openBox("usernameListIdBox");
        List<UserKuaishou> list = appController.getAllUserList();
        List<StreamtapeDownloadStatus> streamTapeDownloadStatusList = await appController.getRemoteDownloadingStatus_background();
        late String url = "";
        for (UserKuaishou userKuaishou in list)
          {
             url = await appController.getStreamUrlForBackgroundUpload(userKuaishou.value!);
             FlutterLocalNotificationsPlugin().show(
               notificationId,
               'Background Uploading Service Running....',
               "Uploading in Progress : ${userKuaishou.value}",
               const NotificationDetails(
                 android: AndroidNotificationDetails(
                   notificationChannelId,
                   'MY FOREGROUND SERVICE',
                   icon: 'ic_bg_service_small',
                   ongoing: true,
                 ),
               ),
             );
             await appController.startUploading_background(url, streamTapeDownloadStatusList);

          }

    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  //await initializeService();
  //startBackgroundService();
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

  @override
  void initState() {
   /* Future.delayed(Duration(seconds: 5),(){
      FlutterBackgroundService().invoke("setAsBackground");
    });*/
    //initAutoStart();
    appController.loginToStreamTape();
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
                  //await reauthenticate();
                  DialogUtils.showUserListDialog(context);
                case "streamtape_downloader":
                  Get.to(StreamtapeDownloadScreen());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(value: "refresh", child: Text('Refresh')),
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
                                bool isFolderCreated =  await appController.createFolder(appController.folderTextEditingController.text.trim());
                                if(isFolderCreated)
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
                                        await appController.deleteRemoteUploadVideo(appController.downloadingList[index]!.id!);
                                      }, icon: Icon(Icons.delete),iconSize: 24,),
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
