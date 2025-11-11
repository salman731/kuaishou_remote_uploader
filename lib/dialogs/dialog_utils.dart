
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/main.dart';
import 'package:kuaishou_remote_uploader/models/user_kuaishou.dart';
import 'package:flutter/services.dart';
import 'package:kuaishou_remote_uploader/utils/app_strings.dart';
import 'package:kuaishou_remote_uploader/utils/video_capture_utils.dart';
import 'package:path/path.dart' as p;

class DialogUtils
{
  static bool? isLoaderShowing = false;

  static stopLoaderDialog()
  {
    if(isLoaderShowing!)
      {
        Get.back();
        isLoaderShowing = false;
      }
  }

  static showLoaderDialog(BuildContext context,{String? title,RxString? text}) async{

    text ??= 'Loading......'.obs;
    if (!isLoaderShowing!) {
      isLoaderShowing = true;
      AlertDialog alert=AlertDialog(
        title: title != null ? Text(title!) : null ,
        content: new Row(
          children: [
            CircularProgressIndicator(),
            Container(margin: EdgeInsets.only(left: 7),child:Obx(()=> Text(text!.value,))),
          ],),
      );
      await showDialog(barrierDismissible: false,
        context:context,
        builder:(BuildContext context){
          return alert;
        },
      );
      isLoaderShowing = false;
    }
  }

  static showUserListDialog(BuildContext context) async {

      AppController appController = Get.find<AppController>();
      List<SocialUser> list = appController.getAllUserList();
      bool isNeedToStartService = list.length ==0;
      RxString currentAddedUser = "".obs;
      await showDialog(barrierDismissible: false,
        context:context,
        builder:(BuildContext context){
          return AlertDialog(
            title: Text("Add User"),

            content: SingleChildScrollView(
              child: new Column(
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(8.0),
                  //   decoration: BoxDecoration(// Background color
                  //     borderRadius: BorderRadius.circular(5.0),
                  //     border: Border.all(
                  //       color: Colors.black, // Border color
                  //       width: 2.0,
                  //     ),
                  //   ), //     <-- TextField expands to this height.
                  //   child: TextField(
                  //     controller: appController.usernameTextEditingController,
                  //     decoration: InputDecoration(
                  //       hintText: "Enter Url e.g (http://v.kuaishou.com/xhjfjahf)",
                  //       border: InputBorder.none,
                  //       suffixIcon: IconButton(
                  //         onPressed: () async {
                  //           showFollowUnfollowUserDialog(context,onFollow: () async {
                  //             String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                  //             await appController.deleteUserByValue(username);
                  //             list = appController.getAllUserList();
                  //             currentAddedUser.value = username;
                  //             appController.usernameTextEditingController.clear();
                  //             appController.update(["updateUserList"]);
                  //           },onUnfollow: () async {
                  //             Uri uri = Uri.parse(appController.usernameTextEditingController.text);
                  //             await appController.deleteUserByValue(uri.path + "<||>UNFOLLOW");
                  //             list = appController.getAllUserList();
                  //             currentAddedUser.value = uri.path;
                  //             appController.usernameTextEditingController.clear();
                  //             appController.update(["updateUserList"]);
                  //           });
                  //
                  //         },
                  //         icon: Icon(Icons.add),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 5,),
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
                      controller: appController.usernameTextEditingController,
                      decoration: InputDecoration(
                        hintText: "Enter Url e.g (http://v.kuaishou.com/xhjfjahf)",
                        border: InputBorder.none,
                        suffixIcon: SizedBox(
                          width: 100,
                          child: Row(children: [
                            IconButton(
                              onPressed: () async {
                                showFollowUnfollowUserDialog(context,onFollow: () async {
                                  appController.showDeleteDialog(() async {
                                    showLoaderDialog(context,text: "Deleting....".obs);
                                    String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                    await appController.deleteUserByValue(username);
                                    list = appController.getAllUserList();
                                    currentAddedUser.value = username;
                                    appController.usernameTextEditingController.clear();
                                    appController.update(["updateUserList"]);
                                    await appController.exportUsers(isSilent: true,isGist: true);
                                    stopLoaderDialog();
                                  });
                                },onUnfollow: () async {
                                  appController.showDeleteDialog(() async {
                                    showLoaderDialog(context,text: "Deleting....".obs);
                                    String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                    await appController.deleteUserName(username);
                                    list = appController.getAllUserList();
                                    currentAddedUser.value = username;
                                    appController.usernameTextEditingController.clear();
                                    appController.update(["updateUserList"]);
                                    await appController.exportUsers(isSilent: true,isGist: true);
                                    stopLoaderDialog();
                                  });
                                },onTiktok: () async {
                                  showLoaderDialog(context,text: "Deleting....".obs);
                                  await appController.deleteUserByValue(appController.usernameTextEditingController.text + "<||>TIKTOK");
                                  list = appController.getAllUserList();
                                  currentAddedUser.value = appController.usernameTextEditingController.text;
                                  appController.usernameTextEditingController.clear();
                                  appController.update(["updateUserList"]);
                                  await appController.exportUsers(isSilent: true,isGist: true);
                                  stopLoaderDialog();
                                });

                              },
                              icon: Icon(Icons.delete),
                            ),
                            SizedBox(width: 2,),
                            IconButton(
                              onPressed: () async {
                                showFollowUnfollowUserDialog(context,onFollow: () async {
                                  showLoaderDialog(context,text: "Adding....".obs);
                                  String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                  await appController.addUsername(username);
                                  list = appController.getAllUserList();
                                  currentAddedUser.value = username;
                                  appController.usernameTextEditingController.clear();
                                  appController.update(["updateUserList"]);
                                  await appController.exportUsers(isSilent: true,isGist: true);
                                  if(isNeedToStartService)
                                  {
                                    await appController.restartBackgroundService(isToEnableSlider: false);
                                  }

                                  stopLoaderDialog();
                                },onUnfollow: () async {
                                  showLoaderDialog(context,text: "Adding....".obs);
                                  Uri uri = Uri.parse(appController.usernameTextEditingController.text);
                                  String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                  await appController.addUsername(uri.path + "<||>UNFOLLOW",unfollowUserName: username);
                                  list = appController.getAllUserList();
                                  currentAddedUser.value = username;
                                  appController.usernameTextEditingController.clear();
                                  appController.update(["updateUserList"]);
                                  await appController.exportUsers(isSilent: true,isGist: true);
                                  if(isNeedToStartService)
                                  {
                                    await appController.initiateUnfollowUploadingProcess();
                                  }
                                  stopLoaderDialog();
                                },onTiktok: () async {
                                  showLoaderDialog(context,text: "Adding....".obs);
                                  await appController.addUsername(appController.usernameTextEditingController.text + "<||>TIKTOK");
                                  list = appController.getAllUserList();
                                  currentAddedUser.value = appController.usernameTextEditingController.text;
                                  appController.usernameTextEditingController.clear();
                                  appController.update(["updateUserList"]);
                                  await appController.exportUsers(isSilent: true,isGist: true);
                                  stopLoaderDialog();
                                });
                              },
                              icon: Icon(Icons.add),
                            )
                          ],),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Obx(()=> Text("Current Added User :" + currentAddedUser.value)),
                  SizedBox(height: 5,),
                  GetBuilder<AppController>(
                    id: "updateUserList",
                      builder: (_)
                  {
                    List<SocialUser> list = appController.getAllUserList();
                    return Text("Total Users : " + list.length.toString());
                  }),
                  SizedBox(height: 5,),
                  GetBuilder<AppController>(
                    id: "updateUserList",
                    builder: (_) {
                      return SizedBox(
                        height: 500,
                        width: 300,
                        child: ListView.builder(
                            shrinkWrap: true,
                            //physics: NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(child: Text((index + 1).toString(),
                                        style: TextStyle(fontSize: 15))),
                                    Expanded(child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(list[index]!.value!,
                                        style: TextStyle(fontSize: 10,),),
                                    )),
                                    IconButton(onPressed: () async {
                                      appController.showDeleteDialog(() async {
                                        await appController.deleteUserName(list[index]!.id!);
                                        list = appController.getAllUserList();
                                        appController.update(["updateUserList"]);
                                      });
                                    }, icon: Icon(Icons.delete), iconSize: 24,),
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
                      );
                    },
                  ),
                ],),
            ),
          );;
        },
      );

  }

  static void showFollowUnfollowUserDialog(BuildContext context,{Function? onUnfollow, Function? onFollow,Function? onTiktok}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Follow or Unfollow'),
          content: Text('Select type of user....'),
          actions: [
            TextButton(
              onPressed: () {
                // Handle Unfollow action
                Navigator.of(context).pop();
                onUnfollow!();
                 // Close the dialog
              },
              child: Text('Unfollow'),
            ),
            TextButton(
              onPressed: () {
                // Handle Follow action
                Navigator.of(context).pop();
                onFollow!();
                //Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Follow'),
            ),
            TextButton(
              onPressed: () {
                // Handle Follow action
                Navigator.of(context).pop();
                onTiktok!();
                //Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Tiktok User'),
            )
          ],
        );
      },
    );
  }

  static void showCustomCookieDialog({
    required BuildContext context,
    required void Function(String) onSave,
  }) {
    final TextEditingController _textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Cookie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Custom Unfollow Users Cookie',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final input = _textController.text.trim();
                onSave(input); // Call the callback with the entered text
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

 static void showCopyListDialog(BuildContext context, List<String> items) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Select an Item'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("https://live.kuaishou.com/u/${items[index]}"),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: "https://live.kuaishou.com/u/${items[index]}"));
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied "${items[index]}" to clipboard')));
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }


  static void showThumbnailAlertDialog (BuildContext context,String url) async
  {
    AppController appController = Get.find<AppController>();
    VideoCaptureUtils videoCaptureUtils = VideoCaptureUtils();
   // appController.listThumbnails = [];
    // appController.fetchThumbnails(url);
    //appController.listThumbnails =  await VideoCaptureUtils().bulkCaptureImageList("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Thumbnails'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child:StreamBuilder<List<(Uint8List,String)>>(
              stream: videoCaptureUtils.bulkCaptureImageList(url),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final images = snapshot.data!;


                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return /*Column(
                      children: [*/
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.memory(images[index].$1, width: 120,),
                        );
                       // Text("(${index}) Is Side Pose Found : ${videoCaptureUtils.sidePoseMap[p.basenameWithoutExtension(images[index].$2)]}"),
                        //Text("File Name : ${p.basenameWithoutExtension(images[index].$2)}")
                    //   ],
                    // );
                  },
                );
              },
            )

            /*},)*/,
          ),
        );
      },
    );

    await videoCaptureUtils.dispose();

  }
}

