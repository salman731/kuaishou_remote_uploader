import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/models/download_item.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';

class StreamtapeDownloadScreen extends StatelessWidget {
  StreamtapeDownloadScreen({super.key});

  AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Streamtape Downloader"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Obx(()=>Center(
              //   child: Container(
              //     padding: EdgeInsets.all(8.0),
              //     decoration: BoxDecoration(// Background color
              //       borderRadius: BorderRadius.circular(5.0),
              //       border: Border.all(
              //         color: Colors.black, // Border color
              //         width: 2.0,
              //       ),
              //     ),
              //     child: DropdownButton<StreamTapeFolderItem>(
              //       value: appController.selectedDownloadFolder.value,
              //       //iconEnabledColor: AppColors.red,
              //       isExpanded: true,
              //       onChanged: ( newValue) {
              //         appController.selectedDownloadFolder.value = newValue!;
              //       },
              //       items:appController.streamTapeFolder!.folders!.map((StreamTapeFolderItem value) {
              //         return DropdownMenuItem<StreamTapeFolderItem>(
              //           value: value,
              //           child: Text("${value.name}"),
              //         );
              //       }).toList(),
              //       //dropdownColor: Colors.black, // Dropdown background color
              //       underline: SizedBox(), // Remove default underline
              //     ),
              //   ),
              // ),
              // ),
              Obx(()=> Row(
                children: [
                  Expanded(
                    child: Container(
                        //height: 100,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(// Background color
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.black, // Border color
                            width: 2.0,
                          ),
                        ),
                        child: DropDownTextField(
                          initialValue: appController.selectedDownloadFolder.value.name,
                          textFieldDecoration: InputDecoration(
                              border: InputBorder.none
                          ),
                          clearOption: false,
                          // searchAutofocus: true,
                          dropDownItemCount: 10,
                          searchShowCursor: false,
                          enableSearch: true,
                          searchKeyboardType: TextInputType.text,
                          dropDownList: appController.streamTapeFolder!.folders!.map((StreamTapeFolderItem value) {
                            return DropDownValueModel(name: value.name!, value: value.id);
                          }).toList(),
                          onChanged: (val) {
                             appController.selectedDownloadFolder.value = StreamTapeFolderItem(name:val.name!,id:val.value!)!;
                            // SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER, val.name!);
                            // SharedPrefsUtil.setString(SharedPrefsUtil.KEY_SELECTED_FOLDER_ID, val.value!);
                          },
                        ),
                      ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await appController.getDownloadLinks(appController.selectedDownloadFolder.value.id!);
                    },
                    icon: Icon(Icons.download),
                  )
                ],
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
                ), //     <-- TextField expands to this height.
                child: TextField(
                  controller: appController.searchFileTextEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      onPressed: () async {
                        appController.searchFileTextEditingController.clear();
                        appController.isSearching = false;
                        appController.update(["updateStreamtapeDownloadingList"]);
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ),
                  onChanged: (value)
                  {
                     appController.isSearching = !value.isEmpty;

                    appController.filterdownloadLinksList = appController.downloadLinksList
                        .where((item) {
                          if(value.length == 1)
                            {
                              return item.name!.toLowerCase().startsWith(value);
                            }
                          else
                            {
                              return item.name!.toLowerCase().contains(value);
                            }

                    })
                        .toList();
                    appController.update(["updateStreamtapeDownloadingList"]);
                  },
                ),
              ),
              GetBuilder<AppController>(
                id: "updateStreamtapeDownloadingList",
                builder: (_)
                {
                  return Column(

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Total Streamtape Links :" + appController.currentDownloadList.length.toString()),
                          if(appController.currentDownloadList.length > 0)...[
                            SizedBox(width: 10,),
                            IconButton(
                              onPressed: () async {
                                appController.selectOrUnselectAllItems();
                              }, icon: Icon(Icons.select_all),iconSize: 36,),
                            SizedBox(width: 10,),
                            IconButton(
                              onPressed: () async {
                                await appController.loadAllItemsLinks();

                              }, icon: Icon(Icons.download),iconSize: 36,)
                          ]
                        ],),

                      Container(
                        padding: EdgeInsets.all(5),
                        //height: 300,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: appController.currentDownloadList.length,
                            itemBuilder: (context,index){
                              return GestureDetector(
                                onLongPress: (){
                                  bool value = appController.currentDownloadList.any((item) => item.isSelected!.value == true);
                                  if (!value && appController.isStreamTapeDownloadUrlLoaded(appController.currentDownloadList[index]) ) {
                                    appController.currentDownloadList[index]!.isSelected!.value = true;
                                  }
                                  else if(!value &&!appController.isStreamTapeDownloadUrlLoaded(appController.currentDownloadList[index]))
                                    {
                                      appController.showToast("Load stream tape download url first......");
                                    }
                                  appController.update(["updateCopyFloatingActionButtonVisibility"]);
                                },
                                onTap: (){
                                  bool value = appController.currentDownloadList.any((item) => item.isSelected!.value == true);
                                  if (value && appController.isStreamTapeDownloadUrlLoaded(appController.currentDownloadList[index])) {
                                    appController.currentDownloadList[index]!.isSelected!.value = !appController.currentDownloadList[index]!.isSelected!.value;
                                  }
                                  else if(!appController.isStreamTapeDownloadUrlLoaded(appController.currentDownloadList[index]))
                                  {
                                    appController.showToast("Load stream tape download url first......");
                                  }
                                  appController.update(["updateCopyFloatingActionButtonVisibility"]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Obx(()=>appController.currentDownloadList[index]!.isSelected!.value ? Icon(Icons.check_circle_rounded) : SizedBox()),
                                      SizedBox(width: 5,),
                                      Text((index+1).toString(),style:TextStyle(fontSize: 15)),
                                      SizedBox(width: 5,),
                                      GetBuilder<AppController>(
                                        id : "updateSearchVideoThumbnail",
                                        builder: (_) {
                                          return InkWell(
                                            onTap: () async {

                                            },
                                            child: SizedBox(
                                                height: 80,
                                                width: 80,
                                                child: appController.currentDownloadList[index]!.imageUrl!.isEmpty ? Text("No Image Found") : Image.network(appController.currentDownloadList[index]!.imageUrl!)
                                            ),
                                          );
                                        },

                                      ),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: ListTile(
                                          title: Text(appController.currentDownloadList[index]!.name!,style: TextStyle(fontSize: 10 ),),
                                          subtitle: Text(appController.currentDownloadList[index]!.downloadUrl!,style: TextStyle(fontSize: 7 ),),
                                          contentPadding: EdgeInsets.all(2),
                                        ),
                                      )),
                                      Obx(()=> !appController.currentDownloadList[index]!.isLoading!.value ?  SizedBox(
                                        height: 28,
                                        width: 28,
                                        child: IconButton(onPressed: () async {
                                              await appController.fetchStreamTapeImageAndDownloadUrl(appController.currentDownloadList[index]);
                                              appController.update(["updateCopyFloatingActionButtonVisibility"]);
                                          }, icon: appController.isStreamTapeDownloadUrlLoaded(appController.currentDownloadList[index]) ? Icon(Icons.refresh) :Icon(Icons.download),iconSize: 20,),
                                      ) : SizedBox(width : 24,height:24,child: CircularProgressIndicator(strokeWidth: 2,)),
                                      ),
                                      SizedBox(
                                        height: 28,
                                        width: 28,
                                        child: IconButton(onPressed: () async {
                                          if(appController.isStreamTapeDownloadUrlLoaded(appController.currentDownloadList[index]))
                                            {
                                              await Clipboard.setData(ClipboardData(text: appController.currentDownloadList[index]!.downloadUrl!));
                                              appController.showToast("Copied.....");
                                            }
                                          else
                                            {
                                              appController.showToast("Unable to get link.....");
                                            }

                                        }, icon: Icon(Icons.copy),iconSize: 20),
                                      ),
                                    ],
                                  ),
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
              /*Obx(()=> Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: Text(appController.downloadLinks.value)),
                    InkWell(onTap:() async {
                    },child: Icon(Icons.download,size: 32,))
                  ],
                ),
              )),*/
            ],
          ),
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GetBuilder<AppController>(
              id: "updateCopyFloatingActionButtonVisibility",
              builder:(_){
                bool value = appController.currentDownloadList!.any((item) => item.isSelected!.value == true);
                if(value)
                {
                  return getCopyFloatingActionButtion();
                }
                else
                {
                  return SizedBox.shrink();
                }
              } ),
          // SizedBox(height: 10,),
          // FloatingActionButton(
          //   onPressed: () async  {
          //
          //   },
          //   tooltip: 'Upload',
          //   child: const Icon(Icons.download),
          // )
        ],
      ),
    );
  }

  getCopyFloatingActionButtion()
  {
    return FloatingActionButton(
      onPressed: () async  {
        StringBuffer linksBuffer = StringBuffer("");
        for(DownloadItem downloadItem in appController.currentDownloadList)
        {
          if(downloadItem.isSelected!.value)
          {
            linksBuffer.write(downloadItem.downloadUrl! + "\n\n");
          }
        }
        await Clipboard.setData(ClipboardData(text: linksBuffer.toString()));
        appController.showToast("Copied.....");
      },
      tooltip: 'Copy Selected Items',
      child: const Icon(Icons.copy),
    );
  }
}
