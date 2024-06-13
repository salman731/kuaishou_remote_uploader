import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kuaishou_remote_uploader/controllers/app_controller.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder.dart';
import 'package:kuaishou_remote_uploader/models/streamtape_folder_item.dart';
import 'package:kuaishou_remote_uploader/utils/shared_prefs_utils.dart';
import 'package:kuaishou_remote_uploader/widgets/custom_button.dart';
import 'package:sizer/sizer.dart';

void main() {
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


  @override
  void initState() {

    appController.loginToStreamTape();
  }

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
               GetBuilder<AppController>(
                 id: "updateDownloadingList",
                 builder: (_)
                 {
                   return Column(
                     children: [
                       Text("Total Downloading Links :" + appController.downloadingList.length.toString()),

                       Container(
                         padding: EdgeInsets.all(12),
                         height: 300,
                         child: ListView.builder(
                             shrinkWrap: true,
                             itemCount: appController.downloadingList.length,
                             itemBuilder: (context,index){
                               return Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Text(appController.downloadingList[index],style: TextStyle(fontSize: 10),),
                               );
                             }),
                       )
                     ],
                   );
                 },
               ),

                Obx(()=>Center(
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
                  height: 200, //     <-- TextField expands to this height.
                  child: TextField(
                    controller: appController.urlTextEditingController,
                    maxLines: null, // Set this
                    expands: true, // and this
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ],
            ),
          ))
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async  {
           await appController.startUploading(appController.urlTextEditingController.text);
           await Future.delayed(Duration(seconds: 3));
           if (!appController.isDownloadStatusUpdating) {
             await appController.getDownloadingVideoStatus(isUpdateList: true);
           }
        },
        tooltip: 'Upload',
        child: const Icon(Icons.upload),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
