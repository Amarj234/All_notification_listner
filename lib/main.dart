import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_all_message/screen_share.dart';
import 'package:get_all_message/video_call_page.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'background_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("amarj234 ${app.options.appId}");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<ServiceNotificationEvent>? _subscription;
  List<ServiceNotificationEvent> events = [];
  List<ServiceNotificationEvent> amar = [];

  List<TextEditingController> mycon = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
   // getpermotion();
  }

  getpermotion() async {
    int j = 1;
    final bool res2 = await NotificationListenerService.isPermissionGranted();
    print(res2);
    if (res2 == false) {
      for (int i = 0; i < j; i++) {
        bool? res = await NotificationListenerService.requestPermission();
        final bool res1 =
        await NotificationListenerService.isPermissionGranted();
        if (res1 == false) {
          j++;
        }
      }
      // print(res);
    }

    initializeService();
  }

  int ist = 0;


  sendata() async {
    for (int i = 0; i < amar.length; i++) {}
    ;
  }

  Future<bool> sendReply(String message, int ids) async {
    try {
      return await methodeChannel.invokeMethod<bool>("sendReply", {
        'message': message,
        'notificationId': ids,
      }) ??
          false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoCallPage(),
      // home: Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Plugin example app'),
      //   ),
      //   body: Center(
      //     child: Column(
      //       children: [
      //         SingleChildScrollView(
      //           scrollDirection: Axis.horizontal,
      //           child: Row(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             children: [
      //               TextButton(
      //                 onPressed: () async {
      //                   final res = await NotificationListenerService
      //                       .requestPermission();
      //                   log("Is enabled: $res");
      //                 },
      //                 child: const Text("Request Permission"),
      //               ),
      //               const SizedBox(height: 20.0),
      //               TextButton(
      //                 onPressed: () async {
      //                   final bool res = await NotificationListenerService
      //                       .isPermissionGranted();
      //                   log("Is enabled: $res");
      //                 },
      //                 child: const Text("Check Permission"),
      //               ),
      //               const SizedBox(height: 20.0),
      //               TextButton(
      //                 onPressed: () {
      //                   // _subscription = NotificationListenerService
      //                   //     .notificationsStream
      //                   //     .listen((event) {
      //                   //   log("$event");
      //                   //   events.forEach((element) {
      //                   //     var textEditingController =
      //                   //         TextEditingController(text: element.title);
      //                   //     mycon.add(textEditingController);
      //                   //   });
      //                   //
      //                   //   setState(() {
      //                   //     events.add(event);
      //                   //   });
      //                   // });
      //                 },
      //                 child: const Text("Start Stream"),
      //               ),
      //               const SizedBox(height: 20.0),
      //               TextButton(
      //                 onPressed: () {
      //                   _subscription?.cancel();
      //                 },
      //                 child: const Text("Stop Stream"),
      //               ),
      //             ],
      //           ),
      //         ),
      //         Expanded(
      //           child: ListView.builder(
      //             shrinkWrap: true,
      //             itemCount: events.length,
      //             itemBuilder: (_, index) {
      //               return Padding(
      //                 padding: const EdgeInsets.only(bottom: 8.0),
      //                 child: Column(
      //                   children: [
      //                     TextFormField(
      //                       controller: mycon[index],
      //                       decoration: InputDecoration(
      //                           suffixIcon: IconButton(
      //                             onPressed: () async {
      //                               try {
      //                                 events[index].id!;
      //                                 await sendReply(mycon[index].text.toString(),
      //                                     events[index].id!);
      //                               } catch (e) {
      //                                 log(e.toString());
      //                               }
      //                             },
      //                             icon: Icon(Icons.send),
      //                           )),
      //                     ),
      //                     ListTile(
      //                       trailing: events[index].hasRemoved!
      //                           ? const Text(
      //                         "Removed",
      //                         style: TextStyle(color: Colors.red),
      //                       )
      //                           : const SizedBox.shrink(),
      //                       leading: events[index].appIcon == null
      //                           ? const SizedBox.shrink()
      //                           : Image.memory(
      //                         events[index].appIcon!,
      //                         width: 35.0,
      //                         height: 35.0,
      //                       ),
      //                       title: Text(events[index].title ?? "No title"),
      //                       subtitle: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Text(
      //                             events[index].content ?? "no content",
      //                             style: const TextStyle(
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                           const SizedBox(height: 8.0),
      //                           events[index].canReply!
      //                               ? const Text(
      //                             "Replied with: This is an auto reply",
      //                             style: TextStyle(color: Colors.purple),
      //                           )
      //                               : const SizedBox.shrink(),
      //                           events[index].haveExtraPicture!
      //                               ? Image.memory(
      //                             events[index].extrasPicture!,
      //                           )
      //                               : const SizedBox.shrink(),
      //                         ],
      //                       ),
      //                       isThreeLine: true,
      //                     ),
      //                   ],
      //                 ),
      //               );
      //             },
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}