import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
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
        child: Column(
          children: [
            Obx(()=>Center(
              child: Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(// Background color
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.black, // Border color
                    width: 2.0,
                  ),
                ),
                child: DropdownButton<StreamTapeFolderItem>(
                  value: appController.selectedDownloadFolder.value,
                  //iconEnabledColor: AppColors.red,
                  isExpanded: true,
                  onChanged: ( newValue) {
                    appController.selectedDownloadFolder.value = newValue!;
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
                        Text("Total Streamtape Links :" + appController.downloadLinksList.length.toString()),
                        SizedBox(width: 10,),
                        IconButton(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: appController.downloadLinks.value));
                            appController.showToast("Copied.....");
                          }, icon: Icon(Icons.copy),iconSize: 36,)
                      ],),

                    Container(
                      padding: EdgeInsets.all(12),
                      //height: 300,
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: appController.downloadLinksList.length,
                          itemBuilder: (context,index){
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Text((index+1).toString(),style:TextStyle(fontSize: 15)),
                                  SizedBox(width: 5,),
                                  Expanded(child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      title: Text(appController.downloadLinksList[index]!.name!,style: TextStyle(fontSize: 10 ),),
                                      subtitle: Text(appController.downloadLinksList[index]!.url!,style: TextStyle(fontSize: 7 ),),
                                    ),
                                  )),
                                  IconButton(onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: appController.downloadLinksList[index].url!));
                                    appController.showToast("Copied.....");
                                  }, icon: Icon(Icons.copy),iconSize: 24,),
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


      floatingActionButton: FloatingActionButton(
        onPressed: () async  {
          await appController.getDownloadLinks(appController.selectedDownloadFolder.value.id!);
        },
        tooltip: 'Upload',
        child: const Icon(Icons.download),
      ),
    );
  }
}
