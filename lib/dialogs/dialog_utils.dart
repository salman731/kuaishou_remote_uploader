
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/main.dart';
import 'package:kuaishou_remote_uploader/models/user_kuaishou.dart';

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

  static showLoaderDialog(BuildContext context,{String text = "Loading..."}) async{

    if (!isLoaderShowing!) {
      isLoaderShowing = true;
      AlertDialog alert=AlertDialog(
        content: new Row(
          children: [
            CircularProgressIndicator(),
            Container(margin: EdgeInsets.only(left: 7),child:Text(text,)),
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
      List<UserKuaishou> list = appController.getAllUserList();
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
                                    showLoaderDialog(context,text: "Deleting....");
                                    String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                    await appController.deleteUserByValue(username);
                                    list = appController.getAllUserList();
                                    currentAddedUser.value = username;
                                    appController.usernameTextEditingController.clear();
                                    appController.update(["updateUserList"]);
                                    await appController.saveListToFile(isSilent: true);
                                    stopLoaderDialog();
                                  });
                                },onUnfollow: () async {
                                  appController.showDeleteDialog(() async {
                                    showLoaderDialog(context,text: "Deleting....");
                                    String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                    await appController.deleteUserName(username);
                                    list = appController.getAllUserList();
                                    currentAddedUser.value = username;
                                    appController.usernameTextEditingController.clear();
                                    appController.update(["updateUserList"]);
                                    await appController.saveListToFile(isSilent: true);
                                    stopLoaderDialog();
                                  });
                                });

                              },
                              icon: Icon(Icons.delete),
                            ),
                            SizedBox(width: 2,),
                            IconButton(
                              onPressed: () async {
                                showFollowUnfollowUserDialog(context,onFollow: () async {
                                  showLoaderDialog(context,text: "Adding....");
                                  String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                  await appController.addUsername(username);
                                  list = appController.getAllUserList();
                                  currentAddedUser.value = username;
                                  appController.usernameTextEditingController.clear();
                                  appController.update(["updateUserList"]);
                                  await appController.saveListToFile(isSilent: true);
                                  if(isNeedToStartService)
                                  {
                                    await appController.restartBackgroundService(isToEnableSlider: false);
                                  }

                                  stopLoaderDialog();
                                },onUnfollow: () async {
                                  showLoaderDialog(context,text: "Adding....");
                                  Uri uri = Uri.parse(appController.usernameTextEditingController.text);
                                  String username = await appController.getUsernameFromKuaishouUrl(appController.usernameTextEditingController.text);
                                  await appController.addUsername(uri.path + "<||>UNFOLLOW",unfollowUserName: username);
                                  list = appController.getAllUserList();
                                  currentAddedUser.value = username;
                                  appController.usernameTextEditingController.clear();
                                  appController.update(["updateUserList"]);
                                  await appController.saveListToFile(isSilent: true);
                                  if(isNeedToStartService)
                                  {
                                    await appController.initiateUnfollowUploadingProcess();
                                  }
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

  static void showFollowUnfollowUserDialog(BuildContext context,{Function? onUnfollow, Function? onFollow}) {
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
          ],
        );
      },
    );
  }
}